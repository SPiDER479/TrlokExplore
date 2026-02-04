BEGIN_OPTIONS
END_OPTIONS

BEGIN_PROPERTIES
	[KeywordEnum(Box, Sphere)] _SGT_Shape ("Shape", Float) = 0
	
	[HideInInspector] _SGT_SurfaceColor("", Color) = (0,0,0)
	[HideInInspector] _SGT_SurfaceDensity("", Float) = 0
	[HideInInspector] _SGT_SurfaceMinimumOpacity("", Float) = 0
	[HideInInspector] _SGT_SurfaceSmoothness("", Float) = 0
	
	[HideInInspector] _SGT_UnderwaterColor("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_UnderwaterDensity("", Float) = 0
	[HideInInspector] _SGT_UnderwaterMinimumOpacity("", Float) = 0
	[HideInInspector] _SGT_UnderwaterBrightness("", Float) = 0
	[HideInInspector] _SGT_UnderwaterShadowRange("", Float) = 0
	
	[Header(REFRACTION)]
	[Toggle(_SGT_REFRACTION)] _SGT_Refraction("	Enable", Float) = 0
	_SGT_RefractionDistance("	Distance", Float) = 1

	[Header(ALBEDO)]
	[Toggle(_SGT_ALBEDO)] _SGT_Albedo("	Enable", Float) = 0
	
	[Header(LIGHTING)]
	[Toggle(_SGT_LIGHTING)] _SGT_Lighting("	Enable", Float) = 0
	
	[Header(CLOUDS)]
	[Toggle(_SGT_CLOUDS)] _SGT_Clouds("	Enable", Float) = 0
	[HideInInspector] [NoScaleOffset] _SGT_CloudShadowTex("", 2D) = "black" {}
	[HideInInspector] _SGT_CloudShadowDirection("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_CloudShadowOpacity("", Vector) = (0,0,0,0)
	
	[Header(CAUSTICS)]
	[Toggle(_SGT_CAUSTICS)] _SGT_Caustics("	Enable", Float) = 0
	[HideInInspector] _SGT_CausticsDirection("", Vector) = (0,0,0,0)
	[NoScaleOffset] _SGT_CausticsTexure("	Texture (R)", 3D) = "black" {}
	_SGT_CausticsTopSharpness("	Top Sharpness", Float) = 1
	_SGT_CausticsBottomSharpness("	Bottom Sharpness", Float) = 0.1
	_SGT_CausticsSpeed("	Speed", Float) = 0.2
	_SGT_CausticsBrightness("	Brightness", Float) = 10.0
	
	[Header(SHORE)]
	[Toggle(_SGT_SHORE)] _SGT_Shore("	Enable", Float) = 0
	[NoScaleOffset] _SGT_ShoreTex("	Texture (RGB)", 2D) = "black" {}
	_SGT_ShoreDistance("	Distance", Float) = 50
	_SGT_ShoreWidth("	Width", Range(0.1, 10)) = 1
	_SGT_ShoreBias("	Bias", Range(0, 1)) = 0.5
	
	[Header(FAST REFLECTIONS)]
	[Toggle(_SGT_FASTSSR)] _SGT_FastSSR("	Enable", Float) = 0
	_SGT_FssrFresnel("	Fresnel", Range(4, 32)) = 10
	_SGT_FssrError("	Error Threshold", Float) = 100

	[Header(SUBSURFACE SCATTERING)]
	[Toggle(_SGT_FASTSSS)] _SGT_SSS("	Enable", Float) = 0
	_SGT_ScatteringDistanceFade("	Distance Fade", Float) = 0.01
END_PROPERTIES

BEGIN_CBUFFER
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_REFRACTION_OFF _SGT_REFRACTION
	#pragma shader_feature_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
	#pragma shader_feature_local _SGT_LIGHTING_OFF _SGT_LIGHTING
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_CAUSTICS_OFF _SGT_CAUSTICS
	#pragma shader_feature_local _SGT_SHORE_OFF _SGT_SHORE
	#pragma shader_feature_local _SGT_FASTSSR_OFF _SGT_FASTSSR
	#pragma shader_feature_local _SGT_FASTSSS_OFF _SGT_FASTSSS
END_DEFINES

float _SGT_RefractionDistance;

float4 _SGT_SurfaceColor;
float4 _SGT_SurfaceScattering;
float  _SGT_SurfaceDensity;
float  _SGT_SurfaceSmoothness;

// CAUSTICS
sampler3D _SGT_CausticsTexure;
float4    _SGT_CausticsDirection;
float     _SGT_CausticsTopSharpness;
float     _SGT_CausticsBottomSharpness;
float     _SGT_CausticsSpeed;
float     _SGT_CausticsBrightness;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

float4   _SGT_SphereData;
float4   _SGT_PlaneData;
float4x4 _SGT_World2Object;

// SHORE
sampler2D _SGT_ShoreTex;
float     _SGT_ShoreDistance;
float     _SGT_ShoreWidth;
float     _SGT_ShoreBias;

// FAST REFLECTIONS
float _SGT_FssrFresnel;
float _SGT_FssrError;

// SUBSURFACE SCATTERING
float _SGT_ScatteringDistanceFade;

float SGT_SampleCloudDensity(float3 wpos, float bias)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2Dbias(_SGT_CloudShadowTex, float4(uv, 0.0f, bias)), _SGT_CloudShadowOpacity));
}

