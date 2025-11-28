using UnityEngine;
using CW.Common;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component is used to render the <b>SgtCloud</b> component.
	/// NOTE: This component is automatically created and managed.</summary>
	[ExecuteInEditMode]
	[HelpURL("https://carloswilkes.com/Documentation/SpaceGraphicsToolkit#SgtCloudModel")]
	[AddComponentMenu("")]
	[RequireComponent(typeof(MeshFilter))]
	[RequireComponent(typeof(MeshRenderer))]
	public class SgtCloudModel : MonoBehaviour
	{
		[SerializeField]
		private SgtCloud parent;

		[SerializeField]
		private MeshFilter cachedMeshFilter;

		[SerializeField]
		private MeshRenderer cachedMeshRenderer;

		public MeshFilter CachedMeshFilter
		{
			get
			{
				return cachedMeshFilter;
			}
		}

		public MeshRenderer CachedMeshRenderer
		{
			get
			{
				return cachedMeshRenderer;
			}
		}

		public static SgtCloudModel Create(SgtCloud parent)
		{
			var gameObject = CwHelper.CreateGameObject("SgtCloudModel", parent.gameObject.layer, parent.transform);
			var instance   = gameObject.AddComponent<SgtCloudModel>();

			instance.parent             = parent;
			instance.cachedMeshFilter   = instance.GetComponent<MeshFilter>();
			instance.cachedMeshRenderer = instance.GetComponent<MeshRenderer>();

			return instance;
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloudModel))]
	public class SgtCloudModel_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudModel tgt; SgtCloudModel[] tgts; GetTargets(out tgt, out tgts);

			BeginDisabled();
				Draw("parent");
			EndDisabled();
		}
	}
}
#endif