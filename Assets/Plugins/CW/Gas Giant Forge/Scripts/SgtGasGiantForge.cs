#if UNITY_2021_3 && !(UNITY_2021_3_0 || UNITY_2021_3_1 || UNITY_2021_3_2 || UNITY_2021_3_3 || UNITY_2021_3_4 || UNITY_2021_3_5 || UNITY_2021_3_6 || UNITY_2021_3_7 || UNITY_2021_3_8 || UNITY_2021_3_9 || UNITY_2021_3_10 || UNITY_2021_3_11 || UNITY_2021_3_12 || UNITY_2021_3_13 || UNITY_2021_3_14 || UNITY_2021_3_15 || UNITY_2021_3_16 || UNITY_2021_3_17)
	#define CW_HAS_NEW_FIND
#elif UNITY_2022_2 && !(UNITY_2022_2_0 || UNITY_2022_2_1 || UNITY_2022_2_2 || UNITY_2022_2_3 || UNITY_2022_2_4)
	#define CW_HAS_NEW_FIND
#elif UNITY_2023_1_OR_NEWER
	#define CW_HAS_NEW_FIND
#endif

using UnityEngine;
using CW.Common;
using SpaceGraphicsToolkit.Volumetrics;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Sky;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.RingSystem;

namespace SpaceGraphicsToolkit
{
	/// <summary>This class provides the Gas Giant Forge menu options, and shows you how to create a gas giant entirely from code.</summary>
	[AddComponentMenu("")]
	public class SgtGasGiantForge : MonoBehaviour
	{
#if UNITY_EDITOR
        [UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Slices) (radius = 500)", false, 10)]
		public static void CreateSlices500()
		{
			GetInstance().CreateGasGiant_Slices(500.0f);
		}

        [UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Slices) (radius = 5,000)", false, 10)]
		public static void CreateSlices5000()
		{
			GetInstance().CreateGasGiant_Slices(5000.0f);
		}

        [UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Slices) (radius = 5,000,000)", false, 10)]
		public static void CreateSlices5000000()
		{
			GetInstance().CreateGasGiant_Slices(5000000.0f);
		}

        [UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Full Fluid Sim) (radius = 500)", false, 10)]
		public static void CreateFullFluidSim500()
		{
			GetInstance().CreateGasGiant_FullFluidSim(500.0f);
		}

		[UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Full Fluid Sim) (radius = 5,000)", false, 10)]
		public static void CreateFullFluidSim5000()
		{
			GetInstance().CreateGasGiant_FullFluidSim(5000.0f);
		}

		[UnityEditor.MenuItem("GameObject/CW/Gas Giant Forge/Gas Giant (Full Fluid Sim) (radius = 5,000,000)", false, 10)]
		public static void CreateFullFluidSim5000000()
		{
			GetInstance().CreateGasGiant_FullFluidSim(5000000.0f);
		}

		private static SgtGasGiantForge GetInstance()
		{
			var guids = UnityEditor.AssetDatabase.FindAssets("t:GameObject GasGiantForge");

			foreach (var guid in guids)
			{
				var path       = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
				var gameObject = UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(path);
				var instance   = gameObject.GetComponent<SgtGasGiantForge>();
				
				if (instance != null)
				{
					return instance;
				}
			}

			return null;
		}

		private void CreateGasGiant_Slices(float radius)
		{
			var cloud = CreateGasGiant("Gas Giant (Slices)", radius);

			cloud.Coverage       = true;
			cloud.CoverageBundle = ExampleBundle;
			cloud.CoverageLayers.Add(new SgtCloud.AlbedoLayerType() { Visual = 10, Height = 0.40f, Thickness = 0.032f, Offset = 0.0f, Speed = 0.0f, Tiling = 1, Opacity = 1.0f, Layers = Vector4.one });
			cloud.CoverageLayers.Add(new SgtCloud.AlbedoLayerType() { Visual = 10, Height = 0.45f, Thickness = 0.032f, Offset = 0.0f, Speed = 0.0f, Tiling = 1, Opacity = 1.0f, Layers = Vector4.one });
			cloud.CoverageLayers.Add(new SgtCloud.AlbedoLayerType() { Visual = 10, Height = 0.50f, Thickness = 0.032f, Offset = 0.0f, Speed = 0.0f, Tiling = 1, Opacity = 1.0f, Layers = Vector4.one });
			cloud.CoverageLayers.Add(new SgtCloud.AlbedoLayerType() { Visual = 10, Height = 0.55f, Thickness = 0.032f, Offset = 0.0f, Speed = 0.0f, Tiling = 1, Opacity = 1.0f, Layers = Vector4.one });
			cloud.CoverageLayers.Add(new SgtCloud.AlbedoLayerType() { Visual = 10, Height = 0.60f, Thickness = 0.032f, Offset = 0.0f, Speed = 0.0f, Tiling = 1, Opacity = 1.0f, Layers = Vector4.one });
		}

