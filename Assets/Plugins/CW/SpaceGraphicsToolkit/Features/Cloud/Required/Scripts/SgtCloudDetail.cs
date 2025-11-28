using UnityEngine;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add detail to the <b>SgtCloud</b> component. This can be added to a child GameObject.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud Detail")]
	public class SgtCloudDetail : MonoBehaviour
	{
		/// <summary>The texture used to define where clouds are, or how the clouds should be eroded.
		/// NOTE: This should be a single channel texture where the coverage is stored in the <b>Red</b> channel.</summary>
		public Texture2D CoverageTex { set { coverageTex = value; } get { return coverageTex; } } [SerializeField] private Texture2D coverageTex;

		/// <summary>This allows you to specify how much of the edges of the clouds will be carved by the <b>CoverageTex</b>.</summary>
		public float CarveEdge { set { carveEdge = value; } get { return carveEdge; } } [SerializeField] [Range(0.0f, 1.0f)] private float carveEdge;

		/// <summary>This allows you to specify how much of the clouds overall will be carved by the <b>CoverageTex</b>.</summary>
		public float CarveCore { set { carveCore = value; } get { return carveCore; } } [SerializeField] [Range(0.0f, 1.0f)] private float carveCore = 0.5f;

		/// <summary>The scale of the detail, where a lower number means more tiling.</summary>
		public float Scale { set { scale = value; } get { return scale; } } [SerializeField] [Range(0.0f, 1.0f)] private float scale = 0.1f;

		/// <summary>The speed of the animation of this detail layer.</summary>
		public float Speed { set { speed = value; } get { return speed; } } [SerializeField] [Range(-1.0f, 1.0f)] private float speed;

		/// <summary>The rotational offset of this detail layer.</summary>
		public float Offset { set { offset = value; } get { return offset; } } [SerializeField] private float offset;

		/// <summary>The cloud layers that will be eroded by this detail layer.</summary>
		public Vector4 Channels { set { channels = value; } get { return channels; } } [SerializeField] private Vector4 channels = Vector4.one;

		public static SgtCloudDetail Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtCloudDetail Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CW.Common.CwHelper.CreateGameObject("Detail", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtCloudDetail>();
		}

		protected virtual void OnEnable()
		{
			var parent = GetComponentInParent<SgtCloud>();

			if (parent != null)
			{
				parent.MarkDetailDirty();
			}
		}

		protected virtual void OnDisable()
		{
			var parent = GetComponentInParent<SgtCloud>();

			if (parent != null)
			{
				parent.MarkDetailDirty();
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtCloudDetail))]
	public class SgtCloudDetail_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudDetail tgt; SgtCloudDetail[] tgts; GetTargets(out tgt, out tgts);

			Draw("coverageTex", "The texture used to define where clouds are, or how the clouds should be eroded.\n\nNOTE: This should be a single channel texture where the coverage is stored in the <b>Red</b> channel.");
			Draw("carveEdge", "This allows you to specify how much of the edges of the clouds will be carved by the <b>CoverageTex</b>.");
			Draw("carveCore", "This allows you to specify how much of the clouds overall will be carved by the <b>CoverageTex</b>.");
			Draw("scale", "The scale of the detail, where a lower number means more tiling.");
			Draw("speed", "The speed of the animation of this detail layer.");
			Draw("offset", "The rotational offset of this detail layer.");
			DrawVector4("channels", "The cloud layers that will be eroded by this detail layer.");

			Separator();

			if (Any(tgts, t => t.CoverageTex != null) && Button("Randomize Texture") == true)
			{
				Each(tgts, t => { if (t.CoverageTex != null) t.CoverageTex = Randomize(t.CoverageTex); }, true);
			}

			if (Button("Randomize Carve") == true)
			{
				Each(tgts, t => { t.CarveEdge = Randomize01(t.CarveEdge); t.CarveCore = Randomize01(t.CarveCore); }, true);
			}
		}

		public static Texture2D Randomize(Texture2D current)//, ref bool markForRebuild)
		{
			if (current != null)
			{
				var currentPath = UnityEditor.AssetDatabase.GetAssetPath(current);
				var guids       = UnityEditor.AssetDatabase.FindAssets("t:Texture2D", new string[] { System.IO.Path.GetDirectoryName(currentPath) });

				if (guids.Length > 0)
				{
					var guid = guids[UnityEngine.Random.Range(0, guids.Length)];
					var path = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
					var next = UnityEditor.AssetDatabase.LoadAssetAtPath<Texture2D>(path);

					if (current != next)
					{
						current        = next;
						//markForRebuild = true;
					}
				}
			}

			return current;
		}

		public static float Randomize01(float current)//, ref bool markForRebuild)
		{
			current        = UnityEngine.Random.Range(0.0f, 1.0f);
			//markForRebuild = true;

			return current;
		}
	}
}
#endif