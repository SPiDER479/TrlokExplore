Shader "Hidden/SgtOcean"
{
	Properties
	{
		_SGT_OffsetTex ("Offset Tex", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv     : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler3D _SGT_CausticsTexure;
			float4    _SGT_CausticsData;

			void vert(appdata v, out v2f o)
			{
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv     = v.uv;
			}

			float4 frag(v2f i) : SV_Target
			{
				float4 caustics = tex3D(_SGT_CausticsTexure, float3(i.uv, _SGT_CausticsData.x));

				caustics = pow(caustics, _SGT_CausticsData.z);

				caustics *= _SGT_CausticsData.y;

				return caustics;
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag
			#include "UnityCG.cginc"
			
			sampler2D _SGT_OffsetTex;
			sampler2D _SGT_Texture;
			float4    _SGT_RipplesData;

			struct a2v
			{
				float4 vertex : POSITION;
				float2 uv     : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv     : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			struct f2g
			{
				float4 color : SV_TARGET;
			};

			void Vert(a2v i, out v2f o)
			{
				o.vertex = UnityObjectToClipPos(i.vertex);
				o.uv     = i.uv;
			}

			void Frag(v2f i, out f2g o)
			{
				float offset = tex2D(_SGT_OffsetTex, i.uv).x * 3 + _SGT_RipplesData.x;
				float indexA = floor(offset);
				float indexB = indexA + 1.0f;
				float time   = smoothstep(0, 1, frac(offset));
				//float time   = sin(offset * 6.2832f/2) * 0.5f + 0.5f;

				float4 sampleA = tex2D(_SGT_Texture, i.uv + sin(float2(3,7) * indexA), ddx(i.uv), ddy(i.uv));
				float4 sampleB = tex2D(_SGT_Texture, i.uv + sin(float2(3,7) * indexB), ddx(i.uv), ddy(i.uv));

				o.color = lerp(sampleA, sampleB, time);
			}
			ENDCG
		} // Pass

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
				#define GERSTNER_WAVES_PER_LAYER 3
			#elif _SGT_WAVES_2
				#define GERSTNER_WAVES_PER_LAYER 2
			#else
				#define GERSTNER_WAVES_PER_LAYER 1
			#endif

			#include "UnityCG.cginc"
			#include "../OceanShared.cginc"

			float    _SGT_SurfaceDensity;
			float3   _SGT_WCam;

			float  _SGT_UnderwaterDensity;
			float  _SGT_UnderwaterMinimumOpacity;

			struct a2v
			{
				float4 vertex    : POSITION;
				float4 texcoord0 : TEXCOORD0;
				float3 normal    : NORMAL;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 position           : SV_POSITION;
				float3 worldSpacePosition : TEXCOORD0;
				float3 worldSpaceNormal   : TEXCOORD1;
				float3 worldSpaceTangent  : TEXCOORD2;
				float4 worldSpaceBent     : TEXCOORD3;
			};

			struct f2g
			{
				float4 distance : SV_Target0;
			};

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

				float3 normalD = normal;

				#if _SGT_DISPLACEMENT_ON
					SGT_ApplyGerstnerNoise(v.vertex.xyz, normalD, tangent, binormal, _SGT_WaveData.x, _SGT_WaveData.y, _SGT_WaveData.z);
				#endif

				o.position           = UnityObjectToClipPos(v.vertex);
				o.worldSpacePosition = mul(_SGT_ObjectToWorld, v.vertex).xyz;
				o.worldSpaceNormal   = mul((float3x3)_SGT_ObjectToWorld, normal);
				o.worldSpaceTangent  = mul((float3x3)_SGT_ObjectToWorld, tangent);
				o.worldSpaceBent.xyz = mul((float3x3)_SGT_ObjectToWorld, normalD);
				o.worldSpaceBent.w   = lerp(0.0, 1.0, exp(-distance(v.vertex.xyz, _WorldSpaceCameraPos) * 0.1));
			}

			void frag(v2f i, out f2g o, in bool isFrontFace : SV_IsFrontFace)
			{
				float dist = distance(_SGT_WCam, i.worldSpacePosition);

				i.worldSpaceNormal   = normalize(i.worldSpaceNormal);
				i.worldSpaceTangent  = normalize(i.worldSpaceTangent);
				i.worldSpaceBent.xyz = normalize(i.worldSpaceBent.xyz);

				float3 worldSpaceBinormal = cross(i.worldSpaceBent.xyz, i.worldSpaceTangent);

				#if _SGT_RIPPLES_ON
					float2 det = SGT_GetRipplesNormal(i.worldSpacePosition);

					i.worldSpaceBent.xyz = i.worldSpaceBent.xyz + i.worldSpaceTangent * det.x + worldSpaceBinormal * det.y;
				#endif

				i.worldSpaceBent.xyz = lerp(i.worldSpaceNormal, i.worldSpaceBent.xyz, i.worldSpaceBent.w);

				i.worldSpaceBent.xyz = normalize(i.worldSpaceBent.xyz);

				// Top surface
				if (isFrontFace == true)
				{
					o.distance = float4(i.worldSpaceBent.xyz, dist);
				}
				// Under surface
				else
				{
					float alpha = saturate(1.0f - exp(-dist * _SGT_UnderwaterDensity) + _SGT_UnderwaterMinimumOpacity);

					o.distance = float4(i.worldSpaceBent.xyz, -dist);
				}
			}
			ENDCG
		} // Pass
	}
}
