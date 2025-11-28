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
			float4    _SGT_WaveData;

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
				float offset = tex2D(_SGT_OffsetTex, i.uv).x * 3 + _SGT_WaveData.x;
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
			#pragma instancing_options procedural:SetupInstancing forwardadd
			#pragma multi_compile_local _SGT_SHAPE_BOX _SGT_SHAPE_SPHERE
			#pragma multi_compile_local _SGT_DISPLACEMENT_OFF _SGT_DISPLACEMENT_ON

			#include "UnityCG.cginc"
			#include "../OceanShared.cginc"

			float    _SGT_SurfaceDensity;
			float    _SGT_SurfaceMinimumOpacity;
			float4x4 _SGT_Object2World;
			float4x4 _SGT_World2Object;
			float4x4 _SGT_World2View;
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
				float3 worldSpacePosition : TEXCOORD1;
				float3 worldSpaceNormal   : TEXCOORD2;
				float4 screenPosition     : TEXCOORD3;
			};

			struct f2g
			{
				float4 distance : SV_Target0;
				float4 alpha    : SV_Target1;
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
			
					unity_ObjectToWorld = _SGT_ObjectToOcean;
					unity_WorldToObject = _SGT_OceanToObject;
				#endif
			}

			void vert(a2v v, out v2f o)
			{
				UNITY_SETUP_INSTANCE_ID(v);

				float4 texcoord0 = 0;
				float4 texcoord1 = 0;
				float4 texcoord2 = 0;
				float4 texcoord3 = 0;

				CW_CalculateVertexData(v.vertex, texcoord0, texcoord1, texcoord2, texcoord3);

				o.position           = UnityObjectToClipPos(v.vertex);
				o.worldSpacePosition = mul(_SGT_ObjectToOcean, v.vertex).xyz;
				o.worldSpaceNormal   = mul((float3x3)_SGT_ObjectToOcean, v.normal);
				o.screenPosition     = ComputeScreenPos(o.position);
			}

			void frag(v2f i, out f2g o, in bool isFrontFace : SV_IsFrontFace)
			{
				float dist = distance(_SGT_WCam, i.worldSpacePosition);

				// Top surface
				if (isFrontFace == true)
				{
					o.distance = float4(dist, 0.0f, 0.0f, 1.0f);
					o.alpha    = 1.0f;//saturate(1.0f - exp(-dist * _SGT_SurfaceDensity) + _SGT_SurfaceMinimumOpacity);
				}
				// Under surface
				else
				{
					float alpha = saturate(1.0f - exp(-dist * _SGT_UnderwaterDensity) + _SGT_UnderwaterMinimumOpacity);

					o.distance = float4(-dist, 0.0f, 0.0f, 1.0f);
					o.alpha    = float4(alpha, 0.0f, 0.0f, 1.0f);
				}
			}
			ENDCG
		} // Pass
	}
}
