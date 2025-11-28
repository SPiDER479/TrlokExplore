#include "UnityCG.cginc"

#if defined(SHADER_API_D3D11) || defined(SHADER_API_XBOXONE) || defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)
	#define UNITY_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) tex.SampleGrad (sampler##tex,coord,dx,dy)
#else
	#if defined(UNITY_COMPILER_HLSL2GLSL) || defined(SHADER_TARGET_SURFACE_ANALYSIS)
		#define UNITY_SAMPLE_TEX2DARRAY_GRAD(tex,coord,dx,dy) tex2DArray(tex,coord,dx,dy)
	#endif
#endif

float2 CW_Rotate(float2 v, float angle)
{
	float s = sin(angle);
	float c = cos(angle);
	return float2(v.x * c - v.y * s, v.x * s + v.y * c);
}

float2 CW_SnapToPixel(float2 uv, float2 size)
{
	float2 pixel = floor(uv * size);
#ifndef UNITY_HALF_TEXEL_OFFSET
	pixel += 0.5f;
#endif
	return pixel / size;
}

float4 CW_Cubic(float v)
{
    float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
    float4 s = n * n * n;
    float4 o;
    o.x = s.x;
    o.y = s.y - 4.0 * s.x;
    o.z = s.z - 4.0 * s.y + 6.0 * s.x;
    o.w = 6.0 - o.x - o.y - o.z;
    return o;
}

float4 CW_SampleCubic(sampler2D sam, float2 uv, float2 size)
{
	float2 invTexSize = 1.0 / size;

   uv = uv * size - 0.5;


    float2 fxy = frac(uv);
    uv -= fxy;

    float4 xcubic = CW_Cubic(fxy.x);
    float4 ycubic = CW_Cubic(fxy.y);

    float4 c = uv.xxyy + float2 (-0.5, +1.5).xyxy;

    float4 s = float4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
    float4 offset = c + float4(xcubic.yw, ycubic.yw) / s;

    offset *= invTexSize.xxyy;

    float4 sample0 = tex2Dlod(sam, float4(offset.xz, 0.0f, 0.0f));
    float4 sample1 = tex2Dlod(sam, float4(offset.yz, 0.0f, 0.0f));
    float4 sample2 = tex2Dlod(sam, float4(offset.xw, 0.0f, 0.0f));
    float4 sample3 = tex2Dlod(sam, float4(offset.yw, 0.0f, 0.0f));

    float sx = s.x / (s.x + s.y);
    float sy = s.z / (s.z + s.w);

    return lerp(
       lerp(sample3, sample2, sx), lerp(sample1, sample0, sx)
    , sy);
}

float4 CW_SampleCubic2(sampler2D sam, float2 uv, float2 size)
{
	uv *= size;
	uv += 0.5f;

	float2 iuv = floor(uv);
	float2 fuv =  frac(uv);

	float4 x = float4(0.8333334f, 0.1666667f, -0.2f, 1.0f) + float4(-0.6666667f, 0.6666667f, 0.2f, 0.2f) * fuv.x;
	float4 y = float4(0.8333334f, 0.1666667f, -0.2f, 1.0f) + float4(-0.6666667f, 0.6666667f, 0.2f, 0.2f) * fuv.y;

	iuv -= 0.5f;

	float2 a = float2(iuv.x + x.z, iuv.y + y.z) / size;
	float2 b = float2(iuv.x + x.w, iuv.y + y.z) / size;
	float2 c = float2(iuv.x + x.z, iuv.y + y.w) / size;
	float2 d = float2(iuv.x + x.w, iuv.y + y.w) / size;
	
	return y.x * (x.x * tex2D(sam, a) + x.y * tex2D(sam, b)) + y.y * (x.x * tex2D(sam, c) + x.y * tex2D(sam, d));
}