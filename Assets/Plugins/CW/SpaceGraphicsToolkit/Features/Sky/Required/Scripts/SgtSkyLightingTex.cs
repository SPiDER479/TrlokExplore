using UnityEngine;
using CW.Common;

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component allows you to generate the SgtAtmosphere.LightingTex field.</summary>
	[RequireComponent(typeof(SgtSky))]
	[AddComponentMenu("")]
	public class SgtSkyLightingTex : MonoBehaviour
	{
		/// <summary>The start point of the day/sunset transition (0 = dark side, 1 = light side).</summary>
		public float SunsetStart { set { if (sunsetStart != value) { sunsetStart = value; } } get { return sunsetStart; } } [Range(0.0f, 1.0f)] [SerializeField] private float sunsetStart = 0.45f;

		/// <summary>The end point of the sunset/night transition (0 = dark side, 1 = light side).</summary>
		public float SunsetEnd { set { if (sunsetEnd != value) { sunsetEnd = value; } } get { return sunsetEnd; } } [Range(0.0f, 1.0f)] [SerializeField] private float sunsetEnd = 1.0f;

		/// <summary>The sharpness of the sunset red channel transition.</summary>
		public float SunsetSharpnessR { set { if (sunsetSharpnessR != value) { sunsetSharpnessR = value; } } get { return sunsetSharpnessR; } } [SerializeField] private float sunsetSharpnessR = 3.0f;

		/// <summary>The sharpness of the sunset green channel transition.</summary>
		public float SunsetSharpnessG { set { if (sunsetSharpnessG != value) { sunsetSharpnessG = value; } } get { return sunsetSharpnessG; } } [SerializeField] private float sunsetSharpnessG = 2.0f;

		/// <summary>The sharpness of the sunset blue channel transition.</summary>
		public float SunsetSharpnessB { set { if (sunsetSharpnessB != value) { sunsetSharpnessB = value; } } get { return sunsetSharpnessB; } } [SerializeField] private float sunsetSharpnessB = 2.0f;
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Sky
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtSkyLightingTex))]
	public class SgtSkyLightingTex_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtSkyLightingTex tgt; SgtSkyLightingTex[] tgts; GetTargets(out tgt, out tgts);

			var dirtyTexture = false;

			BeginError(Any(tgts, t => t.SunsetStart >= t.SunsetEnd));
				Draw("sunsetStart", ref dirtyTexture, "The start point of the day/sunset transition (0 = dark side, 1 = light side).");
				Draw("sunsetEnd", ref dirtyTexture, "The end point of the sunset/night transition (0 = dark side, 1 = light side).");
			EndError();
			Draw("sunsetSharpnessR", ref dirtyTexture, "The sharpness of the sunset red channel transition.");
			Draw("sunsetSharpnessG", ref dirtyTexture, "The sharpness of the sunset green channel transition.");
			Draw("sunsetSharpnessB", ref dirtyTexture, "The sharpness of the sunset blue channel transition.");

			if (Button("Apply And Remove"))
			{
				Each(tgts, t => ApplyAndRemove(t), true);
			}
		}

		private void ApplyAndRemove(SgtSkyLightingTex tgt)
		{
			var sky = tgt.GetComponent<SgtSky>();

			sky.Lighting           = true;
			sky.LightingStart      = tgt.SunsetStart;
			sky.LightingEnd        = tgt.SunsetEnd;
			sky.LightingSharpnessR = tgt.SunsetSharpnessR;
			sky.LightingSharpnessG = tgt.SunsetSharpnessG;
			sky.LightingSharpnessB = tgt.SunsetSharpnessB;

			UnityEditor.EditorUtility.SetDirty(sky);

			DestroyImmediate(tgt);
		}
	}
}
#endif