using UnityEngine;

namespace CW.SimpleOriginSystem
{
	/// <summary>This component can be added to your main Camera GameObject in your scene. When its <b>Transform.position</b> exceeds the <b>MaximumDistance</b>, its position will be snapped to 0, and all GameObjects in the scene with the <b>SnappingObject</b> component will be snapped by this distance.</summary>
	[DefaultExecutionOrder(-50)]
	[DisallowMultipleComponent]
	public class SnappingCamera : MonoBehaviour
	{
		/// <summary>The camera position will snap when it exceeds this distance from the origin.</summary>
		public float MaximumDistance { set { maximumDistance = value; } get { return maximumDistance; } }

		/// <summary>Should this camera's Transform.position also snap? You can disable this if the camera position is driven by another component.</summary>
		public bool SnapSelf { set { snapSelf = value; } get { return snapSelf; } }
	
		[Tooltip("The camera position will snap when it exceeds this distance from the origin.")]
		[SerializeField]
		private float maximumDistance = 1000.0f;
	
		[Tooltip("Should this camera's Transform.position also snap? You can disable this if the camera position is driven by another component.")]
		[SerializeField]
		private bool snapSelf = true;

		protected virtual void LateUpdate()
		{
			var delta = -transform.position;

			delta.x = Mathf.Round(delta.x);
			delta.y = Mathf.Round(delta.y);
			delta.z = Mathf.Round(delta.z);

			if (delta.magnitude > maximumDistance)
			{
				foreach (var o in SnappingObject.AllObjects)
				{
					o.HandleSnap(delta);
				}

				foreach (var e in SnappingEvent.AllEvents)
				{
					e.HandleSnap(delta);
				}

				if (snapSelf == true && GetComponentInParent<SnappingObject>() == null)
				{
					transform.position += delta;
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace CW.SimpleOriginSystem.Inspector
{
	using UnityEditor;
	using UnityEditor.UIElements;
	using UnityEngine.UIElements;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SnappingCamera))]
	public class SnappingCamera_Editor : SnappingObject_Editor
	{
		public override VisualElement CreateInspectorGUI()
		{
			var baseRoot = base.CreateInspectorGUI();
			var root     = new VisualElement();

			baseRoot.Insert(0, root);

			root.Add(new PropertyField(serializedObject.FindProperty("maximumDistance")));
			root.Add(new PropertyField(serializedObject.FindProperty("snapSelf")));

			return baseRoot;
		}
	}
}
#endif