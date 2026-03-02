BEGIN_PROPERTIES
	[NoScaleOffset]_MainTex ("Albedo", 2D) = "white" {}
	[NoScaleOffset][Normal]_BumpMap ("Normal", 2D) = "bump" {}
	[NoScaleOffset]_MetallicGlossMap("Metallic (R) Occlusion (G) Smoothness (B)", 2D) = "white" {}
	[NoScaleOffset]_EmissionMap("Emission (RGB)", 2D) = "white" {}

	_Color("Color", Color) = (1,1,1,1)
	_BumpScale("Normal Map Strength", Range(0,5)) = 1
	_Metallic("Metallic", Range(0,1)) = 0
	_GlossMapScale("Smoothness", Range(0,1)) = 1
	_Emission("Emission", Color) = (0,0,0)
	_Tiling("Tiling (XY)", Vector) = (1,1,0,0)

	[Header(SUBSURFACE SCATTERING)]
	[Toggle(_SGT_SUBSURFACE_SCATTERING)] _SGT_SurfsurfaceScattering ("	Enable", Float) = 0
	_SGT_SurfsurfaceRange("	Range", Float) = 10
	
	[Header(CROSS IMPOSTOR)]
	[Toggle(_SGT_CROSS_IMPOSTOR)] _SGT_CrossImpostor ("	Enable", Float) = 0
	_SGT_DitherStart ("	Dither Start", Range(0, 1)) = 0.7
	_SGT_DitherEnd ("	Dither End", Range(0, 1)) = 0.1
	_SGT_BoundsOffset ("	Bounds Offset", Vector) = (0,0,0,0)
	_SGT_BoundsExtents ("	Bounds Extents", Vector) = (1,1,1,0)
	_SGT_AxisWorldHalf0 ("	Axis 0 World Half", Vector) = (1,1,0,0)
	_SGT_AxisWorldHalf1 ("	Axis 1 World Half", Vector) = (1,1,0,0)
	_SGT_AxisWorldHalf2 ("	Axis 2 World Half", Vector) = (1,1,0,0)
END_PROPERTIES

BEGIN_CBUFFER
	float4 _Color;
	float  _BumpScale;
	float  _Metallic;
	float  _GlossMapScale;
	float3 _Emission;
	float2 _Tiling;

	float _SGT_SurfsurfaceRange;

	float _SGT_DitherStart;
	float _SGT_DitherEnd;
	float4 _SGT_BoundsOffset;
	float4 _SGT_BoundsExtents;
	float4 _SGT_AxisWorldHalf0;
	float4 _SGT_AxisWorldHalf1;
	float4 _SGT_AxisWorldHalf2;
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_SUBSURFACE_SCATTERING
	#pragma shader_feature_local _SGT_CROSS_IMPOSTOR
END_DEFINES

#if _SSS_PASS_SHADOWCASTER || _SSS_PASS_META
	#pragma multi_compile_instancing
#endif

#pragma instancing_options procedural:SetupInstancing

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _MetallicGlossMap;
sampler2D _EmissionMap;

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	float4x4 _SGT_ObjectToWorld;
	float4x4 _SGT_WorldToObject;
	float4x4 _SGT_LocalToGlobal[128];
	float4x4 _SGT_GlobalToLocal[128];
	float4   _SGT_ImpostorData[128]; // x = 0..1 RNG, y = SwapRange, z = 1/SwapFalloff, w = Crossfade Flag
#else
	float4 _SGT_ImpostorData; // x = 0..1 RNG, y = SwapRange, z = 1/SwapFalloff, w = Crossfade Flag
#endif

void SetupInstancing()
{
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		#ifdef unity_ObjectToWorld
			#undef unity_ObjectToWorld
		#endif

		#ifdef unity_WorldToObject
			#undef unity_WorldToObject
		#endif

		unity_ObjectToWorld = float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1);
		unity_WorldToObject = float4x4(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1);
	#endif
}

