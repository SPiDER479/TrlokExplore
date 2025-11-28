using UnityEngine;
using CW.Common;

namespace CW.BuildAndDestroy
{
	[DisallowMultipleComponent]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwExplosion")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Explosion")]
	public class CwExplosion : MonoBehaviour
	{
		/// <summary>Should this explosion apply marks and holes to objects?</summary>
		public bool Mark { set { mark = value; } get { return mark; } } [SerializeField] protected bool mark;

		/// <summary>The explosion will only apply damage and marks to objects on the following layers.</summary>
		public LayerMask Layers { set { layers = value; } get { return layers; } } [SerializeField] protected LayerMask layers = -1;

		/// <summary>The radius of the explosion in world space.
		/// NOTE: This will be multiplied by the <b>Size</b> value.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] protected float radius = 1.0f;

		/// <summary>The size of the explosion in world space.
		/// NOTE: This will be multiplied by the <b>Radius</b> value.</summary>
		public Vector3 Size { set { size = value; } get { return size; } } [SerializeField] protected Vector3 size = Vector3.one;

		/// <summary>The shape of the explosion.</summary>
		public Texture Texture { set { texture = value; } get { return texture; } } [SerializeField] protected Texture texture;

		/// <summary>This GameObject will be destroyed after this many seconds.</summary>
		public float DestroyAfter { set { destroyAfter = value; } get { return destroyAfter; } } [SerializeField] protected float destroyAfter = 1.0f;

		[ContextMenu("Emit")]
		public void Emit()
		{
			CwLoader.ApplyMarkAll(layers, transform.position, transform.rotation, size * radius, texture);
		}

		protected virtual void OnEnable()
		{
			if (mark == true)
			{
				Emit();
			}
		}

		protected virtual void Update()
		{
			destroyAfter -= Time.deltaTime;

			if (destroyAfter <= 0.0f)
			{
				Destroy(gameObject);
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			Gizmos.DrawWireSphere(transform.position, radius);
		}
#endif
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwExplosion;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwExplosion_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			Draw("mark", "Should this explosion apply marks and holes to objects?");
			if (Any(tgts, t => t.Mark == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.Layers == 0));
						Draw("layers", "The explosion will only apply damage and marks to objects on the following layers.");
					EndError();
					Draw("radius", "The radius of the explosion in world space.");
					Draw("size");
					BeginError(Any(tgts, t => t.Texture == null));
						Draw("texture", "The shape of the explosion.");
					EndError();
				EndIndent();
			}

			Separator();

			Draw("destroyAfter", "This GameObject will be destroyed after this many seconds.");
		}
	}
}
#endif