Shader "Hidden/SgtLandscape_BakePass"
{
    Properties
    {
        _AlbedoTex ("Albedo", 2D) = "white" {}
        _BakeTex ("Bake Texture", 2D) = "white" {}
        _BakeMode ("Bake Mode", Float) = 0
        // 0 = Albedo (output albedo RGBA)
        // 1 = Normal (output from normal map)
        // 2 = Depth (output linear depth)
        // 3 = Metallic (output metallic/smoothness)
        // 4 = Emission (output emission RGB)
        _AlphaCutoff ("Alpha Cutoff", Float) = 0.5
        _UseAlphaCutout ("Use Alpha Cutout", Float) = 0
        _NearClip ("Near Clip", Float) = 0
        _FarClip ("Far Clip", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        
        // We need alpha blending for the output
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
        ZTest LEqual
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldTangent : TEXCOORD2;
                float3 worldBitangent : TEXCOORD3;
                float depth : TEXCOORD4;
            };

            sampler2D _AlbedoTex;
            float4 _AlbedoTex_ST;
            sampler2D _BakeTex;
            float4 _BakeTex_ST;
            float _BakeMode;
            float _AlphaCutoff;
            float _UseAlphaCutout;
            float _NearClip;
            float _FarClip;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _AlbedoTex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                o.worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent.xyz));
                o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
                
                // Linear depth
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float viewZ = mul(UNITY_MATRIX_V, float4(worldPos, 1.0)).z;
                o.depth = (-viewZ - _NearClip) / (_FarClip - _NearClip);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 albedo = tex2D(_AlbedoTex, i.uv);
                
                // Alpha cutout test
                if (_UseAlphaCutout > 0.5 && albedo.a < _AlphaCutoff)
                    discard;
                
                fixed4 bakeSample = tex2D(_BakeTex, i.uv);
                int mode = (int)_BakeMode;
                
                // Albedo pass
                if (mode == 0)
                {
                    return fixed4(albedo.rgb, albedo.a);
                }
                // Normal pass
                else if (mode == 1)
                {
                    float3 tNormal = bakeSample.xyz * 2.0 - 1.0;
                    float3x3 TBN = float3x3(
                        normalize(i.worldTangent),
                        normalize(i.worldBitangent),
                        normalize(i.worldNormal)
                    );
                    float3 wNormal = normalize(mul(tNormal, TBN));
                    // View-space normal
                    float3 vNormal = normalize(mul((float3x3)UNITY_MATRIX_V, wNormal));
                    return fixed4(vNormal * 0.5 + 0.5, 1.0);
                }
                // Depth pass
                else if (mode == 2)
                {
                    float d = saturate(i.depth);
                    return fixed4(d, d, d, 1.0);
                }
                // Metallic pass
                else if (mode == 3)
                {
                    // R = metallic, A = smoothness (Standard shader convention)
                    return fixed4(bakeSample.r, bakeSample.r, bakeSample.r, bakeSample.a);
                }
                // Emission pass
                else
                {
                    return fixed4(bakeSample.rgb, albedo.a);
                }
            }
            ENDCG
        }
    }
    Fallback Off
}