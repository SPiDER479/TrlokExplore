Shader "Hidden/SgtLandscape_BakePass"
{
	Properties
	{
		_AlbedoTex ("Albedo (Occupancy)", 2D) = "white" {}
		_BakeTex ("Bake Texture", 2D) = "white" {}
		_BakeMode ("Bake Mode", Float) = 0
		_NearClip ("Near Clip", Float) = 0
		_FarClip ("Far Clip", Float) = 1
		_Metallic ("Metallic", Float) = 0
		_Smoothness ("Smoothness", Float) = 0.5
		_NormalScale ("NormalScale", Float) = 1.0
		_HasMetallicTex ("Has Metallic Tex", Float) = 0
		_MainTex ("Main Tex", 2D) = "white" {}
		_HighResSize ("High Res Size", Vector) = (256, 256, 0, 0)
		_SuperSize ("Super Size", Float) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		ZWrite On ZTest LEqual Cull Off

		// PASS 0: BAKE PASS (Occupancy via Alpha=1)
		Pass
		{
			Name "Bake"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; float3 normal : NORMAL; float4 tangent : TANGENT; };
			struct v2f { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; float3 worldNormal : TEXCOORD1; float3 worldTangent : TEXCOORD2; float3 worldBitangent : TEXCOORD3; float depth : TEXCOORD4; };

			sampler2D _AlbedoTex; sampler2D _BakeTex; float _BakeMode, _NearClip, _FarClip, _Metallic, _Smoothness, _NormalScale, _HasMetallicTex;

			v2f vert(appdata v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
				o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
				o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float viewZ = mul(UNITY_MATRIX_V, float4(worldPos, 1.0)).z;
				o.depth = (-viewZ - _NearClip) / (_FarClip - _NearClip);
				return o;
			}

			float4 frag(v2f i) : SV_Target {
				float4 albedo = tex2D(_AlbedoTex, i.uv);
				if (albedo.a < 0.5) discard; // Strict occupancy check

				float4 bakeSample = tex2D(_BakeTex, i.uv);
				int mode = (int)_BakeMode;
				float3 res = 0;

				if (mode == 0) res = albedo.rgb;
				else if (mode == 1) {
					float3 tNormal = UnpackNormal(bakeSample);
					tNormal.xy *= _NormalScale;
					tNormal = normalize(tNormal);
					float3x3 TBN = float3x3(normalize(i.worldTangent), normalize(i.worldBitangent), normalize(i.worldNormal));
					float3 vNormal = normalize(mul((float3x3)UNITY_MATRIX_V, mul(tNormal, TBN)));
					res = vNormal * 0.5 + 0.5;
				}
				else if (mode == 2) res = saturate(i.depth).rrr;
				else if (mode == 3) {
					float m = _HasMetallicTex > 0.5 ? bakeSample.r * _Metallic : _Metallic;
					float o = _HasMetallicTex > 0.5 ? bakeSample.g : 1.0;
					float s = _HasMetallicTex > 0.5 ? bakeSample.a * _Smoothness : _Smoothness;
					res = float3(m, o, s);
				}
				else res = bakeSample.rgb;

				return float4(res, 1.0); // Occupied pixels = Alpha 1.0
			}
			ENDCG
		}

		// PASS 1: DOWNSAMPLE (Snaps to pixels, Albedo-alpha aware)
		Pass 
		{
			Name "Downsample"
			CGPROGRAM
			#pragma vertex vert_down
			#pragma fragment frag_down
			#include "UnityCG.cginc"

			struct v2f_down { float4 pos : SV_POSITION; float2 uv : TEXCOORD0; };
			v2f_down vert_down(float4 vertex : POSITION, float2 uv : TEXCOORD0) {
				v2f_down o; o.pos = UnityObjectToClipPos(vertex); o.uv = uv; return o;
			}

			sampler2D _MainTex; sampler2D _AlbedoTex; float2 _HighResSize; float _SuperSize; float _BakeMode;

			float4 frag_down(v2f_down i) : SV_Target {
				float2 texelSize = 1.0 / _HighResSize;
				int samples = max(1, (int)floor(_SuperSize));
				// Center-aligned sampling grid for pixel snapping
				float2 startUV = i.uv - (samples - 1.0) * 0.5 * texelSize;
				
				float3 colorSum = 0;
				float occSum = 0;

				for (int y = 0; y < samples; y++) {
					for (int x = 0; x < samples; x++) {
						float2 uv = startUV + float2(x, y) * texelSize;
						float3 s = tex2D(_MainTex, uv).rgb;
						float occ = (tex2D(_AlbedoTex, uv).a > 0.5) ? 1.0 : 0.0;
						colorSum += s * occ;
						occSum += occ;
					}
				}

				if (occSum > 0) return float4(colorSum / occSum, occSum / (samples * samples));
				return ((int)_BakeMode == 1) ? float4(0.5, 0.5, 1.0, 0.0) : 0;
			}
			ENDCG
		}
	}
}