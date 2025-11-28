Shader "Hidden/SgtSphereLandscape"
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
			#define CW_TWO_COORDS
			#include "SgtFeature.cginc"

			float _SGT_OceanHeight;
			float _SGT_OceanDensity;

			float  _CwRadius;
			int    _CwDepth;
			float4 _CwGlobalTiling;

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

			float3 CW_FixDirection(float3 direction)
			{
				if (direction.x == 0.0f && direction.z == 0.0f)
				{
					direction.xz += 0.00000001f;
				}

				return normalize(direction);
			}

			float CW_Asin(float x)
			{
				return x + (x * x * x / 6.0f) + ((3.0f * x * x * x * x * x) / 40.0f);
			}

			float4 CW_CalculateDetailCoords1(float3 direction)
			{
				float u = atan2(direction.z, direction.x) / (3.1415926535f * 2.0f) + 0.5f;
				float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;

				return float4(u, v * 0.5f, direction.xz * 0.25f);
			}

			float4 CW_CalculateDetailCoords2(float3 direction)
			{
				float u = atan2(-direction.z, -direction.x) / (3.1415926535f * 2.0f);
				float v = CW_Asin(direction.y) / 3.1415926535f + 0.5f;

				return float4(u, v * 0.5f, direction.xz * 0.25f);
			}

			void CW_Frag(v2f i, out f2g o)
			{
				float3 weights    = tex2Dlod(_SGT_WeightTex, float4(i.coord, 0.0f, 0.0f)).xyz;
				float3 position   = normalize(_CwPositionA * weights.x + _CwPositionB * weights.y + _CwPositionC * weights.z) * _CwRadius;
				float3 direction  = CW_FixDirection(_CwPositionA * weights.x + _CwPositionB * weights.y + _CwPositionC * weights.z); 
				float2 coord      = CW_CalculateDetailCoords1(direction).xy; coord.y *= 2.0f;
				float4 albedo     = CW_SampleCubic(_CwAlbedo, coord.xy, _CwAlbedoSize);
				float  occlusion  = 1.0f;
				float  emission   = 0.0f;
				float  smoothness = 0.0f;
				float4 topology   = CW_SampleCubic(_CwTopology, coord.xy, _CwTopologySize);
				float  pole       = smoothstep(0.0f, 1.0f, saturate((abs(direction.y) - 0.7f) * 30.0f));
				float  strata     = _CwTopologyData.z * topology.w;

				float4 coordX = mul(_CwCoordX, float4(weights, 0));
				float4 coordY = mul(_CwCoordY, float4(weights, 0));
				float4 coordZ = mul(_CwCoordZ, float4(weights, 0));
				float4 coordW = mul(_CwCoordW, float4(weights, 0));

				//float3 directionM = max(max(direction0, direction1), direction2) - min(min(direction0, direction1), direction2);

				//if (_CwDepth < 15)
				float3 direction0 = normalize(_CwPositionA);
				float3 direction1 = normalize(_CwPositionB);
				float3 direction2 = normalize(_CwPositionC);
				float3 directionM = max(max(direction0, direction1), direction2) - min(min(direction0, direction1), direction2);

				if ((directionM.x + directionM.y + directionM.z) > 0.001f)
				{
					float3 triangleD = normalize(_CwPositionA + _CwPositionB + _CwPositionC);
					float4 coords    = triangleD.x > 0.0f ? CW_CalculateDetailCoords1(direction) : CW_CalculateDetailCoords2(direction);

					coordX = coords * _CwGlobalTiling.x;
					coordY = coords * _CwGlobalTiling.y;
					coordZ = coords * _CwGlobalTiling.z;
					coordW = coords * _CwGlobalTiling.w;
				}

				float4x4 coordM = float4x4(
					coordX.x, coordY.x, coordZ.x, coordW.x,
					coordX.y, coordY.y, coordZ.y, coordW.y,
					coordX.z, coordY.z, coordZ.z, coordW.z,
					coordX.w, coordY.w, coordZ.w, coordW.w);

				topology.x  /= length(direction.xz);
				topology.xyz = normalize(float3(topology.xy / _CwTopologyData.xy, 1.0f));

				float4 localPos = float4(direction * _CwRadius, 1.0f);

				float4 globalCoord = float4(coord.xy, coord.x, coord.y * 0.5f);

				float2 globalOffset = float2(0.0f, sign(direction.y));

				float2 pole2 = float2(1.0f - pole, pole);

				float ang1 = atan2(-direction.x, -direction.z);

				CW_ContributeFeatures(albedo, occlusion, emission, smoothness, topology, strata, coordM, localPos, globalCoord, globalOffset, pole2, ang1);

				albedo *= occlusion;

				float ocean = 1-exp(min(0.0f, (topology.w - _SGT_OceanHeight) * _SGT_OceanDensity));

				o.rgbo = float4(albedo.xyz, ocean);
				o.nnes = float4(topology.xy * 0.5f + 0.5f, emission, smoothness);
			}
			ENDCG
		}
	}
}
