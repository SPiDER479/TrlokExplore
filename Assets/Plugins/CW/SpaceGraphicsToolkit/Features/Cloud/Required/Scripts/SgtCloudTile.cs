using UnityEngine;
using SpaceGraphicsToolkit.Sky;
using SpaceGraphicsToolkit.Volumetrics;
using CW.Common;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add volumetric clouds to your scene that use a custom shape defined by a 2D texture.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud Tile")]
	public class SgtCloudTile : SgtVolumeEffect
	{
		/// <summary>The Material used to render the cloud.
		/// NOTE: This must use the <b>SGT / CloudTile</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The shape of this cloud.
		/// NOTE: Only the red channel is used.</summary>
		public Texture2D SDF { set { sdf = value; } get { return sdf; } } [SerializeField] private Texture2D sdf;

		/// <summary>The ray marching will step by at least this distance. You can reduce this value if your clouds look noisy.</summary>
		public float MinStep { set { minStep = value; } get { return minStep; } } [SerializeField] [Range(0.0f, 10.0f)] private float minStep = 0.2f;

		/// <summary>The ray march step distance will increase by this each step, reducing the detail of distant clouds.</summary>
		public float ScaleStep { set { scaleStep = value; } get { return scaleStep; } } [SerializeField] [Range(1.0f, 1.1f)] private float scaleStep = 1.01f;

		/// <summary>The size of the cloud in local space.</summary>
		public float Size { set { size = value; } get { return size; } } [SerializeField] private float size = 100.0f;

		/// <summary>The altitude of the cloud in local space.</summary>
		public float Altitude { set { altitude = value; } get { return altitude; } } [SerializeField] private float altitude = 10.0f;

		/// <summary>The thickness of the cloud in local space above the <b>Altitude</b>.</summary>
		public float Height { set { height = value; } get { return height; } } [SerializeField] private float height = 2.0f;

		/// <summary>The thickness of the cloud in local space.</summary>
		public float ThicknessBottom { set { thicknessBottom = value; } get { return thicknessBottom; } } [SerializeField] [Range(0.0f, 1.0f)] private float thicknessBottom = 0.1f;

		/// <summary>The thickness of the cloud in local space.</summary>
		public float ThicknessTop { set { thicknessTop = value; } get { return thicknessTop; } } [SerializeField] [Range(0.0f, 1.0f)] private float thicknessTop = 0.1f;

		/// <summary>The density of the cloud.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 10.0f;

		/// <summary>If you want atmospheric effects to apply to this cloud, drag and drop it into here.</summary>
		public SgtSky Sky { set { sky = value; } get { return sky; } } [SerializeField] private SgtSky sky;

		/// <summary>The ray march lighting sample distance in local space.</summary>
		public float LightStep { set { lightStep = value; } get { return lightStep; } } [SerializeField] private float lightStep = 0.01f;

		/// <summary>The amount the scattered light can pierce through the clouds.</summary>
		public float LightDensity { set { lightDensity = value; } get { return lightDensity; } } [SerializeField] private float lightDensity = 2.0f;

		/// <summary>The resolution of the cloud shadow map.</summary>
		public int ShadowResolution { set { shadowResolution = value; } get { return shadowResolution; } } [SerializeField] private int shadowResolution = 128;

		/// <summary>The density of the cloud shadow map.</summary>
		public float ShadowDensity { set { shadowDensity = value; } get { return shadowDensity; } } [SerializeField] [Range(0.0f, 1.0f)] private float shadowDensity = 1.0f;

		/// <summary>The offset of the cloud shadow map.</summary>
		public float ShadowOffset { set { shadowOffset = value; } get { return shadowOffset; } } [SerializeField] private float shadowOffset = 0.0f;

		public float VariationTiling { set { variationTiling = value; } get { return variationTiling; } } [SerializeField] private float variationTiling = 4.0f;

		/// <summary>The erosion texture is tiled this many times around the planet.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeTiling { set { erodeTiling = value; } get { return erodeTiling; } } [SerializeField] private float erodeTiling = 70.0f;

		/// <summary>The erosion will begin when the camera is within this distance of the clouds.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeRange { set { erodeRange = value; } get { return erodeRange; } } [SerializeField] private float erodeRange = 0.2f;

		/// <summary>The erosion texture will cut away this much from the cloud cover.
		/// NOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.</summary>
		public float ErodeStrength { set { erodeStrength = value; } get { return erodeStrength; } } [SerializeField] [Range(0.0f, 5.0f)] private float erodeStrength = 2.0f;

		[System.NonSerialized]
		private static Mesh cubeMesh;

		[System.NonSerialized]
		private static Mesh quadMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private Vector4 cloudShells;

		[System.NonSerialized]
		private Vector4 cloudExtrude;
		
		private static readonly int _SGT_BlueNoiseTex    = Shader.PropertyToID("_SGT_BlueNoiseTex");
		private static readonly int _SGT_Shape           = Shader.PropertyToID("_SGT_Shape");
		private static readonly int _SGT_ShapeSize       = Shader.PropertyToID("_SGT_ShapeSize");
		private static readonly int _SGT_CloudShells     = Shader.PropertyToID("_SGT_CloudShells");
		private static readonly int _SGT_CloudSize       = Shader.PropertyToID("_SGT_CloudSize");
		private static readonly int _SGT_CloudDensity    = Shader.PropertyToID("_SGT_CloudDensity");
		private static readonly int _SGT_CloudExtrude    = Shader.PropertyToID("_SGT_CloudExtrude");
		private static readonly int _SGT_World2Sky       = Shader.PropertyToID("_SGT_World2Sky");
		private static readonly int _SGT_Sky2Cloud       = Shader.PropertyToID("_SGT_Sky2Cloud");
		private static readonly int _SGT_Cloud2Sky       = Shader.PropertyToID("_SGT_Cloud2Sky");
		private static readonly int _SGT_ErodeData       = Shader.PropertyToID("_SGT_ErodeData");
		private static readonly int _SGT_StepData        = Shader.PropertyToID("_SGT_StepData");
		private static readonly int _SGT_LightStep       = Shader.PropertyToID("_SGT_LightStep");
		private static readonly int _SGT_LightDensity    = Shader.PropertyToID("_SGT_LightDensity");
		private static readonly int _SGT_VariationTiling = Shader.PropertyToID("_SGT_VariationTiling");

		protected override void OnEnable()
		{
			base.OnEnable();

			if (cubeMesh == null)
			{
				var go = GameObject.CreatePrimitive(PrimitiveType.Cube);

				go.hideFlags = HideFlags.DontSave;

				cubeMesh = go.GetComponent<MeshFilter>().sharedMesh;

				DestroyImmediate(go);
			}

			if (quadMesh == null)
			{
				var go = GameObject.CreatePrimitive(PrimitiveType.Quad);

				go.hideFlags = HideFlags.DontSave;

				quadMesh = go.GetComponent<MeshFilter>().sharedMesh;

				DestroyImmediate(go);
			}

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			Shader.SetGlobalTexture(_SGT_BlueNoiseTex, SgtVolumeManager.BlueNoiseTex);
		}

		private float SphereDepth(Vector3 point, float radius)
		{
			var p2 = point.x * point.x + point.z * point.z;

			if (p2 > radius * radius)
				return 0.0f;

			var t = point.y - Mathf.Sqrt(radius * radius - p2);

			return t >= 0 ? t : 0.0f;
		}

		protected virtual void Update()
		{
			if (sky != null)
			{
				var radius    = sky.InnerMeshRadius + altitude;
				var depth     = SphereDepth(new Vector3(size * 0.5f, radius, size * 0.5f), radius);
				var thickness = height + depth * 0.5f;

				transform.localScale    = new Vector3(size, size, thickness + depth * 0.5f);
				transform.localPosition = transform.localRotation * new Vector3(0.0f, 0.0f, radius - depth * 0.5f + height * 0.5f);

				cloudShells.x = radius;
				cloudShells.y = radius + height;
				cloudShells.z = radius;
				cloudShells.w = 2.0f / thickness;

				cloudExtrude.x = 0.0f;
				cloudExtrude.y = 0.0f;
				cloudExtrude.z = height;
				cloudExtrude.w = thickness;
			}
		}

		public override void CalculateSortDistance(Vector3 worldPoint)
		{
			sortDistance = Vector3.Distance(worldPoint, transform.position);
		}

		public override void RenderBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
			if (material != null)
			{
				if (sky != null)
				{
					sky.ApplySettings(properties);
				}

				var localScale = transform.localScale;

				if (sdf != null)
				{
					var matrix = Matrix4x4.TRS(transform.localPosition, transform.localRotation, transform.localScale);

					properties.SetTexture(_SGT_Shape, sdf);
					properties.SetVector(_SGT_ShapeSize, new Vector4(sdf.width, sdf.height, 0.0f, 0.0f));
					properties.SetVector(_SGT_CloudShells, cloudShells);
					properties.SetVector(_SGT_CloudSize, new Vector4(localScale.x, localScale.y, localScale.z, 0.0f));
					properties.SetVector(_SGT_CloudExtrude, cloudExtrude);
					properties.SetFloat(_SGT_CloudDensity, density);
					properties.SetMatrix(_SGT_World2Sky, sky.transform.worldToLocalMatrix);
					properties.SetMatrix(_SGT_Sky2Cloud, matrix.inverse);
					properties.SetMatrix(_SGT_Cloud2Sky, matrix);

					properties.SetFloat(_SGT_LightStep, lightStep);
					properties.SetFloat(_SGT_LightDensity, lightDensity);
				}

				// Variation
				properties.SetFloat(_SGT_VariationTiling, variationTiling);

				// Erode
				var invSize = new Vector4(localScale.x * erodeTiling, localScale.y * erodeTiling, localScale.z * erodeTiling, erodeStrength);

				properties.SetVector(_SGT_ErodeData, invSize);

				properties.SetVector(_SGT_StepData, new Vector4((1.0f / erodeTiling) * minStep, scaleStep, 0.0f, 0.0f));

				SgtVolumeCamera.AddDrawMesh(cubeMesh, 0, transform.localToWorldMatrix, material, 0, properties);
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			if (isActiveAndEnabled == true)
			{
				Gizmos.matrix = transform.localToWorldMatrix;
				Gizmos.DrawWireCube(Vector3.zero, Vector3.one);
			}
		}
#endif
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloudTile))]
	public class SgtCloudTile_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudTile tgt; SgtCloudTile[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The Material used to render the cloud.\n\nNOTE: This must use the <b>SGT / CloudTile</b> shader.");
			EndError();
			BeginError(Any(tgts, t => t.Sky == null));
				Draw("sky", "If you want atmospheric effects to apply to this cloud, drag and drop it into here.");
			EndError();
			BeginError(Any(tgts, t => t.SDF == null));
				Draw("sdf", "The shape of this cloud.\n\nNOTE: Only the red channel is used.");
			EndError();
			Draw("minStep", "The ray marching will step by at least this distance. You can reduce this value if your clouds look noisy.");
			Draw("scaleStep", "The ray march step distance will increase by this each step, reducing the detail of distant clouds.");

			Separator();

			Draw("size", "The size of the cloud in local space.");
			Draw("altitude", "The altitude of the cloud in local space.");
			Draw("height", "The thickness of the cloud in local space above the <b>Altitude</b>.");
			Draw("density", "The density of the cloud.");

			Separator();

			Draw("lightStep", "The ray march lighting sample distance in local space.");
			Draw("lightDensity", "The amount the scattered light can pierce through the clouds.");

			Separator();

			Draw("shadowResolution", "The resolution of the cloud shadow map.");
			Draw("shadowDensity", "The density of the cloud shadow map.");
			Draw("shadowOffset", "The offset of the cloud shadow map.");

			Separator();

			Draw("variationTiling");

			Separator();

			Draw("erodeTiling", "The erosion texture is tiled this many times around the planet.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");
			Draw("erodeRange", "The erosion will begin when the camera is within this distance of the clouds.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");
			Draw("erodeStrength", "The erosion texture will cut away this much from the cloud cover.\n\nNOTE: This requires the <b>Material</b> setting to have <b>ERODE</b> enabled.");
		}
	}
}
#endif