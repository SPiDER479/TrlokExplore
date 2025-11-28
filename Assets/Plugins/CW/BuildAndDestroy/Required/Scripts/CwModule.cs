using UnityEngine;
using System.Collections.Generic;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component can be added to any GameObject in your design, and when your design is loaded this GameObject will appear as-is.</summary>
	[DisallowMultipleComponent]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwModule")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Module")]
	public class CwModule : MonoBehaviour
	{
		/// <summary>This allows you to specify which part this module will be associated with.</summary>
		public CwPart DesignPart { set { designPart = value; } get { return designPart; } } [SerializeField] private CwPart designPart;

		public Vector3 CompiledPosition { set { compiledPosition = value; } get { return compiledPosition; } } [SerializeField] private Vector3 compiledPosition;

		public Quaternion CompiledRotation { set { compiledRotation = value; } get { return compiledRotation; } } [SerializeField] private Quaternion compiledRotation = Quaternion.identity;

		public Vector3 CompiledScale { set { compiledScale = value; } get { return compiledScale; } } [SerializeField] private Vector3 compiledScale = Vector3.one;

		public CwLoadedPart LoadedPart { set { loadedPart = value; } get { return loadedPart; } } [SerializeField] private CwLoadedPart loadedPart;
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwModule;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwModule_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.DesignPart == null));
				Draw("designPart", "This allows you to specify which part this module will be associated with.");
			EndError();
		}
	}
}
#endif