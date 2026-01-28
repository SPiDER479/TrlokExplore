using UnityEngine;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Volumetrics;
using CW.Common;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add volumetric clouds to your scene that use a custom shape defined by an SDF texture.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud SDF")]
	public class SgtCloudSDF : SgtVolumeEffect
	{
		/// <summary>The Material used to render the cloud.
		/// NOTE: This must use the <b>SGT / CloudSDF</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The SDF shape of this cloud.</summary>
		public Texture3D Shape { set { shape = value; } get { return shape; } } [SerializeField] private Texture3D shape;

		/// <summary>The resolution of the cloud shadow map.</summary>
		public int ShadowResolution { set { shadowResolution = value; } get { return shadowResolution; } } [SerializeField] private int shadowResolution = 128;

		/// <summary>The density of the cloud shadow map.</summary>
		public float ShadowDensity { set { shadowDensity = value; } get { return shadowDensity; } } [SerializeField] [Range(0.0f, 1.0f)] private float shadowDensity = 1.0f;

		/// <summary>The offset of the cloud shadow map.</summary>
		public float ShadowOffset { set { shadowOffset = value; } get { return shadowOffset; } } [SerializeField] private float shadowOffset = 0.0f;

		[System.NonSerialized]
		private static Mesh cubeMesh;

		[System.NonSerialized]
		private static Mesh quadMesh;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private RenderTexture generatedShadowTexture;

		private static int _SGT_Shape         = Shader.PropertyToID("_SGT_Shape");
		private static int _SGT_ShapeSize     = Shader.PropertyToID("_SGT_ShapeSize");

		public RenderTexture GeneratedShadowTexture
		{
			get
			{
				return generatedShadowTexture;
			}
		}

		public List<SgtLight> GetLights()
		{
			var mask   = 1 << gameObject.layer;
			var lights = SgtLight.Find(mask, transform.position);

			SgtLight.FilterOut(transform.position);
			SgtLight.Write(transform.position, 1.0f, transform, null, SgtLight.MAX_LIGHTS);

			return lights;
		}

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
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			if (generatedShadowTexture != null)
			{
				generatedShadowTexture.Release();

				DestroyImmediate(generatedShadowTexture);

				generatedShadowTexture = null;
			}
		}

		protected virtual void Update()
		{
			var lights = SgtLight.Find(-1, transform.position);

			if (lights[0].CachedLight.type == LightType.Directional)
			{
				RenderShadow(lights[0].transform.forward);
			}
			else
			{
				RenderShadow(lights[0].transform.position - transform.position);
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
				if (shape != null)
				{
					properties.SetTexture(_SGT_Shape, shape);
					properties.SetVector(_SGT_ShapeSize, new Vector4(shape.width, shape.height, shape.depth, 0.0f));
				}

				SgtVolumeCamera.AddDrawMesh(cubeMesh, 0, transform.localToWorldMatrix, material, 0, properties);
			}
		}

		private void RenderShadow(Vector3 lightDirection)
		{
			if (generatedShadowTexture != null && shadowResolution <= 0)
			{
				DestroyImmediate(generatedShadowTexture);
			}

			if (shadowResolution > 0)
			{
				if (generatedShadowTexture == null)
				{
					var desc = new RenderTextureDescriptor(shadowResolution, shadowResolution, RenderTextureFormat.ARGBFloat, 0, 0); desc.sRGB = false;

					generatedShadowTexture = new RenderTexture(desc);
				}
				else if (generatedShadowTexture.width != shadowResolution || generatedShadowTexture.height != shadowResolution)
				{
					generatedShadowTexture.Release();

					generatedShadowTexture.width  = shadowResolution;
					generatedShadowTexture.height = shadowResolution;

					generatedShadowTexture.Create();
				}

				var shadowTemp = RenderTexture.GetTemporary(generatedShadowTexture.descriptor);

				var vm = BuildViewMatrix(lightDirection);
				var pm = BuildOrthoMatrix(1000.0f, 2.0f);
				
				Shader.SetGlobalMatrix("_SGT_ShadowV", vm.inverse);
				Shader.SetGlobalMatrix("_SGT_ShadowIV", vm);
				Shader.SetGlobalMatrix("_SGT_ShadowVP", pm * vm);
				Shader.SetGlobalTexture("_SGT_ShadowTemp", shadowTemp);
				Shader.SetGlobalTexture("_SGT_ShadowTex", generatedShadowTexture);
				Shader.SetGlobalFloat("_SGT_ShadowDensity", ShadowDensity);
				//Shader.SetVector("_SGT_ShadowData", new Vector4(ShadowDensity, ShadowStrength, ShadowBias, ShadowRange));
				Shader.SetGlobalVector("_SGT_ShadowSize", new Vector4(shadowTemp.width, shadowTemp.height, 1.0f / shadowTemp.width, 1.0f / shadowTemp.height));

				Shader.SetGlobalTexture(_SGT_Shape, shape);
				Shader.SetGlobalVector(_SGT_ShapeSize, new Vector4(shape.width, shape.height, shape.depth, 0.0f));

				//Graphics.SetRenderTarget(generatedShadowTexture.colorBuffer, generatedShadowTexture.depthBuffer);
				Graphics.SetRenderTarget(shadowTemp.colorBuffer, shadowTemp.depthBuffer);

				if (material.SetPass(1) == true)
				{
					Graphics.DrawMeshNow(quadMesh, Matrix4x4.identity, 0);
				}

				Graphics.SetRenderTarget(generatedShadowTexture.colorBuffer, generatedShadowTexture.depthBuffer);

				if (material.SetPass(2) == true)
				{
					Graphics.DrawMeshNow(quadMesh, Matrix4x4.identity, 0);
				}

				RenderTexture.ReleaseTemporary(shadowTemp);
			}
		}

		Matrix4x4 BuildOrthoMatrix(float depth, float extent)
		{
			return Matrix4x4.Ortho(-extent, extent, -extent, extent, -depth, depth);
		}

		Matrix4x4 BuildViewMatrix(Vector3 direction)
		{
			direction = transform.InverseTransformDirection(direction).normalized;

			var rot = Quaternion.FromToRotation(direction, Vector3.forward);

			return Matrix4x4.TRS(Vector3.zero, rot, Vector3.one * 1.0f);
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloudSDF))]
	public class SgtCloudBox_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudSDF tgt; SgtCloudSDF[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The Material used to render the cloud.\n\nNOTE: This must use the <b>SGT / CloudSDF</b> shader.");
			EndError();
			BeginError(Any(tgts, t => t.Shape == null));
				Draw("shape", "The SDF shape of this cloud.");
			EndError();
			Draw("shadowResolution", "The resolution of the cloud shadow map.");
			Draw("shadowDensity", "The density of the cloud shadow map.");
			Draw("shadowOffset", "The offset of the cloud shadow map.");

			Separator();

			BeginDisabled();
				EditorGUILayout.ObjectField("Generated Shadow Texture", tgt.GeneratedShadowTexture, typeof(RenderTexture), true);
			EndDisabled();
		}
	}
}
#endif