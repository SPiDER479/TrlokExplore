#include "UnityCG.cginc"

struct a2v
{
	float4 vertex    : POSITION;
	float2 texcoord0 : TEXCOORD0;
};

struct v2f
{
	float4 vertex    : SV_POSITION;
	float2 texcoord0 : TEXCOORD0;
};

float4 _SGT_Constants;
float4 _SGT_Emission;

sampler2D _SGT_DataTex;
float4    _SGT_DataSize;

sampler2D _SGT_OldDataTex;
sampler2D _SGT_NewDataTex;
float     _SGT_OldNewTransition;
float     _SGT_Power;

void Vert(a2v v, out v2f o)
{
	o.vertex    = UnityObjectToClipPos(v.vertex);
	o.texcoord0 = v.texcoord0;
}

float SGT_InverseLerp(float a, float b, float value)
{
	return (value - a) / (b - a);
}

float4 SGT_Sample(float2 uv)
{
	float4 data = tex2D(_SGT_DataTex, uv);

	return data;
}

float2 SGT_SnapToPixel(float2 coord, float2 size)
{
	float2 pixel = floor(coord * size);
	#ifndef UNITY_HALF_TEXEL_OFFSET
		pixel += 0.5f;
	#endif
	return pixel / size;
}