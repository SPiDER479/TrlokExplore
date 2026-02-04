BEGIN_PROPERTIES
	[KeywordEnum(Square, Sphere)] _SGT_Shape ("Shape", Float) = 0
	
	[Header(CLOUDS)]
	[Toggle(_SGT_CLOUDS)] _SGT_Clouds("	Enable", Float) = 0
	[HideInInspector] [NoScaleOffset] _SGT_CloudShadowTex("", 2D) = "black" {}
	[HideInInspector] _SGT_CloudShadowDirection("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_CloudShadowOpacity("", Vector) = (0,0,0,0)
	
	[Header(OCEAN FADE)]
	[Toggle(_SGT_OCEAN_FADE)] _SGT_OceanFade("	Enable", Float) = 0
	[HideInInspector] _SGT_OceanDistance("", Vector) = (0,0,0,0)
	[HideInInspector] _SGT_OceanColor("", Color) = (0,0,0)
	[HideInInspector] _SGT_OceanSmoothness("", Float) = 0
	[HideInInspector] _SGT_OceanLightDirection("", Vector) = (0,0,0,0)
END_PROPERTIES

BEGIN_CBUFFER
END_CBUFFER

BEGIN_DEFINES
	#pragma shader_feature_local _SGT_SHAPE_SQUARE _SGT_SHAPE_SPHERE
	#pragma shader_feature_local _SGT_CLOUDS_OFF _SGT_CLOUDS
	#pragma shader_feature_local _SGT_OCEAN_FADE_OFF _SGT_OCEAN_FADE
END_DEFINES

#pragma instancing_options procedural:SetupInstancing
#if _SSS_PASS_SHADOWCASTER || _SSS_PASS_META
	#pragma multi_compile_instancing // For some reason the ShadowCaster and Meta pass in BIRP doesn't have this line
#endif


#define BATCH_CAPACITY 35
#define VERTEX_COUNT 243

float4 _CwSize;
float4 _CwAtlas;
float4 _CwWeights[VERTEX_COUNT];
float4 _CwCoords[VERTEX_COUNT];

float4 _CwOrigins[BATCH_CAPACITY];
float4 _CwPositionsA[BATCH_CAPACITY];
float4 _CwPositionsB[BATCH_CAPACITY];
float4 _CwPositionsC[BATCH_CAPACITY];

sampler2D DataP;
sampler2D DataA;
sampler2D DataN;

float3 _CwOffset;

float4x4 _CwObjectToWorld;
float4x4 _CwWorldToObject;

// CLOUDS
sampler2D _SGT_CloudShadowTex;
float3    _SGT_CloudShadowDirection;
float4    _SGT_CloudShadowOpacity;
float4x4  _SGT_CloudShadowMatrix;

// OCEAN FADE
float  _SGT_OceanFade;
float2 _SGT_OceanDensity;
float4 _SGT_OceanColor;
float  _SGT_OceanSmoothness;
float4 _SGT_OceanLightDirection;

float _SGT_OceanRadius;

void SetupInstancing()
{
	#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
		#ifdef unity_ObjectToWorld
			#undef unity_ObjectToWorld
		#endif

		#ifdef unity_WorldToObject
			#undef unity_WorldToObject
		#endif
		
		unity_ObjectToWorld = _CwObjectToWorld;
		unity_WorldToObject = _CwWorldToObject;
	#endif
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

float SGT_SampleCloudDensity(float3 wpos)
{
	float3 cpos  = mul(_SGT_CloudShadowMatrix, float4(wpos, 1.0f)).xyz;
	float3 chit  = SGT_SphereTest(cpos, _SGT_CloudShadowDirection, 1.0f);
	float2 uv    = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * _SGT_CloudShadowDirection));
	
	return saturate(dot(tex2D(_SGT_CloudShadowTex, uv), _SGT_CloudShadowOpacity));
}

void SSS_Vert(inout SSS_VertexData v)
{
	float vertexIndex = v.position.x;
	float squareIndex = v.position.y;
	float batchIndex  = v.instanceID;
	
	float  batchCol = batchIndex % _CwAtlas.z;
	float  batchRow = floor(batchIndex / _CwAtlas.z);
	float3 origin   = _CwOrigins[batchIndex].xyz;
	float3 weights  = _CwWeights[vertexIndex].xyz;
	float2 coord    = _CwCoords[vertexIndex].xy; coord.x /= 3.0f;
	float3 position = _CwPositionsA[batchIndex].xyz * weights.x + _CwPositionsB[batchIndex].xyz * weights.y + _CwPositionsC[batchIndex].xyz * weights.z;
	
	v.position.xyz = _CwOffset + origin + tex2Dlod(DataP, float4(vertexIndex * _CwSize.x, batchIndex * _CwSize.y, 0.0f, 0.0f)).xyz;
	
	float3 ocam = mul(_CwWorldToObject, float4(_WorldSpaceCameraPos - _CwOffset, 1.0f)).xyz;
	
	#if _SGT_SHAPE_SQUARE
		v.normal  = float3(0,1,0);
		v.tangent = float4(1,0,0,-1).xyz;
		
		v.extraV2F0.w = ocam.y;
	#elif _SGT_SHAPE_SPHERE
		v.normal = normalize(position);
		
		if (position.x == 0.0f && position.z == 0.0f)
		{
			position.xz += 0.00000001f;
		}
		
		v.tangent = float4(normalize(cross(float3(0,1,0), normalize(position))), -1.0f).xyz;
		
		v.extraV2F0.w = length(ocam) - _SGT_OceanRadius;
	#endif
	
	#if _SGT_OCEAN_FADE
		if (_SGT_OceanFade > 0.0f && length(v.position.xyz - _CwOffset) < _SGT_OceanRadius)
		{
			float3 N = normalize(position); // sphere normal
			float3 V = normalize(_WorldSpaceCameraPos - v.position.xyz);
			float  F = pow(1.0 - saturate(dot(N, V)), 2.0);

			float3 oceanPos = _CwOffset + N * _SGT_OceanRadius;
			v.position.xyz = lerp(v.position.xyz, oceanPos, F);
		}

	#endif
	
	// Calc UV
	float2 pixelS = _CwAtlas.xy * _CwAtlas.zw;
	float  pixelX = batchCol * _CwAtlas.x + coord.x * (_CwAtlas.x - 3.0f) + 0.5f + squareIndex * (_CwAtlas.x / 3.0f);
	float  pixelY = batchRow * _CwAtlas.y + coord.y * (_CwAtlas.y - 1.0f) + 0.5f;
	
	v.extraV2F0.x = pixelX / pixelS.x;
	v.extraV2F0.y = pixelY / pixelS.y;
}

