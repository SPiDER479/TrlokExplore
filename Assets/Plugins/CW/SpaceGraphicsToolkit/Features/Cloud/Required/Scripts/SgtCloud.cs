using UnityEngine;
using CW.Common;
using System.Collections.Generic;
using SpaceGraphicsToolkit.Sky;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Volumetrics;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component renders a layer of volumetric clouds around a planet.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud")]
	public class SgtCloud : SgtVolumeEffect
	{
		[System.Serializable]
		public struct CloudLayerType
		{
			[Range(-1.0f, 1.0f)] public float Height;

			[Range(0.0f, 1.0f)] public float Thickness;

			[Range(0.0f, 1.0f)] public float Density;

			[Range(0.0f, 100.0f)] public float Shadow;

			[Range(0.0f, 5.0f)] public float Shape;
		}

		[System.Serializable]
		public class CoverageLayerType
		{
			public int Visual;

			public float Height;

			public float Thickness;

			public float Offset;

			public float Speed;

			public int Tiling;

			public float Opacity;

			public Vector4 Layers;
		}

		/// <summary>The Material used to render the cloud.
		/// NOTE: This must use the <b>SGT / Cloud</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>This texture defines where clouds appear around the planet.
		/// NOTE: This texture should use the equirectangular/cylindrical projection.</summary>
		public Texture CoverageTex { set { coverageTex = value; } get { return coverageTex; } } [SerializeField] private Texture coverageTex;

		/// <summary>The outer radius of the clouds in local space.</summary>
		public float OuterRadius { set { outerRadius = value; } get { return outerRadius; } } [SerializeField] private float outerRadius = 500.0f;

		/// <summary>The inner radius of the clouds in local space.</summary>
		public float InnerRadius { set { innerRadius = value; } get { return innerRadius; } } [SerializeField] private float innerRadius = 490.0f;

		/// <summary>If your clouds are for a gas giant without a solid core, you can specify the altitude where the clouds are culled out to improve performance and reduce graphical issues.</summary>
		public float CullStrength { set { cullStrength = value; } get { return cullStrength; } } [SerializeField] private float cullStrength = 128;

		/// <summary>The volumetric sorting offset, to make sure it renders in the correct order relative to the sky.</summary>
		public float SortOffset { set { sortOffset = value; } get { return sortOffset; } } [SerializeField] private float sortOffset = 0.01f;

		/// <summary>The erosion texture is tiled this many times around the planet.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeTiling { set { erodeTiling = value; } get { return erodeTiling; } } [SerializeField] private float erodeTiling = 70.0f;

		/// <summary>The erosion will begin when the camera is within this distance of the clouds.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeRange { set { erodeRange = value; } get { return erodeRange; } } [SerializeField] [Range(0.01f, 0.5f)] private float erodeRange = 0.2f;

		/// <summary>The erosion texture will cut away this much from the cloud cover.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeStrength { set { erodeStrength = value; } get { return erodeStrength; } } [SerializeField] [Range(0.1f, 2.0f)] private float erodeStrength = 2.0f;

		/// <summary>If you want atmospheric effects to apply to this cloud, drag and drop it into here.</summary>
		public SgtSky Sky { set { sky = value; } get { return sky; } } [SerializeField] private SgtSky sky;

		/// <summary>The maximum density of clouds.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 5000.0f;

		/// <summary>The height of the generated cloud texture. The width will be set to double this.</summary>
		public int Resolution { set { resolution = value; } get { return resolution; } } [SerializeField] private int resolution = 1024;

		/// <summary>Use a high precision cloud texture for smoother results?</summary>
		public bool HighPrecision { set { highPrecision = value; } get { return highPrecision; } } [SerializeField] private bool highPrecision = true;

		/// <summary>The color of the clouds.</summary>
		public Color Color { set { color = value; } get { return color; } } [SerializeField] private Color color = Color.white;

		/// <summary>The color values will be multiplied by this.</summary>
		public Color Color2 { set { color2 = value; } get { return color2; } } [SerializeField] private Color color2 = Color.white;

		/// <summary>The color rgb values will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 1.0f;

		/// <summary>How much sunlight is blocked underneath clouds.</summary>
		public float ShadowDensity { set { shadowDensity = value; } get { return shadowDensity; } } [SerializeField] [Range(0.0f, 1.0f)] private float shadowDensity = 0.1f;

		/// <summary>How much the shadows darken the planet or ocean.</summary>
		public float ShadowOpacity { set { shadowOpacity = value; } get { return shadowOpacity; } } [SerializeField] [Range(0.0f, 10.0f)] private float shadowOpacity = 1.0f;

		/// <summary>How the cloud lighting is influenced by the cloud density and sun direction.</summary>
		public float ShadowOffset { set { shadowOffset = value; } get { return shadowOffset; } } [SerializeField] [Range(0.001f, 1.0f)] private float shadowOffset = 0.6f;

		/// <summary>The detail of the shadows when ray marching.</summary>
		public float ShadowDetail { set { shadowDetail = value; } get { return shadowDetail; } } [SerializeField] [Range(0.0f, 1.0f)] private float shadowDetail = 0.8f;

		/// <summary>The near detail of the clouds when ray marching.</summary>
		public float NearDetail { set { nearDetail = value; } get { return nearDetail; } } [SerializeField] [Range(0.0f, 1.0f)] private float nearDetail = 0.07f;

		/// <summary>The distant detail of the clouds when ray marching.</summary>
		public float FarDetail { set { farDetail = value; } get { return farDetail; } } [SerializeField] [Range(0.0f, 1.0f)] private float farDetail = 0.0f;

		/// <summary>Generate a coverage texture for the cloud rendering?</summary>
		public bool Coverage { set { coverage = value; } get { return coverage; } } [SerializeField] private bool coverage;

		/// <summary>The texture bundle used to generate the coverage texture.</summary>
		public SgtCloudBundle CoverageBundle { set { coverageBundle = value; } get { return coverageBundle; } } [SerializeField] private SgtCloudBundle coverageBundle;

		/// <summary>This allows you to add bands of texture from the <b>CoverageBundle</b>.</summary>
		public List<CoverageLayerType> CoverageLayers { get { if (coverageLayers == null) coverageLayers = new List<CoverageLayerType>(); return coverageLayers; } } [SerializeField] [UnityEngine.Serialization.FormerlySerializedAs("albedoLayers")] private List<CoverageLayerType> coverageLayers;

		/// <summary>If the <b>SgtCloudDetail</b> components have changed, calling this will force them to update.</summary>
		public void MarkDetailDirty()
		{
			dirtyDetail = true;
		}

		[System.NonSerialized]
		private static Mesh sphereMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private bool dirtyDetail = true;

		[System.NonSerialized]
		private RenderTexture generatedCoverageTexture;

		[System.NonSerialized]
		private List<SgtCloudDetail> detailLayers = new List<SgtCloudDetail>();

		[System.NonSerialized]
		private Material coverageMaterial;

		private static readonly int _SGT_CoverageTex          = Shader.PropertyToID("_SGT_CoverageTex");
		private static readonly int _SGT_CoverageTex_Size     = Shader.PropertyToID("_SGT_CoverageTex_Size");
		private static readonly int _SGT_Size                 = Shader.PropertyToID("_SGT_Size");
		private static readonly int _SGT_CullStrength         = Shader.PropertyToID("_SGT_CullStrength");
		private static readonly int _SGT_CoverageSize         = Shader.PropertyToID("_SGT_CoverageSize");
		private static readonly int _SGT_Density              = Shader.PropertyToID("_SGT_Density");
		private static readonly int _SGT_LightStep            = Shader.PropertyToID("_SGT_LightStep");
		private static readonly int _SGT_Color                = Shader.PropertyToID("_SGT_Color");
		private static readonly int _SGT_Color2               = Shader.PropertyToID("_SGT_Color2");
		private static readonly int _SGT_RectCount            = Shader.PropertyToID("_SGT_RectCount");
		private static readonly int _SGT_RectDataA            = Shader.PropertyToID("_SGT_RectDataA");
		private static readonly int _SGT_RectDataB            = Shader.PropertyToID("_SGT_RectDataB");
		private static readonly int _SGT_RectDataC            = Shader.PropertyToID("_SGT_RectDataC");
		private static readonly int _SGT_WorldToCloud         = Shader.PropertyToID("_SGT_WorldToCloud");
		private static readonly int _SGT_CloudToWorld         = Shader.PropertyToID("_SGT_CloudToWorld");
		private static readonly int _SGT_Detail               = Shader.PropertyToID("_SGT_Detail");
		private static readonly int _SGT_ShadowDensity        = Shader.PropertyToID("_SGT_ShadowDensity");
		private static readonly int _SGT_CloudShadowTex       = Shader.PropertyToID("_SGT_CloudShadowTex");
		private static readonly int _SGT_CloudShadowMatrix    = Shader.PropertyToID("_SGT_CloudShadowMatrix");
		private static readonly int _SGT_CloudShadowDirection = Shader.PropertyToID("_SGT_CloudShadowDirection");
		private static readonly int _SGT_CloudShadowOpacity   = Shader.PropertyToID("_SGT_CloudShadowOpacity");
		private static readonly int _SGT_ErodeData            = Shader.PropertyToID("_SGT_ErodeData");

		public RenderTexture GeneratedCoverageTexture
		{
			get
			{
				return generatedCoverageTexture;
			}
		}

		public static SgtCloud Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtCloud Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CwHelper.CreateGameObject("Cloud", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtCloud>();
		}

		public override void CalculateSortDistance(Vector3 worldPoint)
		{
			var localPoint = transform.InverseTransformPoint(worldPoint);
			var distFromCenter = localPoint.magnitude;
			var midRadius = (innerRadius + outerRadius) * 0.5f;

			// Clamp to shell bounds
			var clampedDist = Mathf.Clamp(distFromCenter, innerRadius, outerRadius);
			var closestPoint = localPoint.normalized * clampedDist;

			var worldClosestPoint = transform.TransformPoint(closestPoint);

			sortDistance = Vector3.Distance(worldPoint, worldClosestPoint) - sortOffset;
		}

		public override void RenderBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
			if (material != null)
			{
				if (sky != null)
				{
					sky.ApplySettings(properties);
				}

				if (generatedCoverageTexture != null)
				{
					properties.SetTexture(_SGT_CoverageTex, generatedCoverageTexture);
					properties.SetVector(_SGT_CoverageTex_Size, new Vector4(generatedCoverageTexture.width, generatedCoverageTexture.height));
				}
				else if (coverageTex != null)
				{
					properties.SetTexture(_SGT_CoverageTex, coverageTex);
					properties.SetVector(_SGT_CoverageTex_Size, new Vector4(coverageTex.width, coverageTex.height));
				}
				
				var inflate = 1.02f;
				var radO = 1.0f;
				var radI = radO * (innerRadius / outerRadius);

				var mat = transform.localToWorldMatrix * Matrix4x4.Scale(Vector3.one * outerRadius);

				var scale      = outerRadius * 2.0f;
				var worldToSky = Matrix4x4.Scale(new Vector3(scale, scale, scale)) * transform.worldToLocalMatrix;
				var detailX    = (radO - radI) / radO / Mathf.Lerp(5, 100, nearDetail);
				var detailY    = Mathf.Lerp(1.05f, 1.0f, farDetail);
				var detailZ    = detailX * Mathf.Lerp(200.0f, 1.0f, shadowDetail);

				properties.SetMatrix(_SGT_WorldToCloud, mat.inverse);
				properties.SetMatrix(_SGT_CloudToWorld, mat);

				properties.SetFloat(_SGT_Density, density);
				properties.SetFloat(_SGT_LightStep, (radO - radI) / radO * shadowOffset);
				properties.SetColor(_SGT_Color, color * brightness);
				properties.SetColor(_SGT_Color2, color2 * brightness);
				properties.SetVector(_SGT_Detail, new Vector4(detailX, detailY, detailZ));
				properties.SetFloat(_SGT_ShadowDensity, shadowDensity);
				properties.SetVector(_SGT_Size, new Vector4((radI + radO) * 0.5f, 2.0f / (radO - radI), radO, radI));
				properties.SetFloat(_SGT_CullStrength, cullStrength);

				// Erode
				properties.SetVector(_SGT_ErodeData, new Vector4(erodeTiling, erodeStrength, erodeRange, 1.0f / erodeRange));

				SgtVolumeCamera.AddDrawMesh(sphereMesh, 0, transform.localToWorldMatrix * Matrix4x4.Scale(Vector3.one * outerRadius * inflate * 2.0f), material, 0, properties);
			}
		}

		public void RandomizeColorHue()
		{
			var h = 0.0f;
			var s = 0.0f;
			var v = 0.0f;

			Color.RGBToHSV(color, out h, out s, out v);

			h = UnityEngine.Random.value;

			color = Color.HSVToRGB(h, s, v);
		}

		public void RandomizeColor2Hue()
		{
			var h = 0.0f;
			var s = 0.0f;
			var v = 0.0f;

			Color.RGBToHSV(color2, out h, out s, out v);

			h = UnityEngine.Random.value;

			color2 = Color.HSVToRGB(h, s, v);
		}

		public void RandomizeCoverageLayers()
		{
			if (coverageLayers != null)
			{
				foreach (var coverageLayer in coverageLayers)
				{
					if (coverageLayer != null)
					{
						var maxVisual = coverageBundle != null ? coverageBundle.Slices.Count : int.MaxValue;

						coverageLayer.Visual    = Random.Range(0, maxVisual);
						coverageLayer.Height    = Random.Range(0.1f, 0.9f);
						coverageLayer.Thickness = Random.Range(0.02f, 0.2f);
						coverageLayer.Offset    = Random.Range(0.0f, 1.0f);
						coverageLayer.Speed     = Random.Range(-0.001f, 0.001f);
						coverageLayer.Tiling    = Random.Range(1, 5);
						coverageLayer.Opacity   = Random.Range(0.5f, 1.0f);
						coverageLayer.Layers    = new Vector4(Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f));
					}
				}
			}
		}

		public void ApplyShadowSettings(MaterialPropertyBlock properties)
		{
			var generatedMatrix    = Matrix4x4.Scale(Vector3.one * (1.0f / outerRadius)) * transform.worldToLocalMatrix;
			var generatedDirection = Vector3.up;

			if (sky != null)
			{
				generatedDirection = transform.InverseTransformDirection(sky.LightDirection);
			}

			if (coverage == true)
			{
				if (generatedCoverageTexture == null)
				{
					UpdateCoverage();
				}

				properties.SetTexture(_SGT_CloudShadowTex, generatedCoverageTexture);
				properties.SetMatrix(_SGT_CloudShadowMatrix, generatedMatrix);
				properties.SetVector(_SGT_CloudShadowDirection, generatedDirection);
				properties.SetVector(_SGT_CloudShadowOpacity, new Vector4(shadowOpacity, 0.0f, 0.0f, 0.0f));
			}
			else if (coverageTex != null)
			{
				properties.SetTexture(_SGT_CloudShadowTex, coverageTex);
				properties.SetMatrix(_SGT_CloudShadowMatrix, generatedMatrix);
				properties.SetVector(_SGT_CloudShadowDirection, generatedDirection);
				properties.SetVector(_SGT_CloudShadowOpacity, new Vector4(shadowOpacity, 0.0f, 0.0f, 0.0f));
			}
			else
			{
				ClearShadowSettings(properties);
			}
		}

		public static void ClearShadowSettings(MaterialPropertyBlock properties)
		{
			properties.SetVector(_SGT_CloudShadowOpacity, new Vector4(0.0f, 0.0f, 0.0f, 0.0f));
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			if (sphereMesh == null)
			{
				var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);

				go.hideFlags = HideFlags.DontSave;

				sphereMesh = go.GetComponent<MeshFilter>().sharedMesh;

				DestroyImmediate(go);
			}

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			if (generatedCoverageTexture != null)
			{
				generatedCoverageTexture.Release();

				DestroyImmediate(generatedCoverageTexture);
			}

			DestroyImmediate(coverageMaterial);
		}

		private void CheckGeneratedCoverageTexture()
		{
			var format = highPrecision == true ? RenderTextureFormat.ARGBFloat : RenderTextureFormat.ARGB32;
			var width  = resolution * 2;
			var height = resolution;

			if (coverage == false || resolution <= 0)
			{
				DestroyImmediate(generatedCoverageTexture);
			}

			if (generatedCoverageTexture != null)
			{
				if (generatedCoverageTexture.width != width || generatedCoverageTexture.height != height || generatedCoverageTexture.format != format)
				{
					generatedCoverageTexture.Release();

					generatedCoverageTexture.format = format;
					generatedCoverageTexture.width  = width;
					generatedCoverageTexture.height = height;

					generatedCoverageTexture.Create();
				}
			}
			else if (coverage == true && resolution > 0)
			{
				var mips = Mathf.FloorToInt(Mathf.Log(Mathf.Max(width, height), 2)) + 1;
				var desc = new RenderTextureDescriptor(width, height, format, 0, mips);

				desc.sRGB = false;

				generatedCoverageTexture = new RenderTexture(desc);
				generatedCoverageTexture.hideFlags         = HideFlags.DontSave;
				generatedCoverageTexture.enableRandomWrite = true;
				generatedCoverageTexture.wrapMode          = TextureWrapMode.Clamp;
				generatedCoverageTexture.useMipMap         = true;
				generatedCoverageTexture.autoGenerateMips  = false;

				generatedCoverageTexture.Create();
			}
		}

		protected virtual void Update()
		{
			if (coverageBundle != null)
			{
				coverageBundle.HandleUpdate();
			}
		}

		protected virtual void LateUpdate()
		{
			UpdateCoverage();
		}

		private void UpdateCoverage()
		{
			if (coverageBundle != null)
			{
				coverageBundle.HandleLateUpdate();
			}

			if (coverageMaterial == null) coverageMaterial = CwHelper.CreateTempMaterial("Blit Mat2", "Hidden/SgtCloud_Coverage");
			if (coverageMaterial == null) return;

			var oldWrite  = GL.sRGBWrite;
			var oldActive = RenderTexture.active;

			coverageMaterial.SetTexture(_SGT_CoverageTex, coverageTex);
			coverageMaterial.SetVector(_SGT_CoverageSize, coverageTex != null ? new Vector2(coverageTex.width, coverageTex.height) : Vector2.zero);

			if (dirtyDetail == true)
			{
				dirtyDetail = false;

				GetComponentsInChildren(detailLayers);
			}

			var detailLayerCount = 0;

			foreach (var cloudDetail in detailLayers)
			{
				if (cloudDetail != null && cloudDetail.enabled == true)
				{
					if (Application.isPlaying == true)
					{
						cloudDetail.Offset += cloudDetail.Speed * Time.deltaTime;
					}

					coverageMaterial.SetTexture("_SGT_DetailTex" + detailLayerCount, cloudDetail.CoverageTex);
					coverageMaterial.SetVector("_SGT_DetailData" + detailLayerCount, new Vector4(cloudDetail.CarveEdge, cloudDetail.CarveCore, cloudDetail.Scale, cloudDetail.Offset));
					coverageMaterial.SetVector("_SGT_DetailChannels" + detailLayerCount, cloudDetail.Channels);

					if (++detailLayerCount >= 3)
					{
						break;
					}
				}
			}

			CheckGeneratedCoverageTexture();

			coverageMaterial.DisableKeyword("_SGT_DETAIL0");
			coverageMaterial.DisableKeyword("_SGT_DETAIL1");
			coverageMaterial.DisableKeyword("_SGT_DETAIL2");
			coverageMaterial.DisableKeyword("_SGT_DETAIL3");
			coverageMaterial.EnableKeyword("_SGT_DETAIL" + detailLayerCount);

			GL.sRGBWrite = true;

			if (coverage == true)
			{
				var coverageLayerCount = 0;

				if (coverageBundle != null && coverageLayers != null && coverageBundle.GetTexture() != null)
				{
					coverageMaterial.EnableKeyword("_SGT_GENERATE_COVERAGE");

					var tex = coverageBundle.GetTexture();

					coverageMaterial.SetTexture(_SGT_CoverageTex, tex);
					coverageMaterial.SetVector(_SGT_CoverageSize, new Vector2(tex.width, tex.height));

					foreach (var coverageLayer in coverageLayers)
					{
						if (coverageLayer != null)
						{
							if (Application.isPlaying == true)
							{
								coverageLayer.Offset = (coverageLayer.Offset + coverageLayer.Speed * Time.deltaTime) % 1.0f;
							}

							var coords = coverageBundle.GetCoords(coverageLayer.Visual);

							rectDataA[coverageLayerCount] = new Vector4(coverageLayer.Height, coverageLayer.Thickness, coords.x, coords.y);
							rectDataB[coverageLayerCount] = new Vector4(coverageLayer.Offset, coverageLayer.Tiling, coverageLayer.Opacity, 0.0f);
							rectDataC[coverageLayerCount] = coverageLayer.Layers;

							coverageLayerCount += 1;

							if (coverageLayerCount >= SGT_MAX_RECTS)
							{
								break;
							}
						}
					}

					if (coverageLayerCount == 0)
					{
						rectDataA[coverageLayerCount] = new Vector4(0.5f, 0.5f, 0.0f, 1.0f);
						rectDataB[coverageLayerCount] = new Vector4(0.0f, 1.0f, 1.0f, 0.0f);
						rectDataC[coverageLayerCount] = new Vector4(1.0f, 1.0f, 1.0f, 1.0f);

						coverageLayerCount += 1;
					}

					coverageMaterial.SetInt(_SGT_RectCount, coverageLayerCount);
					coverageMaterial.SetVectorArray(_SGT_RectDataA, rectDataA);
					coverageMaterial.SetVectorArray(_SGT_RectDataB, rectDataB);
					coverageMaterial.SetVectorArray(_SGT_RectDataC, rectDataC);
				}

				Graphics.Blit(default(Texture), generatedCoverageTexture, coverageMaterial, 0);

				generatedCoverageTexture.GenerateMips();
			}
			else
			{
				coverageMaterial.DisableKeyword("_SGT_GENERATE_COVERAGE");
			}

			GL.sRGBWrite = oldWrite;
			RenderTexture.active = oldActive;
		}

		private static readonly int SGT_MAX_RECTS = 64;

		private static Vector4[] rectDataA = new Vector4[SGT_MAX_RECTS];
		private static Vector4[] rectDataB = new Vector4[SGT_MAX_RECTS];
		private static Vector4[] rectDataC = new Vector4[SGT_MAX_RECTS];
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloud))]
	public class SgtCloud_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloud tgt; SgtCloud[] tgts; GetTargets(out tgt, out tgts);

			if (Button("Add Detail") == true)
			{
				Each(tgts, t => { AddChildComponent<SgtCloudDetail>(t); }, true);
			}

			Separator();

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The Material used to render the cloud.\n\nNOTE: This must use the <b>SGT / Cloud</b> shader.");
			EndError();
			BeginError(Any(tgts, t => t.Sky == null));
				Draw("sky", "If you want atmospheric effects to apply to this cloud, drag and drop it into here.");
			EndError();
			Draw("outerRadius", "The outer radius of the clouds in local space.");
			Draw("innerRadius", "The inner radius of the clouds in local space.");
			Draw("cullStrength", "If your clouds are for a gas giant without a solid core, you can specify the altitude where the clouds are culled out to improve performance and reduce graphical issues.");
			Draw("density", "The maximum density of clouds.");
			Draw("resolution", "The height of the generated cloud texture. The width will be set to double this.");
			Draw("highPrecision", "Use a high precision cloud texture for smoother results?");
			Draw("color", "The color of the clouds.");
			Draw("color2", "The color of the clouds.");
			Draw("brightness", "The color values will be multiplied by this.");

			Separator();

			Draw("nearDetail", "The near detail of the clouds when ray marching.");
			Draw("farDetail", "The far detail of the clouds when ray marching.");

			Separator();

			Draw("shadowDensity", "How much sunlight is blocked underneath clouds.");
			Draw("shadowOffset", "");
			Draw("shadowOpacity", "How much the shadows darken the planet or ocean.");
			Draw("shadowDetail", "The detail of the shadows when ray marching.");

			Separator();

			Draw("coverageTex", "This texture defines where clouds appear around the planet.\n\nNOTE: This texture should use the equirectangular/cylindrical projection.");
			Draw("sortOffset", "The volumetric sorting offset, to make sure it renders in the correct order relative to the sky.");

			Separator();

			Draw("erodeTiling", "The erosion texture is tiled this many times around the planet.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");
			Draw("erodeRange", "The erosion will begin when the camera is within this distance of the clouds.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");
			Draw("erodeStrength", "The erosion texture will cut away this much from the cloud cover.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");

			Separator();

			Draw("coverage", "Generate a coverage texture for the cloud rendering?");

			if (Any(tgts, t => t.Coverage == true))
			{
				BeginIndent();
					Draw("coverageBundle", "The coverage texture will be generated from this texture bundle.", "Bundle");
					Draw("coverageLayers", "This allows you to add bands of texture from the <b>CoverageBundle</b>", "Bands");
					BeginDisabled();
						EditorGUILayout.ObjectField("GeneratedCoverageTexture", tgt.GeneratedCoverageTexture, typeof(Texture), true);
					EndDisabled();
				EndIndent();
			}

			Separator();

			Separator();

			if (Button("Randomize Color Hue") == true)
			{
				Each(tgts, t => { t.RandomizeColorHue(); t.RandomizeColor2Hue(); }, true, true);
			}

			if (Any(tgts, t => t.CoverageLayers.Count > 0) && Button("Randomize Coverage Layers") == true)
			{
				Each(tgts, t => { t.RandomizeCoverageLayers(); }, true);
			}

			//Separator();

			//BeginDisabled();
			//	UnityEditor.EditorGUILayout.ObjectField("GeneratedTexture", tgt.GeneratedTexture, typeof(RenderTexture), true);
			//EndDisabled();
		}

		public static Texture2D Randomize(Texture2D current)
		{
			if (current != null)
			{
				var currentPath = UnityEditor.AssetDatabase.GetAssetPath(current);
				var guids       = UnityEditor.AssetDatabase.FindAssets("t:Texture2D", new string[] { System.IO.Path.GetDirectoryName(currentPath) });

				if (guids.Length > 0)
				{
					var guid = guids[UnityEngine.Random.Range(0, guids.Length)];
					var path = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
					var next = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(path);

					if (current != next)
					{
						current = next;
					}
				}
			}

			return current;
		}

		private static T AddChildComponent<T>(SgtCloud tgt)
			where T : Component
		{
			var child = new GameObject(typeof(T).Name);

			child.transform.SetParent(tgt.transform, false);

			var component = child.AddComponent<T>();

			CW.Common.CwHelper.SelectAndPing(component);

			return component;
		}

		public static float Randomize01()
		{
			return UnityEngine.Random.Range(0.0f, 1.0f);
		}

		[UnityEditor.MenuItem("GameObject/CW/Space Graphics Toolkit/Cloud", false, 10)]
		public static void CreateMenuItem()
		{
			var parent   = CwHelper.GetSelectedParent();
			var instance = SgtCloud.Create(parent != null ? parent.gameObject.layer : 0, parent);

			CwHelper.SelectAndPing(instance);
		}
	}

	[CustomPropertyDrawer(typeof(SgtCloud.CoverageLayerType))]
	public class AlbedoLayerTypeDrawer : PropertyDrawer
	{
		public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
		{
			// 1 line for label + 6 fields + 1 group of 4 sliders
			return EditorGUIUtility.singleLineHeight * 9 + 14f;
		}

		public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
		{
			EditorGUI.BeginProperty(position, label, property);

			// Reset to defaults?
			var height    = property.FindPropertyRelative("Height");
			var thickness = property.FindPropertyRelative("Thickness");
			var tiling    = property.FindPropertyRelative("Tiling");
			var opacity   = property.FindPropertyRelative("Opacity");
			var layers    = property.FindPropertyRelative("Layers");

			if (height.floatValue == 0.0f && thickness.floatValue == 0.0f && tiling.intValue == 0 && opacity.floatValue == 0.0f)
			{
				height.floatValue = 0.5f;
				thickness.floatValue = 0.25f;
				tiling.intValue = 1;
				opacity.floatValue = 1.0f;
			}

			if (layers.vector4Value == Vector4.zero)
			{
				layers.vector4Value = new Vector4(1.0f, 1.0f, 1.0f, 1.0f);
			}

			var lineHeight = EditorGUIUtility.singleLineHeight;
			var spacing    = 2.0f;
			var rect       = new Rect(position.x, position.y, position.width, lineHeight);

			// Label
			EditorGUI.LabelField(rect, label);
			rect.y += lineHeight + spacing;

			// Visual (int)
			EditorGUI.PropertyField(rect, property.FindPropertyRelative("Visual"));
			rect.y += lineHeight + spacing;

			DrawFloatSlider(ref rect, property, "Height", 0f, 1f);
			DrawFloatSlider(ref rect, property, "Thickness", 0f, 1f);
			DrawFloatSlider(ref rect, property, "Offset", 0f, 1f);
			DrawFloatSlider(ref rect, property, "Speed", 0f, 1f);
			DrawIntSlider(ref rect, property, "Tiling", 1, 20);
			DrawFloatSlider(ref rect, property, "Opacity", 0f, 1f);

			Vector4 layersVec = layers.vector4Value;

			// Calculate total width available
			float labelWidth = EditorGUIUtility.labelWidth;
			float remainingWidth = position.width - labelWidth;
			float sliderWidth = (remainingWidth - 6f) / 4f; // 3 spacings between 4 sliders

			Rect labelRect = new Rect(position.x, rect.y, labelWidth, lineHeight);
			EditorGUI.LabelField(labelRect, "Layers");

			// Sliders
			float sliderX = position.x + labelWidth;
			Rect sliderRect = new Rect(sliderX, rect.y, sliderWidth, lineHeight);

			layersVec.x = GUI.HorizontalSlider(sliderRect, layersVec.x, 0f, 1f);

			sliderRect.x += sliderWidth + 2f;
			layersVec.y = GUI.HorizontalSlider(sliderRect, layersVec.y, 0f, 1f);

			sliderRect.x += sliderWidth + 2f;
			layersVec.z = GUI.HorizontalSlider(sliderRect, layersVec.z, 0f, 1f);

			sliderRect.x += sliderWidth + 2f;
			layersVec.w = GUI.HorizontalSlider(sliderRect, layersVec.w, 0f, 1f);

			// Apply changes
			layers.vector4Value = layersVec;

			// Move rect down
			rect.y += lineHeight + spacing;

			EditorGUI.EndProperty();
		}

		private void DrawFloatSlider(ref Rect rect, SerializedProperty parent, string name, float min, float max)
		{
			SerializedProperty prop = parent.FindPropertyRelative(name);
			prop.floatValue = EditorGUI.Slider(rect, ObjectNames.NicifyVariableName(name), prop.floatValue, min, max);
			rect.y += EditorGUIUtility.singleLineHeight + 2f;
		}

		private void DrawIntSlider(ref Rect rect, SerializedProperty parent, string name, int min, int max)
		{
			SerializedProperty prop = parent.FindPropertyRelative(name);
			prop.intValue = EditorGUI.IntSlider(rect, ObjectNames.NicifyVariableName(name), prop.intValue, min, max);
			rect.y += EditorGUIUtility.singleLineHeight + 2f;
		}
	}
}
#endif