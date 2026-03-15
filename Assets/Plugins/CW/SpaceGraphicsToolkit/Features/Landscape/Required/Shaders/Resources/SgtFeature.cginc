#include "SgtShared.cginc"

struct a2v
{
	float4 vertex    : POSITION;
	float2 texcoord0 : TEXCOORD0;
};

struct v2f
{
	float4 vertex   : SV_POSITION;
	float4 pixel    : TEXCOORD0;
	float2 coord    : TEXCOORD1;
	float3 localPos : TEXCOORD2;
};

struct f2g
{
	float4 rgbo : SV_TARGET0;
	float4 nnes : SV_TARGET1;
};

#define VERTEX_COUNT 243

#define GLOBAL_DETAIL_CAPACITY 32
#define LOCAL_DETAIL_CAPACITY 32
#define GLOBAL_FLATTEN_CAPACITY 8
#define LOCAL_FLATTEN_CAPACITY 32
#define GLOBAL_COLOR_CAPACITY 8
#define LOCAL_COLOR_CAPACITY 32
#define HOLES_CAPACITY 64

int    _CwGlobalDetailCount;
float4 _CwGlobalDetailDataA[GLOBAL_DETAIL_CAPACITY];
float4 _CwGlobalDetailDataB[GLOBAL_DETAIL_CAPACITY];
float4 _CwGlobalDetailDataC[GLOBAL_DETAIL_CAPACITY];
float4 _CwGlobalDetailDataD[GLOBAL_DETAIL_CAPACITY];
float4 _CwGlobalDetailDataE[GLOBAL_DETAIL_CAPACITY];
float4 _CwGlobalDetailLayer[GLOBAL_DETAIL_CAPACITY];

int      _CwLocalDetailCount;
float4   _CwLocalDetailDataA[LOCAL_DETAIL_CAPACITY];
float4   _CwLocalDetailDataB[LOCAL_DETAIL_CAPACITY];
float4   _CwLocalDetailDataC[LOCAL_DETAIL_CAPACITY];
float4   _CwLocalDetailDataD[LOCAL_DETAIL_CAPACITY];
float4   _CwLocalDetailDataE[LOCAL_DETAIL_CAPACITY];
float4x4 _CwLocalDetailMatrix[LOCAL_DETAIL_CAPACITY];

int    _CwGlobalFlattenCount;
float4 _CwGlobalFlattenDataA[GLOBAL_FLATTEN_CAPACITY];
float4 _CwGlobalFlattenDataC[GLOBAL_FLATTEN_CAPACITY];

int      _CwLocalFlattenCount;
float4   _CwLocalFlattenDataA[LOCAL_FLATTEN_CAPACITY];
float4   _CwLocalFlattenDataC[LOCAL_FLATTEN_CAPACITY];
float4x4 _CwLocalFlattenMatrix[LOCAL_FLATTEN_CAPACITY];

int    _CwGlobalColorCount;
float4 _CwGlobalColorDataA[GLOBAL_COLOR_CAPACITY];
float4 _CwGlobalColorDataB[GLOBAL_COLOR_CAPACITY];
float4 _CwGlobalColorDataC[GLOBAL_COLOR_CAPACITY];
float4 _CwGlobalColorDataD[GLOBAL_COLOR_CAPACITY];
float4 _CwGlobalColorDataE[GLOBAL_COLOR_CAPACITY];

int      _CwLocalColorCount;
float4   _CwLocalColorDataA[LOCAL_COLOR_CAPACITY];
float4   _CwLocalColorDataB[LOCAL_COLOR_CAPACITY];
float4   _CwLocalColorDataC[LOCAL_COLOR_CAPACITY];
float4   _CwLocalColorDataD[LOCAL_COLOR_CAPACITY];
float4   _CwLocalColorDataE[LOCAL_COLOR_CAPACITY];
float4x4 _CwLocalColorMatrix[LOCAL_COLOR_CAPACITY];

UNITY_DECLARE_TEX2DARRAY(_CwHeightTopologyAtlas);
UNITY_DECLARE_TEX2DARRAY(_CwMaskTopologyAtlas);
UNITY_DECLARE_TEX2DARRAY(_CwGradientAtlas);
UNITY_DECLARE_TEX2DARRAY(_CwDetailAtlas);
float4 _CwHeightTopologyAtlasSize;
float4 _CwMaskTopologyAtlasSize;
float4 _CwGradientAtlasSize;
float4 _CwDetailAtlasSize;

