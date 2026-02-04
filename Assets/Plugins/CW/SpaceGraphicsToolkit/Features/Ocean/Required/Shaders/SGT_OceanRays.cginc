BEGIN_PROPERTIES
	[HideInInspector] _SGT_WrapSize("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_FadeData("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataA("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataB("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Offset("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_FlickerData("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_StretchDirection("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_UnderwaterBrightness("", Float) = 0
	[HideInInspector] _SGT_UnderwaterShadowRange("", Float) = 0
	
	[Header(CLOUDS)]
	[Toggle(_SGT_CLOUDS)] _SGT_Clouds("	Enable", Float) = 0
	[HideInInspector] [NoScaleOffset] _SGT_CloudTex("", 2D) = "black" {}
	[HideInInspector] _SGT_CloudOpacity("", Vector) = (0.0, 0.0, 0.0, 0.0)
	[HideInInspector] _SGT_CloudWarp("", Float) = 0
END_PROPERTIES

BEGIN_CBUFFER
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
END_DEFINES

float4   _SGT_WrapSize; // Auto
float4   _SGT_FadeData; // Auto
float4   _SGT_DataA; // Auto
float4   _SGT_DataB; // Auto
float4   _SGT_FlickerData; // Auto
float4   _SGT_StretchDirection; // Auto
float    _SGT_UnderwaterBrightness; // Auto
float    _SGT_UnderwaterShadowRange; // Auto
float4x4 _SGT_WorldToLocal; // Auto

// CLOUDS
sampler2D _SGT_CloudTex;
float4    _SGT_CloudOpacity;
float     _SGT_CloudWarp;
float4x4  _SGT_CloudMatrix;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 p = normalize(mul(_SGT_CloudMatrix, float4(wpos, 1.0f)).xyz);
	float2 w = float2(-p.x, p.y);
	float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));
	
	return saturate(dot(tex2Dbias(_SGT_CloudTex, float4(z * 0.5f + 0.5f, 0, bias)), _SGT_CloudOpacity));
}

float SGT_Hash(float seed)
{
	return frac(sin(dot(float2(seed,seed+1.0), float2(12.9898, 78.233))) * 43758.5453);
}

float SGT_Noise(float position)
{
	float i = floor(position);
	float f = frac(position);
	
	float a = SGT_Hash(i);
	float b = SGT_Hash(i + 1.0);
	
	float blend = f * f * (3.0 - 2.0 * f);
	return lerp(a, b, blend);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam = _WorldSpaceCameraPos;
	float  seed = v.texcoord0.w;
	
	// Infinite wrap
	float3 wcam_snap = wcam + frac((wcam - _SGT_Offset) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	float3 ocam_snap = SSS_WorldToObject(wcam_snap);
	v.position = frac(v.position - ocam_snap * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	// Calculate wrap fade (fades to 0 at wrap boundary)
	float edgeDist = max(abs(v.position.x), max(abs(v.position.y), abs(v.position.z)));
	float wrapFade = smoothstep(0.5, 0.3, edgeDist);
	
	// Scale up
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in world space
	float3 ocam = SSS_WorldToObject(wcam);
	float3 view = normalize(ocam - v.position);
	float3 up   = cross(_SGT_StretchDirection.xyz, view);
	
	v.position += _SGT_StretchDirection.xyz * v.texcoord0.y * _SGT_FadeData.z;
	
	v.position += normalize(up) * v.texcoord0.z * _SGT_FadeData.y;
	
	float flicker = SGT_Noise(seed * 100 + _Time.x * lerp(_SGT_FlickerData.x, _SGT_FlickerData.y, seed));
	
	v.extraV2F0.x = lerp(_SGT_FlickerData.z, _SGT_FlickerData.w, flicker);
	
	v.extraV2F0.x *= length(up); // Fade out parallel rays
	v.extraV2F0.x *= wrapFade;   // Fade out near wrap boundary
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F0.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataA.y;
	float  maxDepth         = _SGT_DataB.z;
	
	float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
	
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
	
	float depth = radius - length(localPos);
	
	finalColor *= saturate(1.0f - cameraDistance * _SGT_FadeData.x);
	
	finalColor *= 1.0f - saturate(depth - maxDepth);
	
	finalColor *= 1.0f - pow(saturate(length(d.texcoord0.xy)), 1.0f + 4.0f * d.texcoord0.w);
	
	finalColor *= _SGT_UnderwaterBrightness;
	
	// Fade with scene depth
	float3 worldEyePos = SSS_GetSceneWorldPosition(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	finalColor *= saturate(distance(worldEyePos, d.worldSpacePosition));
	
	// Fade with ocean surface
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	finalColor *= saturate(sign(surfaceDistance) * (cameraDistance - abs(surfaceDistance)));
	
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}