using UnityEngine;
using CW.Common;

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component allows you to generate the SgtAtmosphere.InnerDepthTex and SgtAtmosphere.OuterDepthTex fields.</summary>
	[RequireComponent(typeof(SgtSky))]
	[AddComponentMenu("")]
	public class SgtSkyDepthTex : MonoBehaviour
	{
		/// <summary>This allows you to set the color that appears on the horizon.</summary>
		public Color HorizonColor { set { if (horizonColor != value) { horizonColor = value; } } get { return horizonColor; } } [SerializeField] private Color horizonColor = Color.white;

		/// <summary>The base color of the outer texture.</summary>
		public Color OuterColor { set { if (outerColor != value) { outerColor = value; } } get { return outerColor; } } [SerializeField] private Color outerColor = new Color(0.29f, 0.73f, 1.0f);

		/// <summary>The strength of the outer texture transition.</summary>
		public float OuterColorSharpness { set { if (outerColorSharpness != value) { outerColorSharpness = value; } } get { return outerColorSharpness; } } [SerializeField] private float outerColorSharpness = 2.0f;

		[System.NonSerialized]
		private SgtSky cachedSky;

		public void RandomizeHue()
		{
			horizonColor = RandomizeHue(horizonColor);
			outerColor   = RandomizeHue(outerColor);
		}

		private static Color RandomizeHue(Color c)
		{
			var h = default(float);
			var s = default(float);
			var v = default(float);

			Color.RGBToHSV(c, out h, out s, out v);

			h = Random.value;

			return Color.HSVToRGB(h, s, v);
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Sky
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtSkyDepthTex))]
	public class SgtSkyDepthTex_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtSkyDepthTex tgt; SgtSkyDepthTex[] tgts; GetTargets(out tgt, out tgts);

			var dirtyTextures = false;

			Draw("horizonColor", ref dirtyTextures, "This allows you to set the color that appears on the horizon.");

			Separator();

			Draw("outerColor", ref dirtyTextures, "The base color of the outer texture.");
			Draw("outerColorSharpness", ref dirtyTextures, "The strength of the outer texture transition.");
		}
	}
}
#endif