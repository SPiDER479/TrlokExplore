using UnityEngine;
using UnityEngine.Rendering;
using SpaceGraphicsToolkit.LightAndShadow;
using CW.Common;
#if __HDRP__
using UnityEngine.Rendering.HighDefinition;
#endif

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component can be added to your scene, and it will override the sun light color and ambient color when the camera is within the atmosphere of a planet to match the atmospheric scattering.</summary>
	[DefaultExecutionOrder(100)] // Update after SgtSky
	public class SgtSkyLighter : MonoBehaviour
	{
		/// <summary>The camera whose position will be tracked.
		/// None/null = Main Camera.</summary>
		public Camera Observer { set { observer = value; } get { return observer; } } [SerializeField] private Camera observer;

		/// <summary>The sun light.
		/// None/null = First <b>SgtLight</b> in the scene.</summary>
		public SgtLight Sun { set { sun = value; } get { return sun; } } [SerializeField] private SgtLight sun;

		/// <summary>The ambient light will be multiplied by this.</summary>
		public float AmbientMultiplier { set { ambientMultiplier = value; } get { return ambientMultiplier; } } [SerializeField] private float ambientMultiplier = 1.0f;

		[System.NonSerialized]
		private bool ambientSet;

		[System.NonSerialized]
		private Color ambientColor;

		[System.NonSerialized]
		private SgtLight lightInstance;

		[System.NonSerialized]
		private Color lightColor;

		private bool TryFindSky(ref SgtLight foundLight, ref SgtSky foundSky, ref Color foundTransmittance, ref Color foundAmbient)
		{
			var finalCamera = observer;
			var finalLight  = sun;

			if (finalCamera == null) finalCamera = Camera.main;

			if (finalLight == null)
			{
				var lights = SgtLight.Find(-1, transform.position);

				if (lights.Count > 0)
				{
					finalLight = lights[0];
				}
			}

			if (finalCamera != null && finalLight != null)
			{
				var eyePos = finalCamera.transform.position;
				var sunDir = -finalLight.transform.forward;

				foreach (var sky in SgtSky.Instances)
				{
					var skyPos = sky.transform.InverseTransformPoint(eyePos);

					if (skyPos.magnitude < sky.OuterRadius)
					{
						foundLight         = finalLight;
						foundSky           = sky;
						foundTransmittance = sky.GetSkyTransmittance(eyePos, sunDir);
						foundAmbient       = sky.GetSkyAmbient(eyePos, sunDir);

						if (foundTransmittance != Color.white)
						{
							return true;
						}
					}
				}
			}

			return false;
		}

		protected virtual void LateUpdate()
		{
			var light         = default(SgtLight);
			var sky           = default(SgtSky);
			var transmittance = default(Color);
			var ambient       = default(Color);

			if (TryFindSky(ref light, ref sky, ref transmittance, ref ambient) == true)
			{
				if (lightInstance != light)
				{
					Clear();

					lightInstance = light;
					lightColor    = light.CachedLight.color;
				}

				if (ambientSet == false)
				{
					ambientColor = GetAmbientColor();
					ambientSet   = true;
				}

				light.CachedLight.color = lightColor * transmittance;

				ApplyAmbientColor(ambientColor + ambient * ambientMultiplier);
			}
			else
			{
				Clear();
			}
		}

		protected virtual void OnDisable()
		{
			Clear();
		}

		public void Clear()
		{
			if (lightInstance != null)
			{
				lightInstance.CachedLight.color = lightColor;

				lightInstance = null;
			}

			if (ambientSet == true)
			{
				ApplyAmbientColor(ambientColor);

				ambientSet = false;
			}
		}

		private Color GetAmbientColor()
		{
			return RenderSettings.ambientLight;
		}

	#if __HDRP__
		private Volume volume;
		private VisualEnvironment visualEnvironment;
		private HDRISky hdriSky;

		private bool TryGetVolume()
		{
			if (volume != null)
			{
				return true;
			}

			foreach (var v in CwHelper.FindObjectsByType<Volume>())
			{
				if (v != null && v.isGlobal == true)
				{
					volume = v;

					return true;
				}
			}

			return false;
		}

		private void ApplyAmbientColor(Color color)
		{
			if (TryGetVolume() == true)
			{
				if (volume.profile.TryGet(out visualEnvironment) == false)
				{
					visualEnvironment = volume.profile.Add<VisualEnvironment>(true);
				}

				visualEnvironment.skyType.Override((int)SkyType.HDRI);

				if (!volume.profile.TryGet(out hdriSky))
				{
					hdriSky = volume.profile.Add<HDRISky>(true);
				}

				hdriSky.skyIntensityMode.Override(SkyIntensityMode.Lux);
				hdriSky.desiredLuxValue.Override(color.grayscale * Mathf.PI * 15000.0f);
			}
		}
	#else
		private void ApplyAmbientColor(Color color)
		{
			RenderSettings.ambientLight = new Color(color.grayscale, color.grayscale, color.grayscale, 1.0f);
		}
	#endif
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Sky
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtSkyLighter))]
	public class SgtSkyLighter_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtSkyLighter tgt; SgtSkyLighter[] tgts; GetTargets(out tgt, out tgts);
			
			Draw("observer", "The camera whose position will be tracked.\n\nNone/null = Main Camera.");
			Draw("sun", "The sun light.\n\nNone/null = First <b>SgtLight</b> in the scene.");
			Draw("ambientMultiplier", "The ambient light will be multiplied by this.");
		}
	}
}
#endif