using UnityEngine;
using CW.Common;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Jobs;
using SpaceGraphicsToolkit.Landscape;
using SpaceGraphicsToolkit.Sky;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Volumetrics;
using SpaceGraphicsToolkit.LightAndShadow;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>This component can be used to render oceans for your planets.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ocean")]
	public partial class SgtOcean : SgtVolumeEffect, CwChild.IHasChildren
	{
		/// <summary>The material used to render the fluid surface.
		/// NOTE: This must use the <b>SGT/Ocean</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>If you want atmospheric effects to apply to this cloud, drag and drop it into here.</summary>
		public SgtSky Sky { set { sky = value; } get { return sky; } } [SerializeField] private SgtSky sky;

		/// <summary>The radius of the ocean.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] private float radius = 50.0f;

		/// <summary>The overall detail of the ocean relative to the camera distance. The higher you set this, the more triangles it will have.</summary>
		public float Detail { set { detail = value; } get { return detail; } } [SerializeField] [Range(0.01f, 5.0f)] private float detail = 1.2f;

		/// <summary>If you want cloud shadows to appear on the surface of the ocean, specify them here.</summary>
		public SgtCloud CloudShadow { set { cloudShadow = value; } get { return cloudShadow; } } [SerializeField] protected SgtCloud cloudShadow;

		public Camera Observer { set { observer = value; } get { return observer; } } [SerializeField] protected Camera observer;

		/// <summary>This allows you to offset the camera distance in world space when rendering the ocean, giving you fine control over the render order.</summary>
		public float CameraOffset { set { cameraOffset = value; } get { return cameraOffset; } } [SerializeField] private float cameraOffset = 0.1f;

		/// <summary>The color of the fluid when viewed from above the surface.</summary>
		public Color SurfaceColor { set { surfaceColor = value; } get { return surfaceColor; } } [SerializeField] private Color surfaceColor = new Color(0.007843138f, 0.3647059f, 0.5019608f);

		/// <summary>The color of the sub surface scattering.</summary>
		public Color SurfaceScattering { set { surfaceScattering = value; } get { return surfaceScattering; } } [SerializeField] private Color surfaceScattering = new Color(0.19f, 0.84f, 0.78f, 0.5f);

		/// <summary>The density of the water when viewed from above the surface.</summary>
		public float SurfaceDensity { set { surfaceDensity = value; } get { return surfaceDensity; } } [SerializeField] private float surfaceDensity = 0.5f;

		/// <summary>The PBR smoothness of the surface material.</summary>
		public float SurfaceSmoothness { set { surfaceSmoothness = value; } get { return surfaceSmoothness; } } [SerializeField] [Range(0.0f, 1.0f)] private float surfaceSmoothness = 0.9f;

		/// <summary>The sharpness of the underwater lighting.</summary>
		public float UnderwaterLightingSharpness { set { underwaterLightingSharpness = value; } get { return underwaterLightingSharpness; } } [SerializeField] [Range(1.0f, 20.0f)] private float underwaterLightingSharpness = 5.0f;

		/// <summary>The distance from the camera the cloud shadow calculations will use. This should approximately be the underwater fog distance (4.6 * density).</summary>
		public float UnderwaterShadowRange { set { underwaterShadowRange = value; } get { return underwaterShadowRange; } } [SerializeField] private float underwaterShadowRange = 10.0f;

		/// <summary>The maximum +- height displacement of the waves in world space.</summary>
		public float WavesDisplacement { set { wavesDisplacement = value; } get { return wavesDisplacement; } } [SerializeField] [Range(0.0f, 20.0f)] private float wavesDisplacement = 0.1f;

		/// <summary>The amount of waves there are on the ocean surface.</summary>
		public float WavesScale { set { wavesScale = value; } get { return wavesScale; } } [SerializeField] [Range(0.01f, 10.0f)] private float wavesScale = 1.0f;

		/// <summary>The animation speed of the waves.</summary>
		public float WavesSpeed { set { wavesSpeed = value; } get { return wavesSpeed; } } [SerializeField] [Range(0.0f, 10.0f)] private float wavesSpeed = 1.0f;

		/// <summary>The amount of combined wave layers.</summary>
		public int WavesQuality { set { wavesQuality = value; } get { return wavesQuality; } } [SerializeField] [Range(1, 3)] private int wavesQuality = 3;

		/// <summary>The size of the shore texture in world space.</summary>
		public float ShoreScale { set { shoreScale = value; } get { return shoreScale; } } [SerializeField] private float shoreScale = 1.0f;

		/// <summary>The animation speed of the shore.</summary>
		public float ShoreSpeed { set { shoreSpeed = value; } get { return shoreSpeed; } } [SerializeField] [Range(0.0f, 2.0f)] private float shoreSpeed = 0.75f;

		/// <summary>Apply small ripple details to the ocean surface?</summary>
		public bool Ripples { set { ripples = value; } get { return ripples; } } [SerializeField] private bool ripples = true;

		/// <summary>The dual normal map texture for ripples.
		/// RG = 0..1 NormalA.xy
		/// BA = 0..1 NormalB.xy</summary>
		public Texture2D RipplesTexture { set { ripplesTexture = value; } get { return ripplesTexture; } } [SerializeField] [UnityEngine.Serialization.FormerlySerializedAs("wavesTexture")] private Texture2D ripplesTexture;

		/// <summary>The size of the ripple texture in world space.</summary>
		public float RipplesScale { set { ripplesScale = value; } get { return ripplesScale; } } [SerializeField] private float ripplesScale = 1.0f;

		/// <summary>The animation speed of the ripples.</summary>
		public float RipplesSpeed { set { ripplesSpeed = value; } get { return ripplesSpeed; } } [SerializeField] [Range(0.0f, 2.0f)] private float ripplesSpeed = 0.75f;

		/// <summary>The ripples texture strength will be multiplied by this.</summary>
		public float RipplesStrength { set { ripplesStrength = value; } get { return ripplesStrength; } } [SerializeField] [Range(0.01f, 1.0f)] private float ripplesStrength = 0.5f;

		/// <summary>Ocean rendering can look bat at extreme distances, so fade it out.
		/// NOTE: If you enable this, your landscape should use the <b>OceanFade</b> setting.</summary>
		public bool Fade { set { fade = value; } get { return fade; } } [SerializeField] private bool fade;

		/// <summary>The ocean will completely disappear at this distance in world space.</summary>
		public float FadeDistance { set { fadeDistance = value; } get { return fadeDistance; } } [SerializeField] private float fadeDistance = 200.0f;

		/// <summary>The deep ocean surface effect will be fully revealed at this distance in world space.</summary>
		public float FadeDeepDistance { set { fadeDeepDistance = value; } get { return fadeDeepDistance; } } [SerializeField] private float fadeDeepDistance = 10000.0f;

		/// <summary>The deep ocean surface effect will have this density.</summary>
		public float FadeDeepDensity { set { fadeDeepDensity = value; } get { return fadeDeepDensity; } } [SerializeField] private float fadeDeepDensity = 0.1f;

		/// <summary>The light source for the caustics.</summary>
		public SgtLight CausticsLight { set { causticsLight = value; } get { return causticsLight; } } [SerializeField] private SgtLight causticsLight;

		/// <summary>The size of the caustics texture in world space.</summary>
		public float CausticsScale { set { causticsScale = value; } get { return causticsScale; } } [SerializeField] private float causticsScale = 1.0f;

		/// <summary>The animation speed of the caustics.</summary>
		public float CausticsSpeed { set { causticsSpeed = value; } get { return causticsSpeed; } } [SerializeField] [Range(0.0f, 2.0f)] private float causticsSpeed = 0.05f;

		private static float sphereInflate = 1.02f;

		[System.NonSerialized] private static Texture3D noiseTex;
		[System.NonSerialized] private static bool      noiseTexCreated;

		[SerializeField]
		private SgtOceanModel model;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private float underwaterBrightness;

		[System.NonSerialized]
		private float landscapeOpacity = -0.01f;

		[System.NonSerialized]
		private Material blitMaterial;

		[System.NonSerialized]
		private NativeList<double3> cameraPositions;

		[System.NonSerialized]
		private NativeList<Triangle> topology;

		[System.NonSerialized] private NativeList<Triangle> triangles;
		[System.NonSerialized] private NativeList<Triangle> createDiffs;
		[System.NonSerialized] private NativeList<Triangle> deleteDiffs;
		[System.NonSerialized] private NativeList<Triangle> statusDiffs;

		[System.NonSerialized]
		private JobHandle updateHandle;

		[System.NonSerialized]
		private bool updateRunning;

		[System.NonSerialized]
		private List<Batch> batches = new List<Batch>();

		[System.NonSerialized]
		private float wavesPosition;

		[System.NonSerialized] private Matrix4x4 ripplesMatrixA;
		[System.NonSerialized] private Matrix4x4 ripplesMatrixB;
		[System.NonSerialized] private float     ripplesBlend = -1.0f;
		[System.NonSerialized] private float     ripplesPosition;

		[System.NonSerialized] private Matrix4x4 shoreMatrixA;
		[System.NonSerialized] private Matrix4x4 shoreMatrixB;
		[System.NonSerialized] private float     shoreBlend = -1.0f;
		[System.NonSerialized] private float     shorePosition;

		[System.NonSerialized] private Matrix4x4 causticsMatrixA;
		[System.NonSerialized] private Matrix4x4 causticsMatrixB;
		[System.NonSerialized] private float     causticsBlend = -1.0f;
		[System.NonSerialized] private float     causticsPosition;

		[System.NonSerialized]
		private Dictionary<TriangleHash, Batch> triangleBatches = new Dictionary<TriangleHash, Batch>();

		private static readonly int _SGT_CausticsDirection = Shader.PropertyToID("_SGT_CausticsDirection");
		private static readonly int _SGT_FadeOpacity       = Shader.PropertyToID("_SGT_FadeOpacity");
		private static readonly int _SGT_FadeDensity       = Shader.PropertyToID("_SGT_FadeDensity");

		private static readonly int _SGT_SurfaceColor             = Shader.PropertyToID("_SGT_SurfaceColor");
		private static readonly int _SGT_SurfaceScattering        = Shader.PropertyToID("_SGT_SurfaceScattering");
		private static readonly int _SGT_SurfaceDensity           = Shader.PropertyToID("_SGT_SurfaceDensity");
		private static readonly int _SGT_SurfaceSmoothness        = Shader.PropertyToID("_SGT_SurfaceSmoothness");

		private static readonly int _SGT_RipplesMatrixA   = Shader.PropertyToID("_SGT_RipplesMatrixA");
		private static readonly int _SGT_RipplesMatrixB   = Shader.PropertyToID("_SGT_RipplesMatrixB");
		private static readonly int _SGT_RipplesBlend     = Shader.PropertyToID("_SGT_RipplesBlend");

		private static readonly int _SGT_ShoreMatrixA   = Shader.PropertyToID("_SGT_ShoreMatrixA");
		private static readonly int _SGT_ShoreMatrixB   = Shader.PropertyToID("_SGT_ShoreMatrixB");
		private static readonly int _SGT_ShoreBlend     = Shader.PropertyToID("_SGT_ShoreBlend");

		private static readonly int _SGT_CausticsMatrixA   = Shader.PropertyToID("_SGT_CausticsMatrixA");
		private static readonly int _SGT_CausticsMatrixB   = Shader.PropertyToID("_SGT_CausticsMatrixB");
		private static readonly int _SGT_CausticsBlend     = Shader.PropertyToID("_SGT_CausticsBlend");

		private static readonly int _SGT_WavesMatrixA   = Shader.PropertyToID("_SGT_WavesMatrixA");
		private static readonly int _SGT_WavesMatrixB   = Shader.PropertyToID("_SGT_WavesMatrixB");
		private static readonly int _SGT_WavesBlend     = Shader.PropertyToID("_SGT_WavesBlend");

		private static readonly int _SGT_SphereData   = Shader.PropertyToID("_SGT_SphereData");
		private static readonly int _SGT_PlaneData    = Shader.PropertyToID("_SGT_PlaneData");

		protected static readonly int _SGT_CloudTex     = Shader.PropertyToID("_SGT_CloudTex");
		protected static readonly int _SGT_CloudMatrix  = Shader.PropertyToID("_SGT_CloudMatrix");
		protected static readonly int _SGT_CloudOpacity = Shader.PropertyToID("_SGT_CloudOpacity");
		protected static readonly int _SGT_UnderwaterShadowRange = Shader.PropertyToID("_SGT_UnderwaterShadowRange");

		private static readonly int _SGT_ObjectToWorld         = Shader.PropertyToID("_SGT_ObjectToWorld");
		private static readonly int _SGT_WorldToObject         = Shader.PropertyToID("_SGT_WorldToObject");

		protected static readonly int _SGT_OceanDistance       = Shader.PropertyToID("_SGT_OceanDistance");
		protected static readonly int _SGT_OceanDensity        = Shader.PropertyToID("_SGT_OceanDensity");
		protected static readonly int _SGT_OceanHeight         = Shader.PropertyToID("_SGT_OceanHeight");
		protected static readonly int _SGT_OceanLightDirection = Shader.PropertyToID("_SGT_OceanLightDirection");
		protected static readonly int _SGT_OceanLightColor     = Shader.PropertyToID("_SGT_OceanLightColor");
		protected static readonly int _SGT_OceanColor          = Shader.PropertyToID("_SGT_OceanColor");
		protected static readonly int _SGT_OceanMinimum        = Shader.PropertyToID("_SGT_OceanMinimum");
		protected static readonly int _SGT_OceanSmoothness     = Shader.PropertyToID("_SGT_OceanSmoothness");
		protected static readonly int _SGT_OceanRadius         = Shader.PropertyToID("_SGT_OceanRadius");

		private static readonly int _SGT_WaveData       = Shader.PropertyToID("_SGT_WaveData");
		private static readonly int _SGT_RipplesTexture = Shader.PropertyToID("_SGT_RipplesTexture");
		private static readonly int _SGT_NoiseTex       = Shader.PropertyToID("_SGT_NoiseTex");
		private static readonly int _SGT_RipplesData    = Shader.PropertyToID("_SGT_RipplesData");

		private static readonly int _SGT_Offset       = Shader.PropertyToID("_SGT_Offset");
		private static readonly int _SGT_Radius       = Shader.PropertyToID("_SGT_Radius");

		private static readonly int _SGT_Origins        = Shader.PropertyToID("_SGT_Origins");
		private static readonly int _SGT_PositionsA     = Shader.PropertyToID("_SGT_PositionsA");
		private static readonly int _SGT_PositionsB     = Shader.PropertyToID("_SGT_PositionsB");
		private static readonly int _SGT_PositionsC     = Shader.PropertyToID("_SGT_PositionsC");
		private static readonly int _SGT_CoordsX        = Shader.PropertyToID("_SGT_CoordsX");
		private static readonly int _SGT_CoordsY        = Shader.PropertyToID("_SGT_CoordsY");
		private static readonly int _SGT_CoordsZ        = Shader.PropertyToID("_SGT_CoordsZ");
		private static readonly int _SGT_CoordsW        = Shader.PropertyToID("_SGT_CoordsW");

		private static readonly int _SGT_World2View           = Shader.PropertyToID("_SGT_World2View");
		private static readonly int _SGT_WCam                 = Shader.PropertyToID("_SGT_WCam");
		private static readonly int _SGT_ScreenFactor         = Shader.PropertyToID("_SGT_ScreenFactor");

		public Texture3D NoiseTex
		{
			get
			{
				if (noiseTexCreated == false)
				{
					noiseTex = new Texture3D(16, 16, 16, TextureFormat.R8, false);
					noiseTex.hideFlags = HideFlags.DontSave;
					noiseTex.wrapMode  = TextureWrapMode.Repeat;

					var pixels = new NativeArray<byte>(noiseTex.width * noiseTex.height * noiseTex.depth, Allocator.Temp);
					var rng    = new Unity.Mathematics.Random(1337);

					for (var i = 0; i < pixels.Length; i++)
					{
						pixels[i] = (byte)rng.NextInt(0, 256);
					}

					noiseTex.SetPixelData(pixels, 0);
					noiseTex.Apply(false, true);

					noiseTexCreated = true;
				}

				return noiseTex;
			}
		}

		public float UnderwaterBrightness
		{
			get
			{
				return underwaterBrightness;
			}
		}

		public float LandscapeOpacity
		{
			get
			{
				return landscapeOpacity;
			}
		}

		public bool HasChild(CwChild child)
		{
			return child == model;
		}

		public void RandomizeHue()
		{
			var h = 0.0f;
			var s = 0.0f;
			var v = 0.0f;

			Color.RGBToHSV(surfaceColor, out h, out s, out v);

			var newH = UnityEngine.Random.value;

			surfaceColor = Color.HSVToRGB(newH, s, v);
		}

		public void ApplyCloudShadowSettings(MaterialPropertyBlock properties)
		{
			if (cloudShadow != null)
			{
				cloudShadow.ApplyShadowSettings(properties);

				properties.SetFloat(_SGT_UnderwaterShadowRange, underwaterShadowRange);
			}
		}

		private void HandleCameraPreRender(Camera camera)
		{
			var eye = camera.transform.position;

			if (cameraOffset != 0.0f)
			{
				var direction = Vector3.Normalize(eye - transform.position);

				model.transform.position = transform.position + direction * cameraOffset;
			}
			else
			{
				model.transform.localPosition = Vector3.zero;
			}
		}

		/// <summary>This will tell you the +- altitude of the input worldPoint relative to the surface of the ocean without displacement.</summary>
		public float CalculateWorldAltitude(Vector3 worldPoint)
		{
			var localPoint   = transform.InverseTransformPoint(worldPoint);
			var localSurface = localPoint.normalized * radius;
			var worldSurface = transform.TransformPoint(localSurface);

			return Vector3.Distance(worldPoint, worldSurface) * Mathf.Sign(localPoint.magnitude - radius);
		}

		public static SgtOcean Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtOcean Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CwHelper.CreateGameObject("Ocean", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtOcean>();
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			topology            = new NativeList<Triangle>(8, AllocatorManager.Persistent);
			cameraPositions     = new NativeList<double3>(1, AllocatorManager.Persistent);

			triangles   = new NativeList<Triangle>(1024, AllocatorManager.Persistent);
			createDiffs = new NativeList<Triangle>(1024, AllocatorManager.Persistent);
			deleteDiffs = new NativeList<Triangle>(1024, AllocatorManager.Persistent);
			statusDiffs = new NativeList<Triangle>(1024, AllocatorManager.Persistent);

			CwHelper.OnCameraPreRender += HandleCameraPreRender;

			if (model == null)
			{
				model = SgtOceanModel.Create(this);
			}

			model.CachedMeshRenderer.enabled = true;

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			CwHelper.OnCameraPreRender -= HandleCameraPreRender;

			if (model != null)
			{
				model.CachedMeshRenderer.enabled = false;
			}

			if (sky != null)
			{
				sky.Model.CachedMeshRenderer.enabled = true;
			}

			if (updateRunning == true)
			{
				updateHandle.Complete();
				updateRunning = false;
			}

			topology.Dispose();

			cameraPositions.Dispose();

			triangles.Dispose();
			
			createDiffs.Dispose();
			deleteDiffs.Dispose();
			statusDiffs.Dispose();

			foreach (var batch in batches) { Batch.Pool.Push(batch); } batches.Clear();

			triangleBatches.Clear();
		}

		[System.NonSerialized]
		private Vector3 expectedPosition;

		private void UpdatePosition()
		{
			var newPosition = transform.position;

			if (newPosition != expectedPosition)
			{
				var delta = Matrix4x4.Translate(expectedPosition - newPosition);

				expectedPosition = newPosition;

				ripplesMatrixA *= delta;
				ripplesMatrixB *= delta;

				shoreMatrixA *= delta;
				shoreMatrixB *= delta;

				causticsMatrixA *= delta;
				causticsMatrixB *= delta;

				for (int i = 0; i < WAVE_COUNT; i++)
				{
					waveMatrices[i] *= delta;
				}
			}
		}

		private void ScheduleUpdate(float detail)
		{
			cameraPositions.Clear();

			if (observer != null)
			{
				cameraPositions.Add((float3)transform.InverseTransformPoint(observer.transform.position));
			}

			if (cameraPositions.Length == 0 && Camera.main != null)
			{
				cameraPositions.Add((float3)transform.InverseTransformPoint(Camera.main.transform.position));
			}

			var topologyJob = new CreateTopologyJob_Sphere();

			topologyJob.Radius   = radius;
			topologyJob.Topology = topology;

			updateHandle = topologyJob.Schedule();

			var trianglesJob = new UpdateTrianglesJob();

			trianglesJob.Topology        = topology;
			trianglesJob.CameraPositions = cameraPositions;
			trianglesJob.CameraDetailSq  = 1.0f / (detail * detail);
			trianglesJob.Deform          = DeformType.Sphere;
			trianglesJob.Radius          = radius;
			trianglesJob.MaxDepth        = 60;
			trianglesJob.MaxSteps        = 100;

			trianglesJob.Triangles   = triangles;
			trianglesJob.CreateDiffs = createDiffs;
			trianglesJob.DeleteDiffs = deleteDiffs;
			trianglesJob.StatusDiffs = statusDiffs;

			updateHandle  = trianglesJob.Schedule(updateHandle);
			updateRunning = true;
		}

		private void CompleteAndRebuildBatches()
		{
			updateHandle.Complete();

			updateRunning = false;

			BuildBatches(batches, triangleBatches);
		}

		private void BuildBatches(List<Batch> batches, Dictionary<TriangleHash, Batch> triangleBatches)
		{
			foreach (var triangle in deleteDiffs)
			{
				HideVisual(triangle);
			}

			deleteDiffs.Clear();

			foreach (var triangle in createDiffs)
			{
				if (triangle.Split == false)
				{
					ShowVisual(triangle);
				}
			}

			createDiffs.Clear();

			foreach (var triangle in statusDiffs)
			{
				if (triangle.Split == true)
				{
					HideVisual(triangle);
				}
				else
				{
					ShowVisual(triangle);
				}
			}

			statusDiffs.Clear();
		}

		private void ShowVisual(Triangle triangle)
		{
			var batch = GetBatch(batches);

			batch.AddTriangle(triangle, radius / 1.0, 1, radius);

			triangleBatches.Add(triangle.Hash, batch);
		}

		private void HideVisual(Triangle triangle)
		{
			var batch = default(Batch);

			if (triangleBatches.Remove(triangle.Hash, out batch) == true)
			{
				batch.RemoveTriangle(triangle.Hash);

				if (batch.Count == 0)
				{
					batches.Remove(batch);
				}
			}
		}

		private static Batch GetBatch(List<Batch> batches)
		{
			foreach (var batch in batches)
			{
				if (batch.Count < 128)
				{
					return batch;
				}
			}

			var newBatch = new Batch();

			batches.Add(newBatch);

			return newBatch;
		}

		private Matrix4x4 RemoveTranslation(Matrix4x4 matrix)
		{
			matrix.m03 = 0;
			matrix.m13 = 0;
			matrix.m23 = 0;

			return matrix;
		}

		private static readonly int WAVE_COUNT = 24;

		[System.NonSerialized] private int waveIndex = -1;
		[System.NonSerialized] private float waveProgress; // 0 (full) -> 0.5 (reset) -> 1 (full)
		[System.NonSerialized] private Matrix4x4[] waveMatrices;
		[System.NonSerialized] private Vector4[] waveData; // x = displacement, y = speed, z = displacement * fade, w = inv size

		private void ResetWave(int i)
		{
			var size = wavesScale * math.pow(0.847f, i);

			waveMatrices[i] = GenerateWaterMatrix(Camera.main, size, i * 137.5f);
			waveData[i] = new Vector4(wavesDisplacement * math.pow(0.8f, i), wavesSpeed * math.pow(1.07f, i), 0.0f, 1.0f / size);
		}

		private void UpdateWaves()
		{
			if (waveIndex < 0)
			{
				waveMatrices = new Matrix4x4[WAVE_COUNT];
				waveData = new Vector4[WAVE_COUNT];
				waveIndex = 0;

				for (int i = 0; i < WAVE_COUNT; i++) ResetWave(i);
			}

			var cycleSpeed  = math.min(0.2f * math.pow(1.25f, waveIndex), 2.0f);
			var oldProgress = waveProgress;

			waveProgress += Time.deltaTime * cycleSpeed;

			if (oldProgress < 0.5f && waveProgress >= 0.5f) 
			{
				ResetWave(waveIndex);
			}

			if (waveProgress >= 1.0f)
			{
				waveProgress = 0.0f;
				waveIndex    = (waveIndex + 1) % WAVE_COUNT;
			}

			// Animate waves
			var weightSum = 0.0f;

			for (int i = 0; i < WAVE_COUNT; i++)
			{
				var weight = i != waveIndex ? 1.0f : math.abs(math.saturate(waveProgress) * 2.0f - 1.0f);

				weightSum += weight;

				waveMatrices[i] = Matrix4x4.Translate(Vector3.right * waveData[i].y * Time.deltaTime) * waveMatrices[i];
			}

			var weightScale = 1.0f / math.max(0.01f, weightSum);

			for (int i = 0; i < WAVE_COUNT; i++)
			{
				var weight = i != waveIndex ? 1.0f : math.abs(math.saturate(waveProgress) * 2.0f - 1.0f);

				waveData[i].z = waveData[i].x * weight * weightScale;
			}
		}

		protected virtual void LateUpdate()
		{
			if (model != null)
			{
				model.CachedMeshFilter.sharedMesh = SgtSky.InvertedSphereMesh;
			}

			UpdateWaves();

			UpdatePosition();

			if (batches.Count > 0)
			{
				if (updateRunning == false)
				{
					ScheduleUpdate(detail);
				}

				if (updateHandle.IsCompleted == true)
				{
					CompleteAndRebuildBatches();
				}
			}
			else
			{
				ScheduleUpdate(0.01f);
				CompleteAndRebuildBatches();
			}

			wavesPosition += wavesSpeed * Time.deltaTime;

			ripplesPosition += ripplesSpeed * Time.deltaTime;

			causticsPosition += causticsSpeed * Time.deltaTime;

			var finalCamera = observer != null ? observer : Camera.main;

			if (material != null && sky != null && finalCamera != null)
			{
				model.transform.localScale = Vector3.one * CwHelper.Divide(sky.OuterRadius, 0.5f / sphereInflate);

				var altitude    = CalculateWorldAltitude(finalCamera.transform.position);
				var fadeOpacity = fade == true ? Mathf.InverseLerp(fadeDistance, 0.0f, altitude) : 0.0f;
				var targetLO    = fade == true && altitude >= fadeDistance ? 1.0f : 0.0f;

				if (landscapeOpacity >= 0.0f)
				{
					landscapeOpacity = Mathf.MoveTowards(landscapeOpacity, targetLO, Time.deltaTime);
				}
				else
				{
					landscapeOpacity = targetLO;
				}

				if (fade == true && landscapeOpacity >= 1.0f)
				{
					model.CachedMeshRenderer.enabled = false;
					sky.Model.CachedMeshRenderer.enabled = true;
				}
				else
				{
					model.CachedMeshRenderer.enabled = true;
					sky.Model.CachedMeshRenderer.enabled = false;
				}

				model.CachedMeshRenderer.sharedMaterial = material;

				model.CachedMeshRenderer.GetPropertyBlock(properties);

				sky.ApplySettings(properties, finalCamera);

				underwaterBrightness = CalculateUnderwaterBrightness();

				var o2w   = RemoveTranslation(transform.localToWorldMatrix);
				var w2o   = RemoveTranslation(transform.worldToLocalMatrix);
				var rot   = Quaternion.Inverse(transform.rotation) * transform.position;

				var scale      = radius * 2.0f;
				var worldToSky = Matrix4x4.Scale(new Vector3(scale, scale, scale)) * transform.worldToLocalMatrix;
				var center     = (double3)(float3)transform.position;
				var delta      = (double3)(float3)finalCamera.transform.position - center;
				var normal     = math.normalize(delta);
				var planeW     = -math.dot(normal, center + normal * radius);
				//var planeD     = (float)(math.length(delta) - radius);
				
				properties.SetMatrix(_SGT_ObjectToWorld, o2w);
				properties.SetMatrix(_SGT_WorldToObject, w2o);

				properties.SetColor(_SGT_SurfaceColor, surfaceColor);
				properties.SetColor(_SGT_SurfaceScattering, surfaceScattering * surfaceScattering.a);
				properties.SetFloat(_SGT_SurfaceDensity, surfaceDensity);
				properties.SetFloat(_SGT_SurfaceSmoothness, surfaceSmoothness);
				properties.SetVector(_SGT_FadeOpacity, new Vector2(fadeOpacity, 1.0f - landscapeOpacity));
				properties.SetFloat(_SGT_FadeDensity, fadeDeepDensity);

				if (ripplesBlend >= 0.0f)
				{
					ripplesBlend += Time.deltaTime * ripplesSpeed;

					if (ripplesBlend > 1.0f)
					{
						ripplesMatrixA = ripplesMatrixB;
						ripplesMatrixB = GenerateWaterMatrix(finalCamera, ripplesScale, UnityEngine.Random.value * 360.0f);
						ripplesBlend  %= 1.0f;
					}
				}
				else
				{
					ripplesMatrixA = GenerateWaterMatrix(finalCamera, ripplesScale, UnityEngine.Random.value * 360.0f);
					ripplesMatrixB = GenerateWaterMatrix(finalCamera, ripplesScale, UnityEngine.Random.value * 360.0f);
					ripplesBlend   = 0.0f;
				}

				properties.SetMatrixArray("_WaveMatrices", waveMatrices);
				properties.SetVectorArray("_WaveData", waveData);
				properties.SetTexture(_SGT_NoiseTex, NoiseTex);

				properties.SetMatrix(_SGT_RipplesMatrixA, ripplesMatrixA);
				properties.SetMatrix(_SGT_RipplesMatrixB, ripplesMatrixB);
				properties.SetFloat(_SGT_RipplesBlend, ripplesBlend);
				properties.SetVector(_SGT_RipplesData, new Vector4(ripplesStrength, ripplesPosition * Mathf.PI, 0.0f, 0.0f));

				if (shoreBlend >= 0.0f)
				{
					shoreBlend += Time.deltaTime * shoreSpeed;

					if (shoreBlend > 1.0f)
					{
						shoreMatrixA = shoreMatrixB;
						shoreMatrixB = GenerateWaterMatrix(finalCamera, shoreScale, UnityEngine.Random.value * 360.0f);
						shoreBlend  %= 1.0f;
					}
				}
				else
				{
					shoreMatrixA = GenerateWaterMatrix(finalCamera, shoreScale, UnityEngine.Random.value * 360.0f);
					shoreMatrixB = GenerateWaterMatrix(finalCamera, shoreScale, UnityEngine.Random.value * 360.0f);
					shoreBlend   = 0.0f;
				}

				properties.SetMatrix(_SGT_ShoreMatrixA, shoreMatrixA);
				properties.SetMatrix(_SGT_ShoreMatrixB, shoreMatrixB);
				properties.SetFloat(_SGT_ShoreBlend, shoreBlend);

				//properties.SetColor("_LightColor0", Color.yellow);

				if (causticsBlend >= 0.0f)
				{
					causticsBlend += Time.deltaTime;

					if (causticsBlend > 1.0f)
					{
						causticsMatrixA = causticsMatrixB;
						causticsMatrixB = GenerateWaterMatrix(finalCamera, causticsScale, UnityEngine.Random.value * 360.0f);
						causticsBlend  %= 1.0f;
					}
				}
				else
				{
					causticsMatrixA = GenerateWaterMatrix(finalCamera, causticsScale, UnityEngine.Random.value * 360.0f);
					causticsMatrixB = GenerateWaterMatrix(finalCamera, causticsScale, UnityEngine.Random.value * 360.0f);
					causticsBlend   = 0.0f;
				}

				properties.SetMatrix(_SGT_CausticsMatrixA, causticsMatrixA);
				properties.SetMatrix(_SGT_CausticsMatrixB, causticsMatrixB);
				properties.SetFloat(_SGT_CausticsBlend, causticsBlend);

				properties.SetVector(_SGT_CausticsDirection, GetLightDirection());

				properties.SetVector(_SGT_SphereData, new Vector4((float)center.x, (float)center.y, (float)center.z, radius));
				properties.SetVector(_SGT_PlaneData, new Vector4((float)normal.x, (float)normal.y, (float)normal.z, (float)planeW));
				properties.SetVector(_SGT_WaveData, new Vector4(0.0f, ripplesStrength, wavesDisplacement, 0.5f / wavesDisplacement));

				model.CachedMeshRenderer.SetPropertyBlock(properties);
			}
		}

		public override void CalculateSortDistance(Vector3 worldPoint)
		{
			sortDistance = Vector3.Distance(worldPoint, transform.position);
		}

		public override void RenderOceanBuffer(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
			if (blitMaterial == null)
			{
				blitMaterial = CwHelper.CreateTempMaterial("SgtOcean", "Hidden/SgtOcean");
			}

			blitMaterial.SetVector(_SGT_WCam, finalCamera.transform.position);
			blitMaterial.SetFloat(_SGT_ScreenFactor, (2.0f * math.tan(math.radians(finalCamera.fieldOfView * 0.5f))) / (float)renderSize.y);

			blitMaterial.SetFloat(_SGT_SurfaceDensity, surfaceDensity);

			blitMaterial.EnableKeyword("_SGT_SHAPE_SPHERE");

			if (wavesDisplacement > 0.0f)
			{
				blitMaterial.EnableKeyword("_SGT_DISPLACEMENT_ON");
			}
			else
			{
				blitMaterial.DisableKeyword("_SGT_DISPLACEMENT_ON");
			}

			if (wavesQuality == 1)
			{
				blitMaterial.EnableKeyword("_SGT_WAVES_1");
				blitMaterial.DisableKeyword("_SGT_WAVES_2");
				blitMaterial.DisableKeyword("_SGT_WAVES_3");
			}
			else if (wavesQuality == 2)
			{
				blitMaterial.DisableKeyword("_SGT_WAVES_1");
				blitMaterial.EnableKeyword("_SGT_WAVES_2");
				blitMaterial.DisableKeyword("_SGT_WAVES_3");
			}
			else if (wavesQuality == 3)
			{
				blitMaterial.DisableKeyword("_SGT_WAVES_1");
				blitMaterial.DisableKeyword("_SGT_WAVES_2");
				blitMaterial.EnableKeyword("_SGT_WAVES_3");
			}

			if (ripples == true && ripplesTexture != null)
			{
				blitMaterial.SetTexture(_SGT_RipplesTexture, ripplesTexture);
				blitMaterial.SetTexture(_SGT_NoiseTex, NoiseTex);

				blitMaterial.EnableKeyword("_SGT_RIPPLES_ON");
			}
			else
			{
				blitMaterial.DisableKeyword("_SGT_RIPPLES_ON");
			}

			var distance = Vector3.Distance(finalCamera.transform.position, transform.position);
			var altitude = distance - radius;

			if (Mathf.Abs(altitude) > radius * 0.001f)
			{
				blitMaterial.EnableKeyword("_SGT_SNAP_ON");
			}
			else
			{
				blitMaterial.DisableKeyword("_SGT_SNAP_ON");
			}

			var bounds = new Bounds(transform.position, Vector3.one * radius * 2.0f);
			
			blitMaterial.enableInstancing = true;

			var o2w   = RemoveTranslation(transform.localToWorldMatrix);
			var w2o   = RemoveTranslation(transform.worldToLocalMatrix);
			var rot   = Quaternion.Inverse(transform.rotation) * transform.position;

			properties.SetMatrix(_SGT_ObjectToWorld, o2w);
			properties.SetMatrix(_SGT_WorldToObject, w2o);
			properties.SetVector(_SGT_Offset, rot);
			properties.SetFloat(_SGT_Radius, radius);
			properties.SetVector(_SGT_FadeOpacity, new Vector2(1.0f, landscapeOpacity));
			properties.SetVector(_SGT_WaveData, new Vector4(wavesDisplacement, 0.0f, wavesPosition, 0.0f));
			properties.SetVector(_SGT_RipplesData, new Vector4(ripplesStrength, ripplesPosition * Mathf.PI, 0.0f, 0.0f));

			foreach (var batch in batches)
			{
				properties.SetVectorArray(_SGT_Origins, batch.PositionsO);
				properties.SetVectorArray(_SGT_PositionsA, batch.PositionsA);
				properties.SetVectorArray(_SGT_PositionsB, batch.PositionsB);
				properties.SetVectorArray(_SGT_PositionsC, batch.PositionsC);
				properties.SetMatrixArray(_SGT_CoordsX, batch.CoordX);
				properties.SetMatrixArray(_SGT_CoordsY, batch.CoordY);
				properties.SetMatrixArray(_SGT_CoordsZ, batch.CoordZ);
				properties.SetMatrixArray(_SGT_CoordsW, batch.CoordW);

				SgtVolumeCamera.AddDrawMeshInstancedProcedural(GetMesh(), 0, blitMaterial, 2, batch.Count, properties);
			}
		}

		private Matrix4x4 GenerateWaterMatrix(Camera finalCamera, float scale, float degrees)
		{
			return Matrix4x4.Rotate(Quaternion.Euler(0.0f, 0.0f, degrees)) * Matrix4x4.LookAt(transform.position, finalCamera.transform.position, Vector3.up).inverse * Matrix4x4.Scale(Vector3.one / scale);
		}

		private float CalculateUnderwaterBrightness(Vector3 worldPoint)
		{
			var brightness = 0.0f;
			var pivot      = transform.position;
			var direction  = Vector3.Normalize(worldPoint - pivot);
			var lights     = LightAndShadow.SgtLight.Find(-1, pivot);

			foreach (var light in lights)
			{
				var lightPosition  = default(Vector3);
				var lightDirection = default(Vector3);
				var lightColor     = default(Color);
				var lightIntensity = default(float);

				LightAndShadow.SgtLight.Calculate(light, pivot, radius, null, null, ref lightPosition, ref lightDirection, ref lightColor, ref lightIntensity);

				var lightDot = math.smoothstep(0.0f, 1.0f, math.saturate(math.dot(math.normalize(direction), lightDirection) * underwaterLightingSharpness + 0.5f));

				brightness += lightDot * lightIntensity;
			}

			return brightness;
		}

		private float CalculateUnderwaterBrightness()
		{
			if (Camera.main != null)
			{
				return CalculateUnderwaterBrightness(Camera.main.transform.position);
			}

			return 1.0f;
		}

		private Vector3 GetLightDirection()
		{
			var finalLight = causticsLight;

			if (finalLight == null)
			{
				var lights = SgtLight.Find(-1, transform.position);

				if (lights.Count > 0)
				{
					finalLight = lights[0];
				}
			}

			if (finalLight != null && finalLight.isActiveAndEnabled == true)
			{
				if (finalLight.CachedLight.type == LightType.Point || (finalLight.CachedLight.type == LightType.Directional && finalLight.TreatAsPoint == true))
				{
					return Vector3.Normalize(finalLight.CachedTransform.position - transform.position);
				}
				else
				{
					return finalLight.CachedTransform.forward;
				}
			}

			return Vector3.forward;
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Ocean
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtOcean))]
	public class SgtOcean_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtOcean tgt; SgtOcean[] tgts; GetTargets(out tgt, out tgts);

			var markForRebuild = false;
			var markParentForRebuild = false;

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The material used to render the fluid surface.\n\nNOTE: This must use the <b>SGT/Ocean</b> shader.");
			EndError();
			BeginError(Any(tgts, t => t.Sky == null));
				Draw("sky");
			EndError();
			Draw("radius", "The radius of the ocean.");
			Draw("detail", "The overall detail of the ocean relative to the camera distance. The higher you set this, the more triangles it will have.");
			Draw("cloudShadow", "If you want cloud shadows to appear on the surface of the ocean, specify them here.");

			Separator();
			
			Draw("observer", "The camera rendering this ocean.\n\nNone/null = The GameObject with the <b>MainCamera</b> tag will be used.");
			Draw("cameraOffset", "This allows you to offset the camera distance in world space when rendering the ocean, giving you fine control over the render order.");
			BeginDisabled();
				var finalCamera = tgt.Observer != null ? tgt.Observer : Camera.main;
				if (finalCamera != null)
				{
					UnityEditor.EditorGUILayout.FloatField("Camera Altitude", tgt.CalculateWorldAltitude(finalCamera.transform.position));
				}
			EndDisabled();

			Separator();

			Draw("surfaceColor", "The color of the fluid when viewed from above the surface.");
			Draw("surfaceScattering", "The color of the sub surface scattering.");
			Draw("surfaceDensity", "The density of the water when viewed from above the surface.");
			Draw("surfaceSmoothness", "The PBR smoothness of the surface material.");

			Separator();

			Draw("underwaterLightingSharpness", "The sharpness of the underwater lighting.");
			Draw("underwaterShadowRange", "The distance from the camera the cloud shadow calculations will use. This should approximately be the underwater fog distance (4.6 * density).");

			Separator();

			Draw("wavesDisplacement", "The maximum +- height displacement of the waves in world space.");
			Draw("wavesScale");
			Draw("wavesSpeed", "The animation speed of the waves.");
			Draw("wavesQuality", "The amount of combined wave layers.");

			Separator();

			Draw("shoreScale", "The size of the shore texture in world space.");
			Draw("shoreSpeed", "The animation speed of the shore.");

			Separator();

			Draw("ripples", "Apply small ripple details to the ocean surface?");
			if (Any(tgts, t => t.Ripples == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.RipplesTexture == null));
						Draw("ripplesTexture", "The dual normal map texture for ripples.\n\nRG = 0..1 NormalA.xy\n\nBA = 0..1 NormalB.xy", "Texture");
					EndError();
					Draw("ripplesSpeed", "The animation speed of the ripples.", "Speed");
					Draw("ripplesScale", "The size of the ripple texture in world space.", "Scale");
					Draw("ripplesStrength", "The ripples texture strength will be multiplied by this.", "Strength");
				EndIndent();
			}

			Separator();

			Draw("fade", "Ocean rendering can look bat at extreme distances, so fade it out.\n\nNOTE: If you enable this, your landscape should use the <b>OceanFade</b> setting.");
			if (Any(tgts, t => t.Fade == true))
			{
				BeginIndent();
					Draw("fadeDistance", "The ocean will completely disappear at this distance in world space.");
					Draw("fadeDeepDistance", "The deep ocean surface effect will be fully revealed at this distance in world space.", "Deep Distance");
					Draw("fadeDeepDensity", ref markParentForRebuild, "The deep ocean surface effect will have this density.", "Deep Density");
				EndIndent();
			}

			Separator();

			Draw("causticsLight", "The light source for the caustics.");
			Draw("causticsScale", "The size of the caustics texture in world space.");
			Draw("causticsSpeed", "The animation speed of the caustics.");

			if (markForRebuild == true)
			{
				//Each(tgts, t => t.reb);
			}

			if (markParentForRebuild == true)
			{
				foreach (var landscape in SgtLandscape.AllLandscapes)
				{
					if (landscape is SgtSphereLandscape)
					{
						var sphereLandscape = (SgtSphereLandscape)landscape;

						if (sphereLandscape.OceanFade != null && System.Array.IndexOf(tgts, sphereLandscape.OceanFade) >= 0)
						{
							sphereLandscape.MarkForRebuild();
						}
					}
				}
			}

			Separator();

			if (Button("Randomize Hue") == true)
			{
				Each(tgts, t => t.RandomizeHue(), true, true);
			}
		}

		[UnityEditor.MenuItem("GameObject/CW/Space Graphics Toolkit/Ocean", false, 10)]
		public static void CreateMenuItem()
		{
			var parent   = CwHelper.GetSelectedParent();
			var instance = SgtOcean.Create(parent != null ? parent.gameObject.layer : 0, parent);

			CwHelper.SelectAndPing(instance);
		}
	}
}
#endif