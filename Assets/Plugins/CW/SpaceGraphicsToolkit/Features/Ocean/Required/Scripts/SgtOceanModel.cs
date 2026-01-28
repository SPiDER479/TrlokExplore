using UnityEngine;
using CW.Common;

namespace SpaceGraphicsToolkit.Ocean
{
	/// <summary>This component is used to render the <b>SgtSky</b> component.
	/// NOTE: This component is automatically created and managed.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("")]
	[RequireComponent(typeof(MeshFilter))]
	[RequireComponent(typeof(MeshRenderer))]
	public class SgtOceanModel : CwChild
	{
		[SerializeField]
		private SgtOcean parent;

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

		protected override void Start()
		{
			base.Start();

			DestroyGameObjectIfInvalid();
		}

		public static SgtOceanModel Create(SgtOcean parent)
		{
			var gameObject = CwHelper.CreateGameObject("SgtOceanModel", parent.gameObject.layer, parent.transform);
			var instance   = gameObject.AddComponent<SgtOceanModel>();

			instance.parent             = parent;
			instance.cachedMeshFilter   = instance.GetComponent<MeshFilter>();
			instance.cachedMeshRenderer = instance.GetComponent<MeshRenderer>();

			return instance;
		}

		protected override IHasChildren GetParent()
		{
			return parent;
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Ocean
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtOceanModel))]
	public class SgtOceanModel_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			SgtOceanModel tgt; SgtOceanModel[] tgts; GetTargets(out tgt, out tgts);

			BeginDisabled();
				Draw("parent");
			EndDisabled();
		}
	}
}
#endif