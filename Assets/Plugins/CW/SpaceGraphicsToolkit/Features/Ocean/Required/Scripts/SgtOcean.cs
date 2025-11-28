using UnityEngine;
using CW.Common;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Jobs;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Volumetrics;
using SpaceGraphicsToolkit.LightAndShadow;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>This component can be used to render oceans for your planets.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ocean")]
	public partial class SgtOcean : SgtVolumeEffect
	{
		/// <summary>The radius of the ocean.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] private float radius = 50.0f;

		/// <summary>The overall detail of the ocean relative to the camera distance. The higher you set this, the more triangles it will have.</summary>
		public float Detail { set { detail = value; } get { return detail; } } [SerializeField] [Range(0.01f, 3.0f)] private float detail = 1.2f;

		/// <summary>If you want cloud shadows to appear on the surface of the ocean, specify them here.</summary>
		public SgtCloud CloudShadow { set { cloudShadow = value; } get { return cloudShadow; } } [SerializeField] protected SgtCloud cloudShadow;

		/// <summary>The LOD will be based on these transform positions.
		/// None/null = The GameObject with the <b>MainCamera</b> tag will be used.</summary>
		public List<Transform> Observers { get { if (observers == null) observers = new List<Transform>(); return observers; } } [SerializeField] private List<Transform> observers;

		/// <summary>The material used to render the fluid surface.
		/// NOTE: This must use the <b>SGT/OceanUSurface</b> shader.</summary>
		public Material SurfaceMaterial { set { surfaceMaterial = value; } get { return surfaceMaterial; } } [SerializeField] private Material surfaceMaterial;

		/// <summary>The color of the fluid when viewed from above the surface.</summary>
		public Color SurfaceColor { set { surfaceColor = value; } get { return surfaceColor; } } [SerializeField] private Color surfaceColor = new Color(0.007843138f, 0.3647059f, 0.5019608f);

		/// <summary>The density of the water when viewed from above the surface.</summary>
		public float SurfaceDensity { set { surfaceDensity = value; } get { return surfaceDensity; } } [SerializeField] private float surfaceDensity = 0.5f;

		/// <summary>The minimum opacity of the water when viewed from above the surface.</summary>
		public float SurfaceMinimumOpacity { set { surfaceMinimumOpacity = value; } get { return surfaceMinimumOpacity; } } [SerializeField] [Range(0.0f, 1.0f)] private float surfaceMinimumOpacity;

		/// <summary>The PBR smoothness of the surface material.</summary>
		public float SurfaceSmoothness { set { surfaceSmoothness = value; } get { return surfaceSmoothness; } } [SerializeField] [Range(0.0f, 1.0f)] private float surfaceSmoothness = 0.9f;

		/// <summary>The waves normal map texture.</summary>
		public Texture2D SurfaceTexture { set { surfaceTexture = value; } get { return surfaceTexture; } } [SerializeField] private Texture2D surfaceTexture;

		/// <summary>The wave texture gets tiled around the planet this many times.
		/// X = First layer.
		/// Y = Second layer.
		/// Z = Third layer.
		/// W = Fourth layer.
		/// NOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.</summary>
		public Vector4 SurfaceTiling { set { surfaceTiling = value; } get { return surfaceTiling; } } [SerializeField] private Vector4 surfaceTiling = new Vector4(100.0f, 1000.0f, 0.0f, 0.0f);

		/// <summary>The wave texture fades out when the camera is within this world space distance.
		/// X = First layer.
		/// Y = Second layer.
		/// Z = Third layer.
		/// W = Fourth layer.
		/// NOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.</summary>
		public Vector4 SurfaceRange { set { surfaceRange = value; } get { return surfaceRange; } } [SerializeField] private Vector4 surfaceRange = new Vector4(100.0f, 10.0f, 0.0f, 0.0f);

		/// <summary>The waves texture strength will be multiplied by this.
		/// X = First layer.
		/// Y = Second layer.
		/// Z = Third layer.
		/// W = Fourth layer.
		/// NOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.</summary>
		public Vector4 SurfaceStrength { set { surfaceStrength = value; } get { return surfaceStrength; } } [SerializeField] [Range(0.01f, 5.0f)] private Vector4 surfaceStrength = new Vector4(0.5f, 0.5f, 0.0f, 0.0f);

		/// <summary>The color of the water when viewed from below the surface.</summary>
		public Color UnderwaterColor { set { underwaterColor = value; } get { return underwaterColor; } } [SerializeField] private Color underwaterColor = new Color(0.007843138f, 0.3647059f, 0.5019608f);

		/// <summary>The <b>UnderwaterColor</b> will fade out using these value.
		/// X = Red Extinction.
		/// Y = Green Extinction.
		/// Z = Blue Extinction.
		/// W = RGB Multiplier.</summary>
		public Vector4 UnderwaterExtinction { set { underwaterExtinction = value; } get { return underwaterExtinction; } } [SerializeField] private Vector4 underwaterExtinction = new Vector4(1.0f, 1.0f, 1.0f, 0.1f);

		/// <summary>The extinction amount will be calculated at this distance from the camera.</summary>
		public float UnderwaterExtinctionRange { set { underwaterExtinctionRange = value; } get { return underwaterExtinctionRange; } } [SerializeField] private float underwaterExtinctionRange = 10.0f;

		/// <summary>The density of the water when viewed from under the surface.</summary>
		public float UnderwaterDensity { set { underwaterDensity = value; } get { return underwaterDensity; } } [SerializeField] private float underwaterDensity = 0.5f;

		/// <summary>The minimum opacity of the water when viewed from under the surface.</summary>
		public float UnderwaterMinimumOpacity { set { underwaterMinimumOpacity = value; } get { return underwaterMinimumOpacity; } } [SerializeField] [Range(0.0f, 1.0f)] private float underwaterMinimumOpacity;

		/// <summary>The sharpness of the underwater lighting.</summary>
		public float UnderwaterLightingSharpness { set { underwaterLightingSharpness = value; } get { return underwaterLightingSharpness; } } [SerializeField] [Range(1.0f, 20.0f)] private float underwaterLightingSharpness = 5.0f;

		/// <summary>The distance from the camera the cloud shadow calculations will use. This should approximately be the underwater fog distance (4.6 * density).</summary>
		public float UnderwaterShadowRange { set { underwaterShadowRange = value; } get { return underwaterShadowRange; } } [SerializeField] private float underwaterShadowRange = 10.0f;

		/// <summary>The waves normal map texture.</summary>
		public Texture2D WavesTexture { set { wavesTexture = value; } get { return wavesTexture; } } [SerializeField] private Texture2D wavesTexture;

		/// <summary>The texture used to break up the tiling of the wave animation. This should be a Red seamless texture.</summary>
		public Texture2D WavesOffset { set { wavesOffset = value; } get { return wavesOffset; } } [SerializeField] private Texture2D wavesOffset;

		/// <summary>The waves texture will animate at this speed.</summary>
		public float WavesSpeed { set { wavesSpeed = value; } get { return wavesSpeed; } } [SerializeField] private float wavesSpeed = 3.0f;

		/// <summary>The wave texture gets tiled around the planet this many times.</summary>
		public float WavesTiling { set { wavesTiling = value; } get { return wavesTiling; } } [SerializeField] private float wavesTiling = 1000.0f;

		/// <summary>The waves will displace the ocean mesh by this distance.
		/// NOTE: This setting requires your <b>SurfaceMaterial</b> to have the <b>Displacement</b> setting enabled.</summary>
		public float WavesDisplacement { set { wavesDisplacement = value; } get { return wavesDisplacement; } } [SerializeField] private float wavesDisplacement;

		/// <summary>The ripples texture strength will be multiplied by this.</summary>
		public float RipplesStrength { set { ripplesStrength = value; } get { return ripplesStrength; } } [SerializeField] [Range(0.01f, 5.0f)] private float ripplesStrength = 0.5f;

		/// <summary>The ripple texture is tiled this many times relative to the <b>WavesTiling</b> value.</summary>
		public int RipplesTiling { set { ripplesTiling = value; } get { return ripplesTiling; } } [SerializeField] [Range(1, 16)] private int ripplesTiling = 1;

		/// <summary>Should the ocean fade out based on camera distance?
		/// NOTE: This requires the <b>SurfaceMaterial</b> to have the FADE setting enabled.</summary>
		public bool Fade { set { fade = value; } get { return fade; } } [SerializeField] private bool fade;

		/// <summary>The ocean will completely disappear at this distance in world space.</summary>
		public float FadeDistance { set { fadeDistance = value; } get { return fadeDistance; } } [SerializeField] private float fadeDistance = 1000.0f;

		/// <summary>Render underwater caustics effects?
		/// NOTE: This requires the <b>SurfaceMaterial</b> to have the <b>CAUSTICS</b> setting enabled.</summary>
		public bool Caustics { set { caustics = value; } get { return caustics; } } [SerializeField] private bool caustics = true;

		/// <summary>If you want the ocean to apply caustics to the underlying geometry, specify it here.</summary>
		public Texture3D CausticsTexture { set { causticsTexture = value; } get { return causticsTexture; } } [SerializeField] private Texture3D causticsTexture;

		/// <summary>The light source for the caustics.</summary>
		public SgtLight CausticsLight { set { causticsLight = value; } get { return causticsLight; } } [SerializeField] private SgtLight causticsLight;

		/// <summary>The caustics texture will animate at this speed.</summary>
		public float CausticsSpeed { set { causticsSpeed = value; } get { return causticsSpeed; } } [SerializeField] private float causticsSpeed = 0.5f;

		/// <summary>The caustics texture will be tiled this many times around the planet.</summary>
		public float CausticsTiling { set { causticsTiling = value; } get { return causticsTiling; } } [SerializeField] private float causticsTiling = 0.5f;

		/// <summary>The caustics texture will be fade in/out by this amount.</summary>
		public float CausticsOpacity { set { causticsOpacity = value; } get { return causticsOpacity; } } [SerializeField] [Range(0.0f, 1.0f)] private float causticsOpacity = 1.0f;

		/// <summary>The caustics texture smoothness/sharpness.</summary>
		public float CausticsPower { set { causticsPower = value; } get { return causticsPower; } } [SerializeField] [Range(1.0f, 10.0f)] private float causticsPower = 2.0f;

		/// <summary>This allows you to control how deep below the surface caustics can reach.</summary>
		public float CausticsMaxDepth { set { causticsMaxDepth = value; } get { return causticsMaxDepth; } } [SerializeField] private float causticsMaxDepth = 10.0f;

		/// <summary>This allows you to control how quickly caustics fade in based on ocean depth.</summary>
		public float CausticsSurfaceSharpness { set { causticsSurfaceSharpness = value; } get { return causticsSurfaceSharpness; } } [SerializeField] private float causticsSurfaceSharpness = 10.0f;

		/// <summary>This allows you to control how quickly caustics fade out based on ocean depth.</summary>
		public float CausticsDeepSharpness { set { causticsDeepSharpness = value; } get { return causticsDeepSharpness; } } [SerializeField] private float causticsDeepSharpness = 10.0f;

		//public float RefractionStrength { set { refractionStrength = value; } get { return refractionStrength; } } [SerializeField] private float refractionStrength;

		[System.NonSerialized]
		private float underwaterBrightness;

		[System.NonSerialized]
		private RenderTexture causticsSlice;

		[System.NonSerialized]
		private RenderTexture wavesSlice;

		[System.NonSerialized]
		private float causticsPosition;

		[System.NonSerialized]
		private float wavesPosition;

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
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private JobHandle updateHandle;

		[System.NonSerialized]
		private bool updateRunning;

		[System.NonSerialized]
		private List<Batch> batches = new List<Batch>();

		[System.NonSerialized]
		private Dictionary<TriangleHash, Batch> triangleBatches = new Dictionary<TriangleHash, Batch>();

		private static readonly int _SGT_CausticsTexure = Shader.PropertyToID("_SGT_CausticsTexure");
		private static readonly int _SGT_CausticsData   = Shader.PropertyToID("_SGT_CausticsData");
		private static readonly int _SGT_CausticsDirection = Shader.PropertyToID("_SGT_CausticsDirection");
		private static readonly int _SGT_Origins        = Shader.PropertyToID("_SGT_Origins");
		private static readonly int _SGT_PositionsA     = Shader.PropertyToID("_SGT_PositionsA");
		private static readonly int _SGT_PositionsB     = Shader.PropertyToID("_SGT_PositionsB");
		private static readonly int _SGT_PositionsC     = Shader.PropertyToID("_SGT_PositionsC");
		private static readonly int _SGT_CoordsX        = Shader.PropertyToID("_SGT_CoordsX");
		private static readonly int _SGT_CoordsY        = Shader.PropertyToID("_SGT_CoordsY");
		private static readonly int _SGT_CoordsZ        = Shader.PropertyToID("_SGT_CoordsZ");
		private static readonly int _SGT_CoordsW        = Shader.PropertyToID("_SGT_CoordsW");
		private static readonly int _SGT_FadeDistance   = Shader.PropertyToID("_SGT_FadeDistance");

		private static readonly int _SGT_SurfaceColor             = Shader.PropertyToID("_SGT_SurfaceColor");
		private static readonly int _SGT_SurfaceDensity           = Shader.PropertyToID("_SGT_SurfaceDensity");
		private static readonly int _SGT_SurfaceMinimumOpacity    = Shader.PropertyToID("_SGT_SurfaceMinimumOpacity");
		private static readonly int _SGT_SurfaceSmoothness        = Shader.PropertyToID("_SGT_SurfaceSmoothness");
		private static readonly int _SGT_SurfaceTexture           = Shader.PropertyToID("_SGT_SurfaceTexture");
		private static readonly int _SGT_SurfaceTiling            = Shader.PropertyToID("_SGT_SurfaceTiling");
		private static readonly int _SGT_SurfaceRange             = Shader.PropertyToID("_SGT_SurfaceRange");
		private static readonly int _SGT_SurfaceStrength          = Shader.PropertyToID("_SGT_SurfaceStrength");

		private static readonly int _SGT_UnderwaterColor          = Shader.PropertyToID("_SGT_UnderwaterColor");
		private static readonly int _SGT_UnderwaterExtinction     = Shader.PropertyToID("_SGT_UnderwaterExtinction");
		private static readonly int _SGT_UnderwaterDensity        = Shader.PropertyToID("_SGT_UnderwaterDensity");
		private static readonly int _SGT_UnderwaterMinimumOpacity = Shader.PropertyToID("_SGT_UnderwaterMinimumOpacity");
		private static readonly int _SGT_UnderwaterBrightness     = Shader.PropertyToID("_SGT_UnderwaterBrightness");

		private static readonly int _SGT_WaveTexture = Shader.PropertyToID("_SGT_WaveTexture");
		private static readonly int _SGT_WaveData    = Shader.PropertyToID("_SGT_WaveData");

		private static readonly int _SGT_Offset       = Shader.PropertyToID("_SGT_Offset");
		private static readonly int _SGT_Radius       = Shader.PropertyToID("_SGT_Radius");

		protected static readonly int _SGT_CloudTex     = Shader.PropertyToID("_SGT_CloudTex");
		protected static readonly int _SGT_CloudMatrix  = Shader.PropertyToID("_SGT_CloudMatrix");
		protected static readonly int _SGT_CloudOpacity = Shader.PropertyToID("_SGT_CloudOpacity");
		protected static readonly int _SGT_CloudWarp    = Shader.PropertyToID("_SGT_CloudWarp");
		protected static readonly int _SGT_UnderwaterShadowRange = Shader.PropertyToID("_SGT_UnderwaterShadowRange");
		
		private static readonly int _SGT_Texture    = Shader.PropertyToID("_SGT_Texture");
		private static readonly int _SGT_OffsetTex  = Shader.PropertyToID("_SGT_OffsetTex");

		private static readonly int _SGT_ObjectToOcean = Shader.PropertyToID("_SGT_ObjectToOcean");
		private static readonly int _SGT_OceanToObject = Shader.PropertyToID("_SGT_OceanToObject");
		private static readonly int _SGT_WorldToLocal  = Shader.PropertyToID("_SGT_WorldToLocal");

		private static readonly int _SGT_Object2World         = Shader.PropertyToID("_SGT_Object2World");
		private static readonly int _SGT_World2Object         = Shader.PropertyToID("_SGT_World2Object");
		private static readonly int _SGT_World2View           = Shader.PropertyToID("_SGT_World2View");
		private static readonly int _SGT_WCam                 = Shader.PropertyToID("_SGT_WCam");

		public RenderTexture CausticsSlice
		{
			get
			{
				return causticsSlice;
			}
		}

		public RenderTexture WavesSlice
		{
			get
			{
				return wavesSlice;
			}
		}

		public float UnderwaterBrightness
		{
			get
			{
				return underwaterBrightness;
			}
		}

		private void DrawTriangles()
		{
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
			//ScheduleUpdate(meshDetail);
			//CompleteAndRebuildBatches();

			var bounds = new Bounds(Vector3.zero, Vector3.one * 10000.0f);
			var o2w    = RemoveTranslation(transform.localToWorldMatrix);
			var w2o    = RemoveTranslation(transform.worldToLocalMatrix);
			var rot    = Quaternion.Inverse(transform.rotation) * transform.position;

			properties.SetMatrix(_SGT_ObjectToOcean, o2w);
			properties.SetMatrix(_SGT_OceanToObject, w2o);
			properties.SetMatrix(_SGT_WorldToLocal, transform.worldToLocalMatrix);
			properties.SetVector(_SGT_Offset, rot);
			properties.SetFloat(_SGT_Radius, radius);

			ApplyCloudShadowSettings(properties);

			DrawTriangles(batches, surfaceMaterial);
		}

		public void ApplyCloudShadowSettings(MaterialPropertyBlock properties)
		{
			if (cloudShadow != null && cloudShadow.GeneratedTexture != null)
			{
				properties.SetTexture(_SGT_CloudTex, cloudShadow.GeneratedTexture);
				properties.SetMatrix(_SGT_CloudMatrix, cloudShadow.GeneratedMatrix);
				properties.SetVector(_SGT_CloudOpacity, cloudShadow.GeneratedOpacity);
				properties.SetFloat(_SGT_CloudWarp, cloudShadow.Warp);
				properties.SetFloat(_SGT_UnderwaterShadowRange, underwaterShadowRange);
			}
		}

		private void ScheduleUpdate(float detail)
		{
			cameraPositions.Clear();

			if (observers != null)
			{
				foreach (var observer in observers)
				{
					if (observer != null)
					{
						cameraPositions.Add((float3)transform.InverseTransformPoint(observer.position));
					}
				}
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
			trianglesJob.MaxDepth        = 40;
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

			batch.AddTriangle(triangle, (int4)new float4(wavesTiling, surfaceTiling.y, surfaceTiling.z, surfaceTiling.w), radius);

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

		private void DrawTriangles(List<Batch> batches, Material material)
		{
			if (material != null)
			{
				var bounds = new Bounds(transform.position, Vector3.one * radius * 2.0f);

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

					Graphics.DrawMeshInstancedProcedural(GetMesh(), 0, material, bounds, batch.Count, properties, UnityEngine.Rendering.ShadowCastingMode.Off, true, gameObject.layer);
				}
			}
		}

		private Matrix4x4 RemoveTranslation(Matrix4x4 matrix)
		{
			matrix.m03 = 0;
			matrix.m13 = 0;
			matrix.m23 = 0;

			return matrix;
		}

		public float CalculateWorldAltitude(Vector3 worldPoint)
		{
			var localPoint   = transform.InverseTransformPoint(worldPoint);
			var localSurface = localPoint.normalized * radius;
			var worldSurface = transform.TransformPoint(localSurface);

			return Vector3.Distance(worldPoint, worldSurface);
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

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			if (causticsSlice != null)
			{
				DestroyImmediate(causticsSlice);
			}

			if (wavesSlice != null)
			{
				DestroyImmediate(wavesSlice);
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

		protected virtual void LateUpdate()
		{
			UpdateDetail();

			underwaterBrightness = CalculateUnderwaterBrightness();

			properties.SetColor(_SGT_SurfaceColor, surfaceColor);
			properties.SetFloat(_SGT_SurfaceDensity, surfaceDensity);
			properties.SetFloat(_SGT_SurfaceMinimumOpacity, surfaceMinimumOpacity);
			properties.SetFloat(_SGT_SurfaceSmoothness, surfaceSmoothness);
			properties.SetTexture(_SGT_SurfaceTexture, surfaceTexture != null ? surfaceTexture : Texture2D.normalTexture);
			properties.SetVector(_SGT_SurfaceTiling, (float4)(int4)(float4)surfaceTiling);
			properties.SetVector(_SGT_SurfaceRange, surfaceRange);
			properties.SetVector(_SGT_SurfaceStrength, surfaceStrength);
			properties.SetFloat(_SGT_FadeDistance, fadeDistance);

			properties.SetColor(_SGT_UnderwaterColor, underwaterColor);
			properties.SetVector(_SGT_UnderwaterExtinction, new Vector4(underwaterExtinction.x * underwaterExtinction.w, underwaterExtinction.y * underwaterExtinction.w, underwaterExtinction.z * underwaterExtinction.w, underwaterExtinctionRange));
			properties.SetFloat(_SGT_UnderwaterDensity, underwaterDensity);
			properties.SetFloat(_SGT_UnderwaterMinimumOpacity, underwaterMinimumOpacity);
			properties.SetFloat(_SGT_UnderwaterBrightness, underwaterBrightness);

			if (caustics == true && causticsSlice != null)
			{
				properties.SetTexture(_SGT_CausticsTexure, causticsSlice);
				properties.SetVector(_SGT_CausticsData, new Vector4(causticsMaxDepth, causticsSurfaceSharpness, causticsDeepSharpness, causticsTiling));
				properties.SetVector(_SGT_CausticsDirection, GetLightDirection());
			}

			properties.SetTexture(_SGT_WaveTexture, wavesSlice != null ? wavesSlice : Texture2D.normalTexture);
			properties.SetVector(_SGT_WaveData, new Vector4(wavesTiling, wavesDisplacement, ripplesTiling, ripplesStrength));

			DrawTriangles();
		}

		public override void RenderWaterBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
			if (blitMaterial == null)
			{
				blitMaterial = CwHelper.CreateTempMaterial("SgtOcean", "Hidden/SgtOcean");
			}

			blitMaterial.SetMatrix(_SGT_World2View, finalCamera.worldToCameraMatrix);
			blitMaterial.SetVector(_SGT_WCam, finalCamera.transform.position);

			blitMaterial.SetFloat(_SGT_SurfaceDensity, surfaceDensity);
			blitMaterial.SetFloat(_SGT_SurfaceMinimumOpacity, surfaceMinimumOpacity);

			blitMaterial.SetFloat(_SGT_UnderwaterDensity, underwaterDensity);
			blitMaterial.SetFloat(_SGT_UnderwaterMinimumOpacity, underwaterMinimumOpacity);

			blitMaterial.EnableKeyword("_SGT_SHAPE_SPHERE");

			if (wavesDisplacement > 0.0f)
			{
				blitMaterial.EnableKeyword("_SGT_DISPLACEMENT_ON");
			}
			else
			{
				blitMaterial.DisableKeyword("_SGT_DISPLACEMENT_ON");
			}

			var bounds = new Bounds(transform.position, Vector3.one * radius * 2.0f);
			
			blitMaterial.enableInstancing = true;

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

				SgtVolumeCamera.AddDrawMeshInstancedProcedural(GetMesh(), 0, blitMaterial, 2, false, batch.Count, properties);
			}
		}

		public override void RenderBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
		}

		public void UpdateDetail()
		{
			if (blitMaterial == null)
			{
				blitMaterial = CwHelper.CreateTempMaterial("SgtOcean", "Hidden/SgtOcean");
			}

			var oldActive = RenderTexture.active;

			if (caustics == true && causticsTexture != null)
			{
				if (causticsSlice == null)
				{
					var desc = new RenderTextureDescriptor(causticsTexture.width, causticsTexture.height, RenderTextureFormat.R8, 0, 8);

					desc.sRGB = false;

					causticsSlice = new RenderTexture(desc);
					causticsSlice.wrapMode         = TextureWrapMode.Repeat;
					causticsSlice.useMipMap        = true;
					causticsSlice.autoGenerateMips = false;

					causticsSlice.Create();
				}

				causticsPosition += causticsSpeed * Time.deltaTime;

				blitMaterial.SetTexture(_SGT_CausticsTexure, causticsTexture);
				blitMaterial.SetVector(_SGT_CausticsData, new Vector4(causticsPosition, causticsOpacity, causticsPower));

				Graphics.Blit(default(Texture), causticsSlice, blitMaterial, 0);

				causticsSlice.GenerateMips();
			}

			if (wavesTexture != null)
			{
				if (wavesSlice == null)
				{
					var mips = Mathf.FloorToInt(Mathf.Log(Mathf.Max(wavesTexture.width, wavesTexture.height), 2)) + 1;
					var desc = new RenderTextureDescriptor(wavesTexture.width, wavesTexture.height, RenderTextureFormat.ARGB32, 0, mips);
					
					desc.useMipMap        = true;
					desc.autoGenerateMips = false;
					desc.sRGB             = false;

					wavesSlice = new RenderTexture(desc);
					wavesSlice.wrapMode = TextureWrapMode.Repeat;

					wavesSlice.Create();
				}

				wavesPosition += wavesSpeed * Time.deltaTime;

				blitMaterial.SetTexture(_SGT_Texture, wavesTexture);
				blitMaterial.SetTexture(_SGT_OffsetTex, wavesOffset);
				blitMaterial.SetVector(_SGT_WaveData, new Vector4(wavesPosition, ripplesStrength, 1.0f));

				Graphics.Blit(default(Texture), wavesSlice, blitMaterial, 1);

				wavesSlice.GenerateMips();
			}

			RenderTexture.active = oldActive;
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

			Draw("radius", "The radius of the ocean.");
			Draw("detail", "The overall detail of the ocean relative to the camera distance. The higher you set this, the more triangles it will have.");
			Draw("cloudShadow", "If you want cloud shadows to appear on the surface of the ocean, specify them here.");
			Draw("observers", "The LOD will be based on these transform positions.\n\nNone/null = The GameObject with the <b>MainCamera</b> tag will be used.");

			Separator();

			BeginError(Any(tgts, t => t.SurfaceMaterial == null));
				Draw("surfaceMaterial", "The material used to render the fluid surface.\n\nNOTE: This must use the <b>SGT/OceanSurface</b> shader.");
			EndError();
			Draw("surfaceColor", "The color of the fluid when viewed from above the surface.");
			Draw("surfaceDensity", "The density of the water when viewed from above the surface.");
			Draw("surfaceMinimumOpacity", "The minimum opacity of the water when viewed from above the surface.");
			Draw("surfaceSmoothness", "The PBR smoothness of the surface material.");
			Draw("surfaceTexture", "The waves normal map texture.");
			if (DrawVector4("surfaceTiling", "The wave texture gets tiled around the planet this many times.\n\nX = First layer.\n\nY = Second layer.\n\nZ = Third layer.\n\nW = Fourth layer.\n\nNOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.") == true) { markForRebuild = true; }
			DrawVector4("surfaceRange", "The wave texture gets tiled around the planet this many times.\n\nX = First layer.\n\nY = Second layer.\n\nZ = Third layer.\n\nW = Fourth layer.\n\nNOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.");
			DrawVector4("surfaceStrength", "The wave texture gets tiled around the planet this many times.\n\nX = First layer.\n\nY = Second layer.\n\nZ = Third layer.\n\nW = Fourth layer.\n\nNOTE: The <b>SurfaceMaterial</b> has the <b>Layers</b> setting, which allows you to choose how many are used.");

			Separator();

			Draw("underwaterColor", "The color of the water when viewed from below the surface.");
			DrawVector4("underwaterExtinction", "The <b>UnderwaterColor</b> will fade out using these value.\\nX = Red Extinction.\\nY = Green Extinction.\\nZ = Blue Extinction.\\nW = RGB Multiplier.");
			Draw("underwaterExtinctionRange", "The extinction amount will be calculated at this distance from the camera.");
			Draw("underwaterDensity", "The density of the water when viewed from under the surface.");
			Draw("underwaterMinimumOpacity", "The minimum opacity of the water when viewed from under the surface.");
			Draw("underwaterLightingSharpness", "The sharpness of the underwater lighting.");
			Draw("underwaterShadowRange", "The distance from the camera the cloud shadow calculations will use. This should approximately be the underwater fog distance (4.6 * density).");

			Separator();

			BeginError(Any(tgts, t => t.WavesTexture == null));
				Draw("wavesTexture", "The waves normal map texture.");
			EndError();
			BeginError(Any(tgts, t => t.WavesOffset == null));
				Draw("wavesOffset", "The texture used to break up the tiling of the wave animation. This should be a Red seamless texture.");
			EndError();
			Draw("wavesSpeed", "The waves texture will animate at this speed.");
			Draw("wavesTiling", ref markForRebuild, "The wave texture gets tiled around the planet this many times.");
			Draw("wavesDisplacement", "The waves will displace the ocean mesh by this distance.\n\nNOTE: This setting requires your <b>SurfaceMaterial</b> to have the <b>Displacement</b> setting enabled.");

			Separator();

			Draw("ripplesTiling", "The ripple texture is tiled this many times relative to the <b>WavesTiling</b> value.");
			Draw("ripplesStrength", "The ripples texture strength will be multiplied by this.");

			Separator();

			Draw("fade", "Should the ocean fade out based on camera distance?\n\nNOTE: This requires the <b>SurfaceMaterial</b> to have the FADE setting enabled.");

			if (Any(tgts, t => t.Fade == true))
			{
				BeginIndent();
					Draw("fadeDistance", "The ocean will completely disappear at this distance in world space.");
				EndIndent();
			}

			Separator();

			Draw("caustics", "Render underwater caustics effects?\n\nNOTE: This requires the <b>SurfaceMaterial</b> to have the <b>CAUSTICS</b> setting enabled.");

			if (Any(tgts, t => t.Caustics == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.CausticsTexture == null));
						Draw("causticsTexture", "If you want the ocean to apply caustics to the underlying geometry, specify it here.", "Texture");
					EndError();
					Draw("causticsLight", "The light source for the caustics.", "Lights");
					Draw("causticsSpeed", "The caustics texture will animate at this speed.", "Speed");
					Draw("causticsTiling", "The caustics texture will be tiled this many times around the planet.", "Tiling");
					Draw("causticsOpacity", "The caustics texture will be fade in/out by this amount.", "Opacity");
					Draw("causticsPower", "The caustics texture smoothness/sharpness.", "Power");
					Draw("causticsMaxDepth", "This allows you to control how deep below the surface caustics can reach.", "Max Depth");
					Draw("causticsSurfaceSharpness", "This allows you to control how quickly caustics fade in based on ocean depth.", "Surface Sharpness");
					Draw("causticsDeepSharpness", "This allows you to control how quickly caustics fade out based on ocean depth.", "Deep Sharpness");
				EndIndent();
			}

			if (markForRebuild == true)
			{
				//Each(tgts, t => t.reb);
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