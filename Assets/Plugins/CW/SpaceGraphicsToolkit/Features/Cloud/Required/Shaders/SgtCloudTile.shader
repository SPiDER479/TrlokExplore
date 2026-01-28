Shader "SgtCloudTile"
{
	Properties
	{
		_SGT_Curvature("Curvature", Range(0.0, 1.0)) = 0.5
		_SGT_Midpoint("Midpoint", Range(0.4, 0.6)) = 0.5

		[Header(LIGHT)]
		_SGT_LightScatter("	Scatter", Range(0, 10)) = 2
		_SGT_LightPowder("	Powder", Range(0, 1000)) = 1
		_SGT_LightAmbient("	Ambient", Range(0, 1)) = 0.5

		[Header(VARIATION)]
		[NoScaleOffset] _SGT_VariationTex("	Variation Tex", 2D) = "" {}
		_SGT_VariationTopMin("	Top Min", Float) = 2.0
		_SGT_VariationTopMax("	Top Max", Float) = 1.4
		_SGT_VariationTopRange("	Top Range", Range(0, 1)) = 0.5
		_SGT_VariationBotMin("	Bottom Min", Float) = 1.4
		_SGT_VariationBotMax("	Bottom Max", Float) = 1.1
		_SGT_VariationBotRange("	Bottom Range", Range(0, 1)) = 0.5

		[Header(ERODE)]
		[Toggle(_SGT_ERODE)] _SGT_Erode("	Enable", Float) = 0
		[NoScaleOffset] _SGT_ErodeTex("	Erode Tex", 3D) = "" {}
		[NoScaleOffset] _SGT_NoiseTex("	Noise Tex", 3D) = "" {}
		[HideInInspector] _SGT_ErodeData("", Vector) = (0,0,0,0)

		[Header(TWIST)]
		[Toggle(_SGT_TWIST)] _SGT_Twist("	Enable", Float) = 0
		_SGT_TwistStrength("	Strength", Float) = 1.1
	}
	SubShader
	{
		HLSLINCLUDE
			#pragma shader_feature_local _SGT_ERODE_OFF _SGT_ERODE
			#pragma shader_feature_local _SGT_TWIST_OFF _SGT_TWIST

			#include "SgtCloud.cginc"

			float _SGT_Curvature;
			float _SGT_Midpoint;

			sampler2D _SGT_Shape; // Auto
			float3    _SGT_ShapeSize; // Auto
			float     _SGT_CloudDensity; // Auto
			float4    _SGT_CloudShells; // x = radius - thickness/2, y = radius + thickness/2, z = radius, w = 2/thickness
			float4    _SGT_CloudSize; // xyz = localScale, w = thickness
			float4    _SGT_CloudExtrude;
			float4    _SGT_StepData; // x = min step, y = step scale

			// VARIATION
			sampler2D _SGT_VariationTex;
			float     _SGT_VariationTiling; // Auto
			float     _SGT_VariationTopMin;
			float     _SGT_VariationTopMax;
			float     _SGT_VariationTopRange;
			float     _SGT_VariationBotMin;
			float     _SGT_VariationBotMax;
			float     _SGT_VariationBotRange;

			// ERODE
			sampler3D _SGT_ErodeTex;
			sampler3D _SGT_NoiseTex;
			float4    _SGT_ErodeData;

			// TWIST
			float _SGT_TwistStrength;

			float4x4  _SGT_ShadowV;
			float4x4  _SGT_ShadowIV;
			float4x4  _SGT_ShadowVP;
			sampler2D _SGT_ShadowTex;
			float4    _SGT_ShadowData;
			float4    _SGT_ShadowSize;
			float     _SGT_ShadowDensity;

			float    _SGT_LightStep; // Auto
			float    _SGT_LightDensity; // Auto
			float    _SGT_LightPowder;
			float    _SGT_LightAmbient;
			float    _SGT_LightScatter;
			
			float4x4 _SGT_World2Sky;
			float4x4 _SGT_Sky2Cloud;
			float4x4 _SGT_Cloud2Sky;

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos          : SV_POSITION;
				float2 uv           : TEXCOORD0;
				float3 worldPos     : TEXCOORD1;
				float3 localPos     : TEXCOORD2;
				float4 screenPos    : TEXCOORD3;
				float3 viewPosition : TEXCOORD4;
			};

			void SGT_Erode(float3 cloudPos, inout float density)
			{
				if (density > 0)
				{
					cloudPos *= _SGT_ErodeData.xyz;
					cloudPos.x += _Time.x;

					float4 noise4 = tex3Dlod(_SGT_ErodeTex, float4(cloudPos, 1));
					//float  noise  = lerp(noise4.z, noise4.z, saturate(density));
					float noise = noise4.z;

					density = max(0.0f, density - noise * _SGT_ErodeData.w);
				}
			}

			float2 SGT_GetCloudDistances(float3 localPos, float3 localDir, float cloudMax)
			{
				// Box intersection [-0.5, 0.5]
				float3 tMin  = (-float3(0.5f, 0.5f, 0.5f) - localPos) / localDir;
				float3 tMax  = ( float3(0.5f, 0.5f, 0.5f) - localPos) / localDir;
				float3 t1    = min(tMin, tMax);
				float3 t2    = max(tMin, tMax);
				float  localMin = max(max(t1.x, t1.y), t1.z); localMin = max(0.0f, localMin);
				float  localMax = min(min(t2.x, t2.y), t2.z);

				return float2(max(0, localMin), min(localMax, cloudMax));
			}
		ENDHLSL

		Pass // Main 0
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Front
			
			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			struct f2a
			{
				float4 color : SV_TARGET0;
				float4 depth : SV_TARGET1;
			};

			void Vert(a2v v, out v2f o)
			{
				o.pos      = UnityObjectToClipPos(v.vertex);
				o.uv       = v.texcoord0;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.localPos = v.vertex.xyz * 0.5 + 0.5; // local cube space [0..1]
				o.screenPos = ComputeScreenPos(o.pos);
				o.viewPosition = mul(UNITY_MATRIX_V, float4(o.worldPos, 1.0f));
			}

			float4 SGT_GetNoise(float3 cloudPos)
			{
				float3 c = cloudPos * _SGT_ErodeData.xyz;

				float4 o = tex3Dlod(_SGT_ErodeTex, float4(c, 0));

				o.xy = 1-o.xy;

				return o;
			}

			float3 SGT_GetSDF(float3 cloudPos)
			{
				float2 coord = float2(cloudPos.x, -cloudPos.y) + 0.5f;
				float3 shape = tex2Dlod(_SGT_Shape, float4(coord, 0.0f, 0.0f)).xyz;

				shape.x = (shape.x - _SGT_Midpoint) * 128.0f;

				return shape;
			}

			float2 SGT_TwistCoord(float2 uv, float strength)
			{
				float twist = strength * (1.0 - length(uv));

				float s = sin(twist);
				float c = cos(twist);

				return float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
			}

			float SGT_GetDensity(float3 skyPos, float3 cloudPos, float3 shape, float noiseStrength)
			{
				float alt01 = InverseLerpClamped(_SGT_CloudShells.x, _SGT_CloudShells.y, length(skyPos));

				float2 twistedCloudPos = cloudPos.xy;

				#if _SGT_TWIST
					twistedCloudPos = SGT_TwistCoord(cloudPos.xy, _SGT_TwistStrength);
				#endif

				float2 coord = float2(twistedCloudPos.x, -twistedCloudPos.y) + 0.5f;
				float variation = 1.0f - tex2Dlod(_SGT_VariationTex, float4(coord * _SGT_VariationTiling, 0.0f, 0.0f)).x;

				float density = (-shape.x * shape.y * _SGT_CloudDensity);

				float botWeight = InverseLerpClamped(0.0f,        _SGT_VariationBotRange, alt01);
				float topWeight = InverseLerpClamped(1.0f, 1.0f - _SGT_VariationTopRange, alt01 + (_SGT_Curvature - shape.z * _SGT_Curvature));

				density *= pow(botWeight, lerp(_SGT_VariationBotMin, _SGT_VariationBotMax, variation));
				density *= pow(topWeight, lerp(_SGT_VariationTopMin, _SGT_VariationTopMax, variation * shape.z));

				cloudPos *= _SGT_ErodeData.xyz;
				//cloudPos.x += _Time.x;

				#if _SGT_ERODE
					float4 noise4 = tex3Dlod(_SGT_ErodeTex, float4(cloudPos, 1)); //noise4.xy = 1-noise4.xy;
					float noise = noise4.z;
					density -= noise * _SGT_ErodeData.w * noiseStrength;
				#endif

				return max(0.0f, density);
			}

			float3 HSVtoRGB(float3 hsv)
			{
				float3 rgb = hsv.z * (1.0 + hsv.y * (saturate(float3(0.0, 1.0, 2.0) - 1.0)));
				float k = fmod(hsv.x * 6.0, 6.0);
				float p = hsv.z * (1.0 - hsv.y);
				float q = hsv.z * (1.0 - hsv.y * frac(k));
				float t = hsv.z * (1.0 - hsv.y * (1.0 - frac(k)));

				if      (k < 1.0) rgb = float3(hsv.z, t, p);
				else if (k < 2.0) rgb = float3(q, hsv.z, p);
				else if (k < 3.0) rgb = float3(p, hsv.z, t);
				else if (k < 4.0) rgb = float3(p, q, hsv.z);
				else if (k < 5.0) rgb = float3(t, p, hsv.z);
				else              rgb = float3(hsv.z, p, q);

				return rgb;
			}

			// Main function: map step index -> color
			float3 StepToColor(int stepIndex, int totalSteps)
			{
				// Normalize step index into hue [0..1]
				float hue = frac((float)stepIndex / (float)totalSteps);

				// Use full saturation and medium-high value for clarity
				float saturation = 1.0;
				float value      = 1.0;

				return HSVtoRGB(float3(hue, saturation, value));
			}

			float SGT_GetLuminance(float3 skyPos, float3 skyLightStep)
			{
				float density = 0.0f;

				float3 skyLightPos   = skyPos + skyLightStep;
				float3 cloudLightPos = mul(_SGT_Sky2Cloud, float4(skyLightPos, 1.0f)).xyz;

				float alt01 = InverseLerpClamped(_SGT_CloudShells.x, _SGT_CloudShells.y, length(skyLightPos));

				float3 shape = SGT_GetSDF(cloudLightPos);

				density += SGT_GetDensity(skyLightPos, cloudLightPos, shape, 0.0f) * _SGT_LightDensity * pow(alt01, _SGT_LightScatter);

				return exp(-density);
			}

			void SGT_MarchSegment2(float3 skyPos, float3 skyDir, float2 skyDst, inout float4 c, inout float2 d, float dither, float3 skyLightStep, inout float stepSize, float3 eyePos)
			{
				float3 cloudPos = mul(_SGT_Sky2Cloud, float4(skyPos, 1.0f)).xyz;
				float3 cloudDir = mul(_SGT_Sky2Cloud, float4(skyDir, 0.0f)).xyz;

				float t = skyDst.x;

				[loop]
				for (int s = 0; s < 350 && t < skyDst.y && c.w > __SGT_CUTOFF; s++)
				{
					float3 cloudMid = cloudPos + cloudDir * (t + stepSize * dither);
					float3 skyMid   = mul(_SGT_Cloud2Sky, float4(cloudMid, 1.0f)).xyz;

					float3 shape = SGT_GetSDF(cloudMid);
					float  sdf   = shape.x;

					if (sdf < 0.0f)
					{
						float density = SGT_GetDensity(skyMid, cloudMid, shape, 1.0f);

						if (density > 0.0f)
						{
							float len = min(stepSize, skyDst.y - t);

							//density *= _SGT_CloudDensity;

							float  transmittance = exp(-len * density);
							float3 luminance     = SGT_GetLuminance(skyMid, skyLightStep);// * (1-pow(1-density,256));

							float powder = -_SGT_LightPowder + (_SGT_LightPowder + 1.0f) * (1-density);
							luminance *= saturate(1-powder);
							//luminance /= max(0.0001, 1-density);

							d     += float2(t, 1.0f) * (1.0f - transmittance) * c.w;
							c.rgb += (luminance - luminance * transmittance) * c.w;
							c.w   *= transmittance;
						}
					}

					t += max(sdf * 0.25f, stepSize);

					stepSize *= _SGT_StepData.y;
				}

				//c.rgb = StepToColor(s, 150);
			}

			void SGT_March2(float3 cloudPos, float3 cloudFar, out float4 outColor, out float outDepth, float2 screenUV, float waterFactor, float3 eyePos, float3 skyLightDir)
			{
				outColor = 0;
				outDepth = 0;

				float3 skyPos = mul(_SGT_Cloud2Sky, float4(cloudPos, 1.0f)).xyz;
				float3 skyFar = mul(_SGT_Cloud2Sky, float4(cloudFar, 1.0f)).xyz;
				float3 skyDir = normalize(skyFar - skyPos);
				float  skyMax = distance(skyPos, skyFar);

				float  dither   = SGT_DitherBlue(screenUV);
				float4 c        = float4(0.0f, 0.0f, 0.0f, 1.0f);
				float2 d        = 0.0f;
				float  stepSize = _SGT_StepData.x;

				float3 outerHit = SGT_SphereTest(skyPos, skyDir, _SGT_CloudShells.y);
				float3 innerHit = SGT_SphereTest(skyPos, skyDir, _SGT_CloudShells.x);

				outerHit.xy = clamp(outerHit.xy, 0.0f, skyMax);
				innerHit.xy = clamp(innerHit.xy, 0.0f, skyMax);

				if (outerHit.z > 0.0f)
				{
					float3 skyLightStep = skyLightDir * _SGT_LightStep;// / _SGT_ErodeData.xyz;
					
					if (innerHit.z < 0.0f) // One segment
					{
						float2 segment1 = float2(outerHit.x, outerHit.y);
						
						SGT_MarchSegment2(skyPos, skyDir, segment1, c, d.xy, dither, skyLightStep, stepSize, eyePos);
					}
					else // Two segments
					{
						float2 segment1 = float2(outerHit.x, min(innerHit.x, outerHit.y));
						float2 segment2 = float2(max(innerHit.y, outerHit.x), outerHit.y);

						SGT_MarchSegment2(skyPos, skyDir, segment1, c, d, dither, skyLightStep, stepSize, eyePos);
						SGT_MarchSegment2(skyPos, skyDir, segment2, c, d, dither, skyLightStep, stepSize, eyePos);
					}
				}

				c.xyz += c.xyz * pow(saturate(dot(skyDir, skyLightDir)), 32); // Scattering

				c.xyz = lerp(c.xyz, 1.0f, _SGT_LightAmbient);

				float3 softSPos = skyPos + skyDir * (d.x / max(0.0001f, d.y));
				float3 softCPos = mul(_SGT_Sky2Cloud, float4(softSPos, 1.0f)).xyz;
				float3 softWPos = mul(unity_ObjectToWorld, float4(softCPos, 1.0f)).xyz;

				outColor.rgb = c.rgb;
				outColor.a = InverseLerpClamped(1.0f, __SGT_CUTOFF, c.w) * waterFactor;
				
				outDepth = distance(softWPos, _WorldSpaceCameraPos);
			}

			void Frag(v2f i, out f2a o)
			{
				float3 worldPos    = _WorldSpaceCameraPos;
				float3 worldDir    = normalize(i.worldPos - _WorldSpaceCameraPos);
				float  worldMax    = distance(worldPos, i.worldPos);
				float2 screenUV    = (i.screenPos.xy / i.screenPos.w);
				float  linearScale = length(i.viewPosition.xyz / i.viewPosition.z);

				if (unity_OrthoParams.w == 1.0f)
				{
					SGT_Ortho(i.worldPos, worldPos, worldDir);
				}

				// Depth clip
				float worldEyeDepth = SGT_GetLinearEyeDepth(screenUV) * linearScale;

				worldMax = min(worldMax, worldEyeDepth);

				// Convert to sky space
				float3 skyPos      = mul(_SGT_World2Sky, float4(worldPos, 1.0f)).xyz;
				float3 skyFar      = mul(_SGT_World2Sky, float4(worldPos + worldDir * worldMax, 1.0f)).xyz;
				float3 skyLightDir = mul(_SGT_World2Sky, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz;

				float4 color = 0.0f;
				float  depth = 0.0f;

				// Convert to cloud space
				float3 cloudPos = mul(_SGT_Sky2Cloud, float4(skyPos, 1.0f)).xyz;
				float3 cloudFar = mul(_SGT_Sky2Cloud, float4(skyFar, 1.0f)).xyz;
				float3 cloudDir = normalize(cloudFar - cloudPos);
				float2 cloudDst = SGT_GetCloudDistances(cloudPos, cloudDir, distance(cloudPos, cloudFar)); // Clip to cloud

				if (cloudDst.y <= cloudDst.x)
				{
					discard;
				}

				SGT_March2(cloudPos + cloudDir * cloudDst.x, cloudPos + cloudDir * cloudDst.y, color, depth, screenUV, 1.0f, skyPos, skyLightDir);

				if (color.a <= __SGT_CUTOFF)
				{
					discard;
				}

				o.color = color;
				o.depth = float4(depth, 0.0f, 0.0f, 1.0f);
			}
			ENDHLSL
		} // Main 0
	}
}