Shader "Hidden/CwSpaceshipFade"
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
		BlendOp RevSub

		Pass
		{
			CGPROGRAM
			#pragma vertex   Vert
			#pragma fragment Frag

			#include "UnityCG.cginc"

			float _CW_Strength;

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			struct f2g
			{
				float4 color : SV_TARGET;
			};

			void Vert(a2v i, out v2f o)
			{
				o.vertex = float4(i.texcoord0.xy * 2.0f - 1.0f, 0.5f, 1.0f);
#if UNITY_UV_STARTS_AT_TOP
				o.vertex.y = -o.vertex.y;
#endif
			}

			void Frag(v2f i, out f2g o)
			{
				o.color = float4(_CW_Strength, 0.0f, 0.0f, 0.0f);
			}
			ENDCG
		}
	}
}
