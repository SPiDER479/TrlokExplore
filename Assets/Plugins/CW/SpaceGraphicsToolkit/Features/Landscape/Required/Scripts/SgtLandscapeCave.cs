using Unity.Mathematics;
using UnityEngine;
using Unity.Collections;
using Unity.Jobs;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component snaps a prefab to the surface of a planet and modifies its meshes to form a cave interior using background jobs.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Cave")]
	public class SgtLandscapeCave : MonoBehaviour
	{
		public enum ShapeType
		{
			Circle,
			Box
		}

		/// <summary>The prefab that will be spawned at the cave location.</summary>
		public GameObject Prefab { set { prefab = value; } get { return prefab; } } [SerializeField] private GameObject prefab;

		/// <summary>The meshes within the prefab that should be modified. These meshes should have an opening at the top (Y=0).</summary>
		public List<Mesh> DeformMeshes { get { if (deformMeshes == null) deformMeshes = new List<Mesh>(); return deformMeshes; } } [SerializeField] private List<Mesh> deformMeshes;

		/// <summary>The shape of the cave entrance.</summary>
		public ShapeType EntranceShape { set { entranceShape = value; } get { return entranceShape; } } [SerializeField] private ShapeType entranceShape;

		/// <summary>The radius of the cave entrance in local space.</summary>
		public float EntranceRadius { set { entranceRadius = value; } get { return entranceRadius; } } [SerializeField] private float entranceRadius = 1.0f;

		/// <summary>The size of the cave entrance in local space. This will be multiplied by EntranceRadius.</summary>
		public Vector3 EntranceSize { set { entranceSize = value; } get { return entranceSize; } } [SerializeField] private Vector3 entranceSize = new Vector3(1.0f, 5.0f, 1.0f);

		[System.NonSerialized] private SgtSphereLandscape parent;

		[System.NonSerialized] private SgtSphereLandscape.PendingPoints pendingData;

		[System.NonSerialized] private JobHandle pendingHandle;

		[System.NonSerialized] private bool started;

		[System.NonSerialized] private bool isGenerating;

		[System.NonSerialized] private NativeList<double3> spawnPoints;

		[System.NonSerialized] private GameObject clone;

		[System.NonSerialized] private double4x4 entranceMatrix;

		[System.NonSerialized] private List<MeshState> meshStates = new List<MeshState>();

		[System.NonSerialized] private double3    anchorPosition;
		[System.NonSerialized] private quaternion anchorRotation;
		[System.NonSerialized] private float3     anchorScale;

		private static List<MeshFilter> tempMeshFilters = new List<MeshFilter>();
		private static List<MeshCollider> tempMeshColliders = new List<MeshCollider>();

		private class MeshState
		{
			public Mesh      OriginalMesh;
			public Vector3[] OriginalVertices;
			public int       StartIndex;
		}

		public double4x4 EntranceMatrix
		{
			get
			{
				if (started == false)
				{
					GenerateNow();
				}

				if (isGenerating == true)
				{
					if (pendingHandle.IsCompleted == true)
					{
						CompleteGeneration();
					}
				}

				return entranceMatrix;
			}
		}

		public bool IsReady
		{
			get
			{
				return started == true && isGenerating == false;
			}
		}

		protected virtual void OnEnable()
		{
			parent = GetComponentInParent<SgtSphereLandscape>();

			if (parent != null)
			{
				parent.RegisterCave(this);
			}
		}

		protected virtual void OnDisable()
		{
			if (isGenerating == true)
			{
				pendingHandle.Complete();
				pendingData.Dispose();

				if (spawnPoints.IsCreated == true)
				{
					spawnPoints.Dispose();
				}
			}

			if (parent != null)
			{
				parent.UnregisterCave(this);
			}
		}

		public void PopulateDeformMeshes()
		{
			if (prefab != null)
			{
				if (deformMeshes == null)
				{
					deformMeshes = new List<Mesh>();
				}
				
				deformMeshes.Clear();

				var mfs = prefab.GetComponentsInChildren<MeshFilter>(true);

				foreach (var mf in mfs)
				{
					if (mf.sharedMesh != null && deformMeshes.Contains(mf.sharedMesh) == false)
					{
						deformMeshes.Add(mf.sharedMesh);
					}
				}
			}
		}

		private static double4x4 BuildEntranceProjection(double3 localPos, double3 right, double3 up, double3 forward, double3 localSize)
		{
			// Scale each axis by inverse size so that a point at the box boundary maps to Å}1
			var invSize = 1.0 / localSize;

			right   *= invSize.x;
			up      *= invSize.y;
			forward *= invSize.z;

			// Build a "view-like" matrix: projects world-local points into the box's normalized space
			return new double4x4(
				new double4(right.x,   up.x,   forward.x, 0),
				new double4(right.y,   up.y,   forward.y, 0),
				new double4(right.z,   up.z,   forward.z, 0),
				new double4(
					-math.dot(right,   localPos),
					-math.dot(up,      localPos),
					-math.dot(forward, localPos),
					1
				)
			);
		}

		public void GenerateNow()
		{
			if (parent != null && parent.IsActivated == true)
			{
				started      = true;
				isGenerating = true;

				var localPoint      = new double3(transform.localPosition);
				var surfacePoint    = parent.GetLocalPoint(localPoint);
				var surfaceUp       = math.normalize(parent.GetLocalDirection(localPoint));

				// Get the transform's local forward and project it onto the plane perpendicular to surfaceUp
				var transformRotation = (quaternion)transform.localRotation;
				var localForward = (double3)math.mul(transformRotation, new float3(0, 0, 1));

				var projectedForward = localForward - math.dot(localForward, surfaceUp) * surfaceUp;
				if (math.lengthsq(projectedForward) < 1e-10)
				{
					// Fallback: if forward is parallel to surfaceUp, use the transform's right to derive forward
					var localRight = (double3)math.mul(transformRotation, new float3(1, 0, 0));
					projectedForward = math.cross(surfaceUp, localRight);
				}
				projectedForward = math.normalize(projectedForward);

				// Build orthonormal basis: Y = surfaceUp, Z = projectedForward, X = right
				var right   = math.normalize(math.cross(surfaceUp, projectedForward));
				var up      = surfaceUp;
				var forward = projectedForward;

				var surfaceRotation = quaternion.LookRotationSafe((float3)forward, (float3)up);

				entranceMatrix = BuildEntranceProjection(surfacePoint, right, up, forward, new double3(entranceSize * entranceRadius));
				anchorPosition = surfacePoint;
				anchorRotation = surfaceRotation;
				anchorScale    = transform.localScale;

				transform.localPosition = (float3)surfacePoint;
				transform.localRotation = surfaceRotation;

				meshStates.Clear();
				var totalVertices = 0;

				foreach (var mesh in deformMeshes)
				{
					if (mesh != null)
					{
						var state = new MeshState();

						state.OriginalMesh     = mesh;
						state.OriginalVertices = mesh.vertices;
						state.StartIndex       = totalVertices;

						meshStates.Add(state);
						totalVertices += state.OriginalVertices.Length;
					}
				}

				spawnPoints = new NativeList<double3>(totalVertices, Allocator.Persistent);

				foreach (var state in meshStates)
				{
					for (var i = 0; i < state.OriginalVertices.Length; i++)
					{
						var scaled       = anchorScale * (double3)(float3)state.OriginalVertices[i];
						var rotated      = (double3)math.rotate(anchorRotation, (float3)scaled);
						var vertexParent = anchorPosition + rotated;

						spawnPoints.Add(vertexParent);
					}
				}

				pendingData   = parent.SchedulePoints(spawnPoints);
				pendingHandle = pendingData.Handle;
			}
		}

		private void CompleteGeneration()
		{
			isGenerating = false;
			pendingHandle.Complete();

			if (prefab != null)
			{
				clone = Instantiate(prefab);

				clone.GetComponentsInChildren(tempMeshFilters);
				clone.GetComponentsInChildren(tempMeshColliders);

				var inverseRotation = math.inverse(anchorRotation);
				var inverseScale    = 1.0f / anchorScale;

				foreach (var state in meshStates)
				{
					var modifiedVertices = new Vector3[state.OriginalVertices.Length];

					for (var i = 0; i < state.OriginalVertices.Length; i++)
					{
						var jobIndex    = state.StartIndex + i;
						var position    = pendingData.Points[jobIndex] + pendingData.Directions[jobIndex] * pendingData.Heights[jobIndex];
						var relativePos = position - anchorPosition;
						var rotatedBack = (double3)math.rotate(inverseRotation, (float3)relativePos);
						var anchorLocal = rotatedBack * inverseScale;

						modifiedVertices[i]    = state.OriginalVertices[i];
						modifiedVertices[i].y += (float)anchorLocal.y;
					}

					var newMesh = Instantiate(state.OriginalMesh);

					newMesh.name     = state.OriginalMesh.name + " (Generated Cave)";
					newMesh.vertices = modifiedVertices;

					newMesh.RecalculateBounds();

					foreach (var mf in tempMeshFilters)
					{
						if (mf.sharedMesh == state.OriginalMesh)
						{
							mf.sharedMesh = newMesh;
						}
					}

					foreach (var mc in tempMeshColliders)
					{
						if (mc.sharedMesh == state.OriginalMesh)
						{
							mc.sharedMesh = newMesh;
						}
					}
				}

				tempMeshFilters.Clear();
				tempMeshColliders.Clear();

				parent.AddChild(clone.transform, anchorPosition, anchorRotation, anchorScale);
			}

			pendingData.Dispose();

			if (spawnPoints.IsCreated == true)
			{
				spawnPoints.Dispose();
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			Gizmos.color = Color.cyan;

			Gizmos.matrix = transform.localToWorldMatrix * Matrix4x4.Scale(entranceSize * entranceRadius);

			if (entranceShape == ShapeType.Circle) Gizmos.DrawWireSphere(Vector3.zero,               1.0f);
			if (entranceShape == ShapeType.Box   ) Gizmos.DrawWireCube  (Vector3.zero, Vector3.one * 2.0f);
		}
#endif
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtLandscapeCave))]
	public class SgtLandscapeCave_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtLandscapeCave tgt; SgtLandscapeCave[] tgts; GetTargets(out tgt, out tgts);

			Draw("entranceShape", "The shape of the cave entrance.");
			Draw("entranceRadius", "The radius of the cave entrance in local space.");
			Draw("entranceSize", "The size of the cave entrance in local space. This will be multiplied by EntranceRadius.");

			Separator();

			Draw("prefab", "The prefab that will be spawned at the cave location.");
			Draw("deformMeshes", "The meshes within the prefab that should be modified. These meshes should have an opening at the top (Y=0).");

			if (Any(tgts, t => t.Prefab != null) && Button("Populate from Prefab") == true)
			{
				foreach (var t in tgts)
				{
					t.PopulateDeformMeshes();
					UnityEditor.EditorUtility.SetDirty(t);
				}
			}
		}
	}
}
#endif