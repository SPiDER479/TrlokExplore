#define SGT_OPACITY_STEPS  5

float4x4        _SGT_SkyToWorld;
float4x4        _SGT_WorldToSky;
float4          _SGT_SkyColor;
float           _SGT_SkyBrightness;
float           _SGT_SkyExposure;
float4          _SGT_SkyRadius;
float4          _SGT_SkyAltitudeData;
float           _SGT_SkyDensity;
float4          _SGT_SkyMieWeight;
float4          _SGT_SkyMieData;
sampler3D       _SGT_SkyRadianceTex;
float           _SGT_SkyRadianceLod;
sampler2D       _SGT_SkyLightingTex;
sampler2D       _SGT_SkyAlbedoTex;
float           _SGT_SkyRevealStars;
float           _SGT_SkyDepthOpaque;

float     _SGT_Volumetrics_Downscale; // Global
Texture2D _SGT_Volumetrics_ColorTex; // Global
float4    _SGT_Volumetrics_ColorSize; // Global
Texture2D _SGT_Volumetrics_DepthTex; // Global
float2    _SGT_Volumetrics_DepthSize; // Global

SamplerState my_linear_clamp_sampler;
SamplerState my_point_clamp_sampler;

sampler2D _SGT_BlueNoiseTex; // Global
float     _SGT_Frame; // Global
	
float SGT_DitherBlue(float2 screenUV)
{
	float2 pixel = floor(screenUV * _ScreenParams.xy);
	float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
	return frac(noise + _SGT_Frame / sqrt(0.5f));
}

float SGT_DitherFast(float2 screenUV)
{
	// R2 sequence constants (generalized golden ratio)
    const float2 R2 = float2(0.7548776662, 0.5698402909);
    
    // Convert to pixel coords + temporal jitter
    float2 p = screenUV * _ScreenParams.xy + frac(_Time.y * R2) * 256.0;
    
    // Interleaved Gradient Noise (Jorge Jimenez)
    return frac(52.9829189 * frac(dot(p, float2(0.06711056, 0.00583715))));
}
	
float2 SGT_DirectionToEquirectangular(float3 dir)
{
	dir = normalize(dir);
	float u = atan2(dir.z, dir.x) / (2.0 * 3.141592653) + 0.5;
	float v = asin(clamp(dir.y, -1.0, 1.0)) / 3.141592653 + 0.5;
	return float2(u, v);
}

float3 SGT_SphereTest(float3 ray, float3 rayD, float radius)
{
	float B = -dot(ray, rayD);
	float C = dot(ray, ray) - radius * radius;
	float D = B * B - C;
	float E = sqrt(max(D, 0.0f));
	return float3(B - E, B + E, D);
}

float SGT_InverseLerp(float a, float b, float v)
{
	return (v - a) / (b - a);
}

float3 SGT_CalculateMie(float3 ray, float mie)
{
	return normalize(ray * _SGT_SkyMieWeight.xyz + 1e-6) * mie;
}

float SGT_GetPitch01(float3 rayDir, float3 up, float altitude01)
{
	float power = 2.0f;
	float eyeHeight = _SGT_SkyRadius.x + altitude01 * (_SGT_SkyRadius.y - _SGT_SkyRadius.x);
	float horizonAngleFromDown = -acos(clamp(_SGT_SkyRadius.x / max(eyeHeight, 0.00001f), -1.0f, 1.0f));
	float rayAng = asin(clamp(dot(up, rayDir), -1.0f, 1.0f));
	float sun01;

	if (rayAng < horizonAngleFromDown)
	{
		sun01 = SGT_InverseLerp(-3.141592653 * 0.5f, horizonAngleFromDown, rayAng);
		sun01 = 1.0f - pow(1.0f - sun01, 1.0f / power);
		sun01 = sun01 * 0.5f;
	}
	else
	{
		sun01 = SGT_InverseLerp(horizonAngleFromDown, 3.141592653 * 0.5f, rayAng);
		sun01 = pow(sun01, 1.0f / power);
		sun01 = sun01 * 0.5f + 0.5f;
	}

	return sun01;
}

