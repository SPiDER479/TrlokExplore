BEGIN_PROPERTIES
	[HideInInspector] [NoScaleOffset] _SGT_MainTex("", 2D) = "white" {}
	[HideInInspector] _SGT_Cells("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Roll("", Float) = 0
	[HideInInspector] _SGT_WrapSize("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataA("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_DataB("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_Offset("", Vector) = (0,0,0,0)
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

sampler2D _SGT_MainTex;
float4    _SGT_Cells;
float     _SGT_Roll;
float4    _SGT_WrapSize;
float4    _SGT_DataA;
float4    _SGT_DataB;
float3    _SGT_Offset;
float     _SGT_UnderwaterBrightness;
float     _SGT_UnderwaterShadowRange;
float4x4  _SGT_WorldToLocal;
	
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
	
float2 SGT_Rotate(float2 p, float angle)
{
	float s = sin(angle); float c = cos(angle); return float2(c * p.x - s * p.y, s * p.x + c * p.y);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float3 wcam       = _WorldSpaceCameraPos;
	float  seed       = v.texcoord0.w;
	float  randomCell = (seed * 31) % 1;
	
	wcam += frac((wcam - _SGT_Offset*0) * _SGT_WrapSize.y) * _SGT_WrapSize.x;
	
	float3 cameraO   = SSS_WorldToObject(wcam);
	float3 relativeO = v.position - cameraO;
	
	v.position = frac(v.position - cameraO * _SGT_WrapSize.y + 0.5f) - 0.5f;
	
	v.position *= _SGT_WrapSize.x;
	
	// Drift
	float  angle1    = seed * 6.2831853f;
	float  angle2    = frac(seed * 0.384759f + _Time.x * 0.17543f) * 6.2831853f;
	float3 direction = float3(cos(angle1) * sin(angle2), cos(angle2), sin(angle1) * sin(angle2));
	float  drift     = _SGT_DataB.y;
	v.position += direction * drift;
	
	// Expand in view space
	float  roll    = _SGT_Roll + seed * 3.14159f * 11;
	float3 positionV = SSS_ObjectToView(v.position);
	positionV.xy += SGT_Rotate(v.texcoord0.xy, roll) * _SGT_DataA.y;
	v.position = SSS_ViewToObject(positionV);
	
	// Calc UV
	float cellCount = _SGT_Cells.x * _SGT_Cells.y;
	float cellIndex = min(floor(randomCell * cellCount), cellCount - 1);
	v.extraV2F0.xy = v.texcoord0.xy * 0.5f + 0.5f;
	v.extraV2F0.x  += cellIndex % _SGT_Cells.x;
	v.extraV2F0.y  += floor(cellIndex / _SGT_Cells.y);
	v.extraV2F0.xy /= _SGT_Cells.xy;
	
	v.extraV2F1.x = lerp(_SGT_DataA.z, _SGT_DataA.w, seed);
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 finalColor       = d.extraV2F1.x;
	float  radius           = _SGT_DataB.x;
	float  surfaceSharpness = _SGT_DataA.x;
	float  deepSharpness    = _SGT_DataB.w;
	float  maxDepth         = _SGT_DataB.z;
		
	float camDist = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		
	float3 localPos = mul(_SGT_WorldToLocal, float4(d.worldSpacePosition, 1.0f)).xyz;
		
	float depth = radius - length(localPos);
		
	finalColor *= tex2D(_SGT_MainTex, d.extraV2F0.xy).x;
		
	finalColor *= saturate(1.0f - camDist * _SGT_WrapSize.y * 2.0f);
		
	finalColor *= 1.0f - pow(saturate(1.0f - depth / maxDepth), surfaceSharpness);
		
	finalColor *= 1.0f - pow(saturate(depth / maxDepth), deepSharpness);
		
	finalColor *= _SGT_UnderwaterBrightness;
		
	#if _SGT_CLOUDS
		float shadow2 = SGT_SampleCloudDensity(_WorldSpaceCameraPos - d.worldSpaceViewDir * _SGT_UnderwaterShadowRange, 10.0f);
		finalColor.xyz *= 1.0f - shadow2;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		finalColor.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	o.Albedo = finalColor.xyz;
}