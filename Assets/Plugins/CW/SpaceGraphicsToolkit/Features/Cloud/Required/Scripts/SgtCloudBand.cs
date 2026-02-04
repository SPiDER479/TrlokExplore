using UnityEngine;
using SpaceGraphicsToolkit.Sky;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Volumetrics;
using CW.Common;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add a band of volumetric clouds to your scene that can wrap around your planet at a specific latitude.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud Band")]
	public class SgtCloudBand : SgtVolumeEffect
	{
		/// <summary>The Material used to render the cloud.
		/// NOTE: This must use the <b>SGT / CloudBand</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>This allows you to define where clouds appear on the band.</summary>
		public Texture CoverageTex { set { coverageTex = value; } get { return coverageTex; } } [SerializeField] private Texture coverageTex;

		/// <summary>The outer radius of the band in local space.</summary>
		public float OuterRadius { set { outerRadius = value; } get { return outerRadius; } } [SerializeField] private float outerRadius = 500.0f;

		/// <summary>The inner radius of the band in local space.</summary>
		public float InnerRadius { set { innerRadius = value; } get { return innerRadius; } } [SerializeField] private float innerRadius = 490.0f;

		/// <summary>The location of the band.
		/// -1 = South pole.
		/// 1 = North pole.</summary>
		public float Latitude { set { latitude = value; } get { return latitude; } } [SerializeField] [Range(-1.0f, 1.0f)] private float latitude;

		/// <summary>The thickness of the band along the latitude.</summary>
		public float Thickness { set { thickness = value; } get { return thickness; } } [SerializeField] [Range(0.0f, 1.0f)] private float thickness = 0.1f;

		/// <summary>If you want atmospheric effects to apply to this cloud, drag and drop it into here.</summary>
		public SgtSky Sky { set { sky = value; } get { return sky; } } [SerializeField] private SgtSky sky;

		[System.NonSerialized]
		private static Mesh cylinderMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		private static int _SGT_LightRotation = Shader.PropertyToID("_SGT_LightRotation");
		private static int _SGT_CoverageTex   = Shader.PropertyToID("_SGT_CoverageTex");
		private static int _SGT_Radius        = Shader.PropertyToID("_SGT_Radius");

		protected override void OnEnable()
		{
			base.OnEnable();

			if (cylinderMesh == null)
			{
				var go = GameObject.CreatePrimitive(PrimitiveType.Cylinder);

				go.hideFlags = HideFlags.DontSave;

				cylinderMesh = go.GetComponent<MeshFilter>().sharedMesh;

				DestroyImmediate(go);
			}

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
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
					sky.ApplySettings(properties, finalCamera);

					properties.SetMatrix(_SGT_LightRotation, sky.transform.localToWorldMatrix * transform.worldToLocalMatrix);
				}
				else
				{
					CwHelper.SetTempMaterial(properties);

					// Write lights and shadows
					var mask   = 1 << gameObject.layer;
					var lights = SgtLight.Find(mask, transform.position);

					SgtLight.FilterOut(transform.position);
					SgtLight.Write(transform.position, 1.0f, transform, null, SgtLight.MAX_LIGHTS);

					properties.SetMatrix(_SGT_LightRotation, Matrix4x4.identity);
				}

				if (coverageTex != null)
				{
					properties.SetTexture(_SGT_CoverageTex, coverageTex);
				}

				properties.SetVector(_SGT_Radius, new Vector4(innerRadius, outerRadius, 0.0f, 0.0f));

				SgtVolumeCamera.AddDrawMesh(cylinderMesh, 0, transform.localToWorldMatrix, material, 0, properties);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloudBand))]
	public class SgtCloudBand_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudBand tgt; SgtCloudBand[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The Material used to render the cloud.\n\nNOTE: This must use the <b>SGT / CloudBand</b> shader.");
			EndError();
			BeginError(Any(tgts, t => t.CoverageTex == null));
				Draw("coverageTex", "This allows you to define where clouds appear on the band.");
			EndError();
			Draw("outerRadius", "The outer radius of the band in local space.");
			Draw("innerRadius", "The outer radius of the band in local space.");
			Draw("latitude", "The location of the band.\n\n-1 = South pole.\n\n1 = North pole.");
			Draw("thickness", "The thickness of the band along the latitude.");
			Draw("sky", "If you want atmospheric effects to apply to this cloud, drag and drop it into here.");
		}
	}
}
#endif