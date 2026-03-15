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

	[HideInInspector] _SGT_SwapData("", Vector) = (0,0,0,0)

	[Header(SUBSURFACE SCATTERING)]
	[Toggle(_SGT_SUBSURFACE_SCATTERING)] _SGT_SurfsurfaceScattering ("	Enable", Float) = 0
	_SGT_SubsurfaceRange("	Range", Float) = 10
	
	[Header(CROSS IMPOSTOR)]
	[Toggle(_SGT_CROSS_IMPOSTOR)] _SGT_CrossImpostor ("	Enable", Float) = 0
	_SGT_DitherStart ("	Dither Start", Range(0, 1)) = 0.7
	_SGT_DitherEnd ("	Dither End", Range(0, 1)) = 0.1
	_SGT_BoundsOffset ("	Bounds Offset", Vector) = (0,0,0,0)
	_SGT_BoundsExtents ("	Bounds Extents", Vector) = (1,1,1,0)
	_SGT_AxisWorldHalf0 ("	Axis 0 World Half", Vector) = (1,1,0,0)
	_SGT_AxisWorldHalf1 ("	Axis 1 World Half", Vector) = (1,1,0,0)
	_SGT_AxisWorldHalf2 ("	Axis 2 World Half", Vector) = (1,1,0,0)
	_SGT_Expand ("	Expand", Float) = 0.0

	[Header(WIND ANIMATION)]
	[Toggle(_SGT_WIND)] _SGT_Wind ("	Enable", Float) = 0
	_SGT_WindHeightScale ("	Height Scale", Float) = 1.0
	_SGT_WindCoordCenter ("	Coord Gradient (xy = start/0, zw = end/1)", Vector) = (0,0, 0,0)
END_PROPERTIES

BEGIN_CBUFFER
	float4 _Color;
	float  _BumpScale;
	float  _Metallic;
	float  _GlossMapScale;
	float3 _Emission;
	float2 _Tiling;

	float _SGT_SubsurfaceRange;

	float2 _SGT_SwapData;

	float  _SGT_WindHeightScale;
	float4 _SGT_WindCoordCenter;

	float _SGT_DitherStart;
	float _SGT_DitherEnd;
	float4 _SGT_BoundsOffset;
	float4 _SGT_BoundsExtents;
	float4 _SGT_AxisWorldHalf0;
	float4 _SGT_AxisWorldHalf1;
	float4 _SGT_AxisWorldHalf2;
	float _SGT_Expand;
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_SUBSURFACE_SCATTERING
	#pragma shader_feature_local _SGT_CROSS_IMPOSTOR
	#pragma shader_feature_local _SGT_WIND
	#pragma multi_compile __ CW_COMPRESS_POSITIONS
END_DEFINES

#if _SSS_PASS_SHADOWCASTER || _SSS_PASS_META
	#pragma multi_compile_instancing
#endif

#define WIND_LAYER_COUNT 4
#define BATCH_SIZE       1000

#pragma instancing_options procedural:SetupInstancing

sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _MetallicGlossMap;
sampler2D _EmissionMap;

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	float4x4 _SGT_ObjectToWorld;
	float4  _SGT_ImpostorDataA[BATCH_SIZE];
	float4  _SGT_ImpostorDataB[BATCH_SIZE];
	float4  _SGT_ImpostorDataC[BATCH_SIZE]; // x = 0..1 RNG, y = TileID, z = 1/SwapFalloff, w = Opacity +- Crossfade Flag
#else
	float4 _SGT_ImpostorDataC; // x = 0..1 RNG, y = 0, z = 0, w = 0
#endif

float4 _SGT_TileOpacities[BATCH_SIZE / 4];

float4 _SGT_WindDataA[WIND_LAYER_COUNT]; // xyz = spatial offset (time-advanced), w = unused
float4 _SGT_WindDataB[WIND_LAYER_COUNT]; // xyz = direction (normalized), w = amplitude

float GetTileOpacity(int index)
{
	return _SGT_TileOpacities[index >> 2][index & 3];
}

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

float FastSin(float x)
{
	x = x - floor(x * 0.159154943 + 0.5) * 6.283185307;
	float x2 = x * x;
	return x * (1.0f - x2 * (0.166666667 - x2 * (0.008333333 - x2 * 0.000198413)));
}

void ApplyWind(inout float3 worldPos, float weight)
{
	float w = weight * weight;
	float3 d = 0;

	[unroll]
	for (int i = 0; i < WIND_LAYER_COUNT; i++)
	{
		float phase = dot(worldPos, _SGT_WindDataA[i].xyz) + _SGT_WindDataA[i].w;
		float wave = 0.60 + 0.35 * FastSin(phase) + 0.12 * FastSin(phase * 2.3 + 1.7);
		d += _SGT_WindDataB[i].xyz * (wave * _SGT_WindDataB[i].w);
	}

	worldPos += d * w;
}

