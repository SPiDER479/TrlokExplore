Shader "Hidden/SgtSquareLandscape"
{
	Properties
	{
		_CwAlbedo ("Albedo", 2D) = "white" {}
		_CwOpacity ("Opacity", 2D) = "white" {}
	}
	SubShader
	{
		Cull Off
		ZWrite Off
		ZTest Always
		Blend One Zero

		Pass
		{
			CGPROGRAM
			#pragma vertex   CW_Vert
			#pragma fragment CW_Frag
			#include "SgtFeature.cginc"

			float _SGT_OceanHeight;
			float _SGT_OceanDensity;

			float _CwSquareSize;

			float3 _CwPositionA;
			float3 _CwPositionB;
			float3 _CwPositionC;

			float4x4 _CwCoordX;
			float4x4 _CwCoordY;
			float4x4 _CwCoordZ;
			float4x4 _CwCoordW;

			sampler2D _CwAlbedo;
			float2    _CwAlbedoSize;

			sampler2D _SGT_WeightTex;

			sampler2D_float _CwTopology;
			float2          _CwTopologySize;
			float3          _CwTopologyData;

			void CW_Frag(v2f i, out f2g o)
			{
				float3 weights    = tex2Dlod(_SGT_WeightTex, float4(i.coord, 0.0f, 0.0f)).xyz;
				float3 position   = _CwPositionA * weights.x + _CwPositionB * weights.y + _CwPositionC * weights.z;
				float2 coord      = position.xz / _CwSquareSize + 0.5f;
				float4 albedo     = CW_SampleCubic(_CwAlbedo, coord, _CwAlbedoSize);
				float  occlusion  = 0.0f;
				float  emission   = 0.0f;
				float  smoothness = 0.0f;
				float4 topology   = CW_SampleCubic(_CwTopology, coord, _CwTopologySize);
				float  strata     = _CwTopologyData.z * topology.w;

				float2 coordX = mul(_CwCoordX, float4(weights, 0)).xy;
				float2 coordY = mul(_CwCoordY, float4(weights, 0)).xy;
				float2 coordZ = mul(_CwCoordZ, float4(weights, 0)).xy;
				float2 coordW = mul(_CwCoordW, float4(weights, 0)).xy;

				float4x4 coordM = float4x4(
					coordX.x, coordY.x, coordZ.x, coordW.x,
					coordX.y, coordY.y, coordZ.y, coordW.y,
					0,0,0,0,
					0,0,0,0);

				topology.xyz = normalize(float3(topology.xy / _CwTopologyData.xy, 1.0f));

				float4 localPos = float4(position, 1.0f);

				float4 globalCoord = float4(coord, coord);

				float2 globalOffset = float2(0.0f, 0.0f);

				CW_ContributeFeatures(albedo, occlusion, emission, smoothness, topology, strata, coordM, localPos, globalCoord, globalOffset, float2(1.0f, 1.0f), 0.0f);

				albedo *= occlusion;

				float ocean = 1-exp(min(0.0f, (topology.w - _SGT_OceanHeight) * _SGT_OceanDensity));

				o.rgbo = float4(albedo.xyz, ocean);
				o.nnes = float4(topology.xy * 0.5f + 0.5f, emission, smoothness);
			}
			ENDCG
		}
	}
}