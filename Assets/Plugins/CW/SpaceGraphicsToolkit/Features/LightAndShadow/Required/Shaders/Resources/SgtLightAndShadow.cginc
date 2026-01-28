#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

int       _SGT_SphereShadowCount;
float4x4  _SGT_SphereShadowMatrix[SGT_MAX_SPHERE_SHADOWS];
float4    _SGT_SphereShadowPower[SGT_MAX_SPHERE_SHADOWS];

int       _SGT_RingShadowCount;
sampler2D _SGT_RingShadowTexture;
float4    _SGT_RingShadowColor[SGT_MAX_RING_SHADOWS];
float4x4  _SGT_RingShadowMatrix[SGT_MAX_RING_SHADOWS];
float4    _SGT_RingShadowRatio[SGT_MAX_RING_SHADOWS];

float4 SGT_SphereShadowColor(float4x4 shadowMatrix, float4 shadowPower, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	//shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	//float4 shadow = 1.0f - pow(1.0f - shadowMag, shadowPower);
	float4 shadow = pow(shadowMag, shadowPower);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_RingShadowColor(float4x4 shadowMatrix, sampler2D shadowSampler, float shadowRatio, float4 worldPoint)
{
	float4 shadowPoint = mul(shadowMatrix, worldPoint);
	float  shadowMag   = length(shadowPoint.xy);

	shadowMag = 1.0f - (1.0f - shadowMag) * shadowRatio;

	float4 shadow = tex2D(shadowSampler, shadowMag.xx);

	shadow += shadowPoint.z < 0.0f;

	return saturate(shadow);
}

float4 SGT_ShadowColor(float3 worldPoint3)
{
	float4 worldPoint = float4(worldPoint3, 1.0f);
	float4 color      = 1.0f;

	for (int s = 0; s < _SGT_SphereShadowCount; s++)
	{
		color *= SGT_SphereShadowColor(_SGT_SphereShadowMatrix[s], _SGT_SphereShadowPower[s], worldPoint);
	}

	for (int r = 0; r < _SGT_RingShadowCount; r++)
	{
		color *= SGT_RingShadowColor(_SGT_RingShadowMatrix[r], _SGT_RingShadowTexture, _SGT_RingShadowRatio[r].x, worldPoint);
	}

	return color;
}