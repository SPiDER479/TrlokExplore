using System.Collections.Generic;
using UnityEngine;

namespace CW.BuildAndDestroy
{
	[System.Serializable]
	public class CwCompiledPart
	{
		public string Name { set { name = value; } get { return name; } } [SerializeField] private string name;

		public CwRangeData ShapeRangeData { set { shapeRangeData = value; } get { return shapeRangeData; } } [SerializeField] private CwRangeData shapeRangeData;

		public CwRangeData DecalRangeData { set { decalRangeData = value; } get { return decalRangeData; } } [SerializeField] private CwRangeData decalRangeData;
			
		/// <summary>The maximum health value of this part.</summary>
		public float Health { set { health = value; } get { return health; } } [SerializeField] private float health;
			
		/// <summary>The center/pivot of this part relative to the compiled mesh.</summary>
		public Vector3 Center { set { center = value; } get { return center; } } [SerializeField] private Vector3 center;
			
		/// <summary>The maximum health value of this part.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		public List<CwModule> Modules { get { if (modules == null) modules = new List<CwModule>(); return modules; } } [SerializeField] private List<CwModule> modules;

		public List<Mesh> ColliderMeshes { get { if (colliderMeshes == null) colliderMeshes = new List<Mesh>(); return colliderMeshes; } } [SerializeField] private List<Mesh> colliderMeshes;

		public static Stack<CwCompiledPart> Pool = new Stack<CwCompiledPart>();

		public void Clear()
		{
			if (shapeRangeData != null)
			{
				shapeRangeData.Clear();
			}

			if (decalRangeData != null)
			{
				decalRangeData.Clear();
			}

			if (modules != null)
			{
				modules.Clear();
			}

			if (colliderMeshes != null)
			{
				foreach (var colliderMesh in colliderMeshes)
				{
					Object.DestroyImmediate(colliderMesh, true);
				}

				colliderMeshes.Clear();

				/*
				foreach (var asset in UnityEditor.AssetDatabase.LoadAllAssetsAtPath(UnityEditor.AssetDatabase.GetAssetPath(design)))
				{
					if (asset is Mesh)
					{
						DestroyImmediate(asset, true);
					}
				}
				*/
			}
		}
	}
}