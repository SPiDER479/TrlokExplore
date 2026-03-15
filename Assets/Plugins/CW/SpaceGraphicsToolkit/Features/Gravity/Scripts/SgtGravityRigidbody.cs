using UnityEngine;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Gravity
{
	/// <summary>This component allows a Rigidbody to be affected by SgtGravitySphere sources.</summary>
	[ExecuteInEditMode]
	[RequireComponent(typeof(Rigidbody))]
	public class SgtGravityRigidbody : MonoBehaviour
	{
		public static LinkedList<SgtGravityRigidbody> Instances = new LinkedList<SgtGravityRigidbody>();

		[System.NonSerialized] private LinkedListNode<SgtGravityRigidbody> node;

		[System.NonSerialized] private Rigidbody cachedRigidbody;

		[System.NonSerialized] private bool cachedRigidbodySet;

		/// <summary>The linear drag applied to this Rigidbody will be multiplied by this value.</summary>
		public float LinearDragMultiplier { set { linearDragMultiplier = value; } get { return linearDragMultiplier; } } [SerializeField] private float linearDragMultiplier = 1.0f;

		/// <summary>The angular drag applied to this Rigidbody will be multiplied by this value.</summary>
		public float AngularDragMultiplier { set { angularDragMultiplier = value; } get { return angularDragMultiplier; } } [SerializeField] private float angularDragMultiplier = 1.0f;

		public Rigidbody CachedRigidbody
		{
			get
			{
				if (cachedRigidbodySet == false)
				{
					cachedRigidbody    = GetComponent<Rigidbody>();
					cachedRigidbodySet = true;
				}

				return cachedRigidbody;
			}
		}

		protected virtual void OnEnable()
		{
			cachedRigidbody    = GetComponent<Rigidbody>();
			cachedRigidbodySet = true;
			node               = Instances.AddLast(this);
		}

		protected virtual void OnDisable()
		{
			Instances.Remove(node);
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Gravity
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtGravityRigidbody))]
	public class SgtGravityRigidbody_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtGravityRigidbody tgt; SgtGravityRigidbody[] tgts; GetTargets(out tgt, out tgts);

			Draw("linearDragMultiplier", "The linear drag applied to this Rigidbody will be multiplied by this value.");
			Draw("angularDragMultiplier", "The angular drag applied to this Rigidbody will be multiplied by this value.");

			Separator();

			Info("This Rigidbody is currently registered in the SGT gravity simulation.");

			if (Any(tgts, t => t.CachedRigidbody.useGravity == true))
			{
				if (HelpButton("This Rigidbody has UseGravity enabled, you may want to disable it.", MessageType.Warning, "Fix", 40) == true)
				{
					Each(tgts, t => t.CachedRigidbody.useGravity = false, true);
				}
			}

#if UNITY_6000_0_OR_NEWER || UNITY_6_0_OR_NEWER
			if (Any(tgts, t => t.CachedRigidbody.linearDamping > 0))
#else
			if (Any(tgts, t => t.CachedRigidbody.drag > 0))
#endif
			{
				Warning("This Rigidbody has a non-zero Linear Drag. This will apply constant drag even in a vacuum. You should likely set this to 0 and use the SGT Gravity Sphere drag settings instead.");
			}

#if UNITY_6000_0_OR_NEWER || UNITY_6_0_OR_NEWER
			if (Any(tgts, t => t.CachedRigidbody.angularDamping > 0))
#else
			if (Any(tgts, t => t.CachedRigidbody.angularDrag > 0))
#endif
			{
				Warning("This Rigidbody has a non-zero Angular Drag. You should likely set this to 0 to let SGT handle atmospheric rotation resistance.");
			}
		}
	}
}
#endif