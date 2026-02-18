float3   _SGT_Offset;
float    _SGT_Radius;
float4x4 _SGT_ObjectToWorld;
float4x4 _SGT_WorldToObject;

float4   _SGT_Origins[128];
float4   _SGT_PositionsA[128];
float4   _SGT_PositionsB[128];
float4   _SGT_PositionsC[128];
float4x4 _SGT_CoordsX[128];
float4x4 _SGT_CoordsY[128];
float4x4 _SGT_CoordsZ[128];
float4x4 _SGT_CoordsW[128];

float4x4 _SGT_RipplesMatrixA;
float4x4 _SGT_RipplesMatrixB;
float    _SGT_RipplesBlend;

float4x4 _SGT_ShoreMatrixA;
float4x4 _SGT_ShoreMatrixB;
float    _SGT_ShoreBlend;

float4x4 _SGT_CausticsMatrixA;
float4x4 _SGT_CausticsMatrixB;
float    _SGT_CausticsBlend;
float3   _SGT_CausticsDirection;

float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;
float  _SGT_WaveInvAmplitude;

#if !defined(WAVE_SKIP)
	#define WAVE_SKIP 3
#endif

void SGT_ComputeTangentFrame(float3 N, out float3 T, out float3 B)
{
	if (N.z < -0.9999)
	{
		T = float3(0, -1, 0);
		B = float3(-1, 0, 0);
	}
	else
	{
		float a = 1.0 / (1.0 + N.z);
		float b = -N.x * N.y * a;
		T = float3(1.0 - N.x * N.x * a, b, -N.x);
		B = float3(b, 1.0 - N.y * N.y * a, -N.y);
	}
}

float4 _WaveDataA[24]; // xyz = offset, w = period
float4 _WaveDataB[24]; // xyz = direction, w = amplitude

void SGT_ApplyWaves(
	inout float3 vertex,
	inout float3 normal,
	inout float3 tangent,
	inout float3 binormal,
	float2 normalDetail,
	float pixelSize)
{
	float3 displacement = 0, gradient = 0;
	float3 N = normal, T = tangent, B = binormal;
	
	#if _SGT_DISPLACEMENT_ON
		[unroll]
		for (int i = 0; i < 24; i += WAVE_SKIP)
		{
			float3 offset    = _WaveDataA[i].xyz;
			float  period    = _WaveDataA[i].w;
			float  fade      = saturate(1.0 - (pixelSize * period));
			float3 direction = _WaveDataB[i].xyz;
			float  amplitude = _WaveDataB[i].w * fade;
			float  phase     = dot(vertex - offset, direction) * period;
		
			float s, c;
			sincos(phase, s, c);
		
			displacement += N * (s * amplitude);
			gradient     += direction * (c * amplitude * period);
		}
	#endif
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	float3 dPdT = T + dhdT * N;
	float3 dPdB = B + dhdB * N;
	
	normal   = normalize(cross(dPdT, dPdB)); normal *= sign(dot(normal, N));
	tangent  = normalize(dPdT);
	binormal = normalize(cross(normal, tangent));
	
	vertex  += displacement;
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float3 SGT_BlendNormals(float3 a, float3 b)
{
	return normalize(float3(a.xy + b.xy, a.z));
}

float HenyeyGreenstein(float cosTheta, float g)
{
	float g2 = g * g;
	float denom = 1.0 + g2 - 2.0 * g * cosTheta;
	return (1.0 - g2) / (4.0 * 3.14159265 * pow(max(denom, 0.0001), 1.5));
}

void GetOceanTransmittanceScatter(
	out float3 transmittance,
	out float3 scatter,
	float  waterDepth,
	float3 viewDir,
	float3 sunDir,
	float3 sunColor,
	float3 ambColor,
	float2 cameraDepth,
	float3 waterColor,
	float  waterDensity)
{
	const float3 absorptionWeight = float3(1.0, 0.2, 0.1); // red dies fastest

	float3 extinction = absorptionWeight * waterDensity;   // ƒÐ_t
	float3 scattering = waterColor * extinction;           // deep convergence
	
	float3 tau     = extinction * waterDepth;
	float  viewCos = abs(viewDir.y);
	float  sunCos  = max(sunDir.y, 0.01);
	float  phase   = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);

	float sunFactor = (1.0 + viewCos / sunCos);
	float ambFactor = (1.0 + viewCos * 2.0);

	float3 camTransSun = exp(-extinction * cameraDepth.x / sunCos);
	float3 camTransAmb = 1.0 / (1.0 + extinction * cameraDepth.y * 2.0); // rational approx

	float3 sunIntegral = waterDepth / (1.0 + tau * sunFactor);
	float3 ambIntegral = waterDepth / (1.0 + tau * ambFactor);

	transmittance = exp(-tau);
	
	scatter =
		scattering * sunColor * camTransSun * sunIntegral * phase +
		scattering * ambColor * camTransAmb * ambIntegral * ambFactor;
}
