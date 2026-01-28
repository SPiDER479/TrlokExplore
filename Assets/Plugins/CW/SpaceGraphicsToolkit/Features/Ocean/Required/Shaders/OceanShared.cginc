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

#define GERSTNER_LAYERS 4
#if !defined(GERSTNER_WAVES_PER_LAYER)
	#define GERSTNER_WAVES_PER_LAYER 3
#endif

// Hard-coded wave directions for tiling compatibility (30Åã increments)
static const float2 g_WaveDirections[12] = {
	float2(1.0, 0.0),           // 0Åã
	float2(0.866025, 0.5),      // 30Åã
	float2(0.5, 0.866025),      // 60Åã
	float2(0.0, 1.0),           // 90Åã
	float2(-0.5, 0.866025),     // 120Åã
	float2(-0.866025, 0.5),     // 150Åã
	float2(-1.0, 0.0),          // 180Åã
	float2(-0.866025, -0.5),    // 210Åã
	float2(-0.5, -0.866025),    // 240Åã
	float2(0.0, -1.0),          // 270Åã
	float2(0.5, -0.866025),     // 300Åã
	float2(0.866025, -0.5),     // 330Åã
};

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

float4x4 _WaveMatrices[16];
float4   _WaveData[16]; // x = scale, y = weight

void SGT_ComputeGerstnerWave(
    float3 waveDir, 
    float3 surfaceNormal, 
    float amplitude, 
    float frequency, 
    float steepness, 
    float phase, 
    float3 samplePos, 
    inout float3 displacement, 
    inout float3 normalAccum)
{
    float theta = dot(waveDir, samplePos) * frequency + phase;
    
    float sinT, cosT;
    sincos(theta, sinT, cosT);
    
    float Q = min(steepness, 1.0);
    float QA = Q * amplitude;
    float WA = frequency * amplitude;
    
    displacement += waveDir * (QA * cosT);
    displacement += surfaceNormal * (amplitude * sinT);
    
    normalAccum -= waveDir * (WA * cosT);
    normalAccum -= surfaceNormal * (Q * WA * sinT);
}

// Rotate 2D direction by octave matrix rotation
float2 RotateDirectionByMatrix(float2 dir, float4x4 mat)
{
    // Extract rotation from matrix (first two rows, XZ components)
    // The matrix includes scale, so we normalize
    float2 axisX = normalize(float2(mat._m00, mat._m02));
    float2 axisY = normalize(float2(mat._m10, mat._m12));
    
    // Apply rotation: new = dir.x * axisX + dir.y * axisY
    return dir.x * axisX + dir.y * axisY;
}

void SGT_ApplyGerstnerNoise(
    inout float3 vertex,
    inout float3 normal,
    float3 tangent,
    float3 binormal,
    float amplitude,
    float steepness,
    float time)
{
    float3 vertexDelta = 0.0;
    float3 normalDelta = normal;
    
    [unroll]
    for (int i = 0; i < 3; i++)
    {
        float scale = 1.0f;
        float weight = _WaveData[i].y;
        
        // Skip faded-out octaves
        if (weight < 0.001)
            continue;
        
        // Transform position to wave space
        float3 wavePos = mul(_WaveMatrices[i], float4(vertex, 1.0)).xyz;
        
        // Frequency derived from scale (wavelength)
        float octaveFreq = 1.0 * (1.0 / scale);
        
        // Amplitude for this octave (weighted by fade and scale ratio)
        float octaveAmp = amplitude * weight;
        
        [unroll]
        for (int w = 0; w < GERSTNER_WAVES_PER_LAYER; w++)
        {
            // Get base direction and rotate by octave matrix
            float2 dir2D = g_WaveDirections[w % 12];
            dir2D = RotateDirectionByMatrix(dir2D, _WaveMatrices[i]);
            
            float3 waveDir = normalize(float3(dir2D.x, 0.0, dir2D.y));
            
            // Phase speed from dispersion relation
            float phaseSpeed = sqrt(9.81 / octaveFreq) * 1;
            float phase = time * phaseSpeed;
            
            SGT_ComputeGerstnerWave(
                waveDir, 
                normal, 
                octaveAmp, 
                octaveFreq, 
                steepness, 
                phase, 
                wavePos.xzy,  // Swizzle if needed based on your coordinate system
                vertexDelta, 
                normalDelta);
            
            octaveFreq *= 1.8;
            octaveAmp *= 0.5;
        }
    }
    
    vertex = vertex + vertexDelta;
    normal = normalize(normal + normalDelta);
}

void SGT_GetOceanData(float2 uv, out float distance, out float3 normal)
{
	float4 data = _SGT_Volumetrics_OceanTex.Sample(sampler_point_clamp, uv);
	
	distance = data.w;
	normal   = data.xyz;
}

float CW_Asin(float x)
{
	return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
}

float4 CW_CalculateCoords(float3 direction)
{
	float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateCoords2(float3 direction)
{
	float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
	float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;
	//float v = direction.y * 0.3f + 0.5f;

	return float4(u, v * 0.5f, direction.xz * 0.25f);
}

float4 CW_CalculateGradsX(float4 coords)
{
	float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float4 CW_CalculateGradsY(float4 coords)
{
	float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
}

float2 CW_Offset(float2 coords, int index, float tiling)
{
	//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
	coords.xy += sin(float2(3,7) * index);
	
	return coords;
}

float4 CW_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
{
	float bands    = max(tiling * 0.25f, 1);
	float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
	float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

	float indexA = floor(vertical);
	float indexB = indexA + 1.0f;

	float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
	float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

	float2 coordA = CW_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
	float2 coordB = CW_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

	float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
	float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);
	
	return lerp(sampleA, sampleB, frac(vertical));
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