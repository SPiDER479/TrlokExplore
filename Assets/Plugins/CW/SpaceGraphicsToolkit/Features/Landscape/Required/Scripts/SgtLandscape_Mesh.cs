using Unity.Mathematics;
using UnityEngine;
using Unity.Collections;
using UnityEngine.Rendering;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Landscape
{
	public partial class SgtLandscape
	{
		[System.NonSerialized]
		private static readonly int BATCH_CAPACITY = 35;

		[System.NonSerialized]
		private static readonly int VERTEX_RESOLUTION = 8;

		[System.NonSerialized]
		public static readonly int VERTEX_COUNT = (VERTEX_RESOLUTION + 1) * (VERTEX_RESOLUTION + 1) * 3;

		[System.NonSerialized]
		public static readonly int INDEX_COUNT = VERTEX_RESOLUTION * VERTEX_RESOLUTION * 6 * 3;

		[System.NonSerialized]
		public static readonly int TRIANGLE_COUNT = VERTEX_RESOLUTION * VERTEX_RESOLUTION * 2 * 3;

		[System.NonSerialized]
		public static int VERTEX_A;

		[System.NonSerialized]
		public static int VERTEX_B;

		[System.NonSerialized]
		public static int VERTEX_C;

		[System.NonSerialized]
		private static Texture2D PIXEL_WEIGHTS;

		public static NativeArray<double3> VERTEX_WEIGHTS;
		public static Vector4[]            VERTEX_BARY;
		public static Vector4[]            VERTEX_COORDS;
		public static NativeArray<float3>  VERTEX_POSITIONS;
		public static NativeArray<int>     VERTEX_INDICES;
		public static NativeArray<int>     VERTEX_NEIGHBORS;

		[System.NonSerialized]
		public static Mesh visualBlitMesh;

		public void TryGenerateMeshData()
		{
			if (VERTEX_WEIGHTS.IsCreated == true)
			{
				return;
			}

			GenerateTriangleData();

			visualBlitMesh = new Mesh();

			visualBlitMesh.hideFlags   = HideFlags.DontSaveInBuild | HideFlags.DontSaveInEditor;
			visualBlitMesh.indexFormat = IndexFormat.UInt32;
			visualBlitMesh.SetVertices(VERTEX_POSITIONS, 0, VERTEX_COUNT, MeshUpdateFlags.DontRecalculateBounds);
			visualBlitMesh.SetIndices(VERTEX_INDICES, 0, INDEX_COUNT, MeshTopology.Triangles, 0, false, 0);
		}

		public void TryDisposeMeshData()
		{
			if (VERTEX_WEIGHTS.IsCreated == true)
			{
				DisposeTriangleData();
			}
		}

		public void GenerateTex()
		{
			if (PIXEL_WEIGHTS != null)
			{
				DestroyImmediate(PIXEL_WEIGHTS);
			}

			PIXEL_WEIGHTS = new Texture2D(PIXEL_WIDTH, PIXEL_HEIGHT, TextureFormat.RGBAFloat, 0, true);
			PIXEL_WEIGHTS.filterMode = FilterMode.Point;
			PIXEL_WEIGHTS.hideFlags = HideFlags.DontSave;

			var f = 1.0f;
			var m = 0.5f;
			var c = f / 3.0f;

			WriteWeights(0, new float2(0,0), new float2(m,0), new float2(0,m), new float2(c,c));
			WriteWeights(1, new float2(f,0), new float2(m,m), new float2(m,0), new float2(c,c));
			WriteWeights(2, new float2(0,f), new float2(0,m), new float2(m,m), new float2(c,c));

			PIXEL_WEIGHTS.Apply();
		}

		private static void WriteWeights(int step, float2 posA, float2 posB, float2 posC, float2 posD)
		{
			for (var y = 0; y < PIXEL_HEIGHT; y++)
			{
				for (var x = 0; x < PIXEL_HEIGHT; x++)
				{
					var u = x / (PIXEL_HEIGHT - 1.0f);
					var v = y / (PIXEL_HEIGHT - 1.0f);

					var t = v;
					var s = u;
					var leftPos = math.lerp(posA, posC, t);
					var rightPos = math.lerp(posB, posD, t);

					var p = math.lerp(leftPos, rightPos, s);
					var b = float3.zero;

					b = CalculateBary(new float2(0.0f, 0.0f), new float2(1.0f, 0.0f), new float2(0.0f, 1.0f), p);

					PIXEL_WEIGHTS.SetPixel(x + PIXEL_HEIGHT * step, y, new Color(b.x, b.y, b.z, 1.0f));
				}
			}
		}

		private static List<float3>  tempPositions = new List<float3 >();
		private static List<Vector2> tempCoords    = new List<Vector2>();
		private static List<int    > tempIndices   = new List<int    >();
		// 2. Added temporary list for neighbors
		private static List<int    > tempNeighbors = new List<int    >();

		private int Insert(float3 posA, float3 posB, float3 posC, float3 posD, float2 coordA, float2 coordB, float2 coordC, float2 coordD)
		{
			var baseIndex = tempPositions.Count;
			var stride = VERTEX_RESOLUTION + 1;

			for (int i = 0; i <= VERTEX_RESOLUTION; i++)
			{
				var t = (float)i / VERTEX_RESOLUTION;
				var leftPos = math.lerp(posA, posC, t);
				var rightPos = math.lerp(posB, posD, t);
				var leftCoord = math.lerp(coordA, coordC, t);
				var rightCoord = math.lerp(coordB, coordD, t);

				for (int j = 0; j <= VERTEX_RESOLUTION; j++)
				{
					var s = (float)j / VERTEX_RESOLUTION;
					tempPositions.Add(math.lerp(leftPos, rightPos, s));
					tempCoords.Add(math.lerp(leftCoord, rightCoord, s));

					// 3. Calculate and store neighbors (Right, Up, Diagonal)
					// Logic: try to look forward (+1), if at edge, look backward (-1)
					int currentIndex = baseIndex + i * stride + j;

					// Neighbor 1: Horizontal (Next Column)
					if (j < VERTEX_RESOLUTION) tempNeighbors.Add(currentIndex + 1);
					else tempNeighbors.Add(currentIndex - 1);

					// Neighbor 2: Vertical (Next Row)
					if (i < VERTEX_RESOLUTION) tempNeighbors.Add(currentIndex + stride);
					else tempNeighbors.Add(currentIndex - stride);

					// Neighbor 3: Diagonal (Next Row + Column)
					if (j < VERTEX_RESOLUTION && i < VERTEX_RESOLUTION) tempNeighbors.Add(currentIndex + stride + 1);
					else tempNeighbors.Add(currentIndex - stride - 1);
				}
			}

			for (int i = 0; i < VERTEX_RESOLUTION; i++)
			{
				for (int j = 0; j < VERTEX_RESOLUTION; j++)
				{
					int start = baseIndex + i * (VERTEX_RESOLUTION + 1) + j;
					tempIndices.Add(start);
					tempIndices.Add(start + VERTEX_RESOLUTION + 1);
					tempIndices.Add(start + 1);

					tempIndices.Add(start + 1);
					tempIndices.Add(start + VERTEX_RESOLUTION + 1);
					tempIndices.Add(start + VERTEX_RESOLUTION + 2);
				}
			}

			return baseIndex;
		}

		private static float3 CalculateBary(double2 a, double2 b, double2 c, double2 p)
		{
			var v0 = b - a;
			var v1 = c - a;
			var v2 = p - a;

			var d00 = math.dot(v0, v0);
			var d01 = math.dot(v0, v1);
			var d11 = math.dot(v1, v1);
			var d20 = math.dot(v2, v0);
			var d21 = math.dot(v2, v1);

			var denom = d00 * d11 - d01 * d01;
			var v = (d11 * d20 - d01 * d21) / denom;
			var w = (d00 * d21 - d01 * d20) / denom;
			var u = 1.0 - v - w;
			var d = new double3(u, v, w);

			d *= 1024;
			d = math.round(d);
			d /= 1024;

			d /= d.x + d.y + d.z;

			return (float3)d;
		}

		private void GenerateTriangleData()
		{
			var m = VERTEX_RESOLUTION;
			var f = VERTEX_RESOLUTION * 2;
			var c = f / 3.0f;

			VERTEX_A         = Insert(new float3(0,0,0), new float3(m,0,0), new float3(0,m,0), new float3(c,c,0), new float2(0,0), new float2(1,0), new float2(0,1), new float2(1,1));
			VERTEX_B         = Insert(new float3(f,0,1), new float3(m,m,1), new float3(m,0,1), new float3(c,c,1), new float2(0,0), new float2(1,0), new float2(0,1), new float2(1,1));
			VERTEX_C         = Insert(new float3(0,f,2), new float3(0,m,2), new float3(m,m,2), new float3(c,c,2), new float2(0,0), new float2(1,0), new float2(0,1), new float2(1,1));
			VERTEX_WEIGHTS   = new NativeArray<double3>(VERTEX_COUNT, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);
			VERTEX_BARY      = new Vector4[VERTEX_COUNT];
			VERTEX_COORDS    = new Vector4[VERTEX_COUNT];
			VERTEX_POSITIONS = new NativeArray<float3>(VERTEX_COUNT, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);
			VERTEX_INDICES   = new NativeArray<int>(INDEX_COUNT, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);
			VERTEX_NEIGHBORS = new NativeArray<int>(VERTEX_COUNT * 3, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);

			for (var i = 0; i < VERTEX_COUNT; i++)
			{
				var bary = CalculateBary(new float2(0,0), new float2(f,0), new float2(0,f), tempPositions[i].xy);

				VERTEX_POSITIONS[i] = new float3(i, tempPositions[i].z, 0.0f);
				VERTEX_WEIGHTS[i] = new float3(bary.x, bary.y, bary.z);
				VERTEX_BARY[i] = new Vector4(bary.x, bary.y, bary.z, 0.0f);
				VERTEX_COORDS[i] = tempCoords[i];

				VERTEX_NEIGHBORS[i * 3 + 0] = tempNeighbors[i * 3 + 0];
				VERTEX_NEIGHBORS[i * 3 + 1] = tempNeighbors[i * 3 + 1];
				VERTEX_NEIGHBORS[i * 3 + 2] = tempNeighbors[i * 3 + 2];
			}

			for (var i = 0; i < INDEX_COUNT; i++)
			{
				VERTEX_INDICES[i] = tempIndices[i];
			}
		}

		public void DisposeTriangleData()
		{
			VERTEX_WEIGHTS  .Dispose();
			VERTEX_POSITIONS.Dispose();
			VERTEX_INDICES  .Dispose();
			VERTEX_NEIGHBORS.Dispose();

			tempPositions.Clear();
			tempCoords.Clear();
			tempIndices.Clear();
			tempNeighbors.Clear();

			DestroyImmediate(visualBlitMesh);
		}
	}
}