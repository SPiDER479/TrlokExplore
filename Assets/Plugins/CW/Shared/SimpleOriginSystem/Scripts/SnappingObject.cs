using System.Collections.Generic;
using UnityEngine;

namespace CW.SimpleOriginSystem
{
	/// <summary>This component can be added to GameObjects in your scene that should move around the camera when the scene position snaps.
	/// NOTE: For this to work, your main camera must have the <b>SnappingCamera</b> component.</summary>
	[DisallowMultipleComponent]
	public class SnappingObject : MonoBehaviour
	{
		/// <summary>All active and enabled <b>SnappingObject</b> instances will be stored here.</summary>
		public static LinkedList<SnappingObject> AllObjects = new LinkedList<SnappingObject>();

		[System.NonSerialized]
		private LinkedListNode<SnappingObject> node;

		public void HandleSnap(Vector3 delta)
		{
			if (transform.parent == null || transform.parent.GetComponentInParent<SnappingObject>() == null)
			{
				transform.position += delta;
			}
		}

		protected virtual void OnEnable()
		{
			node = AllObjects.AddLast(this);
		}

		protected virtual void OnDisable()
		{
			AllObjects.Remove(node);

			node = null;
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
	[CustomEditor(typeof(SnappingObject))]
	public class SnappingObject_Editor : Editor
	{
		public override VisualElement CreateInspectorGUI()
		{
			var root = new VisualElement(); root.style.marginTop = 10; root.style.marginBottom = 10;

			return root;
		}
	}
}
#endif