using UnityEngine;
using CW.Common;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>This component can be added alongside <b>SgtOcean</b> to add marine snow like debris under the water surface.</summary>
	[RequireComponent(typeof(SgtOcean))]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ocean Debris")]
	public class SgtOceanDebris : MonoBehaviour
	{
		private struct CameraData
		{
			public Quaternion PreviousRotation;
			public float      TotalRoll;

			[System.NonSerialized]
			public static Dictionary<Camera, CameraData> Instances = new Dictionary<Camera, CameraData>();

			public static CameraData Update(Camera camera)
			{
				var instance = Instances.GetValueOrDefault(camera);
				var rotation = camera.transform.rotation;

				instance.TotalRoll       += (Quaternion.Inverse(rotation) * instance.PreviousRotation).eulerAngles.z;
				instance.PreviousRotation = rotation;

				Instances[camera] = instance;

				return instance;
			}
		}

		/// <summary>The material used to render the debris.
		/// NOTE: This must use the <b>SGT / OceanDebris</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The particle brightness will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 0.1f;

		/// <summary>The texture applied to the particles.
		/// NOTE: This should be a 2D texture of a particle, or grid of particles.</summary>
		public Texture MainTex { set { mainTex = value; } get { return mainTex; } } [SerializeField] private Texture mainTex;

		/// <summary>The amount of columns and rows in the <b>MainTex</b>.</summary>
		public Vector2Int Cells { set { cells = value; } get { return cells; } } [SerializeField] private Vector2Int cells = new Vector2Int(1, 1);

		/// <summary>The amount of debris particles used to render the effect.</summary>
		public int Count { set { count = value; } get { return count; } } [SerializeField] private int count = 1500;

		/// <summary>The maximum camera distance debris particles can appear in world space.</summary>
		public float Range { set { range = value; } get { return range; } } [SerializeField] private float range = 5.0f;

		/// <summary>The radius of debris particles in world space.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] private float radius = 0.01f;

		/// <summary>The maximum distance particles can drift in world space.</summary>
		public float Drift { set { drift = value; } get { return drift; } } [SerializeField] private float drift = 1.0f;

		/// <summary>The maximum depth the debris particles can reach below the surface.</summary>
		public float MaxDepth { set { maxDepth = value; } get { return maxDepth; } } [SerializeField] private float maxDepth = 20.0f;

		/// <summary>This allows you to set how quickly debris particles fade out as they approach the ocean surface.</summary>
		public float SurfaceSharpness { set { surfaceSharpness = value; } get { return surfaceSharpness; } } [SerializeField] private float surfaceSharpness = 1000.0f;

		/// <summary>This allows you to set how quickly debris particles fade out as they approach the deep ocean.</summary>
		public float DeepSharpness { set { deepSharpness = value; } get { return deepSharpness; } } [SerializeField] private float deepSharpness = 600.0f;

		/// <summary>The amount the <b>Brightness</b> value can flicker by.</summary>
		public float BrightnessMin { set { brightnessMin = value; } get { return brightnessMin; } } [SerializeField] [Range(0.0f, 1.0f)] private float brightnessMin = 0.0f;

		[System.NonSerialized]
		private Mesh generatedMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private SgtOcean cachedOcean;

		private static int _SGT_WrapSize             = Shader.PropertyToID("_SGT_WrapSize");
		private static int _SGT_WorldToLocal         = Shader.PropertyToID("_SGT_WorldToLocal");
		private static int _SGT_DataA                = Shader.PropertyToID("_SGT_DataA");
		private static int _SGT_DataB                = Shader.PropertyToID("_SGT_DataB");
		private static int _SGT_UnderwaterBrightness = Shader.PropertyToID("_SGT_UnderwaterBrightness");
		private static int _SGT_MainTex              = Shader.PropertyToID("_SGT_MainTex");
		private static int _SGT_Cells                = Shader.PropertyToID("_SGT_Cells");
		private static int _SGT_Roll                 = Shader.PropertyToID("_SGT_Roll");

		public void MarkMeshDirty()
		{
			DestroyImmediate(generatedMesh);
		}

		protected virtual void OnEnable()
		{
			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			cachedOcean = GetComponent<SgtOcean>();

			GenerateMesh();

			Camera.onPreCull += HandleCameraPreRender;
			UnityEngine.Rendering.RenderPipelineManager.beginCameraRendering += HandleCameraPreRender;
		}

		protected virtual void OnDisable()
		{
			Camera.onPreCull -= HandleCameraPreRender;
			UnityEngine.Rendering.RenderPipelineManager.beginCameraRendering -= HandleCameraPreRender;

			DestroyImmediate(generatedMesh);

			CameraData.Instances.Clear();
		}

		protected virtual void Update()
		{
			properties.SetTexture(_SGT_MainTex, mainTex != null ? mainTex : Texture2D.whiteTexture);
			properties.SetVector(_SGT_Cells, new Vector4(cells.x, cells.y, 0.0f, 0.0f));
			properties.SetVector(_SGT_WrapSize, new Vector4(range * 2.0f, CwHelper.Reciprocal(range * 2.0f), 0.0f, 0.0f));
			properties.SetMatrix(_SGT_WorldToLocal, cachedOcean.transform.worldToLocalMatrix);
			properties.SetVector(_SGT_DataA, new Vector4(surfaceSharpness, radius, brightness, brightness * brightnessMin));
			properties.SetVector(_SGT_DataB, new Vector4(cachedOcean.Radius, drift, maxDepth, deepSharpness));
			properties.SetFloat(_SGT_UnderwaterBrightness, cachedOcean.UnderwaterBrightness);

			cachedOcean.ApplyCloudShadowSettings(properties);

			if (generatedMesh == null)
			{
				GenerateMesh();
			}
		}

		private void HandleCameraPreRender(UnityEngine.Rendering.ScriptableRenderContext context, Camera camera)
		{
			HandleCameraPreRender(camera);
		}

		private void HandleCameraPreRender(Camera camera)
		{
			if (generatedMesh != null && material != null && cachedOcean.CalculateWorldAltitude(camera.transform.position) < range + maxDepth)
			{
				var cameraData   = CameraData.Update(camera);
				properties.SetFloat(_SGT_Roll, cameraData.TotalRoll * Mathf.Deg2Rad);

				Graphics.DrawMesh(generatedMesh, Matrix4x4.Translate(camera.transform.position), material, gameObject.layer, camera, 0, properties);
			}
		}

		private void GenerateMesh()
		{
			if (count > 0)
			{
				var vertices  = new Vector3[count * 4];
				var uv        = new Vector4[count * 4];
				var triangles = new int[count * 6];

				for (int i = 0; i < count; i++)
				{
					var position = new Vector3(UnityEngine.Random.Range(-0.5f, 0.5f), UnityEngine.Random.Range(-0.5f, 0.5f), UnityEngine.Random.Range(-0.5f, 0.5f));
					var seed     = UnityEngine.Random.value;

					vertices[i * 4 + 0] = position;
					vertices[i * 4 + 1] = position;
					vertices[i * 4 + 2] = position;
					vertices[i * 4 + 3] = position;

					uv[i * 4 + 0] = new Vector4(-1.0f,  1.0f,  0.5f, seed);
					uv[i * 4 + 1] = new Vector4( 1.0f,  1.0f, -0.5f, seed);
					uv[i * 4 + 2] = new Vector4(-1.0f, -1.0f,  0.5f, seed);
					uv[i * 4 + 3] = new Vector4( 1.0f, -1.0f, -0.5f, seed);

					triangles[i * 6 + 0] = i * 4 + 0;
					triangles[i * 6 + 1] = i * 4 + 1;
					triangles[i * 6 + 2] = i * 4 + 2;
					triangles[i * 6 + 3] = i * 4 + 3;
					triangles[i * 6 + 4] = i * 4 + 2;
					triangles[i * 6 + 5] = i * 4 + 1;
				}

				generatedMesh = new Mesh();

				generatedMesh.hideFlags   = HideFlags.HideAndDontSave;
				generatedMesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
				generatedMesh.bounds      = new Bounds(Vector3.zero, Vector3.one);

				generatedMesh.SetVertices(vertices);
				generatedMesh.SetUVs(0, uv);
				generatedMesh.SetTriangles(triangles, 0);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Ocean
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtOceanDebris))]
	public class SgtOceanDebris_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			Separator();

			SgtOceanDebris tgt; SgtOceanDebris[] tgts; GetTargets(out tgt, out tgts);

			var markMeshDirty = false;

			Draw("material", "The material used to render the debris.\n\nNOTE: This must use the <b>SGT / OceanDebris</b> shader.");
			Draw("brightness", "The particle brightness will be multiplied by this.");
			BeginError(Any(tgts, t => t.MainTex == null));
				Draw("mainTex", "The texture applied to the particles.");
			EndError();
			BeginError(Any(tgts, t => t.Cells.x <= 0 || t.Cells.y <= 0));
				Draw("cells", "The amount of columns and rows in the <b>MainTex</b>.");
			EndError();

			Separator();

			Draw("count", ref markMeshDirty, "The amount of debris particles used to render the effect.");
			Draw("range", "The maximum camera distance debris particles can appear in world space.");
			Draw("radius", "The radius of debris particles in world space.");
			Draw("drift", "The maximum distance particles can drift in world space.");
			Draw("maxDepth", "The maximum depth the debris particles can reach below the surface.");
			Draw("surfaceSharpness", "This allows you to set how quickly debris particles fade out as they approach the ocean surface.");
			Draw("deepSharpness", "This allows you to set how quickly debris particles fade out as they approach the deep ocean.");
			Draw("brightnessMin", "The amount the <b>Brightness</b> value can flicker by.");

			if (markMeshDirty == true)
			{
				Each(tgts, t => t.MarkMeshDirty(), true, true);
			}
		}
	}
}
#endif