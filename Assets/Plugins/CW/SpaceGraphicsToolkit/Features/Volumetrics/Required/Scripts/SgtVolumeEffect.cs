using System.Collections.Generic;
using UnityEngine;

namespace SpaceGraphicsToolkit.Volumetrics
{
	/// <summary>This is the base class for components that render volumetric effects.</summary>
	public abstract class SgtVolumeEffect : MonoBehaviour
	{
		public static LinkedList<SgtVolumeEffect> Instances = new LinkedList<SgtVolumeEffect>();

		public float SortDistance
		{
			get
			{
				return sortDistance;
			}
		}

		[System.NonSerialized]
		protected float sortDistance;

		[System.NonSerialized]
		private LinkedListNode<SgtVolumeEffect> node;

		public abstract void CalculateSortDistance(Vector3 worldPoint);

		public virtual void RenderBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
		}

		public virtual void RenderOceanBuffer(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
		}

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);
		}

		protected virtual void OnDisable()
		{
			Instances.Remove(node); node = null;
		}
	}
}