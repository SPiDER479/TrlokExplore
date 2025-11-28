using System.Collections.Generic;
using UnityEngine;

namespace CW.BuildAndDestroy
{
	/// <summary>When a design is loaded from its compiled state, its data will be copied into this class.</summary>
    [System.Serializable]
    public class CwLoadedPart
    {
		public CwLoader Parent { set { parent = value; } get { return parent; } } [SerializeField] private CwLoader parent;

		public string Name { set { name = value; } get { return name; } } [SerializeField] private string name;

		public CwRangeData ShapeRangeData { set { shapeRangeData = value; } get { return shapeRangeData; } } [SerializeField] private CwRangeData shapeRangeData;

		public CwRangeData DecalRangeData { set { decalRangeData = value; } get { return decalRangeData; } } [SerializeField] private CwRangeData decalRangeData;

		public float Health { set { health = value; } get { return health; } } [SerializeField] private float health;

		/// <summary>The amount of damage this part has received.</summary>
		public float Damage { set { SetDamage(value); } get { return damage; } } [SerializeField] private float damage;

		/// <summary>The center/pivot of this part relative to the compiled mesh.</summary>
		public Vector3 Center { set { center = value; } get { return center; } } [SerializeField] private Vector3 center;

		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The amount of damage this part has received.</summary>
		public bool Detached { get { return detached; } } [SerializeField] private bool detached;

		public List<MeshCollider> MeshColliders { get { if (meshColliders == null) meshColliders = new List<MeshCollider>(); return meshColliders; } } [SerializeField] private List<MeshCollider> meshColliders;

		private static Stack<CwLoadedPart> pool = new Stack<CwLoadedPart>();

		public static CwLoadedPart Create()
		{
			if (pool.Count > 0)
			{
				return pool.Pop();
			}
			else
			{
				return new CwLoadedPart() { shapeRangeData = new CwRangeData(true), decalRangeData = new CwRangeData(true) };
			}
		}

		public static void Delete(CwLoadedPart instance)
		{
			instance.Clear();

			pool.Push(instance);
		}

		public void SetDamage(float newDamage)
		{
			if (damage != newDamage && detached == false)
			{
				damage = newDamage;

				if (damage >= health)
				{
					if (parent.AllowRemoval == true)
					{
						foreach (var meshCollider in meshColliders)
						{
							meshCollider.enabled = false;
						}

						CwDebris.Create(this);

						for (var i = shapeRangeData.VertexRange.x; i < shapeRangeData.VertexRange.y; i++)
						{
							parent.ShapeData.Positions[i] = Vector3.zero;
						}

						parent.ShapeVisual.SetVertices(parent.ShapeData.Positions);

						for (var i = decalRangeData.VertexRange.x; i < decalRangeData.VertexRange.y; i++)
						{
							parent.DecalData.Positions[i] = Vector3.zero;
						}

						parent.DecalVisual.SetVertices(parent.DecalData.Positions);

						detached = true;
					}
				}
			}
		}

		public void Clear()
		{
			if (meshColliders != null)
			{
				foreach (var meshCollider in meshColliders)
				{
					Object.DestroyImmediate(meshCollider);
				}

				meshColliders.Clear();
			}

			if (shapeRangeData != null)
			{
				shapeRangeData.Clear();
			}

			if (decalRangeData != null)
			{
				decalRangeData.Clear();
			}

			parent = null;
			health    = 0.0f;
			damage    = 0.0f;
			detached  = false;
		}
	}
}