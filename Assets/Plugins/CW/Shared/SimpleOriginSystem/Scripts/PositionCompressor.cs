using System.Collections.Generic;
using UnityEngine;

namespace CW.SimpleOriginSystem
{
	/// <summary>This component enables compression of vertices to keep them within range of the camera clipping range.</summary>
	[ExecuteInEditMode]
	[DisallowMultipleComponent]
	public class PositionCompressor : MonoBehaviour
	{
		/// <summary>The world space distance where the compression begins.</summary>
		public float LinearDistance { set { linearDistance = value; } get { return linearDistance; } } [SerializeField] private float linearDistance = 50000.0f;

		/// <summary>The world space distance of vertices will always be below this.</summary>
		public float MaximumDistance { set { maximumDistance = value; } get { return maximumDistance; } } [SerializeField] private float maximumDistance = 150000.0f;

		/// <summary>All active and enabled <b>PositionCompressor</b> instances will be stored here.</summary>
		public static LinkedList<PositionCompressor> Instances = new LinkedList<PositionCompressor>();

		private static readonly int _CW_PositionCompressionData = Shader.PropertyToID("_CW_PositionCompressionData");

		[System.NonSerialized]
		private LinkedListNode<PositionCompressor> node;

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);

			Shader.EnableKeyword("CW_COMPRESS_POSITIONS");

			Shader.SetGlobalVector(_CW_PositionCompressionData, new Vector2(linearDistance, maximumDistance));
		}

		protected virtual void OnDisable()
		{
			Instances.Remove(node);

			node = null;

			if (Instances.Count == 0)
			{
				Shader.DisableKeyword("CW_COMPRESS_POSITIONS");
			}
		}

#if UNITY_EDITOR
		protected virtual void OnValidate()
		{
			Shader.SetGlobalVector(_CW_PositionCompressionData, new Vector2(linearDistance, maximumDistance));
		}
#endif
	}
}

#if UNITY_EDITOR
namespace CW.SimpleOriginSystem.Inspector
{
	using UnityEditor;
	using UnityEditor.UIElements;
	using UnityEngine.UIElements;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(PositionCompressor))]
	public class PositionCompressor_Editor : Editor
	{
		private PropertyField AddPropertyField(VisualElement parent, string path, string tooltip = null)
		{
			var p = new PropertyField(serializedObject.FindProperty(path));
			p.RegisterCallback<GeometryChangedEvent>(_ =>
			{
				p.tooltip = tooltip;
				foreach (var child in p.Query().ToList())
					child.tooltip = tooltip;
			});
			parent.Add(p);
			return p;
		}

		public override VisualElement CreateInspectorGUI()
		{
			var root = new VisualElement(); root.style.marginTop = 10; root.style.marginBottom = 10;

			AddPropertyField(root, "linearDistance", "The world space distance where the compression begins.");
			AddPropertyField(root, "maximumDistance", "The world space distance of vertices will always be below this.");

			return root;
		}
	}
}
#endif