float3 SGT_GetColor(float3 wnormal, float3 wlight)
{
	return saturate(dot(wnormal, wlight));
}

static const float WATER_DEPTH_SHALLOW = 30.0f;
static const float WATER_DEPTH_MAX = 3000.0f;

float SGT_DecodeWaterDepth(float encoded)
{
	float shallow = encoded * (WATER_DEPTH_SHALLOW * 2.0f);
    float deep = WATER_DEPTH_SHALLOW + (encoded - 0.5f) * ((WATER_DEPTH_MAX - WATER_DEPTH_SHALLOW) * 2.0f);
    float isDeep = step(0.5f, encoded);
    return lerp(shallow, deep, isDeep);
}

float3 SGT_ApplyOceanColor(
    float3 terrainColor,
    float  waterDepth01,
    float3 waterColor,
    float2 waterDensity,
    float  waterBlend,
    float3 ambientColor)
{
    float depth = SGT_DecodeWaterDepth(waterDepth01);
    float3 w = float3(1.0, 0.2, 0.1);

    float3 e0 = w * waterDensity.x;
    float3 e1 = w * waterDensity.y;

    float3 floorT0  = exp(-e0 * depth);
    float3 volumeT0 = exp(-e0 * depth * 3.0);

    float3 floorT1  = exp(-e1 * depth);
    float3 volumeT1 = exp(-e1 * depth * 3.0);

    float3 col0 = terrainColor * floorT0 + (waterColor * ambientColor) * (1.0 - volumeT0);
    float3 col1 = terrainColor * floorT1 + (waterColor * ambientColor) * (1.0 - volumeT1);

    return lerp(col0, col1, waterBlend);
}

float SGT_Bayer4x4(float2 screenPos)
{
	int2 p = int2(screenPos * _ScreenParams.xy) % 4;
	float bayer[16] = { 0,  8,  2, 10, 12,  4, 14,  6, 3, 11,  1,  9, 15,  7, 13,  5 };
	return (bayer[p.x + p.y * 4] + 0.5) / 16.0;
}

void SSS_Frag(inout SSS_SurfaceData o, inout SSS_FragmentData d)
{
	float4 dataA = tex2Dlod(DataA, float4(d.extraV2F0.xy,0,0));
	float4 dataN = tex2Dlod(DataN, float4(d.extraV2F0.xy,0,0)); dataN.xy = dataN.xy * 2.0f - 1.0f;
	
	dataN.x = -dataN.x; // Don't set negative tangent sign, so do it manually
	
	o.Albedo     = dataA.xyz;
	o.Occlusion  = 1.0f;
	o.Emission   = dataA.xyz * dataN.z;
	o.Smoothness = dataN.w;
	o.Metallic   = 0.0f;
	o.Normal     = float3(dataN.xy, sqrt(1.0f - saturate(dot(dataN.xy, dataN.xy))));
	
	float localEyeHeight = d.extraV2F0.w;
	
	#if _SGT_OCEAN_FADE
		float fadeTransition = step(SGT_Bayer4x4(d.screenUV), _SGT_OceanFade);
	
		float cameraDistance = distance(d.worldSpacePosition, _WorldSpaceCameraPos);
		float cameraDist01   = 1.0 - pow(saturate(1.0 - cameraDistance / _SGT_OceanRadius), 8.0);
		float3 oceanColor    = SGT_ApplyOceanColor(o.Albedo, dataA.w, _SGT_OceanColor, _SGT_OceanDensity, cameraDist01, 1.0);
	
		float fade = saturate(dataA.w > 0) * fadeTransition;
	
		o.Albedo     = lerp(o.Albedo, oceanColor, fade);
		o.Smoothness = lerp(o.Smoothness, _SGT_OceanSmoothness, fade);
		o.Normal     = lerp(o.Normal, float3(0.0f, 0.0f, 1.0f), fade);
	#endif
	
	#if _SGT_CLOUDS
		float  shadow = SGT_SampleCloudDensity(d.worldSpacePosition);
		
		o.Albedo    = lerp(o.Albedo   , 0.0f, shadow);
		o.Occlusion = lerp(o.Occlusion, 0.0f, shadow);
	#endif
}