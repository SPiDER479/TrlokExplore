using UnityEngine;
using CW.Common;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component renders a layer of volumetric clouds around a planet.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud")]
	public class SgtCloud : MonoBehaviour, CwChild.IHasChildren
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
		public class AlbedoLayerType
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

		[System.Serializable]
		public class CarveLayerType
		{
			public Texture3D Texture;

			public float Tiling;

			[Range(0.0f, 1.0f)] public float Strength;

			public Vector4 Channels;
		}

		/// <summary>This texture defines where clouds appear around the planet.
		/// NOTE: This texture should use the equirectangular/cylindrical projection.</summary>
		public Texture CoverageTex { set { coverageTex = value; } get { return coverageTex; } } [SerializeField] private Texture coverageTex;

		/// <summary>The mesh used to render the clouds.
		/// NOTE: This should have a radius of one.</summary>
		public Mesh SphereMesh { set { sphereMesh = value; } get { return sphereMesh; } } [SerializeField] private Mesh sphereMesh;

		/// <summary>The maximum density of clouds.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 5000.0f;

		/// <summary>The width/height of the generated cloud texture.</summary>
		public int Resolution { set { resolution = value; } get { return resolution; } } [SerializeField] private int resolution = 512;

		/// <summary>Use a high precision cloud texture for smoother results?</summary>
		public bool HighPrecision { set { highPrecision = value; } get { return highPrecision; } } [SerializeField] private bool highPrecision = true;

		/// <summary>If your clouds need higher detail up close you can increase the </summary>
		public float Warp { set { warp = value; } get { return warp; } } [SerializeField] [Range(0.0f, 2.0f)] private float warp = 1.0f;

		/// <summary>The color of the clouds.</summary>
		public Color Color { set { color = value; } get { return color; } } [SerializeField] private Color color = Color.white;

		/// <summary>The density of the clouds when calculating lighting.</summary>
		public float ShadowDensity { set { shadowDensity = value; } get { return shadowDensity; } } [SerializeField] private float shadowDensity = 10.0f;

		/// <summary>The depth of the light samples, which changes how the lighting looks.</summary>
		public float ShadowOffset { set { shadowOffset = value; } get { return shadowOffset; } } [SerializeField] private float shadowOffset = 0.5f;

		/// <summary>This allows you to control the settings for each cloud layer. Cloud layers are defined in the <b>Coverage</b> texture's RGBA channels up to a maximum of 4 cloud layers.</summary>
		public List<CloudLayerType> CloudLayers { get { if (cloudLayers == null) cloudLayers = new List<CloudLayerType>(); return cloudLayers; } } [SerializeField] private List<CloudLayerType> cloudLayers;

		/// <summary>Generate a coverage texture for the cloud rendering?</summary>
		public bool Coverage { set { coverage = value; } get { return coverage; } } [SerializeField] private bool coverage;

		/// <summary>The width/height of the generated cloud albedo texture.</summary>
		public SgtCloudBundle CoverageBundle { set { coverageBundle = value; } get { return coverageBundle; } } [SerializeField] private SgtCloudBundle coverageBundle;

		/// <summary>This allows you to add bands of texture from the <b>CoverageBundle</b>.</summary>
		public List<AlbedoLayerType> CoverageLayers { get { if (coverageLayers == null) coverageLayers = new List<AlbedoLayerType>(); return coverageLayers; } } [SerializeField] [UnityEngine.Serialization.FormerlySerializedAs("albedoLayers")] private List<AlbedoLayerType> coverageLayers;

		/// <summary>Generate an albedo texture for the cloud rendering?</summary>
		public bool Albedo { set { albedo = value; } get { return albedo; } } [SerializeField] private bool albedo;

		/// <summary>If you want the <b>CoverageTex</b> to be colored, you can specify a gradient texture.</summary>
		public Texture2D AlbedoGradientTex { set { albedoGradientTex = value; } get { return albedoGradientTex; } } [SerializeField] private Texture2D albedoGradientTex;

		/// <summary>The <b>GradientTex</b> will begin from this coordinate.</summary>
		public float AlbedoVariationX { set { albedoVariationX = value; } get { return albedoVariationX; } } [SerializeField] [Range(0.0f, 1.0f)] private float albedoVariationX;

		/// <summary>The <b>GradientTex</b> will begin from this coordinate.</summary>
		public float AlbedoVariationY { set { albedoVariationY = value; } get { return albedoVariationY; } } [SerializeField] [Range(0.0f, 1.0f)] private float albedoVariationY;

		/// <summary>The <b>GradientTex</b> will be offset by this amount based on the planet latitude.</summary>
		public float AlbedoLatitudeX { set { albedoLatitudeX = value; } get { return AlbedoLatitudeX; } } [SerializeField] [Range(0.0f, 1.0f)] private float albedoLatitudeX = 0.1f;

		/// <summary>The <b>GradientTex</b> will offset by this amount based on the <b>AlbedoGradientTex</b>.</summary>
		public float AlbedoStrataY { set { albedoStrataY = value; } get { return albedoStrataY; } } [SerializeField] [Range(0.0f, 1.0f)] private float albedoStrataY = 0.1f;

		/// <summary>Carve the clouds with 3D noise textures?</summary>
		public List<CarveLayerType> CarveLayers { get { if (carveLayers == null) carveLayers = new List<CarveLayerType>(); return carveLayers; } } [SerializeField] private List<CarveLayerType> carveLayers;

		/// <summary>If the <b>SgtCloudDetail</b> components have changed, calling this will force them to update.</summary>
		public void MarkDetailDirty()
		{
			dirtyDetail = true;
		}

		[System.NonSerialized]
		private bool dirtyDetail = true;

		[System.NonSerialized]
		private RenderTexture generatedTexture;

		[System.NonSerialized]
		private RenderTexture generatedAlbedoTexture;

		[System.NonSerialized]
		private Matrix4x4 generatedMatrix = Matrix4x4.identity;

		[System.NonSerialized]
		private Vector4 generatedOpacity;

		[System.NonSerialized]
		private Vector4 generatedHeight;

		[SerializeField]
		private SgtCloudModel model;

		[System.NonSerialized]
		private List<SgtCloudDetail> detailLayers = new List<SgtCloudDetail>();

		[System.NonSerialized]
		private static Material coverageMaterial;

		private static MaterialPropertyBlock tempProperties;

		private static int _SGT_CoverageTex          = Shader.PropertyToID("_SGT_CoverageTex");
		private static int _SGT_OldGradientTex       = Shader.PropertyToID("_SGT_OldGradientTex");
		private static int _SGT_NewGradientTex       = Shader.PropertyToID("_SGT_NewGradientTex");
		private static int _SGT_OldNewTransition     = Shader.PropertyToID("_SGT_OldNewTransition");
		private static int _SGT_CoverageSize         = Shader.PropertyToID("_SGT_CoverageSize");
		private static int _SGT_CloudWarp            = Shader.PropertyToID("_SGT_CloudWarp");
		private static int _SGT_Matrix               = Shader.PropertyToID("_SGT_Matrix");
		private static int _SGT_CloudCoverageTex     = Shader.PropertyToID("_SGT_CloudCoverageTex");
		private static int _SGT_GradientTex          = Shader.PropertyToID("_SGT_GradientTex");
		private static int _SGT_Variation            = Shader.PropertyToID("_SGT_Variation");
		private static int _SGT_RectCount            = Shader.PropertyToID("_SGT_RectCount");
		private static int _SGT_RectDataA            = Shader.PropertyToID("_SGT_RectDataA");
		private static int _SGT_RectDataB            = Shader.PropertyToID("_SGT_RectDataB");
		private static int _SGT_RectDataC            = Shader.PropertyToID("_SGT_RectDataC");

		public RenderTexture GeneratedTexture
		{
			get
			{
				return generatedTexture;
			}
		}

		public RenderTexture GeneratedAlbedoTexture
		{
			get
			{
				return generatedAlbedoTexture;
			}
		}

		public Matrix4x4 GeneratedMatrix
		{
			get
			{
				return generatedMatrix;
			}
		}

		public Vector4 GeneratedHeight
		{
			get
			{
				return generatedHeight;
			}
		}

		public Vector4 GeneratedOpacity
		{
			get
			{
				return generatedOpacity;
			}
		}

		public SgtCloudModel Model
		{
			get
			{
				return model;
			}
		}

		public bool HasChild(CwChild child)
		{
			return child == model;
		}

		public static SgtCloud Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtCloud Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CwHelper.CreateGameObject("Cloud", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtCloud>();
		}

		public void RandomizeCoverageLayers()
		{
			if (coverageLayers != null)
			{
				foreach (var albedoLayer in coverageLayers)
				{
					if (albedoLayer != null)
					{
						var maxVisual = coverageBundle != null ? coverageBundle.Slices.Count : int.MaxValue;

						albedoLayer.Visual    = Random.Range(0, maxVisual);
						albedoLayer.Height    = Random.Range(0.1f, 0.9f);
						albedoLayer.Thickness = Random.Range(0.02f, 0.2f);
						albedoLayer.Offset    = Random.Range(0.0f, 1.0f);
						albedoLayer.Speed     = Random.Range(-0.001f, 0.001f);
						albedoLayer.Tiling    = Random.Range(1, 5);
						albedoLayer.Opacity   = Random.Range(0.5f, 1.0f);
						albedoLayer.Layers    = new Vector4(Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f), Random.Range(0.5f, 1.0f));
					}
				}
			}
		}

		protected virtual void OnEnable()
		{
			CheckGeneratedTexture();
			CheckGeneratedAlbedoTexture();

			if (model == null)
			{
				model = SgtCloudModel.Create(this);
			}

			if (tempProperties == null) tempProperties = new MaterialPropertyBlock();

			model.CachedMeshRenderer.enabled           = true;
			model.CachedMeshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.ShadowsOnly;
		}

		private void CheckGeneratedTexture()
		{
			var format = highPrecision == true ? RenderTextureFormat.ARGBFloat : RenderTextureFormat.ARGB32;

			if (generatedTexture != null)
			{
				if (generatedTexture.width != resolution || generatedTexture.height != resolution || generatedTexture.format != format)
				{
					generatedTexture.Release();

					generatedTexture.format = format;
					generatedTexture.width  = resolution;
					generatedTexture.height = resolution;

					generatedTexture.Create();
				}
			}
			else
			{
				var mips = Mathf.FloorToInt(Mathf.Log(Mathf.Max(resolution, resolution), 2)) + 1;
				var desc = new RenderTextureDescriptor(resolution, resolution, format, 0, mips);

				desc.sRGB = false;

				generatedTexture = new RenderTexture(desc);
				generatedTexture.hideFlags         = HideFlags.DontSave;
				generatedTexture.enableRandomWrite = true;
				generatedTexture.wrapMode          = TextureWrapMode.Clamp;
				generatedTexture.useMipMap         = true;
				generatedTexture.autoGenerateMips  = false;

				generatedTexture.Create();
			}
		}

		private void CheckGeneratedAlbedoTexture()
		{
			if (albedo == false || resolution <= 0)
			{
				DestroyImmediate(generatedAlbedoTexture);
			}

			if (generatedAlbedoTexture != null)
			{
				if (generatedAlbedoTexture.width != resolution || generatedAlbedoTexture.height != resolution)
				{
					generatedAlbedoTexture.Release();

					generatedAlbedoTexture.width  = resolution;
					generatedAlbedoTexture.height = resolution;

					generatedAlbedoTexture.Create();
				}
			}
			else if (albedo == true && resolution > 0)
			{
				var mips = Mathf.FloorToInt(Mathf.Log(Mathf.Max(resolution, resolution), 2)) + 1;
				var desc = new RenderTextureDescriptor(resolution, resolution, RenderTextureFormat.ARGB32, 0, mips);

				desc.sRGB = false;

				generatedAlbedoTexture = new RenderTexture(desc);
				generatedAlbedoTexture.hideFlags         = HideFlags.DontSave;
				generatedAlbedoTexture.enableRandomWrite = true;
				generatedAlbedoTexture.wrapMode          = TextureWrapMode.Clamp;
				generatedAlbedoTexture.useMipMap         = true;
				generatedAlbedoTexture.autoGenerateMips  = false;

				generatedAlbedoTexture.Create();
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
			if (coverageBundle != null)
			{
				coverageBundle.HandleLateUpdate();
			}

			if (Camera.main == null)
			{
				return;
			}

			if (coverageMaterial == null) coverageMaterial = CwHelper.CreateTempMaterial("Blit Mat2", "Hidden/SgtCloud_Coverage");
			if (coverageMaterial == null) return;

			var oldWrite  = GL.sRGBWrite;
			var oldActive = RenderTexture.active;

			var del = Vector3.Normalize(transform.InverseTransformVector(Camera.main.transform.position - model.transform.position));
			var lon = Mathf.Atan2(del.x, del.z) * Mathf.Rad2Deg;
			var lat = -Mathf.Asin(del.y) * Mathf.Rad2Deg;
			model.transform.localRotation = Quaternion.Euler(lat, lon, 0.0f);
			//model.transform.localScale = Vector3.one * (radius + height * 1.5f);

			//generatedMatrix = Matrix4x4.Rotate(Quaternion.Euler(-lat, 0.0f, 0.0f) * Quaternion.Euler(0.0f, -lon, 0.0f)) * Matrix4x4.Rotate(Quaternion.Inverse(transform.localRotation));
			generatedMatrix = model.transform.worldToLocalMatrix;

			generatedOpacity = default(Vector4);

			if (cloudLayers != null)
			{
				for (var i = 0; i < 4; i++)
				{
					if (cloudLayers.Count > i)
					{
						var cloudLayer = cloudLayers[i];

						generatedOpacity[i] = cloudLayer.Density * cloudLayer.Thickness * cloudLayer.Shadow;
					}
				}
			}

			coverageMaterial.SetTexture(_SGT_CoverageTex, coverageTex);
			coverageMaterial.SetVector(_SGT_CoverageSize, coverageTex != null ? new Vector2(coverageTex.width, coverageTex.height) : Vector2.zero);
			//coverageMaterial.SetMatrix("_SGT_Matrix", Matrix4x4.Rotate(Quaternion.Inverse(transform.rotation)));
			coverageMaterial.SetMatrix(_SGT_Matrix, Matrix4x4.Rotate(Quaternion.Euler(-lat, -lon, 0.0f)));
			coverageMaterial.SetFloat(_SGT_CloudWarp, warp);

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

			CheckGeneratedTexture();
			CheckGeneratedAlbedoTexture();

			coverageMaterial.DisableKeyword("_SGT_DETAIL0");
			coverageMaterial.DisableKeyword("_SGT_DETAIL1");
			coverageMaterial.DisableKeyword("_SGT_DETAIL2");
			coverageMaterial.DisableKeyword("_SGT_DETAIL3");
			coverageMaterial.EnableKeyword("_SGT_DETAIL" + detailLayerCount);

			GL.sRGBWrite = true;

			if (coverage == true)
			{
				coverageMaterial.SetVector(_SGT_Variation, new Vector4(albedoVariationX, albedoVariationY, albedoLatitudeX, albedoStrataY));

				var albedoLayerCount = 0;

				if (coverageBundle != null && coverageLayers != null && coverageBundle.GetTexture() != null)
				{
					var tex = coverageBundle.GetTexture();

					coverageMaterial.SetTexture(_SGT_CoverageTex, tex);
					coverageMaterial.SetVector(_SGT_CoverageSize, new Vector2(tex.width, tex.height));

					foreach (var albedoLayer in coverageLayers)
					{
						if (albedoLayer != null)
						{
							if (Application.isPlaying == true)
							{
								albedoLayer.Offset = (albedoLayer.Offset + albedoLayer.Speed * Time.deltaTime) % 1.0f;
							}

							var coords = coverageBundle.GetCoords(albedoLayer.Visual);

							albedoDataA[albedoLayerCount] = new Vector4(albedoLayer.Height, albedoLayer.Thickness, coords.x, coords.y);
							albedoDataB[albedoLayerCount] = new Vector4(albedoLayer.Offset, albedoLayer.Tiling, albedoLayer.Opacity, 0.0f);
							albedoDataC[albedoLayerCount] = albedoLayer.Layers;

							albedoLayerCount += 1;

							if (albedoLayerCount >= SGT_MAX_RECTS)
							{
								break;
							}
						}
					}

					if (albedoLayerCount == 0)
					{
						albedoDataA[albedoLayerCount] = new Vector4(0.5f, 0.5f, 0.0f, 1.0f);
						albedoDataB[albedoLayerCount] = new Vector4(0.0f, 1.0f, 1.0f, 0.0f);
						albedoDataC[albedoLayerCount] = new Vector4(1.0f, 1.0f, 1.0f, 1.0f);

						albedoLayerCount += 1;
					}

					coverageMaterial.SetInt(_SGT_RectCount, albedoLayerCount);
					coverageMaterial.SetVectorArray(_SGT_RectDataA, albedoDataA);
					coverageMaterial.SetVectorArray(_SGT_RectDataB, albedoDataB);
					coverageMaterial.SetVectorArray(_SGT_RectDataC, albedoDataC);
				}

				coverageMaterial.EnableKeyword("_SGT_GENERATE_COVERAGE");
			}
			else
			{
				coverageMaterial.DisableKeyword("_SGT_GENERATE_COVERAGE");
			}

			Graphics.Blit(default(Texture), generatedTexture, coverageMaterial, 0);

			// Albedo
			if (albedo == true)
			{
				coverageMaterial.SetTexture(_SGT_CloudCoverageTex, generatedTexture);

				if (albedoGradientTex != null)
				{
					coverageMaterial.SetTexture(_SGT_GradientTex, albedoGradientTex);

					coverageMaterial.EnableKeyword("_SGT_GRADIENT_COLORING");
				}
				else
				{
					coverageMaterial.DisableKeyword("_SGT_GRADIENT_COLORING");
				}

				Graphics.Blit(default(Texture), generatedAlbedoTexture, coverageMaterial, 1);
			}

			GL.sRGBWrite = oldWrite;
			RenderTexture.active = oldActive;

			generatedTexture.GenerateMips();

			if (model != null)
			{
				model.CachedMeshFilter.sharedMesh = sphereMesh;

				tempProperties.SetTexture(_SGT_CloudCoverageTex, generatedTexture);
				tempProperties.SetFloat(_SGT_CloudWarp, warp);

				model.CachedMeshRenderer.SetPropertyBlock(tempProperties);
			}
		}

		private static readonly int SGT_MAX_RECTS = 64;

		private static Vector4[] albedoDataA = new Vector4[SGT_MAX_RECTS];
		private static Vector4[] albedoDataB = new Vector4[SGT_MAX_RECTS];
		private static Vector4[] albedoDataC = new Vector4[SGT_MAX_RECTS];

		protected virtual void OnDisable()
		{
			if (model != null)
			{
				model.CachedMeshRenderer.enabled = false;
			}

			generatedTexture.Release();

			DestroyImmediate(generatedTexture);
		}
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

			BeginError(Any(tgts, t => t.SphereMesh == null));
				Draw("sphereMesh", "The mesh used to render the clouds.\n\nNOTE: This should have a radius of one.");
			EndError();
			Draw("density", "The maximum density of clouds.");
			Draw("resolution", "The width/height of the generated cloud texture.");
			Draw("highPrecision", "Use a high precision cloud texture for smoother results?");
			Draw("warp", "This allows you to increase cloud detail toward the camera, allowing you to use a lower resolution texture that still looks sharp up close.");
			Draw("color", "The color of the clouds.");

			Separator();

			Draw("shadowDensity", "The density of the clouds when calculating lighting.");
			Draw("shadowOffset", "The depth of the light samples, which changes how the lighting looks.");

			Separator();

			Draw("coverageTex", "This texture defines where clouds appear around the planet.\n\nNOTE: This texture should use the equirectangular/cylindrical projection.");

			Separator();

			Draw("coverage", "Generate a coverage texture for the cloud rendering?");

			if (Any(tgts, t => t.Coverage == true))
			{
				BeginIndent();
					Draw("coverageBundle", "The coverage texture will be generated from this texture bundle.", "Bundle");
					Draw("coverageLayers", "This allows you to add bands of texture from the <b>CoverageBundle</b>", "Bands");
				EndIndent();
			}

			Separator();

			Draw("albedo", "Generate an albedo texture for the cloud rendering?");

			if (Any(tgts, t => t.Albedo == true))
			{
				BeginIndent();
					Draw("albedoGradientTex", "If you want the <b>CoverageTex</b> to be colored, you can specify a gradient texture.", "Gradient Tex");
					Draw("albedoVariationX", "The <b>GradientTex</b> will begin from this coordinate.", "Variation X");
					Draw("albedoVariationY", "The <b>GradientTex</b> will begin from this coordinate.", "Variation Y");
					Draw("albedoLatitudeX", "The <b>GradientTex</b> will be offset by this amount based on the planet latitude.", "Latitude X");
					Draw("albedoStrataY", "The <b>GradientTex</b> will offset by this amount based on the <b>AlbedoGradientTex</b>.", "Strata Y");
				EndIndent();
			}

			Separator();

			Draw("carveLayers", "Carve the clouds with 3D noise textures?");

			Separator();

			Draw("cloudLayers", "This allows you to control the settings for each cloud layer. Cloud layers are defined in the <b>Coverage</b> texture's RGBA channels up to a maximum of 4 cloud layers.");

			if (Any(tgts, t => t.AlbedoGradientTex != null) && Button("Randomize Albedo Gradient Texture") == true)
			{
				Each(tgts, t => { if (t.AlbedoGradientTex != null) t.AlbedoGradientTex = Randomize(t.AlbedoGradientTex); }, true);
			}

			if (Button("Randomize Variation") == true)
			{
				Each(tgts, t => { t.AlbedoVariationX = Randomize01(); t.AlbedoVariationY = Randomize01(); }, true);
			}

			if (Any(tgts, t => t.CoverageLayers.Count > 0) && Button("Randomize Albedo Layers") == true)
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

	[CustomPropertyDrawer(typeof(SgtCloud.AlbedoLayerType))]
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