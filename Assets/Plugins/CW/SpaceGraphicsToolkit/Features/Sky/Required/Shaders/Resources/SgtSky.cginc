#define __SGT_LIGHTANDSHADOW 1
#define SGT_MAX_LIGHTS 16
#define SGT_MAX_SPHERE_SHADOWS 16
#define SGT_MAX_RING_SHADOWS 1

struct a2v
{
	float4 vertex    : POSITION;
	float4 texcoord0 : TEXCOORD0;
	float3 normal    : NORMAL;
};

struct v2f
{
	float4 position           : SV_POSITION;
	float3 worldSpacePosition : TEXCOORD1;
	float3 worldSpaceNormal   : TEXCOORD2;
	float4 screenPosition     : TEXCOORD3;
};

struct fdata
{
	float3 worldSpacePosition;
	float3 worldSpaceNormal;
	float3 worldSpaceViewDir;
	float3 worldSpaceLightDir;
	float3 localPosition;
	float3 localViewDir;
	float3 localCamera;
	float3 viewPosition;
	float2 screenUV;
	float  worldDistance;
	float2 texcoord0;
};

float4x4 _SGT_Object2World;
float4x4 _SGT_World2Object;
float4x4 _SGT_Object2Local;
float4x4 _SGT_World2View;
float3   _SGT_WCam;
float    _SGT_Frame;
sampler2D _SGT_BlueNoiseTex;

void vert(a2v v, out v2f o)
{
	o.position           = UnityObjectToClipPos(v.vertex);
	o.worldSpacePosition = mul(_SGT_Object2World, v.vertex).xyz;
	o.worldSpaceNormal   = mul((float3x3)_SGT_Object2World, v.normal);
	o.screenPosition     = ComputeScreenPos(o.position);
}

v2f SGT_Shift(v2f i, float2 sub)
{
	i.worldSpacePosition += ddx(i.worldSpacePosition) * sub.x + ddy(i.worldSpacePosition) * sub.y;
	i.worldSpaceNormal   += ddx(i.worldSpaceNormal  ) * sub.x + ddy(i.worldSpaceNormal  ) * sub.y;
	i.screenPosition     += ddx(i.screenPosition    ) * sub.x + ddy(i.screenPosition    ) * sub.y;

	return i;
}

fdata SGT_GetData(v2f i)
{
	fdata d;

	d.worldSpacePosition = i.worldSpacePosition;
	d.worldSpaceNormal   = normalize(i.worldSpaceNormal);
	d.worldSpaceViewDir  = normalize(_SGT_WCam - i.worldSpacePosition);
	d.worldSpaceLightDir = normalize(float3(1, 1, 0));
	d.screenUV           = i.screenPosition.xy / i.screenPosition.w;
	d.worldDistance      = distance(_SGT_WCam, i.worldSpacePosition);
	d.localPosition      = mul(_SGT_World2Object, float4(i.worldSpacePosition, 1.0f)).xyz;
	d.localViewDir       = mul((float3x3)_SGT_World2Object, d.worldSpaceViewDir);
	d.localCamera        = mul(_SGT_World2Object, float4(_SGT_WCam, 1.0f)).xyz;
	d.viewPosition       = mul(_SGT_World2View, float4(i.worldSpacePosition, 1.0f)).xyz;
	//d.texcoord0          = i.texcoord0;

	return d;
}

float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64).r;
	return frac(noise + (_SGT_Frame)/sqrt(0.5f));
}

sampler2D_float _SGT_SceneDepthTexture;
sampler2D_float _SGT_WaterDepthTexture;
sampler2D       _SGT_WaterAlphaTexture;
float SGT_GetSceneDepth(float2 uv) { return tex2D(_SGT_SceneDepthTexture, uv); }
float SGT_GetLinearEyeDepth(float2 uv) { return SGT_GetSceneDepth(uv); }

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

float SGT_ScatteringPhase(float angle, float4 terms, float4 strengths)
{
	return dot(pow(saturate(angle * sign(terms)), abs(terms)), strengths);
}

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