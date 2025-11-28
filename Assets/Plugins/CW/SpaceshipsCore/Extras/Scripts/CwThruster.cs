using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using CW.Common;

namespace CW.Spaceships
{
	[RequireComponent(typeof(Renderer))]
    [HelpURL(CwCommon.HelpUrlPrefix + "CwThruster")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Thruster")]
    public class CwThruster : MonoBehaviour
    {
		/// <summary>The "Near Far Alpha Power" value can be increased or decreased by this amount.</summary>
        public float NearFarAlphaPowerDeviation { set { nearFarAlphaPowerDeviation = value; } get { return nearFarAlphaPowerDeviation; } } [SerializeField] protected float nearFarAlphaPowerDeviation;

		/// <summary>The "Inner Outer Alpha Power" value can be increased or decreased by this amount.</summary>
        public float InnerOuterAlphaPowerDeviation { set { innerOuterAlphaPowerDeviation = value; } get { return innerOuterAlphaPowerDeviation; } } [SerializeField] protected float innerOuterAlphaPowerDeviation;

		/// <summary>The speed of the animation.</summary>
        public float Speed { set { speed = value; } get { return speed; } } [SerializeField] protected float speed = 10.0f;

		[System.NonSerialized]
		private float offset;

		[System.NonSerialized]
		private float[] points;

		[System.NonSerialized]
		private Renderer cachedRenderer;

		private MaterialPropertyBlock properties;

		private static int _CW_NearFarAlphaPower = Shader.PropertyToID("_CW_NearFarAlphaPower");
		private static int _CW_InnerOuterAlphaPower = Shader.PropertyToID("_CW_InnerOuterAlphaPower");

		protected virtual void OnEnable()
		{
			cachedRenderer = GetComponent<Renderer>();

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			if (points == null)
			{
				points = new float[128];

				for (var i = points.Length - 1; i >= 0; i--)
				{
					points[i] = Random.Range(-1.0f, 1.0f);
				}
			}
		}

		protected virtual void Update()
		{
			offset += speed * Time.deltaTime;

			var sharedMaterial = cachedRenderer.sharedMaterial;

			if (sharedMaterial != null)
			{
				var nearFarAlphaPower    = sharedMaterial.GetFloat(_CW_NearFarAlphaPower);
				var innerOuterAlphaPower = sharedMaterial.GetFloat(_CW_InnerOuterAlphaPower);
				
				nearFarAlphaPower    += SampleNoisePM1(offset      ) *    nearFarAlphaPowerDeviation;
				innerOuterAlphaPower += SampleNoisePM1(offset + 128) * innerOuterAlphaPowerDeviation;

				cachedRenderer.GetPropertyBlock(properties);

				properties.SetFloat(_CW_NearFarAlphaPower, nearFarAlphaPower);
				properties.SetFloat(_CW_InnerOuterAlphaPower, innerOuterAlphaPower);

				cachedRenderer.SetPropertyBlock(properties);
			}
		}

		private float SampleNoisePM1(float position)
		{
			var noise  = Mathf.Repeat(position, points.Length);
			var index  = (int)noise;
			var frac   = noise % 1.0f;
			var pointA = points[index];
			var pointB = points[(index + 1) % points.Length];
			var pointC = points[(index + 2) % points.Length];
			var pointD = points[(index + 3) % points.Length];
			
			return Mathf.Lerp(pointA, pointB, frac);
			//return SgtHelper.CubicInterpolate(pointA, pointB, pointC, pointD, frac) * Flicker;
		}
    }
}

#if UNITY_EDITOR
namespace CW.Spaceships
{
	using UnityEditor;
	using TARGET = CwThruster;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwThruster_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			Draw("nearFarAlphaPowerDeviation", "The \"Near Far Alpha Power\" value can be increased or decreased by this amount.");
			Draw("innerOuterAlphaPowerDeviation", "The \"Inner Outer Alpha Power\" value can be increased or decreased by this amount.");
			Draw("speed", "The speed of the animation.");
		}
	}
}
#endif