float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  pitch01    = SGT_GetPitch01(rayDir, up, altitude01);
	float  sun01      = SGT_GetPitch01(sunDir, up, altitude01);
	
	pitch01 += (dither - 0.5f) / 128.0f;
	sun01   += (dither - 0.5f) /  64.0f;
	
	return float3(pitch01, altitude01, sun01);
}

float2 SGT_GetDensity2(float3 pos)
{
	float alt01 = saturate((1.0f - length(pos)) * _SGT_SkyAltitudeData.z);

	return pow(alt01, _SGT_SkyAltitudeData.xy) * _SGT_SkyDensity;
}

float SGT_GetOpacity(float3 rayPos, float3 rayDir, float rayMax)
{
	float2 opticalDepth = 0.0f;
	float  rayStep      = rayMax / SGT_OPACITY_STEPS;
	float  t            = rayStep * 0.5f;
	
	for (int i = 0; i < SGT_OPACITY_STEPS; i++)
	{
		float3 pos = rayPos + rayDir * t;

		opticalDepth += SGT_GetDensity2(pos) * rayStep;
		
		t += rayStep;
	}
	
	return 1.0f - exp((opticalDepth.x + opticalDepth.y) * -20.0f);
}

float4 SGT_SampleLUT(float3 coord)
{
	return tex3Dlod(_SGT_SkyRadianceTex, float4(coord, _SGT_SkyRadianceLod));
}

float3 SGT_AtmosphereColor(float3 rayPos, float3 sunDir, float dither)
{
	float3 up         = normalize(rayPos);
	float  eyeHeight  = length(rayPos);
	float  altitude01 = saturate(SGT_InverseLerp(_SGT_SkyRadius.z, 1.0f, eyeHeight));
	float  sun01      = 0.5f + 0.5f * dot(sunDir, up);
		
	return tex2Dlod(_SGT_SkyLightingTex, float4(sun01, altitude01, 0.0f, 0.0f)).xyz;
}

float3 SGT_UnderwaterAtmosphere(float3 rayPos, float3 rayDir, float3 sunDir, float exposure, float dither)
{
	float3 coord = GetLutCoord(rayPos, rayDir, sunDir, dither); coord.x = 1.0f;
	float4 ray   = SGT_SampleLUT(coord);
	float3 mie   = SGT_CalculateMie(ray.xyz, ray.w);
	float3 color = ray.xyz + mie;
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	return saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness);
}

