using Unity.Mathematics;
using UnityEngine;
using System.Collections.Generic;
using Unity.Collections;
using Unity.Jobs;
using Unity.Burst;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component renders landscape details using GPU instancing and handles high-detail prefab swapping with dithered crossfading.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Static Spawner")]
	public class SgtLandscapeStaticSpawner : SgtLandscapeSpawner
	{
		private class Batch
		{
			public MaterialPropertyBlock Properties = new MaterialPropertyBlock();
			public int                  Count;
			public Bounds               Bounds;
			public static Stack<Batch>  Pool = new Stack<Batch>();
		}

		private class TileData : System.IDisposable
		{
			public List<Matrix4x4> Matrices;
			public float3[]        Positions;
			public quaternion[]    Rotations;
			public float3[]        Scales;
			public GameObject[]    SpawnedPrefabs;

			public void Dispose()
			{
				if (SpawnedPrefabs != null)
				{
					for (var i = 0; i < SpawnedPrefabs.Length; i++)
					{
						if (SpawnedPrefabs[i] != null)
						{
							if (Application.isPlaying == true) Destroy(SpawnedPrefabs[i]);
							else DestroyImmediate(SpawnedPrefabs[i]);
						}
					}
				}
			}
		}

		[BurstCompile]
		private struct DistanceCheckJob : IJobParallelFor
		{
			[ReadOnly] public NativeArray<float3> Positions;
			public float3 ObserverLocalPosition;
			public float  RangeSq;
			public NativeArray<bool> Results;

			public void Execute(int index) => Results[index] = math.distancesq(Positions[index], ObserverLocalPosition) <= RangeSq;
		}

		/// <summary>The mesh that will be rendered.</summary>
		public Mesh StaticMesh { set { staticMesh = value; } get { return staticMesh; } } [SerializeField] private Mesh staticMesh;

		/// <summary>The material that will be rendered.
		/// NOTE: This must use the <b>SGT / Landscape Static</b> material.</summary>
		public Material StaticMaterial { set { staticMaterial = value; } get { return staticMaterial; } } [SerializeField] private Material staticMaterial;

		/// <summary>The prefab to spawn when in range.</summary>
		public GameObject SwapPrefab { set { swapPrefab = value; } get { return swapPrefab; } } [SerializeField] private GameObject swapPrefab;

		/// <summary>The range in meters to replace the instance with a prefab.</summary>
		public float SwapRange { set { swapRange = value; } get { return swapRange; } } [SerializeField] private float swapRange = 10.0f;

		/// <summary>The distance over which the crossfade occurs.</summary>
		public float SwapFalloff { set { swapFalloff = value; } get { return swapFalloff; } } [SerializeField] private float swapFalloff = 2.0f;

		[System.NonSerialized] private Dictionary<Tile, TileData> tileData = new Dictionary<Tile, TileData>();
		[System.NonSerialized] private List<TileData> activeTiles = new List<TileData>();
		[System.NonSerialized] private List<Batch> batches = new List<Batch>();

		[System.NonSerialized] private NativeArray<float3> jobPositions;
		[System.NonSerialized] private NativeArray<bool>   jobResults;
		[System.NonSerialized] private JobHandle           jobHandle;
		[System.NonSerialized] private bool                jobRunning;
		[System.NonSerialized] private bool                positionsDirty;

		private static readonly int _SGT_ObjectToWorld = Shader.PropertyToID("_SGT_ObjectToWorld");
		private static readonly int _SGT_WorldToObject = Shader.PropertyToID("_SGT_WorldToObject");
		private static readonly int _SGT_LocalToGlobal = Shader.PropertyToID("_SGT_LocalToGlobal");
		private static readonly int _SGT_GlobalToLocal = Shader.PropertyToID("_SGT_GlobalToLocal");
		private static readonly int _SGT_ImpostorData  = Shader.PropertyToID("_SGT_ImpostorData");

		private static Matrix4x4[]    tempLocalToGlobal = new Matrix4x4[128];
		private static Matrix4x4[]    tempGlobalToLocal = new Matrix4x4[128];
		private static Vector4[]      tempImpostorData  = new Vector4[128];
		private static List<Renderer> tempRenderers     = new List<Renderer>();
		private static MaterialPropertyBlock tempProperties;

		private bool staticDirty;

		public void MarkStaticDirty()
		{
			staticDirty = true;
		}

		protected virtual void LateUpdate()
		{
			UpdateJobs();

			if (staticDirty == true) RebuildBatches();

			if (staticMesh == null || staticMaterial == null) return;

			var mat = transform.localToWorldMatrix;
			var inv = transform.worldToLocalMatrix;

			foreach (var batch in batches)
			{
				if (batch.Count > 0)
				{
					batch.Properties.SetMatrix(_SGT_ObjectToWorld, mat);
					batch.Properties.SetMatrix(_SGT_WorldToObject, inv);
					Graphics.DrawMeshInstancedProcedural(staticMesh, 0, staticMaterial, TransformBounds(transform, batch.Bounds), batch.Count, batch.Properties);
				}
			}
		}

		private void CompleteJob()
		{
			if (jobRunning == true)
			{
				jobHandle.Complete();
				jobRunning = false;
				ProcessJobResults();
			}
		}

		private void ProcessJobResults()
		{
			var invFalloff   = 1.0f / Mathf.Max(swapFalloff, 0.001f);
			var impostorData = new Vector4(0.0f, swapRange, invFalloff, 1.0f);
			var resultIndex  = 0;

			foreach (var data in activeTiles)
			{
				for (var i = 0; i < data.Positions.Length; i++)
				{
					var shouldHave = jobResults[resultIndex++] == true && swapPrefab != null;

					if (shouldHave == true && data.SpawnedPrefabs[i] == null)
					{
						var clone = Instantiate(swapPrefab, transform.TransformPoint(data.Positions[i]), transform.rotation * data.Rotations[i], transform);

						clone.transform.localScale = Vector3.Scale(transform.lossyScale, data.Scales[i]);

						clone.GetComponentsInChildren(true, tempRenderers);

						foreach (var r in tempRenderers)
						{
							r.GetPropertyBlock(tempProperties);

							tempProperties.SetVector(_SGT_ImpostorData, impostorData);

							r.SetPropertyBlock(tempProperties);
						}

						data.SpawnedPrefabs[i] = clone;

						staticDirty = true;
					}
					else if (shouldHave == false && data.SpawnedPrefabs[i] != null)
					{
						if (Application.isPlaying == true) Destroy(data.SpawnedPrefabs[i]); else DestroyImmediate(data.SpawnedPrefabs[i]);

						data.SpawnedPrefabs[i] = null;

						staticDirty = true;
					}
				}
			}
		}

		private void RebuildJobArrays()
		{
			if (jobPositions.IsCreated == true) jobPositions.Dispose();
			if (jobResults.IsCreated == true) jobResults.Dispose();

			var totalCount = 0;
			
			foreach (var data in activeTiles)
			{
				totalCount += data.Positions.Length;
			}

			if (totalCount > 0)
			{
				jobPositions = new NativeArray<float3>(totalCount, Allocator.Persistent);
				jobResults   = new NativeArray<bool>(totalCount, Allocator.Persistent);

				var index = 0;
				foreach (var data in activeTiles)
				{
					for (var i = 0; i < data.Positions.Length; i++)
					{
						jobPositions[index++] = data.Positions[i];
					}
				}
			}

			positionsDirty = false;
		}

		private void UpdateJobs()
		{
			if (jobRunning == true && jobHandle.IsCompleted == true)
			{
				CompleteJob();
			}

			if (jobRunning == false && swapPrefab != null)
			{
				if (positionsDirty == true)
				{
					RebuildJobArrays();
				}

				if (jobPositions.IsCreated == true && jobPositions.Length > 0)
				{
					var camPos   = Camera.main != null ? (float3)Camera.main.transform.position : float3.zero;
					var localPos = (float3)transform.InverseTransformPoint(camPos);
					var scale    = transform.lossyScale.x;
					var rangeSq  = (swapRange / scale) * (swapRange / scale);

					jobHandle  = new DistanceCheckJob { Positions = jobPositions, ObserverLocalPosition = localPos, RangeSq = rangeSq, Results = jobResults }.Schedule(jobPositions.Length, 64);
					jobRunning = true;
				}
			}
		}

		protected override void HandleSpawn(Tile tile, NativeList<float3> pos, NativeList<quaternion> rot, NativeList<float3> scale)
		{
			CompleteJob();

			var data = new TileData
				{
					Matrices = new List<Matrix4x4>(tile.spawnCount),
					Positions = new float3[tile.spawnCount],
					Rotations = new quaternion[tile.spawnCount],
					Scales = new float3[tile.spawnCount],
					SpawnedPrefabs = new GameObject[tile.spawnCount]
				};

			for (var i = 0; i < tile.spawnCount; i++)
				{
					var idx = tile.spawnIndex + i;
					data.Positions[i] = pos[idx];
					data.Rotations[i] = rot[idx];
					data.Scales[i]    = scale[idx];
					data.Matrices.Add(Matrix4x4.TRS(pos[idx], rot[idx], scale[idx]));
				}

			tileData[tile] = data;
			activeTiles.Add(data);

			staticDirty = true;
			positionsDirty = true;
		}

		protected override void HandleDespawn(Tile tile)
		{
			if (tileData.TryGetValue(tile, out var data) == true)
			{
				CompleteJob();

				data.Dispose();

				tileData.Remove(tile);
				activeTiles.Remove(data);

				staticDirty = true;
				positionsDirty = true;
			}
		}

		private void RebuildBatches()
		{
			ClearBatches();
			var currentBatch = default(Batch);
			var invFalloff   = 1.0f / Mathf.Max(swapFalloff, 0.001f);

			foreach (var data in activeTiles)
			{
				for (var i = 0; i < data.Matrices.Count; i++)
				{
					if (currentBatch == null || currentBatch.Count >= 128)
					{
						if (currentBatch != null) PushBatchData(currentBatch);
						currentBatch = AddBatch();
						currentBatch.Bounds = new Bounds(data.Matrices[i].GetColumn(3), Vector3.zero);
					}

					tempLocalToGlobal[currentBatch.Count] = data.Matrices[i];
					tempGlobalToLocal[currentBatch.Count] = data.Matrices[i].inverse;
					// Pack: y=range, z=invFalloff, w=crossfade (1 if prefab spawned)
					tempImpostorData[currentBatch.Count]  = new Vector4(0.0f, swapRange, invFalloff, data.SpawnedPrefabs[i] != null ? 1.0f : 0.0f);
					
					currentBatch.Bounds.Encapsulate((Vector3)data.Matrices[i].GetColumn(3));
					currentBatch.Count++;
				}
			}
			if (currentBatch != null) PushBatchData(currentBatch);
			staticDirty = false;
		}

		private void PushBatchData(Batch batch)
		{
			batch.Properties.SetMatrixArray(_SGT_LocalToGlobal, tempLocalToGlobal);
			batch.Properties.SetMatrixArray(_SGT_GlobalToLocal, tempGlobalToLocal);
			batch.Properties.SetVectorArray(_SGT_ImpostorData, tempImpostorData);
		}

		private void ClearBatches()
		{
			foreach (var batch in batches)
			{
				batch.Count = 0;
		
				Batch.Pool.Push(batch);
			}

			batches.Clear();
		}

		private Batch AddBatch()
		{
			var batch = Batch.Pool.Count > 0 ? Batch.Pool.Pop() : new Batch();

			batches.Add(batch);

			return batch;
		}

		private static Bounds TransformBounds(Transform t, Bounds b)
		{
			var center = t.TransformPoint(b.center);
			var extents = b.extents;

			// Calculate world-space axes scaled by extents
			var axisX = t.TransformVector(extents.x, 0, 0);
			var axisY = t.TransformVector(0, extents.y, 0);
			var axisZ = t.TransformVector(0, 0, extents.z);

			// Sum absolute components to find the new world-aligned bounding box size
			var newExtents = new Vector3(
				Mathf.Abs(axisX.x) + Mathf.Abs(axisY.x) + Mathf.Abs(axisZ.x),
				Mathf.Abs(axisX.y) + Mathf.Abs(axisY.y) + Mathf.Abs(axisZ.y),
				Mathf.Abs(axisX.z) + Mathf.Abs(axisY.z) + Mathf.Abs(axisZ.z)
			);

			return new Bounds { center = center, extents = newExtents };
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			if (tempProperties == null) tempProperties = new MaterialPropertyBlock();
		}

		protected override void OnDisable()
		{
			base.OnDisable();
			
			CompleteJob();

			if (jobPositions.IsCreated == true) jobPositions.Dispose();
			if (jobResults.IsCreated == true) jobResults.Dispose();

			foreach (var data in activeTiles)
			{
				data.Dispose();
			}

			tileData.Clear();
			activeTiles.Clear();
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtLandscapeStaticSpawner))]
	public class SgtLandscapeStaticSpawner_Editor : SgtLandscapeSpawner_Editor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			SgtLandscapeStaticSpawner tgt; SgtLandscapeStaticSpawner[] tgts; GetTargets(out tgt, out tgts);

			Separator();

			var markStaticDirty = false;

			BeginError(Any(tgts, t => t.StaticMesh == null));
				Draw("staticMesh", "The mesh that will be rendered.");
			EndError();

			BeginError(Any(tgts, t => t.StaticMaterial == null));
				Draw("staticMaterial", "The material that will be rendered.\n\nNOTE: This must use the <b>SGT / Landscape Static</b> material.");
			EndError();

			Separator();

			Draw("swapPrefab", "The prefab to spawn when in range.");
			Draw("swapRange", ref markStaticDirty, "The range in meters to replace the instance with a prefab.");
			Draw("swapFalloff", ref markStaticDirty, "The distance over which the crossfade occurs.");

			if (Any(tgts, t => t.SwapPrefab != null && t.StaticMesh == null && t.StaticMaterial == null))
			{
				if (Button("Bake Prefab") == true)
				{
					Each(tgts, t => TryBakePrefab(t), true, true);
				}
			}

			if (markStaticDirty == true) Each(tgts, t => t.MarkStaticDirty());
		}

		private void TryBakePrefab(SgtLandscapeStaticSpawner s)
		{
			if (s.SwapPrefab != null && s.StaticMesh == null && s.StaticMaterial == null)
			{
				var path = AssetDatabase.GetAssetPath(s.SwapPrefab);

				if (string.IsNullOrEmpty(path) == false)
				{
					var impostor = SgtLandscapeCrossImpostorBuilder_Editor.CreateImpostorAsset(s.SwapPrefab, path);

					SgtLandscapeCrossImpostorBuilder_Editor.Bake(impostor);

					s.StaticMesh     = impostor.BakedMesh;
					s.StaticMaterial = impostor.Material;
				}
				else
				{
					Debug.LogWarning("Failed to make impostor because SwapPrefab isn't a prefab.");
				}
			}
		}
	}
}
#endif