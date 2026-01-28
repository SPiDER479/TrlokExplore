Shader "Hidden/SgtVolumeFilter"
{
	SubShader
	{
		HLSLINCLUDE
			#include "UnityCG.cginc"

			float4 _SGT_Volumetrics_ColorSize;

			sampler2D_float _SGT_Volumetrics_DepthTex;
			sampler2D       _SGT_Volumetrics_ColorTex;

			sampler2D_float _SGT_Volumetrics_DepthTex_Temp;
			sampler2D       _SGT_Volumetrics_ColorTex_Temp;

			sampler2D_float _SGT_Volumetrics_DepthTex_Old;
			sampler2D       _SGT_Volumetrics_ColorTex_Old;

			sampler2D _SGT_Volumetrics_ShaftMask;

			sampler2D_float _SGT_SceneDepthTexture;

			// DITHER
			sampler2D _SGT_BlueNoiseTex; // Global
			float     _SGT_Frame; // Global
	
			float SGT_DitherBlue(float2 screenUV)
			{
				float2 pixel = floor(screenUV * _ScreenParams.xy);
				float  noise = tex2D(_SGT_BlueNoiseTex, pixel / 64.0f).r;
				return frac(noise + _SGT_Frame / sqrt(0.5f));
			}

			float4 GetFullScreenTriangleVertexPosition(uint vertexID, float z)
			{
				// note: the triangle vertex position coordinates are x2 so the returned UV coordinates are in range -1, 1 on the screen.
				float2 uv = float2((vertexID << 1) & 2, vertexID & 2);
				float4 pos = float4(uv * 2.0 - 1.0, z, 1.0);

				return pos;
			}

			struct Attributes
			{
				uint vertexID : SV_VertexID;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float4 positionCS : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			struct MRT1
			{
				float4 color : SV_Target0;
			};

			struct MRT2
			{
				float4 color : SV_Target0;
				float2 depth : SV_Target1;
			};

			Varyings Vert(Attributes input)
			{
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);
				output.positionCS = GetFullScreenTriangleVertexPosition(input.vertexID, 0.0f);
				output.positionCS = float4(input.texcoord0.xy * 2.0f - 1.0f, 0.5f, 1.0f);
				output.texcoord0  = input.texcoord0;

				#if UNITY_UV_STARTS_AT_TOP
					output.positionCS.y = -output.positionCS.y;
				#endif
				return output;
			}

			float4 SGT_SampleCloudColor0(sampler2D colorTex, float2 screenUV)
			{
				return tex2D(colorTex, screenUV);
			}

			float2 SGT_SampleCloudDepth0(sampler2D_float depthTex, float2 screenUV)
			{
				return tex2D(depthTex, screenUV).xy;
			}
		ENDHLSL

		Pass
		{
			Name "TAA"
			ZWrite Off
			ZTest Always
			Blend Off
			Cull Off

			HLSLPROGRAM
				#pragma vertex   Vert
				#pragma fragment Frag

				float4x4 _SGT_InvViewProj;
				float4x4 _SGT_PrevViewProj;
				float    _SGT_TAA;

				float4 SGT_ClampColorRegion(float2 uv, float4 prevColor)
				{
					float4 minColor = float4( 9999.0,  9999.0,  9999.0,  9999.0);
					float4 maxColor = float4(-9999.0, -9999.0, -9999.0, -9999.0);

					for (int x = -2; x <= 2; ++x)
					{
						for (int y = -2; y <= 2; ++y)
						{
							float4 color = tex2Dlod(_SGT_Volumetrics_ColorTex_Temp, float4(uv + float2(x, y) * _SGT_Volumetrics_ColorSize.zw * 1.5f, 0.0f, 0.0f));

							if (color.w > 0.0f)
							{
								minColor = min(minColor, color);
								maxColor = max(maxColor, color);
							}
						}
					}
					float validityFactor = 0;
					//return ClipCloudsToRegion(prevColor, minColor, maxColor, validityFactor);
					return clamp(prevColor, minColor, maxColor);
				}

				float LinearDepthToNDC(float linearDepthWS)
				{
					float viewZ = -linearDepthWS; // Unity view space is RH
					return UNITY_MATRIX_P._33 + UNITY_MATRIX_P._43 / viewZ;
				}

				float4 SGT_SampleOldColor(float2 uv, float4 newColor)
				{
					float depth = tex2Dlod(_SGT_Volumetrics_DepthTex_Old, float4(uv, 0.0f, 0.0f)).y;

					if (depth <= 0.0) return newColor;

					// Reconstruct NDC and clip space
					float4 clipPos = float4(uv * 2.0 - 1.0, depth, 1.0);

					// World position
					float4 worldPos = mul(_SGT_InvViewProj, clipPos);
					worldPos /= worldPos.w;

					// Reproject to previous frame
					float4 prevClip = mul(_SGT_PrevViewProj, worldPos);
					float2 uvPrev   = prevClip.xy / prevClip.w * 0.5 + 0.5;

					// If out of bounds, fallback
					if (any(uvPrev < 0.0) || any(uvPrev > 1.0)) return newColor;

					float4 prevColor = tex2Dlod(_SGT_Volumetrics_ColorTex_Old, float4(uvPrev, 0.0f, 0.0f));
					//float  prevDepth = tex2Dlod(_SGT_Volumetrics_DepthTex_Old, float4(uvPrev, 0.0f, 0.0f)).y;

					//if (abs(depth - prevDepth) > 0.05) return newColor;

					prevColor.rgb = SGT_ClampColorRegion(uv, prevColor);

					return prevColor;
				}

				// write whole
				MRT2 Frag(Varyings varyings)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
			
					MRT2 m;

					float4 newColor = SGT_SampleCloudColor0(_SGT_Volumetrics_ColorTex_Temp, varyings.texcoord0);
					float4 oldColor = SGT_SampleOldColor(varyings.texcoord0, newColor);
			
					m.color = lerp(oldColor, newColor, _SGT_TAA);
					m.depth = SGT_SampleCloudDepth0(_SGT_Volumetrics_DepthTex_Temp, varyings.texcoord0);
			
					return m;
				}
			ENDHLSL
		}

		Pass
		{
			Name "TAA2"
			ZWrite Off
			ZTest Always
			Blend Off
			Cull Off

			HLSLPROGRAM
				#pragma vertex   Vert
				#pragma fragment Frag

				// write old
				MRT2 Frag(Varyings varyings)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
			
					MRT2 m;
			
					m.color = SGT_SampleCloudColor0(_SGT_Volumetrics_ColorTex     , varyings.texcoord0);
					m.depth = SGT_SampleCloudDepth0(_SGT_Volumetrics_DepthTex_Temp, varyings.texcoord0);
			
					return m;
				}
			ENDHLSL
		}

		Pass
		{
			Name "SunMask"
			ZWrite Off
			ZTest Always
			Blend Off
			Cull Off

			HLSLPROGRAM
				#pragma vertex   Vert
				#pragma fragment Frag

				MRT1 Frag(Varyings varyings)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);

					MRT1 m;

					float occlusion = 0.0f;

					// Clouds
					float clouds = SGT_SampleCloudColor0(_SGT_Volumetrics_ColorTex, varyings.texcoord0).w;

					occlusion = lerp(occlusion, 1.0f, saturate(clouds));

					// Geometry
					float sceneDepth = tex2D(_SGT_SceneDepthTexture, varyings.texcoord0).x;
					float geometry   = sceneDepth > 0.0f && sceneDepth < 1000000000.0f;

					occlusion = lerp(occlusion, 1.0f, saturate(geometry));

					// Output
					m.color = float4(occlusion, 0.0f, 0.0f, 1.0f);

					return m;
				}
			ENDHLSL
		}

		Pass
		{
			Name "SunShafts"
			ZWrite Off
			ZTest Always
			Blend Off
			Cull Off

			HLSLPROGRAM
				#pragma vertex   Vert
				#pragma fragment Frag

				float3 _SGT_SunUV;

				MRT1 Frag(Varyings varyings)
				{
					UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(varyings);
			
					MRT1 m;

					float shafts = 1.0f;

					if (_SGT_SunUV.z > 0.0f)
					{
						int    stepCount = 32;
						float2 delta     = (_SGT_SunUV - varyings.texcoord0) / stepCount;
						float  total     = 0.0f;
						float  dither    = SGT_DitherBlue(varyings.texcoord0);
						float2 uv        = varyings.texcoord0 + delta * dither;

						for (int i = 0; i < stepCount; i++)
						{
							total += tex2D(_SGT_Volumetrics_ShaftMask, uv).x;

							uv += delta;
						}

						shafts = 1.0f - total / stepCount;

						shafts = lerp(1.0f, shafts, _SGT_SunUV.z);
					}
			
					m.color = float4(shafts, 0.0f, 0.0f, 1.0f);
			
					return m;
				}
			ENDHLSL
		}
	}
}