sampler2D       _CwBufferP;
float4          _CwBufferSize;
float           _CwVertexResolution;
float2          _CwPixelSize;
float4x4        _CwMatrix;
float4          _CwCoords[VERTEX_COUNT];
float4          _CwWeights[VERTEX_COUNT];
float3          _CwOffset;

int      _CwHoleCount;
float4   _CwHoleDatas[HOLES_CAPACITY];
float4x4 _CwHoleMatrices[HOLES_CAPACITY];

void CW_ContributeTopo(inout float4 cur, float4 add, float replace, float mask)
{
	cur = lerp(cur, 0.0f, replace * mask) + add * mask;
}

void CW_ContributeStrata(inout float cur, float add, float replace, float mask)
{
	cur = lerp(cur, 0.0f, replace * mask) + add * mask;
}

float4 CW_Load(sampler2D s, float2 t, int x, int y)
{
	return tex2Dlod(s, float4((x + 0.5) * t.x, (y + 0.5) * t.y, 0.0, 0.0));
}

void CW_Vert(a2v i, out v2f o)
{
	int    vertexIndex = round(i.vertex.x);
	float2 coord       = _CwCoords[vertexIndex].xy;
	float  partIndex   = i.vertex.y;
	
	coord.x = (coord.x + partIndex) / 3.0f;
	
	o.coord    = coord;
	o.pixel    = float4(coord * _CwPixelSize, coord * _CwVertexResolution);
	o.localPos = CW_Load(_CwBufferP, _CwBufferSize.zw, vertexIndex, 0).xyz;
    o.vertex   = float4(coord * 2.0f - 1.0f, 0.5f, 1.0f);

#if UNITY_UV_STARTS_AT_TOP
	o.vertex.y = -o.vertex.y;
#endif
}

float4 CW_SampleMaskTopology(float4 globalCoord, float2 globalOffset, float maskIndex, float maskInvert, float maskSharpness, float maskShift, float detailIndex, float2 detailTiling, float maskDetailOffset)
{
	float4 maskTopology = float4(0.0f, 0.0f, 1.0f, 1.0f);

	if (maskIndex >= 0.0f)
	{
		float detail = 1.0f;

		if (detailIndex >= 0.0f)
		{
			detail = UNITY_SAMPLE_TEX2DARRAY(_CwDetailAtlas, float3(globalCoord.zw * detailTiling, detailIndex)).x;

			globalCoord.x += sin(detail * 6.2831853f) * maskDetailOffset;
			globalCoord.y += cos(detail * 6.2831853f) * maskDetailOffset;
		}

		//float mask = tex2Dlod(_CwMaskTex, float4(coord, 0.0f, 0.0f)).x;
		maskTopology = UNITY_SAMPLE_TEX2DARRAY_LOD(_CwMaskTopologyAtlas, float3(globalCoord.xy + globalOffset * maskShift, maskIndex), 0);

		maskTopology.w = maskTopology.w * 2.0f - 1.0f;

		maskTopology.w = sign(maskTopology.w) * (1-pow(1-abs(maskTopology.w), max(1, 1.0f + maskSharpness * detail)));

		maskTopology.w = maskTopology.w * 0.5f + 0.5f;

		maskTopology.xy *= maskTopology.w;

		maskTopology.xyw = lerp(maskTopology.xyw, 1.0f - maskTopology.xyw, maskInvert);
	}

	return maskTopology;
}

void CW_ContributeHoles(inout float4 rgbo, inout float4 nnes, float3 localPos)
{
	for (int h = 0; h < _CwHoleCount; h++)
	{
		float3 entrancePoint = mul(_CwHoleMatrices[h], float4(localPos, 1.0)).xyz;
		float  circleDist    = dot(entrancePoint.xz, entrancePoint.xz);
		float  boxDist       = max(abs(entrancePoint.x), abs(entrancePoint.z));
		float  finalDist     = lerp(circleDist, boxDist, _CwHoleDatas[h].x);
		
		if (finalDist < 1.0 && abs(entrancePoint).y < 1.0)
		{
			rgbo = 0.0f;
			nnes = 0.0f;
			
			break;
		}
	}
}

