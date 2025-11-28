using UnityEngine;
using CW.Common;

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component is used to render the <b>SgtSky</b> component.
	/// NOTE: This component is automatically created and managed.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("")]
	[RequireComponent(typeof(MeshFilter))]
	[RequireComponent(typeof(MeshRenderer))]
	public class SgtSkyModel : MonoBehaviour
	{
		[SerializeField]
		private SgtSky parent;

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

		public static SgtSkyModel Create(SgtSky parent)
		{
			var gameObject = CwHelper.CreateGameObject("SgtSkyModel", parent.gameObject.layer, parent.transform);
			var instance   = gameObject.AddComponent<SgtSkyModel>();

			instance.parent             = parent;
			instance.cachedMeshFilter   = instance.GetComponent<MeshFilter>();
			instance.cachedMeshRenderer = instance.GetComponent<MeshRenderer>();

			return instance;
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Sky
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtSkyModel))]
	public class SgtAtmosphereModel_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtSkyModel tgt; SgtSkyModel[] tgts; GetTargets(out tgt, out tgts);

			BeginDisabled();
				Draw("parent");
			EndDisabled();
		}
	}
}
#endif