float4 SGT_Atmosphere(float3 rayPos, float3 rayDir, float rayFar, float rayMax, float3 sunDir, float exposure, float dither)
{
	float3 coord  = GetLutCoord(rayPos, rayDir, sunDir, dither);
	float2 mieOff = 0.0f;
	float2 mieMul = 1.0f;
	
	if (rayMax * 1.02f <= rayFar) // If ground, limit to below horizon scattering values, and disable secondary mie
	{
		coord.x = min(coord.x, 0.5f - (1.0f / 128.0f));
		coord.x = lerp(0.5f - (1.0f / 128.0f), coord.x, coord.y*coord.y);
		
		mieOff = 0.2f;
		mieMul.y = 0.0f;
	}
	else
	{
		//coord.x = max(coord.x, 0.5f + (1.0f / 128.0f));
	}
	
	float4 ray    = SGT_SampleLUT(coord);
	float3 mie    = SGT_CalculateMie(ray.xyz, ray.w);
	float2 g      = lerp(_SGT_SkyMieData.xy, 0.0f, mieOff);
	float  c      = dot(rayDir, sunDir);
	float  phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
	float2 phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (pow(abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
	float3 color  = ray.xyz * phaseR + mie * dot(phaseM, 1);
	
	#if _SSS_HDRP
		color *= exposure * 0.25f;
	#else
		color = 1.0 - exp(-color * exposure);
	#endif
	
	float opacity = SGT_GetOpacity(rayPos, rayDir, rayMax);
	
	return float4(saturate(_SGT_SkyColor.xyz * color * _SGT_SkyBrightness), opacity);
}

float4 SGT_SimpleAtmosphere(float3 worldPos, float3 worldHit)
{
	float dither   = 0.5f;
	
	float3 ocam = mul(_SGT_WorldToSky, float4(worldPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(worldHit, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	odst.xy = max(odst.xy, 0.0f);
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	return SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
}

float3 CW_Depth2World(float viewDepth, float3 viewDir)
{
	return _WorldSpaceCameraPos + viewDir * viewDepth;
}
	
bool CW_DepthInBounds(float viewDepth, float3 viewDir)
{
	float3 wPos = CW_Depth2World(viewDepth, viewDir);
	float3 oPos = mul(_SGT_WorldToSky, float4(wPos, 1.0f)).xyz;
		
	return length(oPos) < 1.2f;
}
	
void CW_SampleVolumetricsDefault(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	float4 centerColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	float  centerDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
		
	if (CW_DepthInBounds(centerDepth, viewDir) == true)
	{
		outColor = centerColor;
		outDepth = centerDepth;
	}
	else
	{
		outColor = 0;
		outDepth = 0;
	}
}

void CW_SampleVolumetricsDefault2(float2 screenUV, float3 viewDir, out float4 outColor, out float outDepth)
{
	outColor = _SGT_Volumetrics_ColorTex.Sample(my_linear_clamp_sampler, screenUV);
	outDepth = _SGT_Volumetrics_DepthTex.Sample(my_linear_clamp_sampler, screenUV).x;
}
	
void CW_SampleVolumetrics(float2 screenUV, float3 viewDir, float sceneDepth, out float4 outColor, out float outDepth)
{
	outColor = 0;
	outDepth = 0;
		
	if (_SGT_Volumetrics_Downscale > 1)
	{
		float2 pixelF   = screenUV * _SGT_Volumetrics_ColorSize.xy - 0.5f;
		float2 pixelI   = floor(pixelF);
		float2 snappedF = pixelF - pixelI;
			
		float2 coord0 = (pixelI + float2(0.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord1 = (pixelI + float2(1.5f, 0.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord2 = (pixelI + float2(0.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
		float2 coord3 = (pixelI + float2(1.5f, 1.5f)) * _SGT_Volumetrics_ColorSize.zw;
			
		float depth0 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord0).x;
		float depth1 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord1).x;
		float depth2 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord2).x;
		float depth3 = _SGT_Volumetrics_DepthTex.Sample(my_point_clamp_sampler, coord3).x;
			
		float4 color0 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord0);
		float4 color1 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord1);
		float4 color2 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord2);
		float4 color3 = _SGT_Volumetrics_ColorTex.Sample(my_point_clamp_sampler, coord3);
			
		float w0 = CW_DepthInBounds(depth0, viewDir) * (depth0 < sceneDepth) * color0.w * (1.0 - snappedF.x) * (1.0 - snappedF.y);
		float w1 = CW_DepthInBounds(depth1, viewDir) * (depth1 < sceneDepth) * color1.w * snappedF.x * (1.0 - snappedF.y);
		float w2 = CW_DepthInBounds(depth2, viewDir) * (depth2 < sceneDepth) * color2.w * (1.0 - snappedF.x) * snappedF.y;
		float w3 = CW_DepthInBounds(depth3, viewDir) * (depth3 < sceneDepth) * color3.w * snappedF.x * snappedF.y;
			
		float wt = w0 + w1 + w2 + w3;
			
		if (wt > 0.0f)
		{
			outColor = (color0 * w0 + color1 * w1 + color2 * w2 + color3 * w3) / wt;
			outDepth = (depth0 * w0 + depth1 * w1 + depth2 * w2 + depth3 * w3) / wt;
		}
		else
		{
			return;
		}
	}
	else
	{
		CW_SampleVolumetricsDefault(screenUV, viewDir, outColor, outDepth);
	}
}