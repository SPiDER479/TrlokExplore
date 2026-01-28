Shader "SgtCloud"
{
	Properties
	{
		[HideInInspector] _SGT_Detail("_MinStep", Vector) = (0,0,0,0)
		[HideInInspector] _SGT_Density("Density", Range(0, 100000)) = 1

		[HideInInspector] _SGT_Size("", Vector) = (0,0,0,0)
		[HideInInspector] _SGT_CullAltitude("", Float) = 0
		[HideInInspector] _SGT_Color("", Color) = (0,0,0,0)
		[HideInInspector] _SGT_ShadowDensity("", Float) = 0
		[HideInInspector] _SGT_LightDensity("", Float) = 0

		[Header(ERODE)]
		[Toggle(_SGT_ERODE)] _SGT_Erode("	Enable", Float) = 0
		[NoScaleOffset] _SGT_ErodeTex("	Tex", 3D) = "" {}
		[HideInInspector] _SGT_ErodeData("", Vector) = (0,0,0,0)
		
		[Header(ALBEDO)]
		[Toggle(_SGT_ALBEDO)] _SGT_Albedo("	Enable", Float) = 0
		
		[Header(SHADOW)]
		[Toggle(_SGT_SHADOW)] _SGT_Shadow("	Enable", Float) = 0

		[Header(SKY)]
		[Toggle(_SGT_SKY)] _SGT_Sky("	Enable", Float) = 0
	}
	SubShader
	{
		HLSLINCLUDE
			#pragma shader_feature_local _SGT_ERODE_OFF _SGT_ERODE
			#pragma shader_feature_local _SGT_ALBEDO_OFF _SGT_ALBEDO
			#pragma shader_feature_local _SGT_SHADOW_OFF _SGT_SHADOW
			#pragma shader_feature_local _SGT_SKY_OFF _SGT_SKY

			#include "SgtCloud.cginc"

			sampler2D _SGT_CoverageTex;
			float2    _SGT_CoverageTex_Size;

			float4 _SGT_Size;
			float  _SGT_CullStrength;
			float4 _SGT_Color;
			float4 _SGT_Color2;

			float    _SGT_Density; // Auto
			float    _SGT_LightStep;
			float4   _SGT_Detail;
			float    _SGT_Opacity;
			float    _SGT_ShadowDensity;
			
			sampler3D _SGT_ErodeTex;
			float4    _SGT_ErodeData;

			float4x4 _SGT_WorldToCloud;
			float4x4 _SGT_CloudToWorld;

			struct a2v
			{
				float4 vertex    : POSITION;
				float3 normal    : NORMAL;
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
			
			float SGT_GetDensity(float2 uv, float lod)
			{
				float4 coverage = tex2Dlod(_SGT_CoverageTex, float4(uv, 0, lod));
				float  den      = 0.0f;
				
				#if _SGT_ALBEDO
					den = coverage.w;
				#else
					den = dot(coverage.xyz, 1.0f);
				#endif

				return den;
			}

			float4 SGT_GetColorAndDensity(float3 p)
			{
				float2 uv        = SGT_DirectionToEquirectangular(p);
				float4 coverage  = tex2Dlod(_SGT_CoverageTex, float4(uv, 0.0f, 0.0f));
				float  height010 = saturate(1.0f - abs(length(p) - _SGT_Size.x) * _SGT_Size.y);
				float4 colDen    = 0.0f;
				
				#if _SGT_ALBEDO
					colDen.xyz = _SGT_Color.xyz * coverage.xyz;
					colDen.w   = height010 * coverage.w;
				#else
					colDen.xyz = lerp(_SGT_Color.xyz, _SGT_Color2.xyz, coverage.x);
					colDen.w   = height010 * dot(coverage.xyz, 1.0f);
				#endif

				return colDen;
			}
			
			float SGT_SampleCloudDensity(float3 cpos, float3 lightDir)
			{
				float3 chit = SGT_SphereTest(cpos, lightDir, _SGT_Size.w);
				float2 uv   = SGT_DirectionToEquirectangular(normalize(cpos + chit.y * lightDir));
				float  den  = saturate((_SGT_Size.x - length(cpos)) * _SGT_Size.y);
				
				float angle = saturate(dot(normalize(cpos), lightDir));
				
				return den * SGT_GetDensity(uv, 1.0f) * saturate(1.0f / (1.0f + 500.0f * chit.y));// * (1-pow(1-angle,2));
			}

			void Vert(a2v v, out v2f o)
			{
				o.pos      = UnityObjectToClipPos(v.vertex);
				o.uv       = v.texcoord0;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.localPos = v.vertex.xyz * 0.5 + 0.5; // local cube space [0..1]
				o.screenPos = ComputeScreenPos(o.pos);
				o.viewPosition = mul(UNITY_MATRIX_V, float4(o.worldPos, 1.0f));
			}

			float3 SGT_Rotate3(float3 p, float a)
			{
				float s = sin(a);
				float c = cos(a);

				return float3(c * p.x - s * p.y, s * p.x + c * p.y, p.z + a * 0.3f);
			}
			
			void SGT_Erode(float3 eyePos, float3 pos, inout float density)
			{
				float eyeD          = distance(eyePos, pos);
				float erodeCutoff   = 0.5;
				float erodeTiling   = _SGT_ErodeData.x;
				float erodeStrength = _SGT_ErodeData.y;
				float erodeRange    = _SGT_ErodeData.z;
				float erodeRecip    = _SGT_ErodeData.w;
				
				if (density < erodeCutoff && eyeD < erodeRange)
				{
					float distanceWeight = 1.0f - eyeD * erodeRecip;

					float  steps = (1.0f - distanceWeight * distanceWeight) * 5;
					float  i     = floor(steps);
					float  f     = steps - i;
					float3 uv    = pos * erodeTiling * pow(0.5f, i);
					
					float noiseA      = tex3Dlod(_SGT_ErodeTex, float4(uv * 1, 0)).x;
					float noiseB      = tex3Dlod(_SGT_ErodeTex, float4(uv * 2, 0)).x;
					float noise1      = (lerp(noiseB, noiseA, f) - 0.5f) * erodeStrength;
					float noiseWeight = density / erodeCutoff;
					
					noiseWeight *= 1.0f - noiseWeight;
					
					density += noise1 * distanceWeight * noiseWeight;
				}
			}

			void SGT_MarchSegment(float3 rayPos, float3 rayDir, float3 rayDst, inout float4 c, inout float2 d, float dither, float3 lightStep, inout float stepSize)
			{
				float3 eyePos = rayPos;

				float3 mid    = rayPos + rayDir * (rayDst.x + rayDst.z) * 0.5f;
				float  weight = pow(saturate(length(mid) / _SGT_Size.w), _SGT_CullStrength);
				
				float off = rayDst.x;
				rayPos += rayDir * rayDst.x;
				rayDst.xy -= off;
				float t = 0;

				[loop]
				for (int s = 0; s < 150 && t < rayDst.y && c.w > __SGT_CUTOFF; s++)
				{
					float  len    = min(stepSize, rayDst.y - t);
					float3 pos    = rayPos + rayDir * (t + stepSize * dither);
					float4 colDen = SGT_GetColorAndDensity(pos);
					
					colDen.w *= weight;

					if (colDen.w > 0.001f)
					{
						#if _SGT_ERODE
							SGT_Erode(eyePos, pos, colDen.w);
						#endif
					}
					
					float  transmittance = exp(-colDen.w * len * _SGT_Density);

					float shadow = SGT_GetColorAndDensity(pos + lightStep).w;
					colDen.xyz *= saturate(1.0f - 2.0f * shadow);
					float3 luminance     = colDen.xyz;
					//float3 luminance     = saturate((length(pos) - _SGT_Size.w) * _SGT_Size.y * 0.5);

					//d = float2(off + t, 1.0f) * c.w;
					d     += float2(off + t, 1.0f) * (1.0f - transmittance) * c.w;
					c.rgb += (luminance - luminance * transmittance) * c.w;
					c.w   *= transmittance;

					t += stepSize; stepSize *= _SGT_Detail.y;
				}
			}
			
			void SGT_MarchSegmentShadow(float3 rayPos, float3 rayDir, float3 rayDst, inout float4 c, inout float2 d, float dither, float3 lightDir)
			{
				float3 mid      = rayPos + rayDir * (rayDst.x + rayDst.z) * 0.5f;
				float  weight   = pow(saturate(length(mid) / _SGT_Size.w), _SGT_CullStrength);
				float  off      = rayDst.x;
				float  t        = 0.0f;
				float  stepSize = _SGT_Detail.z;
				
				rayPos += rayDir * rayDst.x;
				rayDst.xy -= off;
				
				[loop]
				for (int s = 0; s < 150 && t < rayDst.y && c.w > __SGT_CUTOFF; s++)
				{
					float  len    = min(stepSize, rayDst.y - t);
					float3 pos    = rayPos + rayDir * (t + stepSize * dither);
					float4 colDen = 0;
					
					colDen.w = weight * _SGT_ShadowDensity * SGT_SampleCloudDensity(pos, lightDir);
					
					float  transmittance = exp(-colDen.w * len * _SGT_Density);
					float3 luminance     = colDen.xyz;
					
					d     += float2(off + t, 1.0f) * (1.0f - transmittance) * c.w;
					c.rgb += (luminance - luminance * transmittance) * c.w;
					c.w   *= transmittance;

					t += stepSize; stepSize *= _SGT_Detail.y;
				}
			}

			void SGT_March(float3 rayPos, float3 rayDir, float rayMax, out float4 outColor, out float outDepth, float2 screenUV)
			{
				outColor = 0;
				outDepth = 0;

				// March
				float  stepSize = _SGT_Detail.x;
				float3 lightDir = normalize(mul(_SGT_WorldToCloud, float4(_SGT_LightDirection[0].xyz, 0.0f)).xyz);
				float  costh    = dot(rayDir, lightDir);
				float  dither   = SGT_DitherBlue(screenUV);
				float4 c        = float4(0.0f, 0.0f, 0.0f, 1.0f);
				float2 d        = 0.0f;

				// March one or two segments
				float3 outerHit = SGT_SphereTest(rayPos, rayDir, _SGT_Size.z);
				float3 innerHit = SGT_SphereTest(rayPos, rayDir, _SGT_Size.w);
				
				outerHit.xy = clamp(outerHit.xy, 0.0f, rayMax);
				innerHit.xy = clamp(innerHit.xy, 0.0f, rayMax);
				
				if (outerHit.z > 0.0f)
				{
					float3 lightStep = lightDir * _SGT_LightStep;
					
					if (innerHit.z < 0.0f) // One segment
					{
						float3 segment1 = float3(outerHit.x, outerHit.y, outerHit.x);
						
						SGT_MarchSegment(rayPos, rayDir, segment1, c, d.xy, dither, lightStep, stepSize);
					}
					else // Two segments
					{
						float3 segment1 = float3(outerHit.x, min(innerHit.x, outerHit.y), outerHit.x);
						float3 segment2 = float3(max(innerHit.y, outerHit.x), outerHit.y, outerHit.x);
						float3 segmentM = float3(segment1.y, segment2.x, outerHit.x);

						SGT_MarchSegment(rayPos, rayDir, segment1, c, d, dither, lightStep, stepSize);
						#if _SGT_SHADOW
							SGT_MarchSegmentShadow(rayPos, rayDir, segmentM, c, d, dither, lightDir);
						#endif
						SGT_MarchSegment(rayPos, rayDir, segment2, c, d, dither, lightStep, stepSize);
					}
				}

				if (c.w >= 1.0f - __SGT_CUTOFF)
				{
					discard;
				}

				float3 softPos  = rayPos + rayDir * (d.x / max(0.00001f, d.y));
				float4 softWPos = mul(_SGT_CloudToWorld, float4(softPos, 1.0f));

				outColor.rgb = c.rgb;
				outColor.a   = InverseLerpClamped(1.0f - __SGT_CUTOFF, __SGT_CUTOFF, c.w);
				outDepth     = distance(softWPos, _WorldSpaceCameraPos);
			}
		ENDHLSL

		Pass // Main 0
		{
			Blend One Zero, One Zero
			Cull Front
			ZWrite Off

			HLSLPROGRAM
			#pragma vertex Vert
			#pragma fragment Frag

			struct f2a
			{
				float4 color : SV_TARGET0;
				float4 depth : SV_TARGET1;
			};

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
				
				float3 rayPos = mul(_SGT_WorldToCloud, float4(worldPos, 1)).xyz;
				float3 rayDst = mul(_SGT_WorldToCloud, float4(worldPos + worldDir * worldMax, 1)).xyz;
				float3 rayDir = normalize(rayDst - rayPos);
				float  rayMax = distance(rayPos, rayDst);

				float4 color = 0.0f;
				float  depth = 0.0f;

				SGT_March(rayPos, rayDir, rayMax, color, depth, screenUV);

				#if _SGT_SKY
					float lighting = 1;
					float3 worldHit = worldPos + worldDir * depth;
					float4 skyColor = SGT_SimpleAtmosphere(worldPos, worldHit);
				
					color.xyz = lerp(color.xyz, skyColor.xyz * lighting, skyColor.w);
				#endif

				o.color = color;
				o.depth = float4(depth, 0.0f, 0.0f, 1.0f);
			}
			ENDHLSL
		} // Main 0
	}
}