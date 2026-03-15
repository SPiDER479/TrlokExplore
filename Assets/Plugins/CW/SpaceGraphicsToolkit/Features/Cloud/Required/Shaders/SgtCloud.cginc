#include "UnityCG.cginc"
#include "../../../Sky/Required/Shaders/SgtSky.cginc"
#include "../../../../../Shared/SimpleOriginSystem/Scripts/PositionCompression.cginc"

#define __SGT_CUTOFF 0.02


sampler2D_float _SGT_SceneDepthTexture;
float SGT_GetLinearEyeDepth(float2 uv) { return tex2D(_SGT_SceneDepthTexture, uv); }

#define SGT_MAX_LIGHTS 16

int    _SGT_LightCount;
float4 _SGT_LightColor[SGT_MAX_LIGHTS];
float4 _SGT_LightPosition[SGT_MAX_LIGHTS];
float4 _SGT_LightDirection[SGT_MAX_LIGHTS];

float remap(float x, float low1, float high1, float low2, float high2)
{
	return low2 + (x - low1) * (high2 - low2) / (high1 - low1);
}

float henyey_greenstein_phase_func(float mu, float g)
{
	return (1. - g*g) / ((4. * UNITY_PI) * pow(1. + g*g - 2.*g*mu, 1.5));
}

float SGT_SharpenDensity(float density)
{
	float inDensityScale = 52.11f;
	float EPSILON = 0.01f;
	density *= inDensityScale; 
	density = pow(density, lerp(0.3, 0.6, max(EPSILON, pow(saturate(inDensityScale), 4.0)))); // Sharpen result and lower Density close to camera to both add details and reduce undersampling noise
	return density;
}

void SGT_Ortho(float3 worldPoint, out float3 worldPos, out float3 worldDir)
{
	float3 forward = -normalize(UNITY_MATRIX_V[2].xyz);

	float3 planePoint = _WorldSpaceCameraPos;

	float d = dot(forward, forward);
	float t = dot(planePoint - worldPoint, forward) / d;

	worldPos = worldPoint + forward * t;
	worldDir = forward;
}

float InverseLerpClamped(float a, float b, float value)
{
    return saturate((value - a) / (b - a)); // saturate clamps between 0 and 1
}