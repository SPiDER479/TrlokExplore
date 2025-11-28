using System.Collections.Generic;
using UnityEngine;

namespace CW.BuildAndDestroy
{
	/// <summary>This class helps the design parts compile.</summary>
	[System.Serializable]
	public class CwDesignData
	{
		public List<Vector3> Positions;

		public List<Color32> Colors;

		public List<Vector3> Normals;

		public List<Vector4> Tangents;

		public List<Vector4> Coords0;

		public List<Vector4> Coords1;

		public List<IndexList> IndexLists;

		public class IndexList
		{
			public List<int> Indices;

			public int Added;

			public IndexList(bool initialize)
			{
				if (initialize == true)
				{
					Indices = new List<int>();
				}
			}
		}

		public List<int> GetIndices()
		{
			if (IndexLists.Count == 0)
			{
				return AddIndices();
			}

			return IndexLists[0].Indices;
		}

		public CwDesignData(bool initialize)
		{
			if (initialize == true)
			{
				Positions = new List<Vector3>();

				Colors = new List<Color32>();

				Normals = new List<Vector3>();

				Tangents = new List<Vector4>();

				Coords0 = new List<Vector4>();

				Coords1 = new List<Vector4>();

				IndexLists = new List<IndexList>();
			}
		}

		public List<int> AddIndices()
		{
			var newIndexList = new IndexList(true);

			IndexLists.Add(newIndexList);

			return newIndexList.Indices;
		}

		public void FillFrom(Mesh mesh)
		{
			mesh.GetVertices(Positions);
			mesh.GetColors(Colors);
			mesh.GetNormals(Normals);
			mesh.GetTangents(Tangents);
			mesh.GetUVs(0, Coords0);
			mesh.GetUVs(1, Coords1);

			for (var i = 0; i < mesh.subMeshCount; i++)
			{
				mesh.GetTriangles(AddIndices(), i);
			}
		}

		public void Clear()
		{
			Positions.Clear();

			Colors.Clear();

			Normals.Clear();

			Tangents.Clear();

			Coords0.Clear();

			Coords1.Clear();

			IndexLists.Clear();
		}
	}
}