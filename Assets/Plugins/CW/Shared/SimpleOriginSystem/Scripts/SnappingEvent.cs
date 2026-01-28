using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

namespace CW.SimpleOriginSystem
{
	/// <summary>This component invokes the <b>OnSnap</b> event when the scene position snaps.</summary>
	public class SnappingEvent : MonoBehaviour
	{
		/// <summary>This event will be invoked when this GameObject snaps.
		/// Vector3 = The world space distance this Transform moved.</summary>
		public SnapEvent OnSnap { get { if (onSnap == null) onSnap = new SnapEvent(); return onSnap; } }

		/// <summary>All active and enabled <b>SnappingEvent</b> instances will be stored here.</summary>
		public static LinkedList<SnappingEvent> AllEvents = new LinkedList<SnappingEvent>();

		[System.Serializable]
		public class SnapEvent : UnityEvent<Vector3> {}

		[SerializeField]
		private SnapEvent onSnap;

		[System.NonSerialized]
		private LinkedListNode<SnappingEvent> node;

		public void HandleSnap(Vector3 delta)
		{
			if (onSnap != null)
			{
				onSnap.Invoke(delta);
			}
		}

		protected virtual void OnEnable()
		{
			node = AllEvents.AddLast(this);
		}

		protected virtual void OnDisable()
		{
			AllEvents.Remove(node);

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
	[CustomEditor(typeof(SnappingEvent))]
	public class SnappingEvent_Editor : Editor
	{
		public override VisualElement CreateInspectorGUI()
		{
			var root = new VisualElement(); root.style.marginTop = 10; root.style.marginBottom = 10;

			root.Add(new PropertyField(serializedObject.FindProperty("onSnap")));

			return root;
		}
	}
}
#endif