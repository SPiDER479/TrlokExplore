BEGIN_OPTIONS
END_OPTIONS

BEGIN_PROPERTIES
	[NoScaleOffset] _SGT_Texture("Texture", 2D) = "black" {}
	_SGT_Tiling("Tiling", Float) = 1.0
	_SGT_Brightness("Brightness", Float) = 1.0
	_SGT_ClipDistance("Clip Distance", Range(0.5, 0.999)) = 0.97
	
	[Header(SUN)]
	[Toggle(_SGT_SUN)] _SGT_Sun("	Enable", Float) = 0
	_SGT_SunTintA("	Tint A", Color) = (1,1,1,1)
	_SGT_SunBrightnessA("	Brightness A", Float) = 0.1
	_SGT_SunShapeA("	Shape A", Range(0.5, 0.99)) = 0.8
	_SGT_SunTintB("	Tint B", Color) = (1,1,1,1)
	_SGT_SunBrightnessB("	Brightness B", Float) = 0.1
	_SGT_SunShapeB("	Shape B", Range(0.5, 0.99)) = 0.95
	
	[Header(NOISE)]
	[NoScaleOffset] _SGT_NoiseTexture("	Texture", 3D) = "black" {}
	_SGT_NoiseTiling("	Tiling", Float) = 0.01
	_SGT_NoiseStrength("	Strength", Float) = 1.0
END_PROPERTIES

BEGIN_CBUFFER
	sampler2D _SGT_Texture;
	float     _SGT_Tiling;
	float     _SGT_Brightness;
	float     _SGT_ClipDistance;

	// SUN
	float4 _SGT_SunTintA;
	float  _SGT_SunBrightnessA;
	float  _SGT_SunShapeA;
	float4 _SGT_SunTintB;
	float  _SGT_SunBrightnessB;
	float  _SGT_SunShapeB;

	sampler3D _SGT_NoiseTexture;
	float     _SGT_NoiseTiling;
	float     _SGT_NoiseStrength;
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_SUN_OFF _SGT_SUN
END_DEFINES

float4 _SGT_SunPosition; // Global
float4 _SGT_SunColor; // Global

float2 SGT_Rotate(float2 v, float a)
{
	float s = sin(a); float c = cos(a); return float2(c * v.x - s * v.y, s * v.x + c * v.y);
}

float4 SGT_Sample(sampler2D s, float2 uv, float offset)
{
	float f = frac(offset);
	float i = offset - f;
	float j = i + 1;

	#if _SSS_NO_DERIVATIVES
		return 0;
	#endif
	float2 dx = ddx(uv);
	float2 dy = ddy(uv);

	float4 a = tex2Dgrad(s, SGT_Rotate(uv, i) + sin(i.xx), SGT_Rotate(dx, i), SGT_Rotate(dy, i));
	float4 b = tex2Dgrad(s, SGT_Rotate(uv, j) + sin(j.xx), SGT_Rotate(dx, j), SGT_Rotate(dy, j));

	//return float4(f,0,0,1);
	return lerp(a, b, f);
}

void SSS_Vert(inout SSS_VertexData v)
{
	v.position.x = -v.position.x;
	float3 wpos = SSS_ObjectToWorld(v.position);
	float3 wdir = normalize(wpos - _WorldSpaceCameraPos);
	
	wpos = _WorldSpaceCameraPos + wdir * _ProjectionParams.z * _SGT_ClipDistance;
	
	v.position = SSS_WorldToObject(wpos);
}
 
void SSS_Frag(inout SSS_SurfaceData s, inout SSS_FragmentData d)
{
	float3 wp = normalize(d.localSpaceNormal);
	 
	// Compute blend weights based on normal direction
	float3 blend = abs(wp);
	blend = pow(blend, 4.0); // Sharpen blending
	blend /= (blend.x + blend.y + blend.z);

	float2 uvX = wp.zy * _SGT_Tiling * float2(sign(wp.x), 1.0);
	float2 uvY = wp.xz * _SGT_Tiling * float2(1.0, sign(wp.y));
	float2 uvZ = wp.xy * _SGT_Tiling * float2(sign(wp.z), 1.0);
	
	float offset = tex3Dlod(_SGT_NoiseTexture, float4(wp * _SGT_Tiling * _SGT_NoiseTiling, 0.0)).w * _SGT_NoiseStrength;
	
	// Sample texture from each axis
	float4 colX = SGT_Sample(_SGT_Texture, uvX, offset + 0.0f);
	float4 colY = SGT_Sample(_SGT_Texture, uvY, offset + 4.0f);
	float4 colZ = SGT_Sample(_SGT_Texture, uvZ, offset + 8.0f);

	float4 color = (colX * blend.x + colY * blend.y + colZ * blend.z) * _SGT_Brightness;
	float3 sun   = 0.0;
			
	#if _SGT_SUN
		float2 g = float2(_SGT_SunShapeA, _SGT_SunShapeB);
		float  c = dot(-d.worldSpaceViewDir, normalize(_SGT_SunPosition.xyz - _WorldSpaceCameraPos));
		float2 p = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
				
		sun += _SGT_SunTintA.xyz * _SGT_SunColor.xyz * _SGT_SunColor.w * p.x * _SGT_SunBrightnessA;
		sun += _SGT_SunTintB.xyz * _SGT_SunColor.xyz * _SGT_SunColor.w * p.y * _SGT_SunBrightnessB;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color *= 25000.0;
	#endif
	
	s.Albedo = color.xyz + sun;
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		s.Albedo *= GetCurrentExposureMultiplier();
	#endif
}