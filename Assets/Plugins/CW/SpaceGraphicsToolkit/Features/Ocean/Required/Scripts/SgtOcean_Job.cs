using UnityEngine;
using Unity.Jobs;
using Unity.Burst;
using Unity.Collections;
using Unity.Mathematics;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Ocean
{
	public partial class SgtOcean
	{
		public struct Triangle
		{
			public double4      PositionA;
			public double4      PositionB;
			public double4      PositionC;
			public bool         Split;
			public int          Depth;
			public TriangleHash Hash;

			public double4 Pivot1
			{
				get
				{
					var a = math.min(PositionA, PositionB);
					var b = math.max(PositionA, PositionB);
					return (a + b) * 0.5f;
				}
			}

			public double4 Pivot2
			{
				get
				{
					var a = math.min(PositionB, PositionC);
					var b = math.max(PositionB, PositionC);
					return (a + b) * 0.5f;
				}
			}

			public double4 Pivot3
			{
				get
				{
					var a = math.min(PositionC, PositionA);
					var b = math.max(PositionC, PositionA);
					return (a + b) * 0.5f;
				}
			}

			public double Size1
			{
				get
				{
					var a = math.min(PositionA, PositionB);
					var b = math.max(PositionA, PositionB);
					return math.length(a.xyz - b.xyz);
				}
			}

			public double Size2
			{
				get
				{
					var a = math.min(PositionB, PositionC);
					var b = math.max(PositionB, PositionC);
					return math.length(a.xyz - b.xyz);
				}
			}

			public double Size3
			{
				get
				{
					var a = math.min(PositionC, PositionA);
					var b = math.max(PositionC, PositionA);
					return math.length(a.xyz - b.xyz);
				}
			}

			public Triangle(double4 a, double4 b, double4 c, int d, bool s)
			{
				PositionA  = a;
				PositionB  = b;
				PositionC  = c;
				Depth      = d;
				Split      = s;
				Hash       = new TriangleHash(a.xyz, b.xyz, c.xyz);
			}
		}

		public struct TriangleHash : System.IEquatable<TriangleHash>
		{
			private double3x3 data;

			public TriangleHash(double3 a, double3 b, double3 c)
			{
				data.c0 = a;
				data.c1 = b;
				data.c2 = c;

				if (CompareVectors(data.c0, data.c1) > 0) Swap(ref data.c0, ref data.c1);
				if (CompareVectors(data.c0, data.c2) > 0) Swap(ref data.c0, ref data.c2);
				if (CompareVectors(data.c1, data.c2) > 0) Swap(ref data.c1, ref data.c2);
			}

			private static int CompareVectors(double3 a, double3 b)
			{
				if (a.x != b.x) return a.x < b.x ? -1 : 1;
				if (a.y != b.y) return a.y < b.y ? -1 : 1;
				if (a.z != b.z) return a.z < b.z ? -1 : 1;
				return 0;
			}

			private static void Swap(ref double3 a, ref double3 b)
			{
				var temp = a;
				a = b;
				b = temp;
			}

			public bool Equals(TriangleHash other)
			{
				return data.Equals(other.data);
			}

			public override bool Equals(object obj)
			{
				return obj is TriangleHash other && Equals(other);
			}

			public override int GetHashCode()
			{
				return data.GetHashCode();
			}
		}

		public class Batch
		{
			public int Count;

			public TriangleHash[] Hashes = new TriangleHash[128];

			public Vector4[]  PositionsO = new Vector4[128];
			public Vector4[]  PositionsA = new Vector4[128];
			public Vector4[]  PositionsB = new Vector4[128];
			public Vector4[]  PositionsC = new Vector4[128];
			public Matrix4x4[] CoordX    = new Matrix4x4[128];
			public Matrix4x4[] CoordY    = new Matrix4x4[128];
			public Matrix4x4[] CoordZ    = new Matrix4x4[128];
			public Matrix4x4[] CoordW    = new Matrix4x4[128];

			public static Stack<Batch> Pool = new Stack<Batch>();

			private static double Asin(double x)
			{
				return x + (x * x * x / 6.0) + ((3.0 * x * x * x * x * x) / 40.0);
			}

			private static double4 CalculateCoord(double3 position)
			{
				var d = math.normalize(position);
				var u = math.atan2(d.z, d.x) / (math.PI_DBL * 2.0) + 0.5;
				var v = Asin(d.y) / math.PI_DBL + 0.5;
				//var v = d.y * 0.3 + 0.5;

				return new double4(u, v * 0.5f, d.xz * 0.25);
			}

			private static double4 CalculateCoord2(double3 position)
			{
				var d = math.normalize(position);
				var u = math.atan2(-d.z, -d.x) / (math.PI_DBL * 2.0);
				var v = Asin(d.y) / math.PI_DBL + 0.5;
				//var v = d.y * 0.3 + 0.5;

				return new double4(u, v * 0.5f, d.xz * 0.25);
			}

			public void AddTriangle(Triangle triangle, int4 globalTiling, float radius)
			{
				var positionA = triangle.PositionA;
				var positionB = triangle.PositionB;
				var positionC = triangle.PositionC;

				positionA.xyz = math.normalize(positionA.xyz) * radius;
				positionB.xyz = math.normalize(positionB.xyz) * radius;
				positionC.xyz = math.normalize(positionC.xyz) * radius;

				var origin = (int3)math.floor(positionA.xyz);

				var triangleD = math.normalize(positionA.xyz + positionB.xyz + positionC.xyz);

				var coordA = triangleD.x > 0.0f ? CalculateCoord(positionA.xyz) : CalculateCoord2(positionA.xyz);
				var coordB = triangleD.x > 0.0f ? CalculateCoord(positionB.xyz) : CalculateCoord2(positionB.xyz);
				var coordC = triangleD.x > 0.0f ? CalculateCoord(positionC.xyz) : CalculateCoord2(positionC.xyz);

				var coordX = math.floor(coordA * globalTiling.x);
				var coordY = math.floor(coordA * globalTiling.y);
				var coordZ = math.floor(coordA * globalTiling.z);
				var coordW = math.floor(coordA * globalTiling.w);

				var coordXA = coordA * globalTiling.x - coordX;
				var coordXB = coordB * globalTiling.x - coordX;
				var coordXC = coordC * globalTiling.x - coordX;

				var coordYA = coordA * globalTiling.y - coordY;
				var coordYB = coordB * globalTiling.y - coordY;
				var coordYC = coordC * globalTiling.y - coordY;

				var coordZA = coordA * globalTiling.z - coordZ;
				var coordZB = coordB * globalTiling.z - coordZ;
				var coordZC = coordC * globalTiling.z - coordZ;

				var coordWA = coordA * globalTiling.w - coordW;
				var coordWB = coordB * globalTiling.w - coordW;
				var coordWC = coordC * globalTiling.w - coordW;
				
				PositionsO[Count] = new float4(origin, triangle.Depth);
				PositionsA[Count] = (Vector3)(float3)(positionA.xyz - origin);
				PositionsB[Count] = (Vector3)(float3)(positionB.xyz - origin);
				PositionsC[Count] = (Vector3)(float3)(positionC.xyz - origin);
				CoordX[Count] = new Matrix4x4((Vector4)(float4)coordXA, (Vector4)(float4)coordXB, (Vector4)(float4)coordXC, default(Vector4));
				CoordY[Count] = new Matrix4x4((Vector4)(float4)coordYA, (Vector4)(float4)coordYB, (Vector4)(float4)coordYC, default(Vector4));
				CoordZ[Count] = new Matrix4x4((Vector4)(float4)coordZA, (Vector4)(float4)coordZB, (Vector4)(float4)coordZC, default(Vector4));
				CoordW[Count] = new Matrix4x4((Vector4)(float4)coordWA, (Vector4)(float4)coordWB, (Vector4)(float4)coordWC, default(Vector4));
				Hashes[Count] = triangle.Hash;

				Count += 1;
			}

			public void RemoveTriangle(TriangleHash hash)
			{
				var index = default(int);
				var last  = Count - 1;

				for (var i = 0; i < Count; i++)
				{
					if (Hashes[i].Equals(hash) == true)
					{
						index = i; break;
					}
				}

				if (index != last)
				{
					Hashes[index] = Hashes[last];
					PositionsO[index] = PositionsO[last];
					PositionsA[index] = PositionsA[last];
					PositionsB[index] = PositionsB[last];
					PositionsC[index] = PositionsC[last];
					CoordX[index]     = CoordX[last];
					CoordY[index]     = CoordY[last];
					CoordZ[index]     = CoordZ[last];
					CoordW[index]     = CoordW[last];
				}

				Count -= 1;
			}
		}

		[System.NonSerialized]
		private static readonly int VERTEX_RESOLUTION = 16;

		[System.NonSerialized]
		private static readonly int VERTEX_COUNT = (VERTEX_RESOLUTION + 1) * (VERTEX_RESOLUTION + 1);

		[System.NonSerialized]
		private static readonly int INDEX_COUNT = VERTEX_RESOLUTION * VERTEX_RESOLUTION * 6;

		[System.NonSerialized]
		private static readonly int TRIANGLE_COUNT = VERTEX_RESOLUTION * VERTEX_RESOLUTION * 2;

		[System.NonSerialized]
		private static Mesh cachedMesh;

		[System.NonSerialized]
		private static bool cachedMeshGenerated;

		private static Mesh GetMesh()
		{
			if (cachedMeshGenerated == false)
			{
				var rows = VERTEX_RESOLUTION;
				var columns = VERTEX_RESOLUTION;

				Vector3[] vertices = new Vector3[(rows + 1) * (columns + 1)];
				int[] triangles = new int[rows * columns * 6];

				for (int i = 0, y = 0; y <= rows; y++)
				{
					for (int x = 0; x <= columns - y; x++, i++)
					{
						//float px = x * columns - 0.5f;
						//float py = y * rows    - 0.5f;
						//vertices[i] = new Vector3(px, py, 0);
						float u = (float)x / columns;
						float v = (float)y / rows;
						float w = 1.0f - u - v;
						vertices[i] = new Vector3(u, v, w);
					}
				}

				int triIndex = 0;
				for (int y = 0, i = 0; y < rows; y++)
				{
					for (int x = 0; x < columns - y; x++, i++)
					{
						int a = i;
						int b = i + 1;
						int c = i + (columns - y + 1);
						int d = c + 1;
				
						triangles[triIndex++] = a;
						triangles[triIndex++] = c;
						triangles[triIndex++] = b;
				
						if (x < columns - y - 1)
						{
							triangles[triIndex++] = b;
							triangles[triIndex++] = c;
							triangles[triIndex++] = d;
						}
					}
					i++;
				}

				cachedMesh          = new Mesh();
				cachedMeshGenerated = true;

				cachedMesh.hideFlags = HideFlags.DontSave;

				cachedMesh.SetVertices(vertices);
				cachedMesh.SetTriangles(triangles, 0);
				cachedMesh.RecalculateNormals();
				cachedMesh.RecalculateTangents();
			}

			return cachedMesh;
		}

		[BurstCompile]
		public struct CreateTopologyJob_Sphere : IJob
		{
			[ReadOnly] public float Radius;

			public NativeList<Triangle> Topology;

			public void Execute()
			{
				var pointN = new double4(    0.0,     0.0,  Radius, 1.0);
				var pointE = new double4(+Radius,     0.0,     0.0, 1.0);
				var pointS = new double4(    0.0,     0.0, -Radius, 1.0);
				var pointW = new double4(-Radius,     0.0,     0.0, 1.0);
				var pointU = new double4(    0.0, +Radius,     0.0, 1.0);
				var pointD = new double4(    0.0, -Radius,     0.0, 1.0);

				Topology.Clear();

				Topology.Add(new Triangle(pointU, pointW, pointS, 0, false));
				Topology.Add(new Triangle(pointU, pointS, pointE, 0, false));
				Topology.Add(new Triangle(pointU, pointE, pointN, 0, false));
				Topology.Add(new Triangle(pointU, pointN, pointW, 0, false));

				Topology.Add(new Triangle(pointD, pointS, pointW, 0, false));
				Topology.Add(new Triangle(pointD, pointE, pointS, 0, false));
				Topology.Add(new Triangle(pointD, pointN, pointE, 0, false));
				Topology.Add(new Triangle(pointD, pointW, pointN, 0, false));
			}
		}

		public enum DeformType
		{
			None,
			Sphere
		}

		[BurstCompile]
		public struct UpdateTrianglesJob : IJob
		{
			[ReadOnly] public NativeList<Triangle> Topology;
			[ReadOnly] public NativeList<double3>  CameraPositions;
			[ReadOnly] public float                CameraDetailSq;
			[ReadOnly] public DeformType           Deform;
			[ReadOnly] public double               Radius;
			[ReadOnly] public int                  MaxDepth;
			[ReadOnly] public int                  MaxSteps;

			public NativeList<Triangle> Triangles;
			public NativeList<Triangle> CreateDiffs;
			public NativeList<Triangle> DeleteDiffs;
			public NativeList<Triangle> StatusDiffs;

			private bool TooLarge(double3 a, double3 b, double3 c, double3 e)
			{
				var m = (a + b + c) / 3.0f;

				var r2 = math.max(math.distancesq(m, a), math.max(math.distancesq(m, b), math.distancesq(m, c)));

				var d2 = math.distancesq(e, m);

				if (d2 > r2)
				{
					return (r2 / d2) > CameraDetailSq;
				}
				else
				{
					return true;
				}
			}

			public bool AnyTooLarge(double3 a, double3 b, double3 c, int depth)
			{
				if (depth < 3)
				{
					return true;
				}

				switch (Deform)
				{
					case DeformType.Sphere:
					{
						a = math.normalize(a) * Radius;
						b = math.normalize(b) * Radius;
						c = math.normalize(c) * Radius;
					}
					break;
				}

				for (var i = 0; i < CameraPositions.Length; i++)
				{
					if (TooLarge(a, b, c, CameraPositions[i]) == true)
					{
						return true;
					}
				}

				return false;
			}

			private void CheckTriangles(NativeParallelHashSet<TriangleHash> oldHashes, NativeParallelHashSet<double3> pivots)
			{
				var newCount = 0;

				for (var i = 0; i < Triangles.Length; i++)
				{
					var triangle = Triangles[i];

					if (triangle.Depth < MaxDepth && AnyTooLarge(triangle.PositionA.xyz, triangle.PositionB.xyz, triangle.PositionC.xyz, triangle.Depth) == true)
					{
						var childA = new Triangle(triangle.Pivot2, triangle.PositionA, triangle.PositionB, triangle.Depth + 1, false);
						var childB = new Triangle(triangle.Pivot2, triangle.PositionC, triangle.PositionA, triangle.Depth + 1, false);

						if (oldHashes.Contains(childA.Hash) == true && oldHashes.Contains(childB.Hash) == true)
						{
							triangle.Split = true; Triangles[i] = triangle;

							pivots.Add(triangle.Pivot2.xyz);

							Triangles.Add(childA);
							Triangles.Add(childB);
						}
						else if (newCount < MaxSteps)
						{
							newCount += 1;

							triangle.Split = true; Triangles[i] = triangle;

							pivots.Add(triangle.Pivot2.xyz);

							Triangles.Add(childA);
							Triangles.Add(childB);
						}
					}
				}
			}

			private void FixTriangles(NativeParallelHashSet<double3> pivots)
			{
				for (var i = 0; i < Triangles.Length; i++)
				{
					var tri = Triangles[i];

					if (tri.Split == false)
					{
						if (pivots.Contains(tri.Pivot1.xyz) == true)
						{
							tri.Split = true; Triangles[i] = tri;

							Triangles.Add(new Triangle(tri.Pivot1, tri.PositionC, tri.PositionA, tri.Depth + 1, false));
							Triangles.Add(new Triangle(tri.Pivot1, tri.PositionB, tri.PositionC, tri.Depth + 1, false));
						}
						else if (pivots.Contains(tri.Pivot2.xyz) == true)
						{
							tri.Split = true; Triangles[i] = tri;

							Triangles.Add(new Triangle(tri.Pivot2, tri.PositionA, tri.PositionB, tri.Depth + 1, false));
							Triangles.Add(new Triangle(tri.Pivot2, tri.PositionC, tri.PositionA, tri.Depth + 1, false));
						}
						else if (pivots.Contains(tri.Pivot3.xyz) == true)
						{
							tri.Split = true; Triangles[i] = tri;

							Triangles.Add(new Triangle(tri.Pivot3, tri.PositionB, tri.PositionC, tri.Depth + 1, false));
							Triangles.Add(new Triangle(tri.Pivot3, tri.PositionA, tri.PositionB, tri.Depth + 1, false));
						}
					}
				}
			}

			private void CalculateDiff(NativeList<Triangle> oldTriangles, NativeList<Triangle> newTriangles)
			{
				var oldHashes = new NativeParallelHashMap<TriangleHash, Triangle>(oldTriangles.Length, Allocator.Temp);
				var newHashes = new NativeParallelHashMap<TriangleHash, Triangle>(newTriangles.Length, Allocator.Temp);

				for (var i = 0; i < oldTriangles.Length; i++)
				{
					var oldTriangle = oldTriangles[i]; oldHashes.Add(oldTriangle.Hash, oldTriangle);
				}

				for (var i = 0; i < newTriangles.Length; i++)
				{
					var newTriangle = newTriangles[i]; newHashes.Add(newTriangle.Hash, newTriangle);
				}

				for (var i = 0; i < oldTriangles.Length; i++)
				{
					var newTriangle = default(Triangle);
					var oldTriangle = oldTriangles[i];

					if (newHashes.TryGetValue(oldTriangle.Hash, out newTriangle) == false)
					{
						DeleteDiffs.Add(oldTriangle);
					}
				}

				for (var i = 0; i < newTriangles.Length; i++)
				{
					var newTriangle = newTriangles[i];
					var oldTriangle = default(Triangle);

					if (oldHashes.TryGetValue(newTriangle.Hash, out oldTriangle) == false)
					{
						CreateDiffs.Add(newTriangle);
					}
					else if (newTriangle.Split != oldTriangle.Split)
					{
						StatusDiffs.Add(newTriangle);
					}
				}
			}

			public void Execute()
			{
				var pivots       = new NativeParallelHashSet<double3>(1024 * 64, Allocator.Temp);
				var oldHashes    = new NativeParallelHashSet<TriangleHash>(Triangles.Length, Allocator.Temp);
				var oldTriangles = new NativeList<Triangle>(Triangles.Length, Allocator.Temp);

				oldTriangles.CopyFrom(Triangles);

				for (var i = 0; i < oldTriangles.Length; i++)
				{
					var oldTriangle = oldTriangles[i]; oldHashes.Add(oldTriangle.Hash);
				}

				Triangles.Clear();

				Triangles.AddRange(Topology.AsArray());

				CheckTriangles(oldHashes, pivots);

				FixTriangles(pivots);

				/*
				for (var i = 0; i < Triangles.Length; i++)
				{
					var triangle = Triangles[i];

					if (triangle.Split == false)
					{
						triangle.PositionA.xyz = math.normalize(triangle.PositionA.xyz) * Radius;
						triangle.PositionB.xyz = math.normalize(triangle.PositionB.xyz) * Radius;
						triangle.PositionC.xyz = math.normalize(triangle.PositionC.xyz) * Radius;
					}
				}
				*/

				CreateDiffs.Clear();
				DeleteDiffs.Clear();
				StatusDiffs.Clear();

				CalculateDiff(oldTriangles, Triangles);
			}
		}
	}
}