void CW_ContributeTopologyFeatures(inout float4 finalAlbedo, inout float finalOcclusion, inout float finalEmission, inout float finalSmoothness, inout float4 finalTopology, inout float finalStrata, float4x4 coordM, float4 localPos, float4 globalCoord, float2 globalOffset, float2 pole2, float angle1)
{
	int i;

	for (i = 0; i < _CwGlobalDetailCount; i++)
	{
		float  scale       = _CwGlobalDetailDataA[i].x;
		float  tile        = _CwGlobalDetailDataA[i].y;
		float  strata      = _CwGlobalDetailDataB[i].x;
		float  heightIndex = _CwGlobalDetailDataB[i].y;
		float2 heightRange = _CwGlobalDetailDataB[i].zw;
		float  replace     = _CwGlobalDetailDataE[i].x;

		float  maskIndex        = _CwGlobalDetailDataC[i].x;
		float  maskSharpness    = _CwGlobalDetailDataC[i].y;
		float  maskShift        = _CwGlobalDetailDataC[i].z;
		float  maskInvert       = _CwGlobalDetailDataC[i].w;
		float  maskDetailIndex  = _CwGlobalDetailDataD[i].x;
		float2 maskDetailTiling = _CwGlobalDetailDataD[i].yz;
		float  maskDetailOffset = _CwGlobalDetailDataD[i].w;

		float4 coord = mul(coordM, _CwGlobalDetailLayer[i]) * tile + _CwHeightTopologyAtlasSize.zwzw * 0.5f;

		#ifdef CW_TWO_COORDS
			float4 topologyA = UNITY_SAMPLE_TEX2DARRAY(_CwHeightTopologyAtlas, float3(coord.xy, heightIndex)); topologyA.xy -= 0.5;
			float4 topologyB = UNITY_SAMPLE_TEX2DARRAY(_CwHeightTopologyAtlas, float3(coord.zw, heightIndex)); topologyB.xy -= 0.5; topologyB.xy = CW_Rotate(topologyB.xy, angle1);
			float4 topology  = topologyA * pole2.x + topologyB * pole2.y;
		#else
			float4 topology = UNITY_SAMPLE_TEX2DARRAY(_CwHeightTopologyAtlas, float3(coord.xy, heightIndex)); topology.xy -= 0.5;
		#endif

		float mask = CW_SampleMaskTopology(globalCoord, globalOffset, maskIndex, maskInvert, maskSharpness, maskShift, maskDetailIndex, maskDetailTiling, maskDetailOffset).w;
		//float4 maskTopology = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(globalCoord.xy + globalOffset * maskShift, maskIndex));
		
		CW_ContributeStrata(finalStrata, strata * topology.w, replace, mask);
		
		topology.xy *= scale * _CwHeightTopologyAtlasSize.xy * 0.5;
		topology.w   = heightRange.x + heightRange.y * topology.w;

		CW_ContributeTopo(finalTopology, topology, replace, mask);
	}

	for (i = 0; i < _CwLocalDetailCount; i++)
	{
		float3 featurePoint = mul(_CwLocalDetailMatrix[i], localPos).xyz;
		float3 featureBound = abs(featurePoint - 0.5f);

		if (max(max(featureBound.x, featureBound.y), featureBound.z) < 0.5f)
		{
			float2 tiling      = _CwLocalDetailDataA[i].xy;
			float2 scale       = _CwLocalDetailDataA[i].zw;
			float  strata      = _CwLocalDetailDataB[i].x;
			float  heightIndex = _CwLocalDetailDataB[i].y;
			float2 heightRange = _CwLocalDetailDataB[i].zw;
			float  replace     = _CwLocalDetailDataE[i].x;

			float  maskIndex        = _CwLocalDetailDataC[i].x;
			float  maskSharpness    = _CwLocalDetailDataC[i].y;
			float  maskShift        = _CwLocalDetailDataC[i].z;
			float  maskInvert       = _CwLocalDetailDataC[i].w;
			float  maskDetailIndex  = _CwLocalDetailDataD[i].x;
			float2 maskDetailTiling = _CwLocalDetailDataD[i].yz;
			float  maskDetailOffset = _CwLocalDetailDataD[i].w;

			float4 topology = UNITY_SAMPLE_TEX2DARRAY(_CwHeightTopologyAtlas, float3(featurePoint.xy * tiling, heightIndex)); topology.xy -= 0.5;

			float mask = CW_SampleMaskTopology(featurePoint.xyxy, globalOffset, maskIndex, maskInvert, maskSharpness, maskShift, maskDetailIndex, maskDetailTiling, maskDetailOffset).w;
			//float mask = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(featurePoint.xy, maskIndex)).w;
			
			CW_ContributeStrata(finalStrata, strata * topology.w, replace, mask);
			
			topology.xy *= scale * _CwHeightTopologyAtlasSize.xy * 0.5;
			topology.w   = heightRange.x + heightRange.y * topology.w;

			CW_ContributeTopo(finalTopology, topology, replace, mask);
		}
	}

	for (i = 0; i < _CwGlobalFlattenCount; i++)
	{
		float targetHeight  = _CwGlobalFlattenDataA[i].x;
		float targetStrata  = _CwGlobalFlattenDataA[i].y;
		float flattenHeight = _CwGlobalFlattenDataA[i].z;
		float flattenStrata = _CwGlobalFlattenDataA[i].w;

		float maskIndex  = _CwGlobalFlattenDataC[i].x;
		float maskInvert = _CwGlobalFlattenDataC[i].w;

		//float4 maskTopology = CW_SampleMaskTopology(globalCoord, globalOffset, maskIndex, maskSharpness, maskShift, maskDetailIndex, maskDetailTiling, maskDetailOffset);
		float4 maskTopology = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(globalCoord.xy, maskIndex));

		maskTopology.xyz = normalize(float3(maskTopology.xy * (targetHeight - finalTopology.w), 1.0f));
		maskTopology.xyw = lerp(maskTopology.xyw, 1.0f - maskTopology.xyw, maskInvert);

		finalTopology = lerp(finalTopology, float4(maskTopology.xyz, targetHeight), flattenHeight * maskTopology.w);
		finalStrata   = lerp(finalStrata, targetStrata, flattenStrata * maskTopology.w);
	}

	for (i = 0; i < _CwLocalFlattenCount; i++)
	{
		float3 featurePoint = mul(_CwLocalFlattenMatrix[i], localPos).xyz;
		float3 featureBound = abs(featurePoint - 0.5f);

		if (max(max(featureBound.x, featureBound.y), featureBound.z) < 0.5f)
		{
			float targetHeight  = _CwLocalFlattenDataA[i].x;
			float targetStrata  = _CwLocalFlattenDataA[i].y;
			float flattenHeight = _CwLocalFlattenDataA[i].z;
			float flattenStrata = _CwLocalFlattenDataA[i].w;

			float maskIndex  = _CwLocalFlattenDataC[i].x;
			float maskInvert = _CwLocalFlattenDataC[i].w;

			float4 maskTopology = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(featurePoint.xy, maskIndex));

			maskTopology.xyz = normalize(float3(maskTopology.xy * (targetHeight - finalTopology.w), 1.0f));
			maskTopology.xyw = lerp(maskTopology.xyw, 1.0f - maskTopology.xyw, maskInvert);

			finalTopology = lerp(finalTopology, float4(maskTopology.xyz, targetHeight), flattenHeight * maskTopology.w);
			finalStrata   = lerp(finalStrata, targetStrata, flattenStrata * maskTopology.w);
		}
	}
}

