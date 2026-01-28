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
	
	[Header(DITHER)]
	[Toggle(_SGT_DITHER)] _SGT_Dither("	Enable", Float) = 0
	
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
	
	[Header(FAST SSR)]
	[Toggle(_SGT_FASTSSR)] _SGT_FastSSR("	Enable", Float) = 0
	_SGT_FssrFresnel("	Fresnel", Range(4, 32)) = 10

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
	#pragma shader_feature_local _SGT_DITHER_OFF _SGT_DITHER
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

// FAST SSR
float _SGT_FssrFresnel;

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

float CW_SampleCaustics(float3 worldPosition)
{
	float  slice     = _Time.y * _SGT_CausticsSpeed;
	float  delta     = SGT_Delta(worldPosition, 0);
	float  shore     = saturate(-delta * _SGT_CausticsTopSharpness);
	float  deep      = exp(min(0.0, delta) * _SGT_SurfaceDensity);
	float  lod       = pow(1.0 - deep, 1) * 4.0;
	worldPosition += tex3D(_SGT_NoiseTex, worldPosition * 0.1 + float3(0,0,_Time.x)).x * pow(1.0 - deep, 2.0) * 0.5;
	
	float2 posA      = mul(_SGT_CausticsMatrixA, float4(worldPosition, 1.0f)).xy;
	float2 posB      = mul(_SGT_CausticsMatrixB, float4(worldPosition, 1.0f)).xy;
	
	float  causticsA = tex3Dlod(_SGT_CausticsTexure, float4(posA, slice, lod)).x;
	float  causticsB = tex3Dlod(_SGT_CausticsTexure, float4(posB, slice, lod)).x;
	
	return lerp(causticsA, causticsB, _SGT_CausticsBlend) * shore * deep * _SGT_CausticsBrightness;
}

