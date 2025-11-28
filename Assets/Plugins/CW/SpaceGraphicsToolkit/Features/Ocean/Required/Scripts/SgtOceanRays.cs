using UnityEngine;
using CW.Common;
using SpaceGraphicsToolkit.LightAndShadow;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>This component can be added alongside <b>SgtOcean</b> to add sun light shafts under the water surface.</summary>
	[RequireComponent(typeof(SgtOcean))]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ocean Rays")]
	public class SgtOceanRays : MonoBehaviour
	{
		/// <summary>The material used to render the rays.
		/// NOTE: This must use the <b>SGT / OceanRays</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The particle brightness will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 0.01f;

		/// <summary>The amount of ray particles used to render the effect.</summary>
		public int Count { set { count = value; } get { return count; } } [SerializeField] private int count = 5000;

		/// <summary>The light source for these rays.</summary>
		public SgtLight RayLight { set { rayLight = value; } get { return rayLight; } } [SerializeField] private SgtLight rayLight;

		/// <summary>The maximum camera distance ray particles can appear in world space.</summary>
		public float Range { set { range = value; } get { return range; } } [SerializeField] private float range = 10.0f;

		/// <summary>The thickness of ray particles in world space.</summary>
		public float Thickness { set { thickness = value; } get { return thickness; } } [SerializeField] private float thickness = 0.1f;

		/// <summary>The length of ray particles in world space.</summary>
		public float Length { set { length = value; } get { return length; } } [SerializeField] private float length = 3.0f;

		/// <summary>The maximum distance particles can drift in world space.</summary>
		public float Drift { set { drift = value; } get { return drift; } } [SerializeField] private float drift = 1.0f;

		/// <summary>The maximum depth the rays can reach below the surface.</summary>
		public float MaxDepth { set { maxDepth = value; } get { return maxDepth; } } [SerializeField] private float maxDepth = 10.0f;

		/// <summary>This allows you to set how quickly ray particles fade out as they approach the ocean surface.</summary>
		public float SurfaceSharpness { set { surfaceSharpness = value; } get { return surfaceSharpness; } } [SerializeField] private float surfaceSharpness = 500.0f;

		/// <summary>This allows you to set how quickly ray particles fade out as they approach the deep ocean.</summary>
		public float DeepSharpness { set { deepSharpness = value; } get { return deepSharpness; } } [SerializeField] private float deepSharpness = 600.0f;

		/// <summary>The minimum rate at which a particle can flicker.</summary>
		public float FlickerRateMin { set { flickerRateMin = value; } get { return flickerRateMin; } } [SerializeField] private float flickerRateMin = 20.0f;

		/// <summary>The maximum rate at which a particle can flicker.</summary>
		public float FlickerRateMax { set { flickerRateMax = value; } get { return flickerRateMax; } } [SerializeField] private float flickerRateMax = 50.0f;

		/// <summary>The amount the <b>Brightness</b> value can flicker by.</summary>
		public float BrightnessMin { set { brightnessMin = value; } get { return brightnessMin; } } [SerializeField] [Range(0.0f, 1.0f)] private float brightnessMin = 0.0f;

		[System.NonSerialized]
		private Mesh generatedMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private SgtOcean cachedOcean;

		private static int _SGT_StretchDirection     = Shader.PropertyToID("_SGT_StretchDirection");
		private static int _SGT_WrapSize             = Shader.PropertyToID("_SGT_WrapSize");
		private static int _SGT_WorldToLocal         = Shader.PropertyToID("_SGT_WorldToLocal");
		private static int _SGT_DataA                = Shader.PropertyToID("_SGT_DataA");
		private static int _SGT_DataB                = Shader.PropertyToID("_SGT_DataB");
		private static int _SGT_FadeData             = Shader.PropertyToID("_SGT_FadeData");
		private static int _SGT_FlickerData          = Shader.PropertyToID("_SGT_FlickerData");
		private static int _SGT_UnderwaterBrightness = Shader.PropertyToID("_SGT_UnderwaterBrightness");

		public void MarkMeshDirty()
		{
			DestroyImmediate(generatedMesh);
		}

		private Vector3 GetLightDirection()
		{
			var finalLight = rayLight;

			if (finalLight == null)
			{
				var lights = SgtLight.Find(-1, cachedOcean.transform.position);

				if (lights.Count > 0)
				{
					finalLight = lights[0];
				}
			}

			if (finalLight != null && finalLight.isActiveAndEnabled == true)
			{
				if (finalLight.CachedLight.type == LightType.Point || (finalLight.CachedLight.type == LightType.Directional && finalLight.TreatAsPoint == true))
				{
					return Vector3.Normalize(finalLight.CachedTransform.position - cachedOcean.transform.position);
				}
				else
				{
					return finalLight.CachedTransform.forward;
				}
			}

			return Vector3.forward;
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
		}

		protected virtual void Update()
		{
			properties.SetVector(_SGT_StretchDirection, GetLightDirection());
			properties.SetVector(_SGT_WrapSize, new Vector4(range * 2.0f, CwHelper.Reciprocal(range * 2.0f), cachedOcean.Radius, drift));
			properties.SetMatrix(_SGT_WorldToLocal, cachedOcean.transform.worldToLocalMatrix);
			properties.SetVector(_SGT_FadeData, new Vector4(CwHelper.Reciprocal(range - length), thickness, length, 0.0f));
			properties.SetVector(_SGT_FlickerData, new Vector4(flickerRateMin, flickerRateMax, brightness, brightness * brightnessMin));
			properties.SetFloat(_SGT_UnderwaterBrightness, cachedOcean.UnderwaterBrightness);

			properties.SetVector(_SGT_DataA, new Vector4(surfaceSharpness, deepSharpness, 0.0f, 0.0f));
			properties.SetVector(_SGT_DataB, new Vector4(cachedOcean.Radius, drift, maxDepth, 0.0f));

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
				Graphics.DrawMesh(generatedMesh, Matrix4x4.Translate(camera.transform.position), material, gameObject.layer, camera, 0, properties);
			}
		}

		private void GenerateMesh()
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
			generatedMesh.bounds      = new Bounds(Vector3.zero, Vector3.one * 100);

			generatedMesh.SetVertices(vertices);
			generatedMesh.SetUVs(0, uv);
			generatedMesh.SetTriangles(triangles, 0);
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Ocean
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtOceanRays))]
	public class SgtOceanRays_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			Separator();

			SgtOceanRays tgt; SgtOceanRays[] tgts; GetTargets(out tgt, out tgts);

			var markMeshDirty = false;

			Draw("material", "The material used to render the rays.\n\nNOTE: This must use the <b>SGT / OceanRays</b> shader.");
			Draw("brightness", "The particle brightness will be multiplied by this.");
			Draw("rayLight", "The light source for these rays.");
			Draw("count", ref markMeshDirty, "The amount of ray particles used to render the effect.");
			Draw("range", "The maximum camera distance ray particles can appear in world space.");
			Draw("thickness", "The thickness of ray particles in world space.");
			Draw("length", "The length of ray particles in world space.");
			Draw("drift", "The maximum distance particles can drift in world space.");
			Draw("maxDepth", "The maximum depth the debris particles can reach below the surface.");
			Draw("surfaceSharpness", "This allows you to set how quickly ray particles fade out as they approach the ocean surface.");
			Draw("deepSharpness", "This allows you to set how quickly ray particles fade out as they approach the deep ocean.");

			Separator();

			Draw("flickerRateMin", "The minimum rate at which a particle can flicker.");
			Draw("flickerRateMax", "The maximum rate at which a particle can flicker.");
			Draw("brightnessMin", "The amount the <b>Brightness</b> value can flicker by.");

			if (markMeshDirty == true)
			{
				Each(tgts, t => t.MarkMeshDirty(), true, true);
			}
		}
	}
}
#endif