float Bayer8(float2 p)
{
	int2 i  = (int2)p & 7;
	int  xr = i.x ^ i.y;
	int  v  = (xr  & 1) << 5
			| (i.y & 1) << 4
			| (xr  & 2) << 2
			| (i.y & 2) << 1
			| (xr  & 4) >> 1
			| (i.y & 4) >> 2;
	return (v + 0.5) / 64.0;   // range [0.0078, 0.9922] instead of [0, 0.984]
}

void GetSun(out float3 lightDir, out float3 color)
{
	lightDir = float3(0.5, 0.5, 0);
	color = 1;
	#if _SSS_HDRP
		if (_DirectionalLightCount > 0)
		{
			DirectionalLightData light = _DirectionalLightDatas[0];
			lightDir = -light.forward.xyz;
			color = light.color;
		}
	#elif _SSS_BIRP
			lightDir = normalize(_WorldSpaceLightPos0.xyz);
		color = _LightColor0.rgb;
	#elif _SSS_URP
		Light light = GetMainLight();
		lightDir = light.direction;
		color = light.color;
	#endif
}

void ApplyLeafFakeLighting(
	float3 N,
	float3 L,
	float3 V,
	float3 lightColor,
	float  sssFactor,
	float  thickness,
	inout float3 albedo,
	inout float3 emission)
{
	// Tweak these
	float  SSS_Distortion   = 0.2;
	float  SSS_Power        = 4.0;
	float  SSS_Scale        = 2.5;
	float  SSS_Ambient      = 0.05;
	float3 SSS_Color        = float3(0.6, 0.8, 0.2);
	float  BackTransmit_Str = 0.3;
	float  AmbientFill_Str  = 0.5;
	float  AlbedoBoost_Str  = 0.3;

	// Gate everything on light intensity - nothing emits in the dark
	float lightLuminance = dot(lightColor, float3(0.299, 0.587, 0.114));
	float lightMask      = saturate(lightLuminance);

	// 1. SSS emission (view-dependent back-lighting)
	float3 backLitDir   = normalize(-L + N * SSS_Distortion);
	float  VdotBL       = saturate(dot(V, backLitDir));
	float  transmission = pow(VdotBL, SSS_Power) * SSS_Scale + SSS_Ambient * lightMask;
	transmission       *= sssFactor * thickness;
	float3 sssEmission  = transmission * SSS_Color * lightColor;

	// 2. Back-face transmission (view-independent)
	float  NdotL_back   = saturate(dot(-N, L));
	float3 backTransmit = NdotL_back * thickness * sssFactor * SSS_Color * lightColor * BackTransmit_Str;

	// 3. Ambient fill - scaled by light so it disappears at night
	float  skyBlend    = saturate(N.y * 0.5 + 0.5);
	float3 ambientFill = lerp(float3(0.08, 0.12, 0.02),
							  float3(0.06, 0.08, 0.14),
							  skyBlend);
	ambientFill *= albedo * sssFactor * AmbientFill_Str * lightMask;

	// 4. Albedo boost (fake wrap lighting)
	float  NdotL   = saturate(dot(N, L));
	float  wrapFake = saturate(1.0 - NdotL);
	albedo         *= 1.0 + wrapFake * sssFactor * AlbedoBoost_Str * lightMask;

	// 5. Combine emission
	emission += sssEmission + backTransmit + ambientFill;
}

