using UnityEngine;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add a fluid simulation to a <b>SgtCloudBundle</b>.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Gas Giant Fluid")]
	public class SgtGasGiantFluid : SgtCloudBundleSlice
	{
		/// <summary>The resolution of the fluid sim.
		/// NOTE: The resolution of the simulation changes how it behaves, so you may need to tweak the <b>Constants</b> if you change the resolution.</summary>
		public Vector2Int Resolution { set { resolution = value; } get { return resolution; } } [SerializeField] private Vector2Int resolution = new Vector2Int(1024, 512);

		/// <summary>The baked initial state of the fluid simulation for instant startup.</summary>
		public Texture2D InitialTexture { set { initialTexture = value; } get { return initialTexture; } } [SerializeField] private Texture2D initialTexture;

		/// <summary>The fluid simulation constants.
		/// X = Pressure.
		/// Y = Viscosity.
		/// Z = Speed.
		/// W = Turbulence.</summary>
		public Vector4 Constants { set { constants = value; } get { return constants; } } [SerializeField] private Vector4 constants = new Vector4(0.2f, 0.55f, 0.15f, 0.0f);

		/// <summary>The fluid emission constants.
		/// X = Frequency.
		/// Y = Amplitude.
		/// Z = Brightness.
		/// W = Sharpness.</summary>
		public Vector4 Emission { set { emission = value; } get { return emission; } } [SerializeField] private Vector4 emission = new Vector4(30.0f, 1.0f, 0.3f, 0.005f);

		/// <summary>The amount of seconds between each fluid simulation update step.</summary>
		public float Interval { set { interval = value; } get { return interval; } } [SerializeField] [Range(0.0f, 10.0f)] private float interval = 0.1f;

		/// <summary>The sharpness of the output fluid gradient.</summary>
		public float Power { set { power = value; } get { return power; } } [SerializeField] private float power = 1.0f;

		[System.NonSerialized]
		private RenderTexture oldTexture;

		[System.NonSerialized]
		private RenderTexture newTexture;

		[System.NonSerialized]
		private RenderTexture midTexture;

		[System.NonSerialized]
		private float oldNewTransition;

		[System.NonSerialized]
		private Material blitMaterial;

		private static int _SGT_OldDataTex       = Shader.PropertyToID("_SGT_OldDataTex");
		private static int _SGT_NewDataTex       = Shader.PropertyToID("_SGT_NewDataTex");
		private static int _SGT_OldNewTransition = Shader.PropertyToID("_SGT_OldNewTransition");
		private static int _SGT_Power            = Shader.PropertyToID("_SGT_Power");
		private static int _SGT_DataTex          = Shader.PropertyToID("_SGT_DataTex");
		private static int _SGT_DataSize         = Shader.PropertyToID("_SGT_DataSize");
		private static int _SGT_Constants        = Shader.PropertyToID("_SGT_Constants");
		private static int _SGT_Emission         = Shader.PropertyToID("_SGT_Emission");

		public RenderTexture OldTexture
		{
			get
			{
				return oldTexture;
			}
		}

		public RenderTexture NewTexture
		{
			get
			{
				return newTexture;
			}
		}

		public RenderTexture MidTexture
		{
			get
			{
				return midTexture;
			}
		}

		public override SliceInstance TryCreate(int width, int offset)
		{
			if (resolution.x > 0 && resolution.y > 0)
			{
				var instance = new SliceInstance();
				var scale    = width / (float)resolution.x;
				var height   = (int)(resolution.y * scale);

				instance.Parent        = this;
				instance.CreatedHeight = height;

				if (blitMaterial == null)
				{
					blitMaterial = new Material(Shader.Find("Hidden/SgtGasGiantFluid"));

					blitMaterial.hideFlags = HideFlags.DontSave;
				}

				var descA = new RenderTextureDescriptor(resolution.x, resolution.y, RenderTextureFormat.ARGBFloat, 0, 0);
				var descB = new RenderTextureDescriptor(       width,       height, RenderTextureFormat.R8       , 0, 0);

				descA.sRGB = false;
				descB.sRGB = false;

				oldTexture = new RenderTexture(descA);
				newTexture = new RenderTexture(descA);
				midTexture = new RenderTexture(descB);

				oldTexture.wrapModeU = TextureWrapMode.Repeat;
				newTexture.wrapModeU = TextureWrapMode.Repeat;

				TryLoadInitialTexture();

				var oldActive = RenderTexture.active;

				WriteMid();

				RenderTexture.active = oldActive;

				return instance;
			}

			return null;
		}

		public override void Write(SliceInstance sliceInstance, RenderTexture target)
		{
			Graphics.CopyTexture(midTexture, 0, 0, 0, 0, midTexture.width, midTexture.height, target, 0, 0, 0, sliceInstance.CreatedOffset);
		}

		public override void Dispose(SliceInstance sliceInstance)
		{
			sliceInstances.Remove(sliceInstance);

			if (sliceInstances.Count == 0)
			{
				if (oldTexture != null)
				{
					oldTexture.Release();

					DestroyImmediate(oldTexture);

					oldTexture = null;
				}

				if (newTexture != null)
				{
					newTexture.Release();

					DestroyImmediate(newTexture);

					newTexture = null;
				}

				if (blitMaterial != null)
				{
					DestroyImmediate(blitMaterial);

					blitMaterial = null;
				}
			}
		}

		public override void HandleLateUpdate(SliceInstance sliceInstance, RenderTexture target)
		{
			var oldActive = RenderTexture.active;

			if (Application.isPlaying == true)
			{
				if (interval > 0.0f)
				{
					oldNewTransition += Time.deltaTime / interval;

					if (oldNewTransition > 1.0f)
					{
						oldNewTransition %= 1.0f;

						StepSimulation();
					}
				}
			}

			WriteMid();

			RenderTexture.active = oldActive;

			Write(sliceInstance, target);
		}

		private void WriteMid()
		{
			blitMaterial.SetTexture(_SGT_OldDataTex, oldTexture);
			blitMaterial.SetTexture(_SGT_NewDataTex, newTexture);
			blitMaterial.SetVector(_SGT_DataSize, new Vector2(newTexture.width, newTexture.height));
			blitMaterial.SetFloat(_SGT_OldNewTransition, oldNewTransition);
			blitMaterial.SetFloat(_SGT_Power, power);

			Graphics.Blit(default(Texture), midTexture, blitMaterial, 3);
		}

	#if UNITY_EDITOR
		[ContextMenu("Write Initial Texture")]
		public void WriteInitialTexture()
		{
			if (newTexture != null && initialTexture != null)
			{
				var oldActive = RenderTexture.active;
				var oldWrite  = GL.sRGBWrite;

				var temp2D = new Texture2D(newTexture.width, newTexture.height, TextureFormat.RGBAFloat, false, true);
				var tempDc = new RenderTextureDescriptor(newTexture.width, newTexture.height, RenderTextureFormat.ARGBFloat, 0); tempDc.sRGB = false;
				var tempRT = new RenderTexture(tempDc);

				blitMaterial.SetTexture(_SGT_DataTex, newTexture);
				blitMaterial.SetVector(_SGT_DataSize, new Vector2(newTexture.width, newTexture.height));

				GL.sRGBWrite = false;

				Graphics.Blit(default(Texture), tempRT, blitMaterial, 2);

				RenderTexture.active = tempRT;

				temp2D.ReadPixels(new Rect(0, 0, newTexture.width, newTexture.height), 0, 0);

				temp2D.Apply();

				var path = UnityEditor.AssetDatabase.GetAssetPath(initialTexture);

				System.IO.File.WriteAllBytes(path, temp2D.EncodeToPNG());

				RenderTexture.active = oldActive;

				GL.sRGBWrite = oldWrite;

				DestroyImmediate(tempRT);
				DestroyImmediate(temp2D);

				UnityEditor.AssetDatabase.ImportAsset(path);
			}
		}
	#endif

		[ContextMenu("Try Load Initial Texture")]
		private void TryLoadInitialTexture()
		{
			if (newTexture != null && initialTexture != null)
			{
				var oldActive = RenderTexture.active;
				var oldWrite  = GL.sRGBWrite;

				blitMaterial.SetTexture(_SGT_DataTex, initialTexture);
				blitMaterial.SetVector(_SGT_DataSize, new Vector2(initialTexture.width, initialTexture.height));

				GL.sRGBWrite = false;

				Graphics.Blit(default(Texture), oldTexture, blitMaterial, 1);
				Graphics.Blit(default(Texture), newTexture, blitMaterial, 1);

				RenderTexture.active = oldActive;

				GL.sRGBWrite = oldWrite;
			}
		}

		public void StepSimulation(int count)
		{
			for (var i = 0; i < count; i++)
			{
				StepSimulation();
			}
		}

		private void StepSimulation()
		{
			if (newTexture != null && blitMaterial != null)
			{
				// Swap
				var t = oldTexture; oldTexture = newTexture; newTexture = t;

				blitMaterial.SetTexture(_SGT_DataTex, oldTexture);
				blitMaterial.SetVector(_SGT_DataSize, new Vector2(resolution.x, resolution.y));
				blitMaterial.SetVector(_SGT_Constants, constants);
				blitMaterial.SetVector(_SGT_Emission, emission);

				Graphics.Blit(default(RenderTexture), newTexture, blitMaterial, 0);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtGasGiantFluid))]
	public class GasGiantForge_Editor : CW.Common.CwEditor
	{
		private bool turbo;

		protected override void OnInspector()
		{
			SgtGasGiantFluid tgt; SgtGasGiantFluid[] tgts; GetTargets(out tgt, out tgts);

			Draw("resolution", "The resolution of the fluid sim.\n\nNOTE: The resolution of the simulation changes how it behaves, so you may need to tweak the <b>Constants</b> if you change the resolution.");
			UnityEditor.EditorGUILayout.BeginHorizontal();
				Draw("initialTexture", "The baked initial state of the fluid simulation for instant startup.");
				if (GUILayout.Button("Bake", GUILayout.Width(40)) == true)
				{
					Each(tgts, Bake);
				}
			UnityEditor.EditorGUILayout.EndHorizontal();
			Draw("constants", "The fluid simulation constants.\n\nX = Pressure.\n\nY = Viscosity.\n\nZ = Speed.\n\nW = Turbulence.");
			Draw("emission", "The fluid emission constants.\n\nX = Frequency.\n\nY = Amplitude.\n\nZ = Brightness.\n\nW = Sharpness.");
			Draw("interval", "The amount of seconds between each fluid simulation update step.");
			Draw("power", "The sharpness of the output fluid gradient.");

			if (tgt.MidTexture != null)
			{
				Separator();

				var aspect = (float)tgt.MidTexture.height / tgt.MidTexture.width;
				var width  = UnityEditor.EditorGUIUtility.currentViewWidth - 40;
				var height = width * aspect;

				var rect = GUILayoutUtility.GetRect(width, height);

				GUI.DrawTexture(rect, tgt.MidTexture, ScaleMode.ScaleToFit);

				Repaint();
			}

			//BeginDisabled();
			//	UnityEditor.EditorGUILayout.ObjectField("NewTexture", tgt.NewTexture, typeof(RenderTexture), true);
			//	UnityEditor.EditorGUILayout.ObjectField("MidTexture", tgt.MidTexture, typeof(RenderTexture), true);
			//EndDisabled();

			if (Button("Step Simulation x1000") == true)
			{
				Each(tgts, t => t.StepSimulation(1000));
			}
		}

		private void Bake(SgtGasGiantFluid tgt)
		{
			if (tgt.InitialTexture == null)
			{
				var path = UnityEditor.EditorUtility.SaveFilePanelInProject("Save Fluid Sim State", "FluidSimInitialTexture (" + tgt.name + ")", "png", "Please enter a file name to save the PNG.");

				if (string.IsNullOrEmpty(path) == true)
				{
					return;
				}

				var tempTexture = new Texture2D(1, 1); tempTexture.SetPixel(0, 0, Color.magenta); tempTexture.Apply();

				System.IO.File.WriteAllBytes(path, tempTexture.EncodeToPNG());

				UnityEditor.AssetDatabase.ImportAsset(path);

				var importer = UnityEditor.AssetImporter.GetAtPath(path) as UnityEditor.TextureImporter;

				if (importer != null)
				{
					importer.sRGBTexture   = false;
					importer.mipmapEnabled = false;

					importer.SaveAndReimport();
				}

				DestroyImmediate(tempTexture);

				tgt.InitialTexture = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(path);
			}

			tgt.WriteInitialTexture();
		}
	}
}
#endif