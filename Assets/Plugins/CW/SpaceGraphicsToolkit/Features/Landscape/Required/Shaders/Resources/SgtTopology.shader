Shader "Hidden/SgtTopology"
{
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
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			sampler2D_float _CwHeightTex;
			float2          _CwHeightSize;

			void CW_Vert(a2v i, out v2f o)
			{
				o.vertex   = UnityObjectToClipPos(i.vertex);
				o.texcoord = i.texcoord0;
			}

			float4 CW_Frag(v2f i) : SV_TARGET
			{
				float3 step    = float3(1.0f / _CwHeightSize, 0.0f);
				float  height  = tex2Dlod(_CwHeightTex, float4(i.texcoord.xy          , 0.0f,  0.0f)).x;
				float  heightL = tex2Dlod(_CwHeightTex, float4(i.texcoord.xy - step.xz, 0.0f,  0.0f)).x;
				float  heightR = tex2Dlod(_CwHeightTex, float4(i.texcoord.xy + step.xz, 0.0f,  0.0f)).x;
				float  heightB = tex2Dlod(_CwHeightTex, float4(i.texcoord.xy - step.zy, 0.0f,  0.0f)).x;
				float  heightT = tex2Dlod(_CwHeightTex, float4(i.texcoord.xy + step.zy, 0.0f,  0.0f)).x;
				float  deltaH  = heightL - heightR;
				float  deltaV  = heightB - heightT;

				return float4(deltaH, deltaV, 1.0f, height);
			}
			ENDCG
		}
	}
}