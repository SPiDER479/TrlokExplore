using UnityEngine;
using System.Collections.Generic;

namespace CW.BuildAndDestroy
{
	[System.Serializable]
	public class CwRangeData
	{
		public Vector2Int VertexRange;

		public List<Vector2Int> IndexRanges;

		public CwRangeData(bool initialize)
		{
			if (initialize == true)
			{
				IndexRanges = new List<Vector2Int>();
			}
		}

		public void Clear()
		{
			VertexRange = default(Vector2Int);

			if (IndexRanges != null)
			{
				IndexRanges.Clear();
			}
		}
	}
}