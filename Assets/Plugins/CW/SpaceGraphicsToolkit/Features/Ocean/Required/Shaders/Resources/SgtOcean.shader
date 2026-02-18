Shader "Hidden/SgtOcean"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Cull Off
			ZWrite On

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#pragma instancing_options procedural:SetupInstancing
			#pragma multi_compile_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
			#pragma multi_compile_local _SGT_DISPLACEMENT_OFF _SGT_DISPLACEMENT_ON
			#pragma multi_compile_local _SGT_RIPPLES_OFF _SGT_RIPPLES_ON
			#pragma multi_compile_local _SGT_SNAP_OFF _SGT_SNAP_ON
			#pragma multi_compile_local _SGT_WAVES_1 _SGT_WAVES_2 _SGT_WAVES_3

			#if _SGT_WAVES_3
				#define WAVE_SKIP 1
			#elif _SGT_WAVES_2
				#define WAVE_SKIP 2
			#else
				#define WAVE_SKIP 3
			#endif

			#include "UnityCG.cginc"
			#include "../OceanShared.cginc"

			float3 _SGT_WCam;

			struct a2v
			{
				float4 vertex    : POSITION;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 position            : SV_POSITION;
				float3 objectSpacePosition : TEXCOORD0;
				float3 objectSpaceNormal   : TEXCOORD1;
				float3 objectSpaceTangent  : TEXCOORD2;
				float3 worldSpacePosition  : TEXCOORD3;
				float4 screenPos           : TEXCOORD4;
			};

			struct f2g
			{
				float4 distance : SV_Target0;
			};

			float SGT_Bayer4x4(float2 screenPos)
			{
				uint2 p = uint2(screenPos * _ScreenParams.xy) % 4;
				float bayer[16] = { 0,  8,  2, 10, 12,  4, 14,  6, 3, 11,  1,  9, 15,  7, 13,  5 };
				return (bayer[p.x + p.y * 4] + 0.5) / 16.0;
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
			
					unity_ObjectToWorld = _SGT_ObjectToWorld;
					unity_WorldToObject = _SGT_WorldToObject;
				#endif
			}

			float2 SGT_GetRipplesNormal(float3 wp)
			{
				float2 positionA   = mul(_SGT_RipplesMatrixA, float4(wp, 1.0f)).xy;
				float2 positionB   = mul(_SGT_RipplesMatrixB, float4(wp, 1.0f)).xy;
				float4 dualNormalA = tex2D(_SGT_RipplesTexture, positionA) * 2.0 - 1.0; // xy = normal A, zw = normal B
				float4 dualNormalB = tex2D(_SGT_RipplesTexture, positionB) * 2.0 - 1.0; // xy = normal A, zw = normal B
				float  worldNoise  = tex3Dlod(_SGT_NoiseTex, float4(wp.xy * 1, 0, 0)).x * 2.0;
				float  pingPong    = sin((worldNoise + _SGT_RipplesData.y) * 3.1415) * 0.5 + 0.5; // Smoothly ping pong between normals with world space offset to create the illusion of standing waves
				float2 normalA     = lerp(dualNormalA.xy, dualNormalA.zw, pingPong);
				float2 normalB     = lerp(dualNormalB.xy, dualNormalB.zw, pingPong);
	
				return lerp(normalA, normalB, _SGT_RipplesBlend) * _SGT_RipplesData.x * _SGT_RipplesData.x;
			}

			void vert(a2v v, out v2f o)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				float  weight     = 1.0f;
				float3 weights    = v.vertex.xyz;
				float  batchIndex = 0;

				#ifdef UNITY_PROCEDURAL_INSTANCING_ENABLED
					batchIndex = unity_InstanceID;
				#endif

				float3 origin = _SGT_Origins[batchIndex].xyz;
				float  depth  = _SGT_Origins[batchIndex].w;

				float4 position = _SGT_PositionsA[batchIndex] * weights.x + _SGT_PositionsB[batchIndex] * weights.y + _SGT_PositionsC[batchIndex] * weights.z;
				float3 normalPos = position.xyz + origin;

				position.xyz += _SGT_Offset + origin;

				float3 direction = normalize(normalPos.xyz);
	
				#if _SGT_SHAPE_SPHERE && _SGT_SNAP_ON
					position.xyz = direction * _SGT_Radius + _SGT_Offset;
				#endif

				v.vertex.xyz = position.xyz;
	
				float3 normal   = float3(0.0, 1.0,  0.0);
				float3 tangent  = float3(1.0, 0.0,  0.0);
				float3 binormal = float3(0.0, 0.0, -1.0);

				#if _SGT_SHAPE_SPHERE
					normal = direction;

					SGT_ComputeTangentFrame(normal, tangent, binormal);
				#endif
				
				o.objectSpacePosition = v.vertex;
				o.objectSpaceNormal   = normal;
				o.objectSpaceTangent  = tangent;

				SGT_ApplyWaves(v.vertex.xyz, normal, tangent, binormal, 0.0, 0.01);

				o.position           = UnityObjectToClipPos(v.vertex);
				o.worldSpacePosition = mul(_SGT_ObjectToWorld, v.vertex).xyz;
				o.screenPos          = ComputeScreenPos(o.position);
			}

			void frag(v2f i, out f2g o, in bool isFrontFace : SV_IsFrontFace)
			{
				float2 detail = 0.0;

				#if _SGT_RIPPLES_ON
					float3 worldSpacePositionD = mul(_SGT_ObjectToWorld, float4(i.objectSpacePosition, 1.0)).xyz;
					detail = SGT_GetRipplesNormal(worldSpacePositionD);
				#endif

				float3 objectSpaceBinormal = cross(i.objectSpaceNormal, i.objectSpaceTangent);
				float  pixelSize           = length(fwidth(i.objectSpacePosition));
				float2 screenUV            = (i.screenPos.xy / i.screenPos.w);

				SGT_ApplyWaves(i.objectSpacePosition, i.objectSpaceNormal, i.objectSpaceTangent, objectSpaceBinormal, detail, pixelSize);

				float3 worldSpacePosition = mul(_SGT_ObjectToWorld, float4(i.objectSpacePosition, 1.0)).xyz;
				float3 worldSpaceNormal   = normalize(mul((float3x3)_SGT_ObjectToWorld, i.objectSpaceNormal));
				float  dist               = distance(_SGT_WCam, worldSpacePosition);

				// Top surface
				if (isFrontFace == true)
				{
					o.distance = float4(worldSpaceNormal, dist);
				}
				// Under surface
				else
				{
					o.distance = float4(worldSpaceNormal, -dist);
				}

				o.distance *= step(_SGT_FadeOpacity.y, SGT_Bayer4x4(screenUV));
			}
			ENDCG
		} // Pass
	}
}