		private void CreateGasGiant_FullFluidSim(float radius)
		{
			var cloud  = CreateGasGiant("Gas Giant (Full Fluid Sim)", radius);
			var bundle = cloud.gameObject.AddComponent<SgtCloudBundle>();
			var fluid  = cloud.gameObject.AddComponent<SgtGasGiantFluid>();

			bundle.Slices.Add(fluid);

			cloud.Coverage       = true;
			cloud.CoverageBundle = bundle;
		}

		private SgtCloud CreateGasGiant(string title, float radius)
		{
			CheckForVolumeManager();
			CheckForVolumeCamera();
			CheckForLights();

			var parent = CwHelper.GetSelectedParent();
			var layer  = parent != null ? parent.gameObject.layer : 0;
			var root   = CwHelper.CreateGameObject(title, layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
			var sky    = SgtSky.Create(layer, root.transform);
			var cloud  = SgtCloud.Create(layer, root.transform);
			var ringS  = SgtRingSystem.Create(layer, root.transform);
			var ringP  = ringS.gameObject.AddComponent<SgtRingParticles>();

			if (SgtLight.InstanceCount > 0)
			{
				// Planet shadow
				var shadowS = sky.gameObject.AddComponent<SgtShadowSphere>();

				shadowS.RadiusMax = radius;

				// Ring shadow settings auto updated
				ringS.gameObject.AddComponent<SgtShadowRing>();
			}

			sky.InnerMeshRadius = radius * 0.95f;
			sky.Height          = radius - sky.InnerMeshRadius;
			sky.Clouds          = cloud;
			sky.UpperColor      = Color.white;
			sky.LowerColor      = Color.white;
			sky.Density         = 100.0f;
			sky.Lighting        = SgtLight.InstanceCount > 0;

			cloud.Density           = 5000.0f;
			cloud.Albedo            = true;
			cloud.AlbedoGradientTex = ExampleAlbedoGradient;
			cloud.AlbedoVariationX  = 0.986801f;
			cloud.AlbedoVariationY  = 0.06925857f;
			cloud.AlbedoStrataY     = 0.075f;
			cloud.CloudLayers.Add(new SgtCloud.CloudLayerType() { Height = 0.5f, Thickness = 0.5f, Density = 1.0f, Shadow = 2.0f, Shape = 1.0f });

			ringS.RadiusInner        = radius * 1.5f;
			ringS.RadiusOuter        = radius * 2.5f;
			ringS.Thickness          = radius * 0.01f;
			ringS.Bands              = true;
			ringS.BandsTex           = ExampleRingBands;
			ringS.Lighting           = SgtLight.InstanceCount > 0;
			ringS.BandsOpacityShadow = true;

			ringP.Material = ExampleRingParticlesMaterial;
			ringP.MainTex  = ExampleRingParticlesSdf;

			CwHelper.SelectAndPing(root);

			return cloud;
		}
#endif

		public SgtCloudBundle ExampleBundle;

		public Texture2D ExampleAlbedoGradient;

		public Texture2D ExampleRingBands;

		public Material ExampleRingParticlesMaterial;

		public Texture3D ExampleRingParticlesSdf;

		public static void CheckForVolumeManager()
		{
			if (SgtVolumeManager.Instances.Count == 0)
			{
				var vm = new GameObject("SgtVolumeManager").AddComponent<SgtVolumeManager>();

				Debug.Log("Your scene didn't contain the SgtVolumeManager component, so one was added.", vm);
			}
		}

		public static void CheckForVolumeCamera()
		{
			foreach (var camera in Camera.allCameras)
			{
				if (camera.GetComponent<SgtVolumeCamera>() != null)
				{
					return;
				}
			}

			if (Camera.main != null)
			{
				var vc = CwHelper.GetOrAddComponent<SgtVolumeCamera>(Camera.main.gameObject);

				Debug.Log("Your scene didn't contain the SgtVolumeManager component, so one was added.", vc);
			}
			else
			{
				Debug.Log("None of the cameras in your scene have the SgtVolumeCamera component, please add it to at least one so the planet atmosphere can be rendered.");
			}
		}

		public static void CheckForLights()
		{
			if (SgtLight.InstanceCount == 0)
			{
				if (TryAddLight(RenderSettings.sun) == true)
				{
					return;
				}

				var lights        = FindObjectsByType<Light>();
				var bestLight     = default(Light);
				var bestIntensity = default(float);

				foreach (var light in lights)
				{
					if (light.intensity > bestIntensity)
					{
						bestLight     = light;
						bestIntensity = light.intensity;
					}
				}

				if (TryAddLight(bestLight) == true)
				{
					return;
				}

				Debug.Log("None of the lights in your scene have the SgtLight component, please add it to at least one so the planet atmosphere can be lit.");
			}
		}

		private static bool TryAddLight(Light light)
		{
			if (light != null)
			{
				var sl = light.gameObject.AddComponent<SgtLight>();

				Debug.Log("Your scene lights contain the SgtLight component, so one was added.", sl);
			}

			return false;
		}

		public static T[] FindObjectsByType<T>()
			where T : Object
		{
#if CW_HAS_NEW_FIND
			return Object.FindObjectsByType<T>(FindObjectsSortMode.None);
#else
			return Object.FindObjectsOfType<T>();
#endif
		}
    }
}