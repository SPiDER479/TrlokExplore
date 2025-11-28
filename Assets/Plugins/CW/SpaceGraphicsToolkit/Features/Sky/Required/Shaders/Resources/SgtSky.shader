Shader "Hidden/SgtSky"
{
	Properties
	{
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		ZTest Always
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			Cull Front
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _SGT_UNLIT _SGT_ONE_LIGHT
			#pragma multi_compile_local _SGT_SHARP _SGT_SMOOTH
			#pragma multi_compile_local _SGT_CLOUDS_OFF _SGT_CLOUDS _SGT_CLOUDS_ALBEDO
			#pragma multi_compile_local _SGT_CARVE0 _SGT_CARVE1 _SGT_CARVE2
			#define __SGT_CLOUD_STEPS 5
			#define __SGT_CUTOFF      0.01

			#include "UnityCG.cginc"
			#include "SgtSky.cginc"

			float     _SGT_LightingDensity;
			float     _SGT_LightingScale;
			sampler2D _SGT_CoverageTex;
			float     _SGT_CloudWarp;
			float4    _SGT_Color;
			float     _SGT_Brightness;
			float4    _SGT_Density;
			float4    _SGT_Weight;
			float     _SGT_Detail;
			float     _SGT_AltitudeScale;
			float     _SGT_SilhouetteRange;
			float     _SGT_DepthOpaque;
			float4x4  _SGT_ViewProj;

			float  _SGT_SmoothRange;

			sampler2D _SGT_CloudAlbedoTex;
			
			float4 _SGT_CloudColor;
			float4 _SGT_CloudLayerHeight;
			float4 _SGT_CloudLayerThickness;
			float4 _SGT_CloudLayerDensity;
			float4 _SGT_CloudLayerShape;

			float3    _SGT_AmbientColor;
			sampler2D _SGT_LightingTex;

			float4    _SGT_ScatteringTerms;
			float4    _SGT_ScatteringPower;
			sampler2D _SGT_ScatteringTex;
			
			sampler3D _SGT_CarveTex0;
			sampler3D _SGT_CarveTex1;
			float4    _SGT_CarveData0;
			float4    _SGT_CarveData1;
			float4    _SGT_CarveWeights0;
			float4    _SGT_CarveWeights1;

			float SGT_GetDensity1(float4 density4)
			{
				return max(max(density4.x, density4.y), max(density4.z, density4.w));
			}
			
			float2 WorldDirToEquirectUV(float3 dir)
			{
				// Normalize direction to ensure correct mapping
				dir = normalize(dir);

				float2 uv;
				uv.x = (atan2(dir.z, dir.x) / (2.0 * UNITY_PI)) + 0.5;
				uv.y = 0.5 - (asin(dir.y) / UNITY_PI);
				
				return uv;
			}

			float4 CW_Remap(float4 value, float4 valueMin, float4 valueMax)
			{
				return (value - valueMin) / (valueMax - valueMin);
			}

			float4 CW_Carve(float4 coverage, float3 p, sampler3D tex, float4 data, float4 weights)
			{
				float detail = 1.0f - tex3Dlod(tex, float4(p * data.x, 0.0f)).x;

				float4 f = 1.0 - coverage;
				float4 a = detail * weights + (1.0f - weights);
				//return saturate(lerp(coverage, coverage - detail * data.y, 1.0f - coverage));
				//return saturate(coverage - detail * data.y);
				return saturate(CW_Remap(a, f, f + (1.0f - weights)));
				
				//float weight = saturate(1.0f - coverage / data.y);
				
				//return lerp(coverage, coverage * detail, weight * weight);
			}

			float4 SGT_GetDensity4(float3 p, float alt01, inout float4 col)
			{
				float2 w = float2(-p.x, p.y);
				float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));

				float4 c = tex2Dlod(_SGT_CoverageTex, float4(z * 0.5f + 0.5f, 0, 0));
				float4 t = pow(abs(alt01 - _SGT_CloudLayerHeight) / _SGT_CloudLayerThickness, _SGT_CloudLayerShape) * _SGT_CloudLayerThickness;
				float4 e = max(0.0f, c * _SGT_CloudLayerThickness - t);
				
				#if !_SGT_CARVE0
					float3 p2 = mul(_SGT_Object2Local, float4(p,1)).xyz * 0.01f;
					
					e = CW_Carve(e, p2, _SGT_CarveTex0, _SGT_CarveData0, _SGT_CarveWeights0);
					#if _SGT_CARVE2
						e = CW_Carve(e, p2, _SGT_CarveTex1, _SGT_CarveData1, _SGT_CarveWeights1);
					#endif
				#endif

				col = tex2Dlod(_SGT_CloudAlbedoTex, float4(z * 0.5f + 0.5f, 0, 0));

				return e;
			}

			float4 SGT_GetDensityShadow4(float3 p, float alt01)
			{
				float2 w = float2(-p.x, p.y);
				float2 z = normalize(w) * pow(length(w), 1.0f / (_SGT_CloudWarp + 1.0f));

				float4 c = tex2Dlod(_SGT_CoverageTex, float4(z * 0.5f + 0.5f, 0, 0));
				float4 t = pow(max(0.0f, alt01 - _SGT_CloudLayerHeight) / _SGT_CloudLayerThickness, _SGT_CloudLayerShape) * _SGT_CloudLayerThickness;
				float4 e = max(0.0f, c * _SGT_CloudLayerThickness - t);

				#if !_SGT_CARVE0
					float3 p2 = mul(_SGT_Object2Local, float4(p,1)).xyz * 0.01f;
					
					e = CW_Carve(e, p2, _SGT_CarveTex0, _SGT_CarveData0, _SGT_CarveWeights0);
					#if _SGT_CARVE2
						e = CW_Carve(e, p2, _SGT_CarveTex1, _SGT_CarveData1, _SGT_CarveWeights1);
					#endif
				#endif

				return e;
			}

			float3 SGT_GetLuminance(float3 p, float stepSize)
			{
				#if _SGT_ONE_LIGHT && (_SGT_CLOUDS || _SGT_CLOUDS_ALBEDO)
					float4 shadow4 = 0.0f;
					float s = 1;
					float3 pStep = _SGT_LightDirection[0] * stepSize * _SGT_LightingScale / s;

					//for (int i = 0; i < s; i++)
					{
						p += pStep;

						float p01 = saturate((1.0f - length(p)) * _SGT_AltitudeScale);

						shadow4 += SGT_GetDensityShadow4(p, 1.0f - p01);
					}

					float shadow1 = SGT_GetDensity1(shadow4);

					return exp(-shadow1 * _SGT_LightingDensity);
				#else
					return 1.0f;
				#endif
			}

			float2 SGT_GetOutsideDistances(float3 ray, float3 rayD, float radius)
			{
				float B = -dot(ray, rayD);
				float C = dot(ray, ray) - radius * radius;
				float D = B * B - C;
				float E = sqrt(max(D, 0.0f));
				return float2(max(B - E, 0.0f), B + E);
			}

			struct f2g
			{
				float4 color    : SV_Target0;
				float4 distance : SV_Target1;
			};

			float SGT_SampleWorldWaterDepth(float2 screenUV)
			{
				float best = tex2D(_SGT_WaterDepthTexture, screenUV).x;
				
				/*
				#if _SGT_SMOOTH
					float2 delta = _SGT_SmoothRange / _ScreenParams.xy;
					for (int y = -1; y <= 1; y++)
					{
						for (int x = -1; x <= 1; x++)
						{
							if (x != 0 && y != 0)
							{
								best = max(best, tex2D(_SGT_WaterDepthTexture, screenUV + float2(x, y) * delta));
							}
						}
					}
				#endif
				*/

				return best;
			}

			void frag(v2f i, out f2g o)
			{
				o.color    =  0.0f;
				o.distance = -1.0f;

				fdata d = SGT_GetData(i);

				float3 rayDir = normalize(d.localPosition - d.localCamera);
				float2 rayDst = SGT_GetOutsideDistances(d.localCamera, rayDir, 1.0f);
				float3 rayPos = d.localCamera + rayDir * rayDst.x;
				
				float linearEyeDepth = SGT_GetLinearEyeDepth(d.screenUV);
				float worldBufferDist = linearEyeDepth * length(d.viewPosition.xyz / d.viewPosition.z);
				float worldWaterDepth = SGT_SampleWorldWaterDepth(d.screenUV);
				float worldWaterAlpha = tex2D(_SGT_WaterAlphaTexture, d.screenUV).x;

				if (worldWaterDepth > 0.0f)
				{
					worldBufferDist = min(worldBufferDist, worldWaterDepth);
				}

				float waterFactor = 1.0f;

				if (worldWaterDepth < 0.0f)
				{
					waterFactor = 1.0f - worldWaterAlpha;

					if (waterFactor < 0.001f)
					{
						discard;
					}
				}

				float3 worldBuffer     = _SGT_WCam - d.worldSpaceViewDir * worldBufferDist;
				float3 localBuffer     = mul(_SGT_World2Object, float4(worldBuffer, 1.0f)).xyz;
				float  localDist       = min(length(localBuffer - rayPos), rayDst.y);

				// Clouds begin behind the foreground?
				if (rayDst.x > distance(d.localCamera, localBuffer))
				{
					return;
				}

				float4 softPosition = 0.00001f;
				float  slope        = abs(dot(normalize(d.localPosition), rayDir));
				float  stepSize     = lerp(0.02f, 0.002f, pow(slope,0.45f)) / _SGT_Detail; // Increase ray density at zenith
				float  dither       = SGT_DitherBlue(d.screenUV);
				float4 cloudDensity = _SGT_CloudLayerDensity / stepSize;
				float4 c            = float4(0, 0, 0, 1);
				float  t            = stepSize * dither;

				[loop]
				for (int r = 0; r < 150 && t < localDist && c.a >= __SGT_CUTOFF; r++)
				{
					float  subSize = min(stepSize, localDist - t);
					float3 raySub  = rayPos + rayDir * t;

					// Atmosphere
					float  alt01    = saturate((1.0f - length(raySub)) * _SGT_AltitudeScale);
					float4 densityA = pow(alt01, _SGT_Weight) * _SGT_Density;
					float4 color    = float4(_SGT_Color.xyz + densityA.xyz, 1.0f) * (densityA.w + 0.00001f);

					#if _SGT_CLOUDS || _SGT_CLOUDS_ALBEDO
						float4 densityC;
						float4 density4 = SGT_GetDensity4(raySub, 1.0f - alt01, densityC);
						float  densityB = SGT_GetDensity1(density4 * cloudDensity) * subSize;

						color += _SGT_CloudColor * densityB;

						#if _SGT_CLOUDS_ALBEDO
							color.xyz *= densityC.xyz;
						#endif
					#endif

					//if (color.w > 0.01f)
					{
						float  transmittance = exp(-color.w * subSize);
						float3 luminance     = SGT_GetLuminance(raySub, 0.005f) * (color.xyz / color.w);

						softPosition += float4(raySub, 1.0f) * transmittance * c.a;
						//softDepth += float2(t, 1.0f) * c.a * (1.0f - transmittance);

						c.rgb += (luminance - luminance * transmittance) * c.a;
						c.a *= transmittance;
					}

					t += stepSize;
				}

				if (c.w > 0.99f)
				{
					discard;
				}

				c.a = saturate((c.a - __SGT_CUTOFF) / (1.0f - __SGT_CUTOFF));
				
				float4 opos  = softPosition / softPosition.w;
				float3 onorm = normalize(opos.xyz);
				float3 wpos  = mul(_SGT_Object2World, opos).xyz;

				float4 finalColor = float4(c.xyz * _SGT_Brightness, (1.0f - c.w) * waterFactor);
				float  finalDepth = distance(_SGT_WCam, wpos);
				float4 main       = finalColor;

				float scatteringMultiplier = saturate((worldBufferDist / finalDepth) * _SGT_SilhouetteRange);

				#if _SGT_ONE_LIGHT
					finalColor.rgb *= _SGT_AmbientColor;

					float4 lighting   = 0.0f;
					float4 scattering = 0.0f;

					for (int i = 0; i < _SGT_LightCount; i++)
					{
						float theta = dot(onorm, _SGT_LightDirection[i].xyz) * 0.5f + 0.5f;

						lighting += tex2D(_SGT_LightingTex, theta) * main * _SGT_LightColor[i];

						float3 worldViewDir  = normalize(wpos - _SGT_WCam);
						float3 worldLightDir = normalize(_SGT_LightPosition[i].xyz - _SGT_WCam);
						float  angle         = dot(worldViewDir, worldLightDir);
						float  phase         = SGT_ScatteringPhase(angle, _SGT_ScatteringTerms, _SGT_ScatteringPower);

						scattering += tex2D(_SGT_ScatteringTex, theta) * _SGT_LightColor[i] * phase;
					}

					#if _SGT_HDR || _HDRP
						scattering *= main;
						lighting.xyz += scattering.xyz;
					#else
						scattering *= finalColor.a; // Fade scattering out according to optical depth
						scattering *= 1.0f - finalColor.a;
						scattering *= saturate(1.0f - (finalColor + lighting)); // Only scatter into remaining rgba
						lighting += scattering * scatteringMultiplier;
					#endif

					finalColor += lighting * SGT_ShadowColor(wpos);
					finalColor.a = saturate(main.a);
				#endif

				float  cam01 = saturate((1.0f - length(d.localCamera)) * _SGT_AltitudeScale);
				float4 camD  = saturate(pow(cam01, _SGT_Weight) * _SGT_DepthOpaque);

				finalColor.a = lerp(finalColor.a, 1.0f, scatteringMultiplier * waterFactor * camD);

				float4 clipPos = mul(_SGT_ViewProj, float4(wpos, 1.0f));

				o.color      = finalColor;
				o.distance.x = finalDepth;
				o.distance.y = clipPos.z / clipPos.w;
				o.distance.w = 1;
			}
			ENDCG
		} // Pass
	}
}