float2 SGT_ProjectWorldToScreen(float3 worldPos)
{
	float4 cs = mul(UNITY_MATRIX_VP, float4(SSS_AbsoluteToWorld(worldPos), 1.0f));
	
	float2 ndc = cs.xy / cs.w;
	ndc.y = -ndc.y;

	return ndc * 0.5f + 0.5f;
}

float SGT_Delta(float3 worldPos, float weight)
{
	float planeDist  = dot(_SGT_PlaneData.xyz, worldPos) + _SGT_PlaneData.w;
	float sphereDist = length(worldPos - _SGT_SphereData.xyz) - _SGT_SphereData.w;
	
	return lerp(planeDist, sphereDist, weight);
}

float CW_SampleCaustics(float3 worldPosition, float blurStrength)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0 + blurStrength * 5.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float2 SGT_FixRefractedUV(float2 originalUV, float2 refractedUV)
{
	float2 uvOffset = refractedUV - originalUV;
	
	// Edge distances: 0 at edge, 1 at center
	float2 edgeDistMin = originalUV;
	float2 edgeDistMax = 1.0 - originalUV;
	
	// Select the edge we're moving towards
	float2 relevantEdgeDist = lerp(edgeDistMax, edgeDistMin, step(uvOffset, 0.0));
	
	// Attenuation based on offset vs available distance
	float  falloffZone  = 0.25;
	float2 attenuation  = saturate(relevantEdgeDist / (abs(uvOffset) + falloffZone));
	float  refractAtten = min(attenuation.x, attenuation.y);
	
	return lerp(originalUV, refractedUV, refractAtten);
}

float SGT_EdgeFade(float2 screenUV, float fadeWidth)
{
	float2 d = min(screenUV, 1.0 - screenUV);
	return smoothstep(0, fadeWidth, min(d.x, d.y));
}

float3 SGT_SurfaceSSR(float2 screenUV, float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float wmax, float3 baseColor, float3 sunDir, float dither, float3 lighting)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz));
	
	float3 reflectedDir   = reflect(worldViewDir, worldNormal);
	float  reflectedLen   = abs(worldEyeDepth - surfaceDistance);
	float3 reflectedPos   = worldPos + reflectedDir * reflectedLen;
	float2 reflectedUV    = SGT_ProjectWorldToScreen(reflectedPos);
	float3 reflectedColor = SSS_GetSceneColorHD(reflectedUV);
	float  reflectedDepth = SSS_GetSceneWorldDistance(reflectedUV, SSS_GetSceneDepth(reflectedUV));
	float3 reflectedVDir  = -normalize(_WorldSpaceCameraPos - reflectedPos);
	
	// Directional edge fade
	float2 normDir  = normalize(reflectedUV - screenUV + 1e-6);
	float2 edgeDist = saturate(lerp(reflectedUV, 1.0 - reflectedUV, step(0, normDir)) * 10.0);
	float2 fade2    = lerp(1.0, edgeDist, abs(normDir));
	float  edgeFade = fade2.x * fade2.y;
	
	#if _SGT_CLOUDS
		float4 cloudColor;
		float  cloudDepth;
	
		float3 reflectedPos2   = worldPos + reflectedDir * (_SGT_SkyRadius.y - _SGT_SkyRadius.x) * 0.5;
		float2 reflectedUV2    = SGT_ProjectWorldToScreen(reflectedPos2);
	
		CW_SampleVolumetricsDefault(reflectedUV2, reflectedVDir, cloudColor, cloudDepth);
	
		if (cloudColor.w > 0.0f)
		{
			float3 cloudWPos = CW_Depth2World(cloudDepth, reflectedVDir);
			float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
			cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting; // Apply atmospheric lighting to clouds
	
			// Directional edge fade
			float2 normDirC  = normalize(reflectedUV2 - screenUV + 1e-6);
			float2 edgeDistC = saturate(lerp(reflectedUV2, 1.0 - reflectedUV2, step(0, normDirC)) * 10.0);
			float2 fadeC2    = lerp(1.0, edgeDistC, abs(normDirC));
			float  edgeFadeC = fadeC2.x * fadeC2.y;
	
			baseColor = lerp(baseColor, cloudColor.xyz, cloudColor.w * edgeFadeC);
		}
	#endif
	
	// Depth confidence fade
	float expectedDepth = length(reflectedPos - _WorldSpaceCameraPos);
	float depthError    = abs(reflectedDepth - expectedDepth);
	float contactBlend  = saturate(reflectedLen / _SGT_FssrError);
	float fadeDist      = lerp(_SGT_FssrError, reflectedLen, contactBlend);
	float depthFade     = saturate(1.0 - depthError / fadeDist);
	
	baseColor = lerp(baseColor, reflectedColor, edgeFade * depthFade * step(reflectedDepth, wmax));
	
	return baseColor;
}