void CW_ContributeColorFeatures(inout float4 finalAlbedo, inout float finalOcclusion, inout float finalEmission, inout float finalSmoothness, inout float4 finalTopology, inout float finalStrata, float4x4 coordM, float4 localPos, float4 globalCoord, float2 globalOffset, float2 pole2, float angle1)
{
	int i;
	
	float3 slope = float3(finalTopology.xy, sqrt(1.0f - saturate(dot(finalTopology.xy, finalTopology.xy))));
	float n = length(slope.xy);

	for (i = 0; i < _CwGlobalColorCount; i++)
	{
		float variation     = _CwGlobalColorDataA[i].x;
		float occlusion     = _CwGlobalColorDataA[i].y;
		float strata        = _CwGlobalColorDataA[i].z;
		float gradientIndex = _CwGlobalColorDataA[i].w;
		float blur          = _CwGlobalColorDataB[i].x;
		float offset        = _CwGlobalColorDataB[i].y;
		float smoothnessStr = _CwGlobalColorDataB[i].z;
		float smoothnessMid = _CwGlobalColorDataE[i].x;
		float smoothnessPow = _CwGlobalColorDataE[i].y;
		float emissionStr   = _CwGlobalColorDataB[i].w;
		float emissionMid   = _CwGlobalColorDataE[i].z;
		float emissionPow   = _CwGlobalColorDataE[i].w;

		float  maskIndex        = _CwGlobalColorDataC[i].x;
		float  maskSharpness    = _CwGlobalColorDataC[i].y;
		float  maskShift        = _CwGlobalColorDataC[i].z;
		float  maskInvert       = _CwGlobalColorDataC[i].w;
		float  maskDetailIndex  = _CwGlobalColorDataD[i].x;
		float2 maskDetailTiling = _CwGlobalColorDataD[i].yz;
		float  maskDetailOffset = _CwGlobalColorDataD[i].w;
		
		float  v   = finalStrata * strata * 0.125f;
		float  ao  = pow(1.0f - n, occlusion);

		//float mask = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(globalCoord.xy + globalOffset * maskShift, maskIndex)).w;
		float mask = CW_SampleMaskTopology(globalCoord, globalOffset, maskIndex, maskInvert, maskSharpness, maskShift, maskDetailIndex, maskDetailTiling, maskDetailOffset).w;

		float4 detailAlbedo = UNITY_SAMPLE_TEX2DARRAY_LOD(_CwGradientAtlas, float3(variation, offset + v, gradientIndex), blur) * ao;

		float luminosity = dot(detailAlbedo.xyz, float3(0.2126f, 0.7152f, 0.0722f));

		float smoothnessWeight = saturate(pow(1.0f - abs(luminosity - smoothnessMid), smoothnessPow));

		float emissionWeight = saturate(pow(1.0f - abs(luminosity - emissionMid), emissionPow));

		finalAlbedo.xyz = lerp(finalAlbedo.xyz, detailAlbedo.xyz, mask);

		finalSmoothness = lerp(finalSmoothness, smoothnessStr, mask * smoothnessWeight);

		finalEmission = lerp(finalEmission, emissionStr, mask * emissionWeight);
	}

	for (i = 0; i < _CwLocalColorCount; i++)
	{
		float3 featurePoint = mul(_CwLocalColorMatrix[i], localPos).xyz;
		float3 featureBound = abs(featurePoint - 0.5f);

		if (max(max(featureBound.x, featureBound.y), featureBound.z) < 0.5f)
		{
			float variation     = _CwLocalColorDataA[i].x;
			float occlusion     = _CwLocalColorDataA[i].y;
			float strata        = _CwLocalColorDataA[i].z;
			float gradientIndex = _CwLocalColorDataA[i].w;
			float blur          = _CwLocalColorDataB[i].x;
			float offset        = _CwLocalColorDataB[i].y;
			float smoothnessStr = _CwLocalColorDataB[i].z;
			float smoothnessMid = _CwLocalColorDataE[i].x;
			float smoothnessPow = _CwLocalColorDataE[i].y;
			float emissionStr   = _CwLocalColorDataB[i].w;
			float emissionMid   = _CwLocalColorDataE[i].z;
			float emissionPow   = _CwLocalColorDataE[i].w;

			float  maskIndex        = _CwLocalColorDataC[i].x;
			float  maskSharpness    = _CwLocalColorDataC[i].y;
			float  maskShift        = 0;
			float  maskInvert       = _CwLocalColorDataC[i].w;
			float  maskDetailIndex  = _CwLocalColorDataD[i].x;
			float2 maskDetailTiling = _CwLocalColorDataD[i].yz;
			float  maskDetailOffset = _CwLocalColorDataD[i].w;

			float  v   = finalStrata * strata * 0.125f;
			float  ao  = pow(1.0f - n, occlusion);

			//float mask = UNITY_SAMPLE_TEX2DARRAY(_CwMaskTopologyAtlas, float3(featurePoint.xy, maskIndex)).w;
			float mask = CW_SampleMaskTopology(featurePoint.xyxy, globalOffset, maskIndex, maskInvert, maskSharpness, maskShift, maskDetailIndex, maskDetailTiling, maskDetailOffset).w;

			float4 detailAlbedo = UNITY_SAMPLE_TEX2DARRAY_LOD(_CwGradientAtlas, float3(variation, offset + v, gradientIndex), blur) * ao;

			float luminosity = dot(detailAlbedo.xyz, float3(0.2126f, 0.7152f, 0.0722f));

			float smoothnessWeight = saturate(pow(1.0f - abs(luminosity - smoothnessMid), smoothnessPow));

			float emissionWeight = saturate(pow(1.0f - abs(luminosity - emissionMid), emissionPow));

			finalAlbedo.xyz = lerp(finalAlbedo.xyz, detailAlbedo.xyz, mask);

			finalSmoothness = lerp(finalSmoothness, smoothnessStr, mask * smoothnessWeight);

			finalEmission = lerp(finalEmission, emissionStr, mask * emissionWeight);
		}
	}
}