float3 SGT_SSR(float3 worldPos, float3 worldNormal, float3 worldViewDir, float worldEyeDepth, float surfaceDistance, float4 baseColor, float wmax)
{
	worldEyeDepth = min(worldEyeDepth, distance(_WorldSpaceCameraPos, _SGT_SphereData.xyz)); // Clip distance if there is no geometry
	
	float3 reflectedPos = worldPos + reflect(worldViewDir, worldNormal) * abs(worldEyeDepth - surfaceDistance);
	float2 uv           = SGT_ProjectWorldToScreen(reflectedPos);
	float2 edge         = saturate(1.0 - abs(uv * 2.0 - 1.0));
	float  fresnel      = pow(1.0 - saturate(dot(worldNormal, -worldViewDir)), _SGT_FssrFresnel);
	float  sceneDepth   = SSS_GetSceneWorldDistance(uv, SSS_GetSceneDepth(uv));
	
	if (sceneDepth < wmax)
	{
		baseColor.xyz = SSS_GetSceneColorHD(uv);
	}

	return baseColor.xyz * edge.x * edge.y * fresnel;
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
	float  sssPower      = 8.0;
	
	float fresnel = pow(saturate(1.0 - dot(viewDir, normal) - surfaceDistance * _SGT_ScatteringDistanceFade), sssPower);
	
	float heightWeight = saturate((waveHeight + _SGT_WaveData.z) * _SGT_WaveData.w);
	
	return fresnel * heightWeight * _SGT_SurfaceScattering.xyz * lightColor;
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
	float3 odir = normalize(ofar - ocam);
	float3 odst = SGT_SphereTest(ocam, odir, 1.0f);
	
	if (odst.z < 0.0f) discard; // Miss
	
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
	
	#if _SGT_DITHER
		float dither = SGT_DitherBlue(d.screenUV);
	#else
		float dither = 0.5f;
	#endif
	
	#if _SGT_ALBEDO
		float2 uv  = SGT_DirectionToEquirectangular(rayPos);
		float2 uvx = ddx(uv); uvx.x *= (abs(uvx.x) < 0.5f);
		float2 uvy = ddy(uv); uvy.x *= (abs(uvy.x) < 0.5f);
			
		tint = tex2Dgrad(_SGT_SkyAlbedoTex, uv, uvx, uvy).xyz;
	#endif
	
	float4 cloudColor;
	float  cloudDepth;
	
	CW_SampleVolumetrics(d.screenUV, -d.worldSpaceViewDir, wfar, cloudColor, cloudDepth);
	
	#if _SGT_LIGHTING
		float4 lighting = float4(0.0f, 0.0f, 0.0f, 1.0f);
		
		for (int i = 0; i < _SGT_LightCount; i++)
		{
			lighting.xyz += _SGT_LightColor[i].xyz;
		}
	#else
		float4 lighting = float4(1.0f, 1.0f, 1.0f, 1.0f);
	#endif
	
	float4 color = SGT_Atmosphere(rayPos, rayDir, rayFar, rayMax, sunDir, _SGT_SkyExposure, dither);
	
	// Boost opacity when near ground
	float skyWeight = rayMax * 1.02f > rayFar;//saturate(rayMax / rayFar); skyWeight = pow(skyWeight,16);
	float luminance = dot(color.xyz, float3(0.2126f, 0.7152f, 0.0722f));
	float boost     = dot(SGT_GetDensity2(rayPos), 1) * luminance * _SGT_SkyDepthOpaque;
	
	color.xyz *= lighting.xyz;
	color.w    = lerp(1.0f, color.a, exp(-boost * skyWeight));
	
	//float3 skyColor = color.xyz; // Why doesn't this work properly?
	float3 skyColor = SGT_AtmosphereColor(ocam, sunDir, dither);
	float3 skyAmbient = skyColor;
	
	if (cloudColor.w > 0.0f && (surfaceDistance == 0.0 || cloudDepth < abs(surfaceDistance)))
	{
		float3 cloudWPos = CW_Depth2World(cloudDepth, -d.worldSpaceViewDir);
		float3 cloudSPos = mul(_SGT_WorldToSky, float4(cloudWPos, 1.0f)).xyz;
		
		#if _SGT_LIGHTING && _SSS_HDRP
			lighting.xyz *= 0.25;
		#endif
		
		cloudColor.rgb *= SGT_AtmosphereColor(cloudSPos, sunDir, dither) * lighting.xyz; // Apply atmospheric lighting to clouds
		
		color.rgb *= color.a;
		cloudColor.rgb *= cloudColor.a;
		
		color.a += cloudColor.a * (1.0f - color.a);
		color.rgb = (cloudColor.rgb + color.rgb * (1.0 - cloudColor.a)) / max(color.a, 1e-6);
	}
	
	#if _SSS_HDRP && !_SSS_NO_DERIVATIVES
		color.xyz *= GetCurrentExposureMultiplier();
	#endif
	
	float3 oceanTransmittance;
	float3 oceanScatter;
	
	if (surfaceDistance < 0.0f) // Below ocean
	{
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = -surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float dist    = min(-surfaceDistance, worldEyeDepth);
		float opacity = 1.0;// - exp(-dist * _SGT_SurfaceDensity);
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, skyAmbient, worldCamUnderwater, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		o.Alpha      = 1.0;
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		if (abs(surfaceDistance) < worldEyeDepth) // Ocean surface
		{
			o.Albedo = 0.0;
			
			#if _SGT_REFRACTION
				#if _SGT_FASTSSR
					d.extraV2F1.xyz += SGT_UnderwaterSSR(d.worldSpacePosition, surfaceNormal, -d.worldSpaceViewDir, -worldEyeDepth, surfaceDistance, float4(_SGT_SurfaceColor.xyz, 1), wmax);
				#endif
			#endif
			
			#if _SGT_REFRACTION
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
			d.extraV2F0.xyz = 0.0; // Replace post lighting color with black
			d.extraV2F1.xyz = SSS_GetSceneColorHD(d.screenUV); // Begin with scene color
			
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz *= 1.0 + CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance + oceanScatter;
		}
	}
	else if (surfaceDistance > 0.0f && surfaceDistance < worldEyeDepth) // Above ocean
	{
		if (SGT_DitherBlue(d.screenUV) < _SGT_FadeOpacity.y)
		{
			o.Alpha = 0.0;
		}
		else
		{
			o.Alpha = 1.0;
		}
		o.Alpha = 1.0;
		
		// Override fragment data
		d.worldSpacePosition = worldHit;
		d.worldSpaceNormal   = surfaceNormal;
		d.worldSpaceTangent  = normalize(cross(float3(0,1,0), d.worldSpaceNormal));
		
		float originalDist = worldEyeDepth - surfaceDistance;
		
		#if _SGT_REFRACTION
			float3 refractDir      = refract(-d.worldSpaceViewDir, d.worldSpaceNormal, airIOR / waterIOR);
			float3 refractedWP     = d.worldSpacePosition + refractDir * _SGT_RefractionDistance;
			float2 refractedUV     = SGT_ProjectWorldToScreen(refractedWP);
			float3 refractedPos    = SSS_GetSceneWorldPosition(refractedUV, SSS_GetSceneDepth(refractedUV));
			float  refractedDist   = distance(_WorldSpaceCameraPos, refractedPos);
			float  refractedWeight = saturate(refractedDist - surfaceDistance);
		
			// Override values with refracted data
			d.screenUV       = lerp(d.screenUV, refractedUV, refractedWeight);
			worldEyePosition = lerp(worldEyePosition, refractedPos, refractedWeight);
			worldEyeDepth    = SSS_GetSceneWorldDistance(d.screenUV, SSS_GetSceneDepth(d.screenUV));
		#endif
		
		float dist         = worldEyeDepth - surfaceDistance;
		float opticalDepth = 1.0 - exp(-max(0.0f, dist) * _SGT_SurfaceDensity);
		float shoreClip    = 1.0 - exp(-originalDist * 100);
		
		o.Smoothness = _SGT_SurfaceSmoothness;
		
		GetOceanTransmittanceScatter(oceanTransmittance, oceanScatter, dist, -d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, lerp(1.0, skyAmbient, _SGT_FadeOpacity.x), 0.0, _SGT_SurfaceColor.xyz, _SGT_SurfaceDensity);
		
		#if _SGT_REFRACTION
			o.Albedo     = 0.0f;
			d.extraV2F1.xyz   = SSS_GetSceneColorHD(d.screenUV);
		
			#if _SGT_CAUSTICS
				d.extraV2F1.xyz += d.extraV2F1.xyz * CW_SampleCaustics(worldEyePosition);
			#endif
		
			d.extraV2F1.xyz = d.extraV2F1.xyz * oceanTransmittance;
		
			d.extraV2F1.xyz += oceanScatter;
		
			o.Albedo   = lerp(d.extraV2F1.xyz, o.Albedo, _SGT_FadeOpacity.x);
			d.extraV2F1.xyz = lerp(0.0, d.extraV2F1.xyz, _SGT_FadeOpacity.x);
		#else
			o.Albedo = _SGT_SurfaceColor.xyz * oceanTransmittance + oceanScatter;
		#endif
		
		#if _SGT_CLOUDS
			float shadow = SGT_SampleCloudDensity(d.worldSpacePosition, 0.0f);
			o.Albedo = lerp(o.Albedo, float3(0,0,0), shadow);
		#endif
		
		#if _SGT_SHORE
			float  stretch   = lerp(abs(dot(localViewDir, _SGT_PlaneData.xyz)), 1.0f, _SGT_ShoreBias);
			float3 shore     = exp(-originalDist * stretch * float3(10, 20, 40) * _SGT_ShoreWidth);
			float2 shorePosA = mul(_SGT_ShoreMatrixA, float4(worldHit, 1.0f)).xy;
			float2 shorePosB = mul(_SGT_ShoreMatrixB, float4(worldHit, 1.0f)).xy;
			float3 shoreTexA = tex2D(_SGT_ShoreTex, shorePosA).xyz;
			float3 shoreTexB = tex2D(_SGT_ShoreTex, shorePosB).xyz;
			float3 shoreTex  = lerp(shoreTexA, shoreTexB, _SGT_RipplesBlend);
			float  shoreFade = 1.0f - saturate(surfaceDistance / _SGT_ShoreDistance);
			
			o.Albedo = lerp(o.Albedo, 1.0f, saturate(dot(shoreTex, shore * shoreFade * shoreClip)));
		#endif
		
		#if _SGT_LIGHTING && _SGT_FASTSSS
			d.extraV2F1.xyz += SGT_CalculateOceanSSS(surfaceNormal, d.worldSpaceViewDir, _SGT_LightDirection[0].xyz, skyColor, waveHeight, surfaceDistance);
		#endif
		
		#if _SGT_FASTSSR
			d.extraV2F1.xyz += SGT_SSR(d.worldSpacePosition, d.worldSpaceNormal, -d.worldSpaceViewDir, worldEyeDepth, surfaceDistance, color, wmax) * _SGT_FadeOpacity.x;
		#endif
		
		d.extraV2F0.xyz = 1.0f; // Use Unity lighting result as-is
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