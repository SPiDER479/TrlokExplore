using UnityEngine;
using CW.Common;
using CW.BuildAndDestroy;

namespace CW.Spaceships
{
    /// <summary>This class contains some useful methods used by this asset.</summary>
	[HelpURL(CwCommon.HelpUrlPrefix + "CwSpaceship")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Spaceship")]
	public class CwSpaceship : CwLoader
	{
		/// <summary>The heat glow from explosion marks will fade out at this speed.
		/// 1 = Fades out in one second.
		/// 2 = Fades out in half a second.</summary>
		public float CooldownSpeed { set { cooldownSpeed = value; } get { return cooldownSpeed; } } [SerializeField] private float cooldownSpeed = 0.2f;

		/// <summary>The cooldown value must accumulate by this much (1..255) before it gets applied. The higher you set this the higher the performance, but the choppier the fade out will be.</summary>
		public byte CooldownThreshold { set { cooldownThreshold = value; } get { return cooldownThreshold; } } [SerializeField] private byte cooldownThreshold = 4;

		private float cooldownCounter;

		private static Material fadeMaterial;

		private static int _CW_Strength = Shader.PropertyToID("_CW_Strength");

		public static CwSpaceship Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static CwSpaceship Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			var gameObject = CwHelper.CreateGameObject("Spaceship", layer, parent, localPosition, localRotation, localScale);
			var instance   = gameObject.AddComponent<CwSpaceship>();

			return instance;
		}

		protected virtual void Update()
		{
			cooldownCounter = Mathf.Clamp01(cooldownCounter + cooldownSpeed * Time.deltaTime);

			var cooldownSteps = Mathf.FloorToInt(cooldownCounter * 255.0f);

			if (cooldownSteps >= cooldownThreshold)
			{
				var cooldownDelta = cooldownSteps / 255.0f;

				cooldownCounter -= cooldownDelta;

				ApplyFade(cooldownDelta);
			}
		}

		private void ApplyFade(float strength)
		{
			if (MarkTexture != null)
			{
				if (fadeMaterial == null)
				{
					fadeMaterial = CwHelper.CreateTempMaterial("Spaceship Fade", "Hidden/CwSpaceshipFade");
				}

				fadeMaterial.SetFloat(_CW_Strength, strength);

				CwHelper.BeginActive(MarkTexture);
					if (fadeMaterial.SetPass(0) == true)
					{
						Graphics.DrawMeshNow(GetQuadMesh(), Matrix4x4.identity, 0);
					}
				CwHelper.EndActive();

				MarkTexture.GenerateMips();
			}
		}

	}
}

#if UNITY_EDITOR
namespace CW.Spaceships
{
	using UnityEditor;
	using TARGET = CwSpaceship;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwSpaceship_Editor : CwLoader_Editor
	{
		[MenuItem(CwCommon.GameObjectMenuPrefix + "Spaceship", false, 10)]
		public static void CreateMenuItem()
		{
			var parent   = CwHelper.GetSelectedParent();
			var instance = CwSpaceship.Create(parent != null ? parent.gameObject.layer : 0, parent);

			CwHelper.SelectAndPing(instance);
		}

		protected override void DrawAllowMarks()
		{
			base.DrawAllowMarks();

			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			if (Any(tgts, t => t.AllowMarks == true))
			{
				BeginIndent();
					Draw("cooldownSpeed", "The heat glow from explosion marks will fade out at this speed.\n\n1 = Fades out in one second.\n\n2 = Fades out in half a second.");
					Draw("cooldownThreshold", "The cooldown value must accumulate by this much (1..255) before it gets applied. The higher you set this the higher the performance, but the choppier the fade out will be.");
				EndIndent();
			}
		}
	}
}
#endif