float Bayer8(float2 p)
{
	uint2 i  = (uint2)p & 7u;
	uint  xr = i.x ^ i.y;
	uint  v  = (xr  & 1u) << 5u
			 | (i.y & 1u) << 4u
			 | (xr  & 2u) << 2u
			 | (i.y & 2u) << 1u
			 | (xr  & 4u) >> 1u
			 | (i.y & 4u) >> 2u;
	return (v + 0.5) / 64.0;
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
	float  transmission = pow(abs(VdotBL), SSS_Power) * SSS_Scale + SSS_Ambient * lightMask;
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

float4x4 BuildTRS(float4 posScale, float4 q)
{
	float x = q.x, y = q.y, z = q.z, w = q.w;
	float x2 = x + x, y2 = y + y, z2 = z + z;

	float xx = x * x2, xy = x * y2, xz = x * z2;
	float yy = y * y2, yz = y * z2, zz = z * z2;
	float wx = w * x2, wy = w * y2, wz = w * z2;

	float s = posScale.w;
	float3 t = posScale.xyz;

	return float4x4(
		s * (1 - (yy + zz)),  s * (xy - wz),         s * (xz + wy),         t.x,
		s * (xy + wz),         s * (1 - (xx + zz)),   s * (yz - wx),         t.y,
		s * (xz - wy),         s * (yz + wx),         s * (1 - (xx + yy)),   t.z,
		0,                     0,                      0,                      1
	);
}

float LinearGradient01(float2 uv, float4 coords)
{
	float2 dir = coords.zw - coords.xy;
	float len2 = max(dot(dir, dir), 1e-6);
	return saturate(dot(uv - coords.xy, dir) / len2);
}

void SSS_Vert(inout SSS_VertexData v)
{
	float windWeight = saturate(v.position.y * _SGT_WindHeightScale) + LinearGradient01(v.texcoord0.xy, _SGT_WindCoordCenter);
	#if _SGT_CROSS_IMPOSTOR
		v.position += v.normal * _SGT_Expand;
	#endif
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	float4x4 localToGlobal = BuildTRS(_SGT_ImpostorDataA[unity_InstanceID], _SGT_ImpostorDataB[unity_InstanceID]);
	float4x4 combinedMat   = mul(_SGT_ObjectToWorld, localToGlobal);
	
	v.position    = mul(combinedMat, float4(v.position, 1.0));
	v.normal      = normalize(mul((float3x3)combinedMat, v.normal));
	v.tangent.xyz = normalize(mul((float3x3)combinedMat, v.tangent.xyz));
	
	float3 pivotWS = float3(combinedMat[0][3], combinedMat[1][3], combinedMat[2][3]);
	
	#if _SGT_WIND
		ApplyWind(v.position, windWeight);
	#endif
	
	#if _SGT_CROSS_IMPOSTOR
		// 1. Calculate world space view direction from the bounds center
		float3 boundsCenterWS = pivotWS + mul((float3x3)combinedMat, _SGT_BoundsOffset.xyz);
		float3 viewDirWS = normalize(_WorldSpaceCameraPos - boundsCenterWS);
		
		// 2. Extract world-space local axes from the matrix columns
		float3 localX = normalize(float3(combinedMat[0][0], combinedMat[1][0], combinedMat[2][0]));
		float3 localY = normalize(float3(combinedMat[0][1], combinedMat[1][1], combinedMat[2][1]));
		float3 localZ = normalize(float3(combinedMat[0][2], combinedMat[1][2], combinedMat[2][2]));
		
		// 3. Dot product gives the absolute local view direction (avoids matrix inverse!)
		v.extraV2F0.xyz = abs(float3(dot(viewDirWS, localX), dot(viewDirWS, localY), dot(viewDirWS, localZ)));
	#else
		v.extraV2F0.xyz = 0.0;
	#endif
	
	float  tileID     = _SGT_ImpostorDataC[unity_InstanceID].y;
	float  opacity    = abs(_SGT_ImpostorDataC[unity_InstanceID].w) * GetTileOpacity(tileID);
	float  isPrefab   = step(_SGT_ImpostorDataC[unity_InstanceID].w, 0.0);
#else
	float3 pivotWS = SSS_ObjectToWorld(float3(0.0, 0.0, 0.0));
	
	#if _SGT_WIND
		float3 positionW = SSS_ObjectToWorld(v.position);
		ApplyWind(positionW, windWeight);
		v.position = SSS_WorldToObject(positionW);
	#endif
	
	#if _SGT_CROSS_IMPOSTOR
		float3 boundsCenterWS = SSS_ObjectToWorld(_SGT_BoundsOffset.xyz);
		float3 viewDirWS = normalize(_WorldSpaceCameraPos - boundsCenterWS);
		
		// Extract world-space local axes securely to handle varying macros
		float3 localX = normalize(SSS_ObjectToWorld(float3(1,0,0)) - pivotWS);
		float3 localY = normalize(SSS_ObjectToWorld(float3(0,1,0)) - pivotWS);
		float3 localZ = normalize(SSS_ObjectToWorld(float3(0,0,1)) - pivotWS);
		
		v.extraV2F0.xyz = abs(float3(dot(viewDirWS, localX), dot(viewDirWS, localY), dot(viewDirWS, localZ)));
	#else
		v.extraV2F0.xyz = 0.0;
	#endif
	
	float  opacity  = 1.0;
	float  isPrefab = 1.0;
#endif
	float dist = distance(pivotWS, _WorldSpaceCameraPos);
	
	// If swapRange is 0 (default/uninitialized), we assume the object is always "in range" (fade = 1)
	float fade = (_SGT_SwapData.x > 0.0) ? saturate((_SGT_SwapData.x - dist) * _SGT_SwapData.y) : 1.0;

#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	// Procedural instances are invisible if opacity is 0 (uninitialized)
	v.extraV2F0.w = opacity * (1.0 - (fade * isPrefab));
#else
	// Normal prefabs are 100% visible (w = 0) if opacity is 0 (uninitialized).
	// Otherwise, we calculate the dither threshold (1.0 = hidden, 0.0 = visible)
	v.extraV2F0.w = (opacity > 0.0) ? (1.0 - (opacity * fade)) : 0.0;
	
	v.extraV2F0.w -= step(0.001, v.extraV2F0.w) * 0.02; // Instance and prefab positions may be slightly off due to floating point precision, so add a bias to make the crossfade overlap
#endif
	
	#if CW_COMPRESS_POSITIONS
		float3 wpos = SSS_ObjectToWorld(v.position);
		wpos = SSS_CompressWorld(wpos);
		v.position = SSS_WorldToObject(wpos);
	#endif
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	#if CW_COMPRESS_POSITIONS
		d.worldSpacePosition = SSS_DecompressWorld(d.worldSpacePosition);
		d.worldSpaceViewDir  = normalize(_WorldSpaceCameraPos - d.worldSpacePosition);
	#endif
	
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
		float weight = saturate(1.0 - distance(d.worldSpacePosition, _WorldSpaceCameraPos) / _SGT_SubsurfaceRange);
		ApplyLeafFakeLighting(d.worldSpaceNormal, sunDir, d.worldSpaceViewDir, sunCol, d.vertexColor.x, pow(abs(texMain.y), 1.5) * weight, o.Albedo, o.Emission);
	#endif
	
	#if _SGT_CROSS_IMPOSTOR
		int axis = (int)(d.texcoord1.x * 6.0 + 0.25) / 2;
	
		// Fetch pre-computed absolute dot products directly from the vertex shader interpolator
		float3 absDots = d.extraV2F0.xyz;

		float3 areas = float3(
			_SGT_AxisWorldHalf0.x * _SGT_AxisWorldHalf0.y,
			_SGT_AxisWorldHalf1.x * _SGT_AxisWorldHalf1.y,
			_SGT_AxisWorldHalf2.x * _SGT_AxisWorldHalf2.y);
		float3 areaWeight  = areas / max(max(areas.x, max(areas.y, areas.z)), 1e-4);
		float3 importance  = absDots * areaWeight;

		float maxImp    = max(importance.x, max(importance.y, importance.z));
		float dominance = importance[axis] / max(maxImp, 1e-4);
		float blend     = smoothstep(_SGT_DitherEnd, _SGT_DitherStart, dominance);
		blend = pow(abs(blend), lerp(2.5, 1.0, areaWeight[axis]));

		float dither    = Bayer8(screenPx + axis * float2(37.0, 53.0));

		o.Alpha *= absDots[axis] > 0.02 && blend > dither;
	#endif
	
#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
	o.Alpha *= step(Bayer8(screenPx), d.extraV2F0.w);
	
	o.Smoothness *= 0;//saturate(o.Normal.z); // Remove fireflies from billboards
#else
	o.Alpha *= step(d.extraV2F0.w, Bayer8(screenPx));
#endif
}