float3 SGT_UnderwaterSSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	
	float2 uv      = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge    = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	
	float  sceneDepth = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}
	
	float opacity = exp(-sceneDepth * _SGT_SurfaceDensity);

	return baseColor.xyz * edge.x * edge.y * fresnel;
}

float3 SGT_CalculateOceanSSS(float3 normal, float3 viewDir, float3 lightDir, float3 lightColor, float waveHeight, float surfaceDistance)
{
	// --- Refraction: approximate internal light direction ---
	// IOR ratio: air (1.0) -> water (1.33)
	float eta = 0.66;
	float3 refractedDir = normalize(refract(-viewDir, normal, eta));

	// --- Forward scattering lobe ---
	// Strong when refracted ray aligns with sun
	float forwardScatter =
		pow(saturate(dot(refractedDir, lightDir)), 16.0);

	// --- Sun elevation factor ---
	// More SSS when sun is higher in the sky
	float sunUp = saturate(dot(lightDir, float3(0.0, 1.0, 0.0)));

	float sunElevationBoost =
		1.0 - 1.0 / (1.0 + 5.0 * sunUp);

	// --- Spectral water scattering color ---
	float3 waterSSSColor = float3(0.01, 0.33, 0.55) * 0.171;

	// --- Forward-scattered sun glow ---
	float3 forwardSSS =
		_SGT_SurfaceScattering.xyz * _SGT_SurfaceScattering.w *
		forwardScatter *
		lightColor *
		81.0 *
		sunElevationBoost;

	// --- Volumetric depth-based scattering ---
	float3 volumeSSS =
		waterSSSColor *
		lightColor *
		(0.3 + 5.0) *
		saturate(waveHeight) *
		0.3 *
		sunUp;

	return forwardSSS + volumeSSS;
}


float SGT_InterleavedGradientNoise(float2 screenPos)
{
	float3 magic = float3(0.06711056, 0.00583715, 52.9829189);
	return frac(magic.z * frac(dot(screenPos + _SGT_Frame * 5.588238, magic.xy)));
}

