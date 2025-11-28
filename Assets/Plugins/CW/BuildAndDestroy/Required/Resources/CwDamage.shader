Shader "Hidden/BuildAndDestroy/CwDamage"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		Blend One One
		Cull Off
		ZWrite Off

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"

			float4x4  _CW_Matrix;
			sampler2D _CW_Texture;

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord1 : TEXCOORD1;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float4 position : TEXCOORD0;
			};

			struct f2g
			{
				float4 color : SV_TARGET;
			};

			void Vert(a2v i, out v2f o)
			{
				o.vertex   = float4(i.texcoord1.xy * 2.0f - 1.0f, 0.5f, 1.0f);
				o.position = mul(unity_ObjectToWorld, i.vertex);
#if UNITY_UV_STARTS_AT_TOP
				o.vertex.y = -o.vertex.y;
#endif
			}

			void Frag(v2f i, out f2g o)
			{
				float3 position = mul(_CW_Matrix, i.position).xyz; position.xy /= 1.0f - position.z * position.z;
				float3 box      = pow(saturate(abs(position)), 1000.0f);
				float2 coord    = position.xy * 0.5f + 0.5f;
				float strength  = 1.0f;

				strength -= max(box.x, max(box.y, box.z));

				o.color = tex2D(_CW_Texture, coord) * strength;
			}
			ENDCG
		}
	}
}
