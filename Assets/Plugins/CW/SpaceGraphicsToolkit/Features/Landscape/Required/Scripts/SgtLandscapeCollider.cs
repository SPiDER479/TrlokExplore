using Unity.Mathematics;
using UnityEngine;
using Unity.Jobs;
using Unity.Collections;
using Unity.Burst;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component can be added alongside a terrain to give it <b>MeshColliders</b> that match the visual mesh up to the specified LOD depth.</summary>
	[RequireComponent(typeof(SgtLandscape))]
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Collider")]
	public class SgtLandscapeCollider : MonoBehaviour
	{
		/// <summary>Approximately the smallest triangle we want to be generated when you go to the landscape surface.</summary>
		public float MinimumTriangleSize { set { minimumTriangleSize = value; } get { return minimumTriangleSize; } } [SerializeField] private float minimumTriangleSize = 0.5f;

		[System.NonSerialized]
		private int maxDepth;

		[System.NonSerialized]
		private SgtLandscape parent;

		[System.NonSerialized]
		private GameObject root;

		[System.NonSerialized]
		private Dictionary<SgtLandscape.TriangleHash, MeshCollider> colliders = new Dictionary<SgtLandscape.TriangleHash, MeshCollider>();

		[BurstCompile]
		private struct BuildIndicesJob : IJob
		{
			[ReadOnly] public NativeArray<double3>   Points;
			[ReadOnly] public NativeArray<double3>   Directions;
			[ReadOnly] public NativeArray<double>    Heights;
			[ReadOnly] public NativeArray<int>       Indices;
			[ReadOnly] public NativeArray<float4>    HoleDatas;
			[ReadOnly] public NativeArray<double4x4> HoleMatrices;
			[ReadOnly] public int                    HoleCount;
			[ReadOnly] public int3                   Origin;

			public NativeList<float3> OutVertices;
			public NativeList<int>    OutIndices;

			static bool PointInHole(double3 point, float4 data, double4x4 hole)
			{
				var local = math.transform(hole, point);
				var circleDist = math.dot(local.xz, local.xz);
				var boxDist    = math.max(math.abs(local.x), math.abs(local.z));
				var finalDist  = math.lerp(circleDist, boxDist, data.x);
				return finalDist < 1.0 && math.abs(local.y) < 1.0;
			}

		   static double FindBoundaryCrossing(
				double3 worldFrom, double3 worldTo,
				float4 data, double4x4 hole, bool fromInside)
			{
				var a = math.transform(hole, worldFrom);
				var b = math.transform(hole, worldTo);
				var d = b - a;

				double shape = data.x;

				// Y slab intersection (depth axis)
				double yLo, yHi;
				{
					if (math.abs(d.y) > 1e-14)
					{
						double t1 = (-1.0 - a.y) / d.y;
						double t2 = ( 1.0 - a.y) / d.y;
						yLo = math.min(t1, t2);
						yHi = math.max(t1, t2);
					}
					else
					{
						bool inside = math.abs(a.y) < 1.0;
						yLo = inside ? -1e10 :  2.0;
						yHi = inside ?  1e10 : -1.0;
					}
				}

				if (shape < 0.001)
				{
					// Circle in XZ
					double cylLo, cylHi;
					{
						double qa = d.x * d.x + d.z * d.z;
						double qb = 2.0 * (a.x * d.x + a.z * d.z);
						double qc = a.x * a.x + a.z * a.z - 1.0;

						if (qa > 1e-14)
						{
							double disc = qb * qb - 4.0 * qa * qc;
							if (disc > 0.0)
							{
								double sq = math.sqrt(disc);
								cylLo = (-qb - sq) / (2.0 * qa);
								cylHi = (-qb + sq) / (2.0 * qa);
							}
							else
							{
								cylLo =  2.0;
								cylHi = -1.0;
							}
						}
						else
						{
							bool inside = qc < 0.0;
							cylLo = inside ? -1e10 :  2.0;
							cylHi = inside ?  1e10 : -1.0;
						}
					}

					double holeLo = math.max(cylLo, yLo);
					double holeHi = math.min(cylHi, yHi);

					double t = fromInside ? holeHi : holeLo;
					return math.clamp(t, 0.0, 1.0);
				}
				else if (shape > 0.999)
				{
					// Box slabs: X, Z, Y
					double xLo, xHi;
					{
						if (math.abs(d.x) > 1e-14)
						{
							double t1 = (-1.0 - a.x) / d.x;
							double t2 = ( 1.0 - a.x) / d.x;
							xLo = math.min(t1, t2);
							xHi = math.max(t1, t2);
						}
						else
						{
							bool inside = math.abs(a.x) < 1.0;
							xLo = inside ? -1e10 :  2.0;
							xHi = inside ?  1e10 : -1.0;
						}
					}

					double zLo, zHi;
					{
						if (math.abs(d.z) > 1e-14)
						{
							double t1 = (-1.0 - a.z) / d.z;
							double t2 = ( 1.0 - a.z) / d.z;
							zLo = math.min(t1, t2);
							zHi = math.max(t1, t2);
						}
						else
						{
							bool inside = math.abs(a.z) < 1.0;
							zLo = inside ? -1e10 :  2.0;
							zHi = inside ?  1e10 : -1.0;
						}
					}

					double holeLo = math.max(math.max(xLo, zLo), yLo);
					double holeHi = math.min(math.min(xHi, zHi), yHi);

					double t = fromInside ? holeHi : holeLo;
					return math.clamp(t, 0.0, 1.0);
				}
				else
				{
					// Blended shape
					double lo = 0.0;
					double hi = 1.0;

					for (int iter = 0; iter < 64; iter++)
					{
						double mid = (lo + hi) * 0.5;
						double3 p = a + d * mid;

						double circleDist = p.x * p.x + p.z * p.z;
						double boxDist    = math.max(math.abs(p.x), math.abs(p.z));
						double dist       = math.lerp(circleDist, boxDist, shape);

						bool inXZ = dist < 1.0;
						bool inY  = math.abs(p.y) < 1.0;
						bool isInside = inXZ && inY;

						if (isInside == fromInside)
							lo = mid;
						else
							hi = mid;
					}

					return math.clamp((lo + hi) * 0.5, 0.0, 1.0);
				}
			}

			public void Execute()
			{
				for (var i = 0; i < Points.Length; i++)
				{
					var position = Points[i] + Directions[i] * Heights[i];
					OutVertices.Add(new float3(position - Origin));
				}

				for (var i = 0; i < Indices.Length; i += 3)
				{
					var i0 = Indices[i];
					var i1 = Indices[i + 1];
					var i2 = Indices[i + 2];

					double3 w0 = (double3)OutVertices[i0] + Origin;
					double3 w1 = (double3)OutVertices[i1] + Origin;
					double3 w2 = (double3)OutVertices[i2] + Origin;

					var clipped = false;

					for (var h = 0; h < HoleCount; h++)
					{
						var hole = HoleMatrices[h];
						var data = HoleDatas[h];

						bool in0 = PointInHole(w0, data, hole);
						bool in1 = PointInHole(w1, data, hole);
						bool in2 = PointInHole(w2, data, hole);
						int  cnt = (in0 ? 1 : 0) + (in1 ? 1 : 0) + (in2 ? 1 : 0);

						if (cnt == 0)
							continue;

						clipped = true;

						if (cnt == 3)
							break;

						if (cnt == 1)
						{
							double3 wA, wB, wC;
							int idxB, idxC;

							if      (in0) { wA = w0; wB = w1; wC = w2; idxB = i1; idxC = i2; }
							else if (in1) { wA = w1; wB = w2; wC = w0; idxB = i2; idxC = i0; }
							else          { wA = w2; wB = w0; wC = w1; idxB = i0; idxC = i1; }

							double tAB = FindBoundaryCrossing(wA, wB, data, hole, true);
							double tAC = FindBoundaryCrossing(wA, wC, data, hole, true);

							int newAB = OutVertices.Length;
							OutVertices.Add(new float3(math.lerp(wA, wB, tAB) - Origin));

							int newAC = OutVertices.Length;
							OutVertices.Add(new float3(math.lerp(wA, wC, tAC) - Origin));

							OutIndices.Add(newAB); OutIndices.Add(idxB);  OutIndices.Add(idxC);
							OutIndices.Add(newAB); OutIndices.Add(idxC);  OutIndices.Add(newAC);
						}

						else
						{
							double3 wA, wB, wC;
							int idxA;

							if      (!in0) { wA = w0; wB = w1; wC = w2; idxA = i0; }
							else if (!in1) { wA = w1; wB = w2; wC = w0; idxA = i1; }
							else           { wA = w2; wB = w0; wC = w1; idxA = i2; }

							double tAB = FindBoundaryCrossing(wA, wB, data, hole, false);
							double tAC = FindBoundaryCrossing(wA, wC, data, hole, false);

							int newAB = OutVertices.Length;
							OutVertices.Add(new float3(math.lerp(wA, wB, tAB) - Origin));

							int newAC = OutVertices.Length;
							OutVertices.Add(new float3(math.lerp(wA, wC, tAC) - Origin));

							OutIndices.Add(idxA); OutIndices.Add(newAB); OutIndices.Add(newAC);
						}

						break;
					}

					if (!clipped)
					{
						OutIndices.Add(i0);
						OutIndices.Add(i1);
						OutIndices.Add(i2);
					}
				}
			}
		}

		public void MarkForRebuild()
		{
			var t = GetComponentInParent<SgtLandscape>();

			if (t != null)
			{
				t.MarkForRebuild();
			}
		}

		protected virtual void OnEnable()
		{
			parent = GetComponentInParent<SgtLandscape>();

			parent.OnAddVisual    += HandleAddVisual;
			parent.OnRemoveVisual += HandleRemoveVisual;
			parent.OnShowVisual   += HandleShowVisual;
			parent.OnHideVisual   += HandleHideVisual;

			root = new GameObject("Colliders");

			root.hideFlags = HideFlags.DontSave;
			root.transform.SetParent(transform, false);

			maxDepth = parent.CalculateLodDepth(minimumTriangleSize);
		}

		protected virtual void OnDisable()
		{
			parent.OnAddVisual    -= HandleAddVisual;
			parent.OnRemoveVisual -= HandleRemoveVisual;
			parent.OnShowVisual   -= HandleShowVisual;
			parent.OnHideVisual   -= HandleHideVisual;

			DestroyImmediate(root);

			colliders.Clear();
		}

		private void HandleAddVisual(SgtLandscape.Visual visual, SgtLandscape.PendingTriangle pendingTriangle)
		{
			if (pendingTriangle.Triangle.Depth <= maxDepth)
			{
				var baseIndices  = SgtLandscape.VERTEX_INDICES;

				using (var finalVertices = new NativeList<float3>(SgtLandscape.VERTEX_INDICES.Length, Allocator.TempJob))
				using (var finalIndices  = new NativeList<int>(SgtLandscape.VERTEX_INDICES.Length, Allocator.TempJob))
				{
					new BuildIndicesJob
					{
						Points       = pendingTriangle.Points,
						Directions   = pendingTriangle.Directions,
						Heights      = pendingTriangle.Heights,
						Indices      = baseIndices,
						HoleDatas    = parent.ActiveHoleDatasNA,
						HoleMatrices = parent.ActiveHoleMatricesNA,
						HoleCount    = parent.ActiveHoleCount,
						OutVertices  = finalVertices,
						OutIndices   = finalIndices,
						Origin       = visual.Origin
					}.Run();

					if (finalIndices.Length > 0)
					{
						var child        = new GameObject("Child"); child.transform.SetParent(root.transform, false);
						var meshCollider = child.AddComponent<MeshCollider>();
						var mesh         = new Mesh();

						mesh.SetVertices(finalVertices.AsArray());
						mesh.SetIndices(finalIndices.AsArray(), MeshTopology.Triangles, 0);

						child.transform.localPosition = (float3)visual.Origin;

						meshCollider.cookingOptions = MeshColliderCookingOptions.None;
						meshCollider.sharedMesh     = mesh;
						meshCollider.enabled        = pendingTriangle.Triangle.Depth == maxDepth;

						colliders.Add(visual.Hash, meshCollider);
					}
				}
			}
		}

		private void HandleRemoveVisual(SgtLandscape.Visual visual)
		{
			var meshCollider = default(MeshCollider);

			if (colliders.Remove(visual.Hash, out meshCollider) == true)
			{
				DestroyImmediate(meshCollider.sharedMesh);
				DestroyImmediate(meshCollider.gameObject);
			}
		}

		private void HandleShowVisual(SgtLandscape.Visual visual)
		{
			var meshCollider = default(MeshCollider);

			if (colliders.TryGetValue(visual.Hash, out meshCollider) == true)
			{
				meshCollider.enabled = true;
			}
		}

		private void HandleHideVisual(SgtLandscape.Visual visual)
		{
			var meshCollider = default(MeshCollider);

			if (colliders.TryGetValue(visual.Hash, out meshCollider) == true)
			{
				if (visual.Depth == maxDepth)
				{
					meshCollider.enabled = true;
				}
				else
				{
					meshCollider.enabled = false;
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtLandscapeCollider))]
	public class SgtLandscapeCollider_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtLandscapeCollider tgt; SgtLandscapeCollider[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			BeginError(Any(tgts, t => t.MinimumTriangleSize <= 0.0f));
				Draw("minimumTriangleSize", ref markAsDirty, "Approximately the smallest triangle we want to be generated when you go to the landscape surface.");
			EndError();

			if (markAsDirty == true)
			{
				Each(tgts, t => t.MarkForRebuild());
			}
		}
	}
}
#endif