void SSS_Vert(inout SSS_VertexData v)
{
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	float4x4 combinedMat = mul(_SGT_ObjectToWorld, _SGT_LocalToGlobal[unity_InstanceID]);
	float4x4 combinedInv = mul(_SGT_GlobalToLocal[unity_InstanceID], _SGT_WorldToObject);
	
	v.position    = mul(combinedMat, float4(v.position, 1.0));
	v.normal      = normalize(mul((float3x3)combinedMat, v.normal));
	v.tangent.xyz = normalize(mul((float3x3)combinedMat, v.tangent.xyz));
	
	v.extraV2F0.xyz = mul(combinedInv, float4(_WorldSpaceCameraPos, 1.0)).xyz;
	
	float3 pivotWS = float3(combinedMat[0][3], combinedMat[1][3], combinedMat[2][3]);
#else
	v.extraV2F0.xyz = SSS_WorldToObject(_WorldSpaceCameraPos);
	
	float3 pivotWS = SSS_ObjectToWorld(float3(0.0, 0.0, 0.0));
#endif
	
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		float swapRange  = _SGT_ImpostorData[unity_InstanceID].y;
		float invFalloff = _SGT_ImpostorData[unity_InstanceID].z;
		float crossfade  = _SGT_ImpostorData[unity_InstanceID].w;
	#else
		float swapRange  = _SGT_ImpostorData.y;
		float invFalloff = _SGT_ImpostorData.z;
		float crossfade  = _SGT_ImpostorData.w;
	#endif

	float dist = distance(pivotWS, _WorldSpaceCameraPos);
	float fade = saturate((swapRange - dist) * invFalloff);
	
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		v.extraV2F0.w = (crossfade > 0.5) ? 1.0 - fade : 1.0;
	#else
		v.extraV2F0.w = (crossfade > 0.5) ? 1.0 - fade : 0.0;
		v.extraV2F0.w -= step(0.001, v.extraV2F0.w) * 0.02; // Instance and prefab positions may be slightly off due to floating point precision, so add a bias to make the crossfade overlap
	#endif
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float2 uv       = d.texcoord0.xy * _Tiling;
	float4 texMain  = tex2D(_MainTex, uv);
	float4 gloss    = tex2D(_MetallicGlossMap, uv);
	float4 bump     = tex2D(_BumpMap, uv);
	float4 glow     = tex2D(_EmissionMap, uv);
	float2 screenPx = d.screenPos.xy / d.screenPos.w * _ScreenParams.xy;
	
	float3 sunDir;
	float3 sunCol;
	GetSun(sunDir, sunCol);
	

	o.Albedo     = texMain.rgb * _Color.rgb * d.vertexColor.x;
	o.Normal     = SSS_UnpackNormalScale(bump, _BumpScale);
	o.Metallic   = gloss.r * _Metallic;
	o.Occlusion  = gloss.g;
	o.Smoothness = gloss.b * _GlossMapScale;
	o.Emission   = glow.rgb * _Emission;
	o.Alpha      = texMain.a * _Color.a;
	
	o.Normal.xy = d.isFrontFace ? o.Normal.xy : -o.Normal.xy;
	
	#if _SGT_SUBSURFACE_SCATTERING
		float weight = saturate(1.0 - distance(d.worldSpacePosition, _WorldSpaceCameraPos) / _SGT_SurfsurfaceRange);
		ApplyLeafFakeLighting(d.worldSpaceNormal, sunDir, d.worldSpaceViewDir, sunCol, d.vertexColor.x, pow(texMain.y, 1.5) * weight, o.Albedo, o.Emission);
	#endif
	
#if _SGT_CROSS_IMPOSTOR
	int axis = (int)(d.texcoord1.x * 6.0 + 0.25) / 2;
	
	float3 viewDirOS   = normalize(d.extraV2F0.xyz - _SGT_BoundsOffset.xyz);
	float3 absDots     = abs(viewDirOS);

	float3 areas = float3(
		_SGT_AxisWorldHalf0.x * _SGT_AxisWorldHalf0.y,
		_SGT_AxisWorldHalf1.x * _SGT_AxisWorldHalf1.y,
		_SGT_AxisWorldHalf2.x * _SGT_AxisWorldHalf2.y);
	float3 areaWeight  = areas / max(max(areas.x, max(areas.y, areas.z)), 1e-4);
	float3 importance  = absDots * areaWeight;

	float maxImp    = max(importance.x, max(importance.y, importance.z));
	float dominance = importance[axis] / max(maxImp, 1e-4);
	float blend     = smoothstep(_SGT_DitherEnd, _SGT_DitherStart, dominance);
	blend = pow(blend, lerp(2.5, 1.0, areaWeight[axis]));

	float dither    = Bayer8(screenPx + axis * float2(37.0, 53.0));

	o.Alpha *= absDots[axis] > 0.02 && blend > dither;
#endif
	
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		o.Alpha *= step(Bayer8(screenPx), d.extraV2F0.w);
	#else
		o.Alpha *= step(d.extraV2F0.w, Bayer8(screenPx));
	#endif
}