void SSS_Vert(inout SSS_VertexData v)
{
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float3 wdir = -d.worldSpaceViewDir;
	float  wmax = distance(_WorldSpaceCameraPos, d.worldSpacePosition);
	float  wfar = wmax;
	float  worldEyeDepth = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
	float3 tint = 1.0f;
	float  dither = SGT_DitherFast(d.screenUV);

	wfar = min(wfar, worldEyeDepth);

	float3 worldEyePosition   = _WorldSpaceCameraPos - d.worldSpaceViewDir * worldEyeDepth;
	float  worldCamUnderwater = max(0.0, -SGT_Delta(_WorldSpaceCameraPos, 0.0));
	
	float3 localEyePosition  = mul(_SGT_World2Object, float4(worldEyePosition, 1.0f)).xyz;
	float3 localEye          = mul(_SGT_World2Object, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 localViewDir = normalize(mul(_SGT_World2Object, float4(d.worldSpaceViewDir, 0.0f)).xyz);
	
	float  surfaceDistance;
	float3 surfaceNormal;
	SGT_GetOceanData(d.screenUV, surfaceDistance, surfaceNormal);
	
	surfaceDistance = max(surfaceDistance, -10000); // Limit underwater distances so things don't break
	
	#if _SGT_SHAPE_SQUARE
		float localEyeHeight = localEye.y;
	#elif _SGT_SHAPE_SPHERE
		float localEyeHeight = length(localEye) - _SGT_SphereData.w;
	#endif
	
	float3 worldHit        = _WorldSpaceCameraPos - d.worldSpaceViewDir * abs(surfaceDistance);
	float  waveHeight      = dot(_SGT_PlaneData.xyz, worldHit) + _SGT_PlaneData.w;
	
	float airIOR   = 1.0;
	float waterIOR = 1.33;
	
	if (surfaceDistance > 0.0f)
	{
		wfar = min(wfar, abs(surfaceDistance));
	}
	
	// Convert to sky space
	float3 ocam = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos, 1.0f)).xyz;
	float3 ofar = mul(_SGT_WorldToSky, float4(_WorldSpaceCameraPos + wdir * wfar, 1.0f)).xyz;
	float  omax = distance(ocam, ofar);
	float3 odir = normalize(mul(_SGT_WorldToSky, float4(-d.worldSpaceViewDir, 0.0f)).xyz);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
	odst.xy = max(odst.xy, 0.0f);
	
	// Clip Inner
	float3 ihit = SGT_SphereTest(ocam, odir, _SGT_SkyRadius.w);
	omax = ihit.z > 0.0f && ihit.x > 0.0f ? min(ihit.x, omax) : omax;
	
	float3 rayPos = ocam + odir * odst.x;
	float3 rayDir = odir;
	float  rayFar = SGT_SphereTest(rayPos, rayDir, 1.0f).y;
	float  rayMax = min(odst.y, omax) - odst.x;
	
	#if _SGT_LIGHTING
		float3 sunDir = normalize(mul(_SGT_WorldToSky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
	#else
		float3 sunDir = normalize(rayPos);
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	#if _SGT_LIGHTING
		float3 lighting = 0.0f;
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting += _SGT_LightColor[i].xyz;
		}
	#else
		float3 lighting = 1.0f;
	#endif
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		lighting *= GetCurrentExposureMultiplier();
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither); // Something about this is a little wrong and causes color brightness pops when near ocean on massive planets
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	float3 skyColor = color.xyz; // Why doesn't this work properly? it causes brightness pops with altitude
	//float3 skyColor   = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	#if _SGT_LIGHTING && _SSS_HDRP
		lighting *= 0.25;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist         = min(-surfaceDistance, worldEyeDepth);
		float blurStrength = 1.0 - exp(-dist * _SGT_SurfaceDensity * 0.1);
		float opacity      = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			
				float3 refractDir  = refract(-d.worldSpaceViewDir, surfaceNormal, waterIOR / airIOR);
				float2 refractedUV = SGT_ProjectWorldToScreen(d.worldSpacePosition + refractDir * _SGT_RefractionDistance);
			
				refractedUV = saturate(refractedUV);
			
				d.extraV2F1.xyz += length(refractDir) > 0.0f ? color.xyz : 0.0f;
			#endif
			
			d.extraV2F1.xyz *= oceanTransmittance;
			
			d.extraV2F0.xyz  = oceanTransmittance; // Darken post lighting color
			d.extraV2F1.xyz += oceanScatter;
		}
		else // Sea floor
		{
			float blurStrength = 1.0 - exp(-dist * _SGT_SurfaceDensity * 0.1);
			
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition, blurStrength);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_FixRefractedUV(d.screenUV, SGT_ProjectWorldToScreen(refractedWP));
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float blurStrength = 1.0 - exp(-dist * _SGT_SurfaceDensity * 0.1);
		float shoreClip    = 1.0 - exp(-dist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo        = 0.0f;
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition, blurStrength);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-dist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_ShoreBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance) * _SGT_FadeOpacity.x;
		#endif
		
		#if _SGT_FASTSSR
			float3 reflectedColor = SGT_SurfaceSSR(d.screenUV, d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, wmax, color.xyz, sunDir, dither, lighting);
			float cosTheta = clamp(dot(d.worldSpaceViewDir, d.worldSpaceNormal), 0.0, 1.0);
			float F0 = pow((waterIOR / airIOR - 1.0) / (waterIOR / airIOR + 1.0), 2.0);

			float fresnel = F0 + (1.0 - F0) * pow(1.0 - cosTheta, _SGT_FssrFresnel);
		
			d.extraV2F1.xyz = lerp(d.extraV2F1.xyz, reflectedColor, fresnel * _SGT_FadeOpacity.x);
		#endif
		
		d.extraV2F0.xyz = 1.0f * (1.0f - color.w); // Use Unity lighting result as-is
		d.extraV2F1.xyz = d.extraV2F1.xyz * (1.0f - color.w) + color.xyz * color.w; // Fade out water contributions based on atmosphere/cloud opacity, and then add atmmosphere/cloud contribution
	}
	else // Nothing - use sky color directly
	{
		d.extraV2F0.xyz = 0.0;
		d.extraV2F1.xyz = color.xyz;
		
		o.Alpha = color.w;
	}
}

half4 SSS_FinalColorModifier(half4 color, float4x4 extra)
{
	color.xyz *= extra[0].xyz;
	color.xyz += extra[1].xyz;
	
	#if _SSS_HDRP
		color.xyz *= color.w;
	#endif
	
	return color;
}