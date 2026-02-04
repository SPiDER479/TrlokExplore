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

float4    _SGT_WaveData;
float4    _SGT_SurfaceTiling;

sampler2D _SGT_RipplesTexture;
sampler3D _SGT_NoiseTex;
float4    _SGT_RipplesData;

Texture2D _SGT_Volumetrics_OceanTex;
SamplerState sampler_point_clamp;

float2 _SGT_FadeOpacity;

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

float4x4 _WaveMatrices[24];
float4   _WaveData[24]; // x = scale, y = weight

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
	
	[unroll]
	for (int i = 0; i < 24; i += WAVE_SKIP)
	{
		float3 scale = _WaveMatrices[i][0].xyz;
		float2 pos   = mul(_WaveMatrices[i], float4(vertex, 1)).xy;
		float  fade  = saturate(1.0 - (pixelSize * _WaveData[i].w));
		
		float s, c;
		sincos(pos.x, s, c);
		
		float amp = _WaveData[i].z * fade;
		
		displacement += N * (s * amp);
		gradient     += scale * (c * amp);
	}
	
	float dhdT = dot(gradient, T) + normalDetail.x;
	float dhdB = dot(gradient, B) + normalDetail.y;
	
	vertex  += displacement;
	normal   = normalize(N - dhdT * T - dhdB * B);
	tangent  = normalize(T + dhdT * N);
	binormal = normalize(B + dhdB * N);
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
	float3 ambientColor,
	float  cameraDepth,
	float3 waterColor, // The "Deep" convergence color
	float  waterDensity)
{
	// 1. Artist-Friendly Absorption Profile
	// Typical ocean water absorbs Red much faster than Blue.
	// We use these coefficients to scale the extinction per channel.
	// Higher value = color disappears faster with depth.
	float3 absorptionWeight = float3(1.0, 0.2, 0.1); 
	
	// 2. Derive Coefficients
	// Extinction must be float3 for color shifting to happen.
	float3 extinction = absorptionWeight * waterDensity;
	
	// To ensure convergence to waterColor at infinite depth, 
	// the scattering/extinction ratio must equal waterColor.
	float3 scatt = waterColor * extinction;
	
	// 3. Transmittance (The "Nice Shift" happens here)
	// Red channel will drop to 0 much faster than Blue.
	transmittance = exp(-extinction * waterDepth);
	
	float viewCos = abs(viewDir.y);
	float sunCos = max(sunDir.y, 0.01);
	
	// 4. Sun Scattering
	float3 sunExt = extinction * (1.0 + viewCos / sunCos);
	float3 sunAtten = sunColor * exp(-extinction * cameraDepth / sunCos);
	float  phase = HenyeyGreenstein(dot(viewDir, sunDir), 0.7);
	
	// Volume scattering formula with float3 coefficients
	scatter = sunAtten * phase * (scatt / max(sunExt, 1e-4)) * (1.0 - exp(-sunExt * waterDepth));
	
	// 5. Ambient Scattering (Converges to waterColor when ambient=1)
	float  geomFactor = (1.0 + viewCos * 2.0); 
	float3 ambExt = extinction * geomFactor;
	float3 ambAtten = ambientColor * exp(-extinction * cameraDepth * 2.0);
	
	// This term simplifies to (scatt / extinction) at infinite depth
	scatter += ambAtten * (scatt * geomFactor / max(ambExt, 1e-4)) * (1.0 - exp(-ambExt * waterDepth));
}