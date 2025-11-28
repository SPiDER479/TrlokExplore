using UnityEngine;
using CW.Common;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Volumetrics
{
	/// <summary>This component must be added to your scene if you want to render volumetric effects like <b>SgtSky</b> or <b>SgtCloud</b>.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Volume Manager")]
	public class SgtVolumeManager : MonoBehaviour
	{
		public enum SmoothType
		{
			None,
			Box5x5,
			Bicubic
		}

		public static LinkedList<SgtVolumeManager> Instances = new LinkedList<SgtVolumeManager>();

		/// <summary>This allows you to specify how the width/height of the volumetric effects are divided. For example, a value of 1 means no downscaling, and 5 means 1/5 width and height or 1/25 of the total pixels.</summary>
		public int Downscale { set { downscale = value; } get { return downscale; } } [SerializeField] [Range(1, 10)] private int downscale = 2;

		/// <summary>Smooth volumetric effects over time?</summary>
		public float TAA { set { taa = value; } get { return taa; } } [SerializeField] [Range(0.0f, 1.0f)] private float taa;

		/// <summary>This allows you to apply a smoothing pass to the clouds.
		/// Box5x5 = Aggressive smoothing that can look good up close, but not recommended for distant effects.
		/// Bicubic = Retains most detail and provides some smoothing.</summary>
		public SmoothType Smooth { set { smooth = value; } get { return smooth; } } [SerializeField] private SmoothType smooth;

		/// <summary>Use a higher precision color buffer for smoother volumetrics?</summary>
		public bool HighPrecision { set { highPrecision = value; } get { return highPrecision; } } [SerializeField] private bool highPrecision = true;

		public static Camera CurrentCamera;

		[System.NonSerialized]
		private RenderTexture wholeColor;

		[System.NonSerialized]
		private RenderTexture wholeDepth;

		[System.NonSerialized]
		private RenderTexture oldColor;

		[System.NonSerialized]
		private RenderTexture oldDepth;

		[System.NonSerialized]
		private RenderTexture waterDepth;

		[System.NonSerialized]
		private RenderTexture waterAlpha;

		[System.NonSerialized]
		private RenderTexture sceneDepth;

		[System.NonSerialized]
		private RenderTexture tempColor;

		[System.NonSerialized]
		private RenderTexture tempDepth;

		[System.NonSerialized]
		private float smoothRange;

		[System.NonSerialized]
		private static Material depthMaterial;

		[System.NonSerialized]
		private static Material filterMaterial;

		[System.NonSerialized]
		private static int passSceneDepth;

		[System.NonSerialized]
		private static int passTAA;

		[System.NonSerialized]
		private static int passTAA2;

		[System.NonSerialized]
		private static Texture2D blueNoiseTex;

		[System.NonSerialized]
		private Matrix4x4 prevVP = Matrix4x4.identity;

		[System.NonSerialized]
		private LinkedListNode<SgtVolumeManager> node;

		private static int _SGT_Volumetrics_ColorTex  = Shader.PropertyToID("_SGT_Volumetrics_ColorTex");
		private static int _SGT_Volumetrics_ColorSize = Shader.PropertyToID("_SGT_Volumetrics_ColorSize");
		private static int _SGT_Volumetrics_DepthTex  = Shader.PropertyToID("_SGT_Volumetrics_DepthTex");
		private static int _SGT_Volumetrics_DepthSize = Shader.PropertyToID("_SGT_Volumetrics_DepthSize");
		private static int _SGT_SceneDepthTexture     = Shader.PropertyToID("_SGT_SceneDepthTexture");
		private static int _SGT_WaterDepthTexture     = Shader.PropertyToID("_SGT_WaterDepthTexture");
		private static int _SGT_WaterAlphaTexture     = Shader.PropertyToID("_SGT_WaterAlphaTexture");
		private static int _SGT_Downscale             = Shader.PropertyToID("_SGT_Downscale");

		public RenderTexture WholeColor
		{
			get
			{
				return wholeColor;
			}
		}

		public RenderTexture WholeDepth
		{
			get
			{
				return wholeDepth;
			}
		}

		public RenderTexture SceneDepth
		{
			get
			{
				return sceneDepth;
			}
		}

		public RenderTexture WaterDepth
		{
			get
			{
				return waterDepth;
			}
		}

		public RenderTexture WaterAlpha
		{
			get
			{
				return waterAlpha;
			}
		}

		public Material DepthMaterial
		{
			get
			{
				return depthMaterial;
			}
		}

		public int PassSceneDepth
		{
			get
			{
				return passSceneDepth;
			}
		}

		public float SmoothRange
		{
			get
			{
				return smoothRange;
			}
		}

		public void MarkForRebuild()
		{
			if (wholeColor != null)
			{
				Release();
			}
		}

		public static Texture2D BlueNoiseTex
		{
			get
			{
				if (blueNoiseTex == null)
				{
					blueNoiseTex = new Texture2D(64, 64, TextureFormat.R8, false, true);

					blueNoiseTex.wrapMode   = TextureWrapMode.Repeat;
					blueNoiseTex.filterMode = FilterMode.Point;

					blueNoiseTex.LoadImage(System.Convert.FromBase64String(
						"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"));
				}

				return blueNoiseTex;
			}
		}

		private void Release()
		{
			RenderTexture.ReleaseTemporary(oldColor); oldColor = null;
			RenderTexture.ReleaseTemporary(oldDepth); oldDepth = null;
			RenderTexture.ReleaseTemporary(wholeColor); wholeColor = null;
			RenderTexture.ReleaseTemporary(wholeDepth); wholeDepth = null;
			RenderTexture.ReleaseTemporary(sceneDepth); sceneDepth = null;
			RenderTexture.ReleaseTemporary(waterDepth); waterDepth = null;
			RenderTexture.ReleaseTemporary(waterAlpha); waterAlpha = null;
			RenderTexture.ReleaseTemporary(tempColor); tempColor = null;
			RenderTexture.ReleaseTemporary(tempDepth); tempDepth = null;
		}

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);
		}

		protected virtual void OnDisable()
		{
			Instances.Remove(node); node = null;

			Release();
		}

		protected virtual void LateUpdate()
		{
			if (Camera.main != null)
			{
				var cameraV = Camera.main.worldToCameraMatrix;
				var cameraP = Camera.main.projectionMatrix;

				var currVP    = cameraP * cameraV;
				var currInvVP = currVP.inverse;

				Shader.SetGlobalMatrix("_SGT_ViewProj", currVP);
				if (filterMaterial != null)
				{
					filterMaterial.SetMatrix("_SGT_InvViewProj", currInvVP);
					filterMaterial.SetMatrix("_SGT_PrevViewProj", prevVP);
					filterMaterial.SetFloat("_SGT_TAA", Mathf.Lerp(1.0f, 0.01f, taa));
				}

				prevVP = currVP;
			}
		}

		private static List<SgtVolumeEffect> tempVolumeEffects = new List<SgtVolumeEffect>();

		public bool PrepareEffects()
		{
			if (CurrentCamera == null)
			{
				return false;
			}

			if (depthMaterial == null)
			{
				depthMaterial  = CwHelper.CreateTempMaterial("Depth Mat", "Hidden/SgtVolumeDepth");
				passSceneDepth = depthMaterial.FindPass("SceneDepth");
				
				filterMaterial = CwHelper.CreateTempMaterial("Filter Mat", "Hidden/SgtVolumeFilter");
				passTAA        = filterMaterial.FindPass("TAA");
				passTAA2       = filterMaterial.FindPass("TAA2");
			}

			var smallW = CurrentCamera.pixelWidth  / downscale;
			var smallH = CurrentCamera.pixelHeight / downscale;
			var wholeW = CurrentCamera.pixelWidth  / 1;
			var wholeH = CurrentCamera.pixelHeight / 1;

			if (downscale > 1)
			{
				if (smallW % 2 == 0) smallW -= 1;
				if (smallH % 2 == 0) smallH -= 1;
			}

			var format = highPrecision == true ? RenderTextureFormat.ARGBFloat : RenderTextureFormat.ARGB32;

			if (wholeColor != null && (wholeColor.width != smallW || wholeColor.height != smallH || wholeColor.format != format))
			{
				Release();
			}

			if (wholeColor == null)
			{
				var wholeColorDesc = new RenderTextureDescriptor(smallW, smallH, format, 0, 0) { sRGB = false };
				var wholeDepthDesc = new RenderTextureDescriptor(smallW, smallH, RenderTextureFormat.RGFloat, 0, 0) { sRGB = false };
				var waterDepthDesc = new RenderTextureDescriptor(wholeW, wholeH, RenderTextureFormat.RFloat, 24, 0) { sRGB = false };
				var waterAlphaDesc = new RenderTextureDescriptor(wholeW, wholeH, RenderTextureFormat.R8, 0, 0) { sRGB = false };

				wholeColor = RenderTexture.GetTemporary(wholeColorDesc);
				wholeDepth = RenderTexture.GetTemporary(wholeDepthDesc);
				sceneDepth = RenderTexture.GetTemporary(smallW, smallH, 0, RenderTextureFormat.RFloat);
				waterDepth = RenderTexture.GetTemporary(waterDepthDesc);
				waterAlpha = RenderTexture.GetTemporary(waterAlphaDesc);
			}

			Shader.SetGlobalFloat(_SGT_Downscale, downscale);
			Shader.SetGlobalTexture(_SGT_SceneDepthTexture, sceneDepth);
			Shader.SetGlobalTexture(_SGT_WaterDepthTexture, waterDepth);
			Shader.SetGlobalTexture(_SGT_WaterAlphaTexture, waterAlpha);
			Shader.SetGlobalTexture(_SGT_Volumetrics_ColorTex, wholeColor);
			Shader.SetGlobalVector(_SGT_Volumetrics_ColorSize, new Vector4(wholeColor.width, wholeColor.height, 1.0f / wholeColor.width, 1.0f / wholeColor.height));
			Shader.SetGlobalTexture(_SGT_Volumetrics_DepthTex, wholeDepth);
			Shader.SetGlobalVector(_SGT_Volumetrics_DepthSize, new Vector4(wholeDepth.width, wholeDepth.height, 1.0f / wholeDepth.width, 1.0f / wholeDepth.height));

			return true;
		}

		public void UpdateEffects()
		{
			if (CurrentCamera == null)
			{
				return;
			}

			var oldNearClip = CurrentCamera.nearClipPlane;
			var oldFarClip  = CurrentCamera.farClipPlane;

			CurrentCamera.nearClipPlane = oldNearClip;
			CurrentCamera.farClipPlane  = oldFarClip;

			var renderSize = new Vector2Int(wholeColor.width, wholeColor.height);

			tempVolumeEffects.Clear();

			foreach (var volumeEffect in SgtVolumeEffect.Instances)
			{
				volumeEffect.sortDistance = Vector3.Distance(CurrentCamera.transform.position, volumeEffect.transform.position);

				tempVolumeEffects.Add(volumeEffect);
			}

			tempVolumeEffects.Sort((a, b) => b.sortDistance.CompareTo(a.sortDistance));
			
			/*
			var cameraV           = CurrentCamera.worldToCameraMatrix;
			var cameraV2          = CurrentCamera.worldToCameraMatrix;
			var cameraP           = CurrentCamera.projectionMatrix;

			if (Camera.current != null)
			{
				cameraV2 *= Camera.current.cameraToWorldMatrix; // ??
			}

			var currVP    = cameraP * cameraV;
			var currInvVP = currVP.inverse;

			Shader.SetGlobalMatrix("_SGT_ViewProj", currVP);
			filterMaterial.SetMatrix("_SGT_InvViewProj", currInvVP);
			filterMaterial.SetMatrix("_SGT_PrevViewProj", prevVP);
			filterMaterial.SetFloat("_SGT_TAA", Mathf.Lerp(1.0f, 0.01f, taa));

			prevVP = currVP;
			*/

			// Render volume
			SgtVolumeCamera.AddMRT(waterDepth.colorBuffer, waterAlpha.colorBuffer, waterDepth.depthBuffer, new Color(float.PositiveInfinity, 0.0f, 0.0f, 0.0f));

			foreach (var volumeEffect in tempVolumeEffects)
			{
				volumeEffect.RenderWaterBuffers(this, CurrentCamera, 0, renderSize);
			}

			if (taa > 0.0f)
			{
				if (tempColor == null) { tempColor = RenderTexture.GetTemporary(wholeColor.descriptor); filterMaterial.SetTexture("_SGT_Volumetrics_ColorTex_Temp", tempColor); }
				if (tempDepth == null) { tempDepth = RenderTexture.GetTemporary(wholeDepth.descriptor); filterMaterial.SetTexture("_SGT_Volumetrics_DepthTex_Temp", tempDepth); }

				if (oldColor == null) { oldColor = RenderTexture.GetTemporary(wholeColor.descriptor); filterMaterial.SetTexture("_SGT_Volumetrics_ColorTex_Old", oldColor); }
				if (oldDepth == null) { oldDepth = RenderTexture.GetTemporary(wholeDepth.descriptor); filterMaterial.SetTexture("_SGT_Volumetrics_DepthTex_Old", oldDepth); }

				SgtVolumeCamera.AddMRT(tempColor.colorBuffer, tempDepth.colorBuffer, tempDepth.depthBuffer, Color.clear);

				foreach (var volumeEffect in tempVolumeEffects)
				{
					volumeEffect.RenderBuffers(this, CurrentCamera, 0, renderSize);
				}

				// TAA
				SgtVolumeCamera.AddMRT(wholeColor.colorBuffer, wholeDepth.colorBuffer, wholeDepth.depthBuffer, Color.clear);

				SgtVolumeCamera.AddDrawMesh(CwHelper.GetQuadMesh(), 0, Matrix4x4.identity, filterMaterial, passTAA, false);


				SgtVolumeCamera.AddMRT(oldColor.colorBuffer, oldDepth.colorBuffer, oldDepth.depthBuffer, Color.clear);

				SgtVolumeCamera.AddDrawMesh(CwHelper.GetQuadMesh(), 0, Matrix4x4.identity, filterMaterial, passTAA2, false);

				// TODO: Find out why this needs to be set to wholeColor/wholeDepth at the end
				SgtVolumeCamera.AddMRT(wholeColor.colorBuffer, wholeDepth.colorBuffer, wholeDepth.depthBuffer);
			}
			else
			{
				SgtVolumeCamera.AddMRT(wholeColor.colorBuffer, wholeDepth.colorBuffer, wholeDepth.depthBuffer, Color.clear);

				foreach (var volumeEffect in tempVolumeEffects)
				{
					volumeEffect.RenderBuffers(this, CurrentCamera, 0, renderSize);
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Volumetrics
{
	class SgtAssetPostprocessor : UnityEditor.AssetPostprocessor
	{
		static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
		{
			foreach (var landscape in SgtVolumeManager.Instances)
			{
				landscape.MarkForRebuild();
			}
		}
	}

	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtVolumeManager))]
	public class SgtVolumeManager_Editor : CwEditor
	{
		public static void Require()
		{
			if (SgtVolumeManager.Instances.Count == 0)
			{
				Separator();

				if (CwEditor.HelpButton("This component requires your scene to have the " + typeof(SgtVolumeManager).Name + " component, but it doesn't.", UnityEditor.MessageType.Error, "Fix", 50.0f) == true)
				{
					var vm = new GameObject("SgtVolumeManager").AddComponent<SgtVolumeManager>();

					CwHelper.SelectAndPing(vm);
				}
			}
		}

		protected override void OnInspector()
		{
			SgtVolumeManager tgt; SgtVolumeManager[] tgts; GetTargets(out tgt, out tgts);

			Draw("downscale", "This allows you to specify how the width/height of the volumetric effects are divided. For example, a value of 1 means no downscaling, and 5 means 1/5 width and height or 1/25 of the total pixels.");
			Draw("taa", "Smooth volumetric effects over time?");
			//Draw("smooth", "This allows you to apply a smoothing pass to the clouds.\n\nox5x5 = Aggressive smoothing that can look good up close, but not recommended for distant effects.\n\nBicubic = Retains most detail and provides some smoothing.");
			Draw("highPrecision", "Use a higher precision color buffer for smoother volumetrics?");


			BeginDisabled();
				UnityEditor.EditorGUILayout.ObjectField(tgt.WholeColor, typeof(RenderTexture), true);
				UnityEditor.EditorGUILayout.ObjectField(tgt.WholeDepth, typeof(RenderTexture), true);

				Separator();

				UnityEditor.EditorGUILayout.ObjectField(tgt.WaterDepth, typeof(RenderTexture), true);
				UnityEditor.EditorGUILayout.ObjectField(tgt.WaterAlpha, typeof(RenderTexture), true);

				Separator();

				UnityEditor.EditorGUILayout.ObjectField(tgt.SceneDepth, typeof(RenderTexture), true);
			EndDisabled();
		}
	}
}
#endif