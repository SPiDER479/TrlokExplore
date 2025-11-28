Shader "Hidden/SgtCloud_Coverage"
{
	Properties
	{
		_SGT_CoverageTex("Coverage Tex", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _SGT_USE_COVERAGE _SGT_GENERATE_COVERAGE
			#pragma multi_compile_local _SGT_DETAIL0 _SGT_DETAIL1 _SGT_DETAIL2 _SGT_DETAIL3
			#define SGT_MAX_RECTS 64

			#include "UnityCG.cginc"

			#if _SGT_DETAIL3
				#define _SGT_DETAIL_COUNT 3
			#elif _SGT_DETAIL2
				#define _SGT_DETAIL_COUNT 2
			#elif _SGT_DETAIL1
				#define _SGT_DETAIL_COUNT 1
			#else
				#define _SGT_DETAIL_COUNT 0
			#endif

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex    : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			sampler2D _SGT_CoverageTex;
			float2    _SGT_CoverageSize;
			float4x4  _SGT_Matrix;
			float     _SGT_CloudWarp;

			sampler _SGT_OldGradientTex;
			sampler _SGT_NewGradientTex;
			float   _SGT_OldNewTransition;

			sampler2D _SGT_DetailTex0; float4 _SGT_DetailData0; float4 _SGT_DetailChannels0;
			sampler2D _SGT_DetailTex1; float4 _SGT_DetailData1; float4 _SGT_DetailChannels1;
			sampler2D _SGT_DetailTex2; float4 _SGT_DetailData2; float4 _SGT_DetailChannels2;

			int    _SGT_RectCount;
			float4 _SGT_RectDataA[SGT_MAX_RECTS];
			float4 _SGT_RectDataB[SGT_MAX_RECTS];
			float4 _SGT_RectDataC[SGT_MAX_RECTS];

			void vert(a2v v, out v2f o)
			{
				o.vertex    = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
			}

			float SGT_GetOutsideDistance1(float3 ray, float3 rayD)
			{
				float B = dot(ray, rayD);
				float C = dot(ray, ray) - 1.0f;
				float D = B * B - C;
				return max(-B - sqrt(max(D, 0.0f)), 0.0f);
			}

			float4 remap4(float4 value, float4 valueMin, float4 valueMax)
			{
				return (value - valueMin) / (valueMax - valueMin);
			}

			float4 CW_Cubic(float v)
			{
				float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
				float4 s = n * n * n;
				float4 o;
				o.x = s.x;
				o.y = s.y - 4.0 * s.x;
				o.z = s.z - 4.0 * s.y + 6.0 * s.x;
				o.w = 6.0 - o.x - o.y - o.z;
				return float4(s.x, s.y - 4.0f * s.x, s.z - 4.0f * s.y + 6.0f * s.x, 6.0f - o.x - o.y - o.z);
			}

			float4 CW_SampleCubic(sampler2D sam, float2 uv, float2 size)
			{
				uv = uv * size - 0.5;

				float2 fxy    = frac(uv);
				float4 xcubic = CW_Cubic(fxy.x);
				float4 ycubic = CW_Cubic(fxy.y);
				float4 coord  = (uv.xxyy - fxy.xxyy) + float2 (-0.5, +1.5).xyxy;
				float4 s      = float4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
				float4 offset = (coord + float4(xcubic.yw, ycubic.yw) / s) / size.xxyy;
				float4 sample0 = tex2Dlod(sam, float4(offset.xz, 0.0f, 0.0f));
				float4 sample1 = tex2Dlod(sam, float4(offset.yz, 0.0f, 0.0f));
				float4 sample2 = tex2Dlod(sam, float4(offset.xw, 0.0f, 0.0f));
				float4 sample3 = tex2Dlod(sam, float4(offset.yw, 0.0f, 0.0f));
				float2 weights = s.xz / (s.xz + s.yw);

				return lerp(lerp(sample3, sample2, weights.x), lerp(sample1, sample0, weights.x), weights.y);
			}

			float SGT_SampleDetail(sampler2D detailTex, float noise, float2 coord)
			{
				float detailA = tex2Dlod(detailTex, float4(coord, 0.0f, 0.0f)).x;

				return noise;
			}

			float2 SGT_Rotate(float2 p, float angle)
			{
				float c = cos(angle); float s = sin(angle); return float2( p.x * c - p.y * s, p.x * s + p.y * c);
			}

			float4 SGT_CalculateCoords(float3 direction)
			{ 
				//float t = 0.25f - direction.x * rcp(abs(direction.x) + abs(direction.z)) * 0.25f;
				//float u = 0.5f - (direction.z < 0.0f ? -t : t);
				float u = 0.5f - atan2(direction.z, direction.x) / 3.1415926535f * 0.5f;
				float v = 0.5f + asin(direction.y) / 3.1415926535f;

				return float4(u, v, direction.xz * 0.25f);
			}

			float4 SGT_CalculateGradsX(float4 coords)
			{
				float4 grad = ddx(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
			}

			float4 SGT_CalculateGradsY(float4 coords)
			{
				float4 grad = ddy(coords); grad.x *= abs(grad.x) < 0.5f; return grad;
			}

			float2 SGT_Offset(float2 coords, int index, float tiling)
			{
				//coords.y += cos(coords.x * ceil(tiling / 2) * 6.2831853f) * 0.002;
				coords.xy += sin(float2(3,7) * index);
		
				return coords;
			}
	
			float4 SGT_SampleSphere(sampler2D samp, float4 coords, float4 gradsX, float4 gradsY, float tiling)
			{
				float bands    = max(tiling * 0.25f, 1);
				float poles    = abs(coords.y * 4.0f - 1.0f); poles = 1.0f - poles * poles;
				float vertical = coords.y * 16 * bands + cos(coords.x * ceil(tiling / 3) * 6.2831853f) * 2 * poles;

				float indexA = floor(vertical);
				float indexB = indexA + 1.0f;

				float overA = abs(indexA - bands * 4.0f) >= bands * 2.5f;
				float overB = abs(indexB - bands * 4.0f) >= bands * 2.5f;

				float2 coordA = SGT_Offset(overA ? coords.zw : coords.xy, indexA, tiling);
				float2 coordB = SGT_Offset(overB ? coords.zw : coords.xy, indexB, tiling);

				float4 sampleA = tex2Dgrad(samp, coordA * tiling, (overA ? gradsX.zw : gradsX.xy) * tiling, (overA ? gradsY.zw : gradsY.xy) * tiling);
				float4 sampleB = tex2Dgrad(samp, coordB * tiling, (overB ? gradsX.zw : gradsX.xy) * tiling, (overB ? gradsY.zw : gradsY.xy) * tiling);

				return lerp(sampleA, sampleB, frac(vertical));
			}

			float4 SGT_ContributeDetail(float4 coverage, float3 direction, float4 coords, sampler2D detailTex, float4 detailData, float4 detailChannels)
			{
				float tiling = round(1.0f / detailData.z);
				float speed  = detailData.w / tiling;

				coords.x  += speed;
				coords.zw  = SGT_Rotate(coords.zw, speed * 3.1415926535f * -2.0f);

				float4 gradsX = SGT_CalculateGradsX(coords);
				float4 gradsY = SGT_CalculateGradsY(coords);

				float4 detail = SGT_SampleSphere(detailTex, coords, gradsX, gradsY, tiling).x * detailChannels;

				return remap4(coverage - detail * detailData.y, detail * detailData.x, 1.0f);
				//return coverage - tex3D(detailTex, position / detailScale + _Time.x * detailSpeed) * detailStrength;
			}

			float4 SGT_Lerp(float4 a, float4 b, float t)
			{
				float4 delta   = b - a;
				float  minimum = 1.0f / 255.0f;

				return a + sign(delta) * min(abs(delta), minimum);
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 coord       = i.texcoord0.xy * 2.0f - 1.0f;
				float2 warpedCoord = coord * pow(saturate(length(coord)), _SGT_CloudWarp);

				float3 rayP = float3(-warpedCoord.x, warpedCoord.y, -1.0f);
				float3 rayD = float3(0.0f, 0.0f, 1.0f);
				float  rayX = dot(rayP, rayD);
				float  rayY = dot(rayP, rayP) - 1.0f;
				float  rayZ = rayX * rayX - rayY; if (rayZ < 0.0f) return 0; // Miss
				float  rayL = max(-rayX - sqrt(rayZ), 0.0f);

				float3 d      = normalize(mul((float3x3)_SGT_Matrix, rayP + rayD * rayL));
				float4 coords = SGT_CalculateCoords(d);

				#if _SGT_GENERATE_COVERAGE
					float4 col = 0.0f;

					for (int i = 0; i < _SGT_RectCount; i++)
					{
						float4 rectDataA = _SGT_RectDataA[i];
						float4 rectDataB = _SGT_RectDataB[i];
						float4 rectDataC = _SGT_RectDataC[i];

						if (abs(rectDataA.x - coords.y) < abs(rectDataA.y))
						{
							float  u = (coords.x + rectDataB.x) * rectDataB.y;
							float  v = lerp(rectDataA.z, rectDataA.w, (coords.y - rectDataA.x) / rectDataA.y * 0.5f + 0.5f);
							float4 c = tex2Dlod(_SGT_CoverageTex, float4(u, v, 0, 0)).x * rectDataB.z * rectDataC;
							//float4 c = CW_SampleCubic(_SGT_CoverageTex, float2(u, v), _SGT_CoverageSize).x * rectDataC;

							col += c * (1.0f - col);
						}
					}
				#else
					//float4 col = tex2Dlod(_SGT_CoverageTex, float4(u, v, 0, 0));
					float4 col = CW_SampleCubic(_SGT_CoverageTex, float2(coords.x, coords.y), _SGT_CoverageSize);

					coords.y *= 0.5f;
				#endif

				#if _SGT_DETAIL_COUNT >= 1
					col = SGT_ContributeDetail(col, d, coords, _SGT_DetailTex0, _SGT_DetailData0, _SGT_DetailChannels0);
				#endif

				#if _SGT_DETAIL_COUNT >= 2
					col = SGT_ContributeDetail(col, d, coords, _SGT_DetailTex1, _SGT_DetailData1, _SGT_DetailChannels1);
				#endif

				#if _SGT_DETAIL_COUNT >= 3
					col = SGT_ContributeDetail(col, d, coords, _SGT_DetailTex2, _SGT_DetailData2, _SGT_DetailChannels2);
				#endif

				return saturate(col);
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _SGT_NO_COLORING _SGT_GRADIENT_COLORING

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex    : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			float4x4  _SGT_Matrix;
			float     _SGT_CloudWarp;
			sampler2D _SGT_GradientTex;
			float4    _SGT_Variation;
			sampler2D _SGT_CloudCoverageTex;

			void vert(a2v v, out v2f o)
			{
				o.vertex    = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
			}

			float4 CW_Cubic(float v)
			{
				float4 n = float4(1.0, 2.0, 3.0, 4.0) - v;
				float4 s = n * n * n;
				float4 o;
				o.x = s.x;
				o.y = s.y - 4.0 * s.x;
				o.z = s.z - 4.0 * s.y + 6.0 * s.x;
				o.w = 6.0 - o.x - o.y - o.z;
				return float4(s.x, s.y - 4.0f * s.x, s.z - 4.0f * s.y + 6.0f * s.x, 6.0f - o.x - o.y - o.z);
			}

			float4 CW_SampleCubic(sampler2D sam, float2 uv, float2 size)
			{
				uv = uv * size - 0.5;

				float2 fxy    = frac(uv);
				float4 xcubic = CW_Cubic(fxy.x);
				float4 ycubic = CW_Cubic(fxy.y);
				float4 coord  = (uv.xxyy - fxy.xxyy) + float2 (-0.5, +1.5).xyxy;
				float4 s      = float4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
				float4 offset = (coord + float4(xcubic.yw, ycubic.yw) / s) / size.xxyy;
				float4 sample0 = tex2Dlod(sam, float4(offset.xz, 0.0f, 0.0f));
				float4 sample1 = tex2Dlod(sam, float4(offset.yz, 0.0f, 0.0f));
				float4 sample2 = tex2Dlod(sam, float4(offset.xw, 0.0f, 0.0f));
				float4 sample3 = tex2Dlod(sam, float4(offset.yw, 0.0f, 0.0f));
				float2 weights = s.xz / (s.xz + s.yw);

				return lerp(lerp(sample3, sample2, weights.x), lerp(sample1, sample0, weights.x), weights.y);
			}

			float4 SGT_CalculateCoords(float3 direction)
			{
				float u = 0.5f - atan2(direction.z, direction.x) / 3.1415926535f * 0.5f;
				float v = 0.5f + asin(direction.y) / 3.1415926535f;

				return float4(u, v * 0.5f, direction.xz * 0.25f);
			}

			float4 frag(v2f i) : SV_Target
			{
				float2 coord       = i.texcoord0.xy * 2.0f - 1.0f;
				float2 warpedCoord = coord * pow(saturate(length(coord)), _SGT_CloudWarp);

				float3 rayP = float3(-warpedCoord.x, warpedCoord.y, -1.0f);
				float3 rayD = float3(0.0f, 0.0f, 1.0f);
				float  rayX = dot(rayP, rayD);
				float  rayY = dot(rayP, rayP) - 1.0f;
				float  rayZ = rayX * rayX - rayY; if (rayZ < 0.0f) return 0; // Miss
				float  rayL = max(-rayX - sqrt(rayZ), 0.0f);

				float3 d   = normalize(mul((float3x3)_SGT_Matrix, rayP + rayD * rayL));
				float4 col = tex2Dlod(_SGT_CloudCoverageTex, float4(i.texcoord0.xy, 0, 0));

				#if _SGT_GRADIENT_COLORING
					col = tex2D(_SGT_GradientTex, _SGT_Variation.xy + _SGT_Variation.zw * float2(d.y * 0.5f + 0.5f, max(max(col.x, col.y), max(col.z, col.w))));
				#endif

				return saturate(col);
			}
			ENDCG
		} // Pass

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex    : POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex    : SV_POSITION;
				float2 texcoord0 : TEXCOORD0;
			};

			sampler2D _SGT_Tex;


			void vert(a2v v, out v2f o)
			{
				o.vertex    = UnityObjectToClipPos(v.vertex);
				o.texcoord0 = v.texcoord0;
			}

			float4 frag(v2f i) : SV_Target
			{
				//return tex2D(_SGT_Tex, i.texcoord0.xy);
				float4 o = float2(-0.5f, 0.5f).xxyy / float2(1024,1024).xyxy;
				float4 s =
					tex2D(_SGT_Tex, i.texcoord0 + o.xy) +
					tex2D(_SGT_Tex, i.texcoord0 + o.zy) +
					tex2D(_SGT_Tex, i.texcoord0 + o.xw) +
					tex2D(_SGT_Tex, i.texcoord0 + o.zw);
				return s * 0.25f;
			}
			ENDCG
		} // Pass
	}
}
