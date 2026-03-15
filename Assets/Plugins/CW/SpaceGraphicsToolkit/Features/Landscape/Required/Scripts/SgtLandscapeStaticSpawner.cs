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
		private const int BATCH_SIZE = 1000;

		private struct SuperTileKey : System.IEquatable<SuperTileKey>
		{
			public long u, v;
			public int  faceIndex;

			public bool Equals(SuperTileKey other) => u == other.u && v == other.v && faceIndex == other.faceIndex;
			public override int GetHashCode() => unchecked((int)((17 * 23 + u) * 23 + v) * 23 + faceIndex);
		}

		private class Batch
		{
			public MaterialPropertyBlock Properties = new MaterialPropertyBlock();
			public int                   Count;
			public Bounds                Bounds;
			public static Stack<Batch>   Pool = new Stack<Batch>();
		}

		private class PooledPrefab
		{
			public GameObject GameObject;
			public Renderer[] Renderers;
		}

		private class SuperTileData
		{
			public SuperTileKey                 Key;
			public double3                      BakedOffset;
			public List<TileData>               ActiveTiles = new List<TileData>();
			public List<Batch>                  Batches     = new List<Batch>();
			public Bounds                       Bounds;

			public NativeArray<double3>         JobPositions;
			public NativeArray<quaternion>      JobRotations;
			public NativeArray<float>           JobScales;
			public NativeArray<float>           JobSeeds;
			public NativeArray<int>             JobIDs;
			public NativeArray<byte>            JobIsSpawned;
			public NativeQueue<int>             JobChangedIndices;
			
			public NativeArray<float4>          JobDataA;
			public NativeArray<float4>          JobDataB;
			public NativeArray<float4>          JobDataC;

			public JobHandle                    JobHandle;
			public bool                         JobRunning;
			public bool                         PositionsDirty;
			public bool                         StaticDirty;

			public int                          CurrentCapacity;
			public int                          CurrentTotalCount;

			public static Stack<SuperTileData>  Pool = new Stack<SuperTileData>();

			public Batch AddBatch()
			{
				var batch = Batch.Pool.Count > 0 ? Batch.Pool.Pop() : new Batch();
				Batches.Add(batch);
				return batch;
			}

			public void ClearBatches()
			{
				foreach (var batch in Batches)
				{
					batch.Count = 0;
					Batch.Pool.Push(batch);
				}
				Batches.Clear();
			}

			public void AllocateArrays()
			{
				JobPositions      = new NativeArray<double3>(CurrentCapacity, Allocator.Persistent);
				JobRotations      = new NativeArray<quaternion>(CurrentCapacity, Allocator.Persistent);
				JobScales         = new NativeArray<float>(CurrentCapacity, Allocator.Persistent);
				JobSeeds          = new NativeArray<float>(CurrentCapacity, Allocator.Persistent);
				JobIDs            = new NativeArray<int>(CurrentCapacity, Allocator.Persistent);
				JobIsSpawned      = new NativeArray<byte>(CurrentCapacity, Allocator.Persistent);
				JobChangedIndices = new NativeQueue<int>(Allocator.Persistent);

				JobDataA          = new NativeArray<float4>(CurrentCapacity, Allocator.Persistent);
				JobDataB          = new NativeArray<float4>(CurrentCapacity, Allocator.Persistent);
				JobDataC          = new NativeArray<float4>(CurrentCapacity, Allocator.Persistent);
			}

			public void DisposeArrays()
			{
				if (JobPositions.IsCreated)      JobPositions.Dispose();
				if (JobRotations.IsCreated)      JobRotations.Dispose();
				if (JobScales.IsCreated)         JobScales.Dispose();
				if (JobSeeds.IsCreated)          JobSeeds.Dispose();
				if (JobIDs.IsCreated)            JobIDs.Dispose();
				if (JobIsSpawned.IsCreated)      JobIsSpawned.Dispose();
				if (JobChangedIndices.IsCreated) JobChangedIndices.Dispose();
				
				if (JobDataA.IsCreated)          JobDataA.Dispose();
				if (JobDataB.IsCreated)          JobDataB.Dispose();
				if (JobDataC.IsCreated)          JobDataC.Dispose();
				
				CurrentCapacity   = 0;
				CurrentTotalCount = 0;
			}

			public void Reset()
			{
				Key               = default(SuperTileKey);
				JobRunning        = false;
				PositionsDirty    = false;
				StaticDirty       = false;
				Bounds            = default(Bounds);
    
				ActiveTiles.Clear();
				ClearBatches();

				CurrentTotalCount = 0;
			}
		}

		private class TileData
		{
			public Tile                    Tile;
			public SuperTileData           SuperTile;
			public Bounds                  TileBounds;
			public int                     GlobalStartIndex;
			public float                   Opacity;
			public bool                    Despawning;
			public int                     Count;
			public long                    SortKey;
			public NativeArray<double3>    Positions;
			public NativeArray<quaternion> Rotations;
			public NativeArray<float>      Scales;
			public NativeArray<float>      Seeds;
			public NativeArray<int>        TileIDs;
			public NativeArray<byte>       IsSpawned;
			public PooledPrefab[]          SpawnedInstances;
			public List<int>               ActiveSpawnIndices = new List<int>();

			public void Allocate(int count)
			{
				Count = count;

				// Reuse if capacity is sufficient, otherwise dispose and reallocate
				if (!Positions.IsCreated || Positions.Length < count)
				{
					DisposeNative();

					Positions = new NativeArray<double3>(count, Allocator.Persistent);
					Rotations = new NativeArray<quaternion>(count, Allocator.Persistent);
					Scales    = new NativeArray<float>(count, Allocator.Persistent);
					Seeds     = new NativeArray<float>(count, Allocator.Persistent);
					TileIDs   = new NativeArray<int>(count, Allocator.Persistent);
					IsSpawned = new NativeArray<byte>(count, Allocator.Persistent);
				}

				// Managed arrays must match count exactly for indexing
				if (SpawnedInstances == null || SpawnedInstances.Length != count)
				{
					SpawnedInstances = new PooledPrefab[count];
				}
				else
				{
					System.Array.Clear(SpawnedInstances, 0, count);
				}
				
				ActiveSpawnIndices.Clear();
			}

			public void ComputeSortKey()
			{
				var c = (int3)math.round((float3)TileBounds.center / 200.0f);
				SortKey = ((long)(c.x + 16384) << 30) | ((long)(c.y + 16384) << 15) | (long)(c.z + 16384);
			}

			public void ClearSpawns(Stack<PooledPrefab> pool)
			{
				if (SpawnedInstances != null)
				{
					for (var i = 0; i < ActiveSpawnIndices.Count; i++)
					{
						int idx = ActiveSpawnIndices[i];
						var instance = SpawnedInstances[idx];

						if (instance != null)
						{
							if (instance.GameObject != null)
							{
								instance.GameObject.SetActive(false);
								pool.Push(instance);
							}
							SpawnedInstances[idx] = null;
						}
						
						IsSpawned[idx] = 0;
					}
					ActiveSpawnIndices.Clear();
				}
			}

			public void DisposeNative()
			{
				if (Positions.IsCreated) Positions.Dispose();
				if (Rotations.IsCreated) Rotations.Dispose();
				if (Scales.IsCreated)    Scales.Dispose();
				if (Seeds.IsCreated)     Seeds.Dispose();
				if (TileIDs.IsCreated)   TileIDs.Dispose();
				if (IsSpawned.IsCreated) IsSpawned.Dispose();
			}

			public void Dispose()
			{
				// Prefab cleanup is now handled by object pooling in the spawner
				DisposeNative();
			}

			public void Reset()
			{
				Tile               = default(Tile);
				SuperTile          = null;
				TileBounds         = default;
				GlobalStartIndex   = 0;
				Opacity            = 0.0f;
				Despawning         = false;
				Count              = 0;
				SortKey            = 0;
				SpawnedInstances   = null;
				ActiveSpawnIndices.Clear();
			}

			public static Stack<TileData> Pool = new Stack<TileData>();
		}

		private class TileDataComparer : IComparer<TileData>
		{
			public static readonly TileDataComparer Instance = new TileDataComparer();
			public int Compare(TileData a, TileData b) { return a.SortKey.CompareTo(b.SortKey); }
		}

		[BurstCompile]
		private struct EvaluateStateJob : IJobParallelFor
		{
			[ReadOnly]  public NativeArray<double3>  Positions;
			[ReadOnly]  public NativeArray<byte>     IsSpawned;
			public double3                           ObserverLocalPosition;
			public double                            SpawnRangeSq;
			public double                            DespawnRangeSq;
			public bool                              HasSwapPrefab;

			[WriteOnly] public NativeQueue<int>.ParallelWriter ChangedIndices;

			public void Execute(int index)
			{
				var distSq     = math.distancesq(Positions[index], ObserverLocalPosition);
				var isSpawned  = IsSpawned[index] != 0;
				var shouldHave = HasSwapPrefab && (isSpawned ? distSq < DespawnRangeSq : distSq < SpawnRangeSq);

				if (shouldHave != isSpawned)
				{
					ChangedIndices.Enqueue(index);
				}
			}
		}

		[BurstCompile]
		private struct BuildMatricesJob : IJobParallelFor
		{
			[ReadOnly] public double3                 SpawnOffset;
			[ReadOnly] public NativeArray<double3>    Positions;
			[ReadOnly] public NativeArray<quaternion> Rotations;
			[ReadOnly] public NativeArray<float>      Scales;
			[ReadOnly] public NativeArray<float>      Seeds;
			[ReadOnly] public NativeArray<int>        TileIDs;
			[ReadOnly] public NativeArray<byte>       IsSpawned;

			[WriteOnly] public NativeArray<float4> DataA;
			[WriteOnly] public NativeArray<float4> DataB;
			[WriteOnly] public NativeArray<float4> DataC;

			public void Execute(int i)
			{
				var t = (float3)(Positions[i] - SpawnOffset);

				var packedW = IsSpawned[i] == 1 ? -1.0f : 1.0f;

				DataA[i] = new float4(t, Scales[i]);
				DataB[i] = new float4(Rotations[i].value);
				DataC[i] = new float4(Seeds[i], TileIDs[i], 0.0f, packedW);
			}
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

		/// <summary>The speed at which tiles fade in and out when spawning/despawning.</summary>
		public float FadeSpeed { set { fadeSpeed = value; } get { return fadeSpeed; } } [SerializeField] private float fadeSpeed = 2.0f;

		[System.NonSerialized] private Dictionary<SuperTileKey, SuperTileData> superTiles       = new Dictionary<SuperTileKey, SuperTileData>();
		[System.NonSerialized] private List<SuperTileData>                     activeSuperTiles = new List<SuperTileData>();
		[System.NonSerialized] private Dictionary<Tile, TileData>              tileDataMap      = new Dictionary<Tile, TileData>();
		[System.NonSerialized] private Stack<PooledPrefab>                     prefabPool       = new Stack<PooledPrefab>();

		[System.NonSerialized] private Vector4[] tileOpacities = new Vector4[256];

		[System.NonSerialized] private int     superTileSize = 1;

		private static readonly int _SGT_TileOpacities = Shader.PropertyToID("_SGT_TileOpacities");
		private static readonly int _SGT_ObjectToWorld = Shader.PropertyToID("_SGT_ObjectToWorld");
		private static readonly int _SGT_ImpostorDataA = Shader.PropertyToID("_SGT_ImpostorDataA");
		private static readonly int _SGT_ImpostorDataB = Shader.PropertyToID("_SGT_ImpostorDataB");
		private static readonly int _SGT_ImpostorDataC = Shader.PropertyToID("_SGT_ImpostorDataC");
		private static readonly int _SGT_SwapData      = Shader.PropertyToID("_SGT_SwapData");

		private static Vector4[]      tempDataA     = new Vector4[BATCH_SIZE];
		private static Vector4[]      tempDataB     = new Vector4[BATCH_SIZE];
		private static Vector4[]      tempDataC     = new Vector4[BATCH_SIZE];
		private static List<Renderer> tempRenderers = new List<Renderer>();
		private static MaterialPropertyBlock tempProperties;

		public void MarkStaticDirty()
		{
			foreach (var stData in activeSuperTiles)
			{
				stData.StaticDirty = true;
			}
		}

		private void UpdateFading()
		{
			if (activeSuperTiles.Count == 0 || fadeSpeed <= 0.0f) return;

			var delta = fadeSpeed * Time.deltaTime;

			for (int s = activeSuperTiles.Count - 1; s >= 0; s--)
			{
				var stData = activeSuperTiles[s];

				for (var i = stData.ActiveTiles.Count - 1; i >= 0; i--)
				{
					var data = stData.ActiveTiles[i];

					if (data.Despawning)
					{
						data.Opacity -= delta;

						if (data.Opacity <= 0.0f)
						{
							CompleteJob(stData);
							tileDataMap.Remove(data.Tile);
							stData.ActiveTiles.RemoveAt(i);
							ReturnTileData(data);
							stData.PositionsDirty = true;
							continue;
						}
					}
					else if (data.Opacity < 1.0f)
					{
						data.Opacity = Mathf.Min(1.0f, data.Opacity + delta);
					}

					WriteTileOpacity(data.Tile.id, data.Opacity);
				}

				// Pool the SuperTile if empty
				if (stData.ActiveTiles.Count == 0)
				{
					activeSuperTiles.RemoveAt(s);
					superTiles.Remove(stData.Key);
					stData.Reset();
					SuperTileData.Pool.Push(stData);
				}
			}
		}

		private void WriteTileOpacity(int index, float opacity)
		{
			var packedIndex = index >> 2;
			var component   = index & 3;

			var v = tileOpacities[packedIndex];

			v[component] = opacity;

			tileOpacities[packedIndex] = v;
		}

		private void CompleteJob(SuperTileData stData)
		{
			if (stData.JobRunning == true)
			{
				stData.JobHandle.Complete();
				stData.JobRunning = false;
				ProcessJobResults(stData);
			}
		}

		private void ProcessJobResults(SuperTileData stData)
		{
			if (stData.JobChangedIndices.IsCreated == false) return;

			var changedSpawn = false;

			while (stData.JobChangedIndices.TryDequeue(out int globalIndex))
			{
				TileData data = null;

				// Binary search for corresponding TileData using GlobalStartIndex
				int lo = 0;
				int hi = stData.ActiveTiles.Count - 1;

				while (lo <= hi)
				{
					int mid = (lo + hi) / 2;
					var td = stData.ActiveTiles[mid];
					int end = td.GlobalStartIndex + td.Count;

					if (globalIndex >= td.GlobalStartIndex && globalIndex < end)
					{
						data = td;
						break;
					}
					
					if (globalIndex < td.GlobalStartIndex) hi = mid - 1;
					else lo = mid + 1;
				}

				if (data == null) continue;

				int localIndex = globalIndex - data.GlobalStartIndex;
				bool isSpawned = data.IsSpawned[localIndex] != 0;

				if (isSpawned == false)
				{
					PooledPrefab instance;

					if (prefabPool.Count > 0)
					{
						instance = prefabPool.Pop();
						if (instance.GameObject != null) instance.GameObject.SetActive(true);
					}
					else
					{
						var clone = Instantiate(swapPrefab);
						clone.GetComponentsInChildren(true, tempRenderers);
						instance = new PooledPrefab { GameObject = clone, Renderers = tempRenderers.ToArray() };
					}

					if (instance.GameObject != null)
					{
						var pos = data.Positions[localIndex];
						var rot = data.Rotations[localIndex];
						var sca = swapPrefab.transform.localScale * data.Scales[localIndex];

						parent.AddChild(instance.GameObject.transform, pos, rot, sca);

						foreach (var r in instance.Renderers)
						{
							if (r == null) continue;
							r.GetPropertyBlock(tempProperties);
							tempProperties.SetVector(_SGT_ImpostorDataC, new Vector4(data.Seeds[localIndex], data.Tile.id, 0.0f, 1.0f));
							tempProperties.SetVector(_SGT_SwapData, new Vector4(swapRange, 1.0f / Mathf.Max(swapFalloff, 0.001f)));
							r.SetPropertyBlock(tempProperties);
						}
					}

					data.SpawnedInstances[localIndex] = instance;
					data.IsSpawned[localIndex]        = 1;
					stData.JobIsSpawned[globalIndex]  = 1;
					
					data.ActiveSpawnIndices.Add(localIndex);
					changedSpawn = true;
				}
				else
				{
					var instance = data.SpawnedInstances[localIndex];
					if (instance != null)
					{
						if (instance.GameObject != null)
						{
							instance.GameObject.SetActive(false);
							prefabPool.Push(instance);
						}
						data.SpawnedInstances[localIndex] = null;
					}

					data.IsSpawned[localIndex]       = 0;
					stData.JobIsSpawned[globalIndex] = 0;

					// O(1) Remove from Active list
					int listIndex = data.ActiveSpawnIndices.IndexOf(localIndex);
					if (listIndex >= 0)
					{
						data.ActiveSpawnIndices[listIndex] = data.ActiveSpawnIndices[data.ActiveSpawnIndices.Count - 1];
						data.ActiveSpawnIndices.RemoveAt(data.ActiveSpawnIndices.Count - 1);
					}
					
					changedSpawn = true;
				}
			}

			if (changedSpawn) stData.StaticDirty = true;
		}

		private void RebuildJobArrays(SuperTileData stData)
		{
			var totalCount = 0;
			foreach (var data in stData.ActiveTiles) totalCount += data.Count;

			if (totalCount == 0)
			{
				stData.CurrentTotalCount = 0;
				stData.PositionsDirty    = false;
				return;
			}

			// Only reallocate if the current pool is too small
			if (totalCount > stData.CurrentCapacity)
			{
				stData.DisposeArrays();
				stData.CurrentCapacity = Mathf.Max(1024, Mathf.NextPowerOfTwo(totalCount));
				stData.AllocateArrays();
			}

			stData.CurrentTotalCount = totalCount;

			// Bulk copy via NativeArray sub-array slicing - no per-instance loops
			var index = 0;
			foreach (var data in stData.ActiveTiles)
			{
				data.GlobalStartIndex = index;
				var count = data.Count;

				if (count > 0)
				{
					NativeArray<double3>.Copy(data.Positions, 0, stData.JobPositions, index, count);
					NativeArray<quaternion>.Copy(data.Rotations, 0, stData.JobRotations, index, count);
					NativeArray<float>.Copy(data.Scales, 0, stData.JobScales, index, count);
					NativeArray<float>.Copy(data.Seeds, 0, stData.JobSeeds, index, count);
					NativeArray<int>.Copy(data.TileIDs, 0, stData.JobIDs, index, count);
					NativeArray<byte>.Copy(data.IsSpawned, 0, stData.JobIsSpawned, index, count);
				}

				index += count;
			}

			stData.PositionsDirty = false;
			stData.StaticDirty    = true;
		}

		private void UpdateJobs(SuperTileData stData)
		{
			if (stData.JobRunning == true && stData.JobHandle.IsCompleted == true)
			{
				CompleteJob(stData);
			}

			if (stData.JobRunning == false && swapPrefab != null)
			{
				if (stData.PositionsDirty == true) RebuildJobArrays(stData);

				// Use currentTotalCount instead of JobPositions.Length because of over-allocation
				if (stData.CurrentTotalCount > 0)
				{
					var camPos         = Camera.main != null ? (float3)Camera.main.transform.position : float3.zero;
					var localPos       = (float3)transform.InverseTransformPoint(camPos);
					var scale          = transform.lossyScale.x;
					var spawnRangeSq   = (swapRange / scale) * (swapRange / scale);
					var despawnRangeSq = ((swapRange + swapFalloff * 0.1f) / scale) * ((swapRange + swapFalloff * 0.1f) / scale);

					stData.JobChangedIndices.Clear();

					stData.JobHandle  = new EvaluateStateJob { 
						Positions             = stData.JobPositions,
						IsSpawned             = stData.JobIsSpawned,
						ObserverLocalPosition = localPos, 
						SpawnRangeSq          = spawnRangeSq,
						DespawnRangeSq        = despawnRangeSq,
						HasSwapPrefab         = swapPrefab != null,
						ChangedIndices        = stData.JobChangedIndices.AsParallelWriter() 
					}.Schedule(stData.CurrentTotalCount, 64);
			
					stData.JobRunning = true;
				}
			}
		}

		private TileData GetTileData()
		{
			return TileData.Pool.Count > 0 ? TileData.Pool.Pop() : new TileData();
		}

		private void ReturnTileData(TileData data)
		{
			data.ClearSpawns(prefabPool);
			data.Reset();
			TileData.Pool.Push(data);
		}

		/// <summary>Binary search insert into a sorted list by precomputed sort key.</summary>
		private void InsertSorted(SuperTileData stData, TileData data)
		{
			var lo = 0;
			var hi = stData.ActiveTiles.Count;

			while (lo < hi)
			{
				var mid = (lo + hi) >> 1;
				if (stData.ActiveTiles[mid].SortKey <= data.SortKey) lo = mid + 1;
				else hi = mid;
			}

			stData.ActiveTiles.Insert(lo, data);
		}

		protected override void HandleSpawn(Tile tile, NativeList<double3> positions, NativeList<quaternion> rotations, NativeList<float> scales, NativeList<float> seeds, NativeList<int> tileIDs)
		{
			// Find or create SuperTile mapping
			long su = tile.u / superTileSize;
			long sv = tile.v / superTileSize;
			var stKey = new SuperTileKey { u = su, v = sv, faceIndex = tile.faceIndex };

			if (superTiles.TryGetValue(stKey, out var stData) == false)
			{
				stData     = SuperTileData.Pool.Count > 0 ? SuperTileData.Pool.Pop() : new SuperTileData();
				stData.Key = stKey;
				superTiles[stKey] = stData;
				activeSuperTiles.Add(stData);
			}

			CompleteJob(stData);

			if (tileDataMap.TryGetValue(tile, out var existingData) == true)
			{
				existingData.Despawning = false;
				return;
			}

			var count = tile.spawnCount;
			var data  = GetTileData();

			data.Tile       = tile;
			data.SuperTile  = stData;
			data.Opacity    = 0.0f;
			data.Despawning = false;

			data.Allocate(count);

			if (count > 0)
			{
				data.TileBounds.SetMinMax((float3)tile.localMin, (float3)tile.localMax);

				var src = tile.spawnIndex;

				NativeArray<double3>   .Copy(positions.AsArray(), src, data.Positions, 0, count);
				NativeArray<quaternion>.Copy(rotations.AsArray(), src, data.Rotations, 0, count);
				NativeArray<float>     .Copy(   scales.AsArray(), src, data.Scales   , 0, count);
				NativeArray<float>     .Copy(    seeds.AsArray(), src, data.Seeds    , 0, count);
				NativeArray<int>       .Copy(  tileIDs.AsArray(), src, data.TileIDs  , 0, count);
			}

			data.ComputeSortKey();

			tileDataMap[tile] = data;
			InsertSorted(stData, data);

			stData.StaticDirty    = true;
			stData.PositionsDirty = true;
		}

		protected override void HandleDespawn(Tile tile)
		{
			if (tileDataMap.TryGetValue(tile, out var data) == true)
			{
				CompleteJob(data.SuperTile);
				data.Despawning = true;
			}
		}

		private void RebuildBatches(SuperTileData stData)
		{
			if (stData.CurrentTotalCount == 0 || stData.JobDataA.IsCreated == false)
			{
				stData.ClearBatches();
				stData.StaticDirty = false;
				return;
			}

			stData.BakedOffset = parent.SpawnOffset;

			// Schedule only for the active count within this SuperTile
			new BuildMatricesJob {
				SpawnOffset   = stData.BakedOffset,
				Positions     = stData.JobPositions,
				Rotations     = stData.JobRotations,
				Scales        = stData.JobScales,
				Seeds         = stData.JobSeeds,
				TileIDs       = stData.JobIDs,
				IsSpawned     = stData.JobIsSpawned,
				DataA         = stData.JobDataA,
				DataB         = stData.JobDataB,
				DataC         = stData.JobDataC
			}.Schedule(stData.CurrentTotalCount, 64).Complete();

			stData.ClearBatches();
			stData.Bounds = default(Bounds);
			bool boundsSet = false;

			Batch currentBatch = null;

			foreach (var data in stData.ActiveTiles)
			{
				int instancesLeft = data.Count;
				
				while (instancesLeft > 0)
				{
					if (currentBatch == null || currentBatch.Count >= BATCH_SIZE)
					{
						currentBatch = stData.AddBatch();
						currentBatch.Bounds = data.TileBounds;
					}
					else
					{
						currentBatch.Bounds.Encapsulate(data.TileBounds);
					}

					if (!boundsSet) { stData.Bounds = data.TileBounds; boundsSet = true; }
					else stData.Bounds.Encapsulate(data.TileBounds);

					int space = BATCH_SIZE - currentBatch.Count;
					int toAdd = Mathf.Min(space, instancesLeft);

					currentBatch.Count += toAdd;
					instancesLeft -= toAdd;
				}
			}

			var offset = 0;

			foreach (var batch in stData.Batches)
			{
				if (batch.Count > 0)
				{
					var sliceA = stData.JobDataA.GetSubArray(offset, batch.Count).Reinterpret<Vector4>();
					var sliceB = stData.JobDataB.GetSubArray(offset, batch.Count).Reinterpret<Vector4>();
					var sliceC = stData.JobDataC.GetSubArray(offset, batch.Count).Reinterpret<Vector4>();

					NativeArray<Vector4>.Copy(sliceA, 0, tempDataA, 0, batch.Count);
					NativeArray<Vector4>.Copy(sliceB, 0, tempDataB, 0, batch.Count);
					NativeArray<Vector4>.Copy(sliceC, 0, tempDataC, 0, batch.Count);

					batch.Properties.SetVectorArray(_SGT_ImpostorDataA, tempDataA);
					batch.Properties.SetVectorArray(_SGT_ImpostorDataB, tempDataB);
					batch.Properties.SetVectorArray(_SGT_ImpostorDataC, tempDataC);
					batch.Properties.SetVector(_SGT_SwapData, new Vector4(swapRange, 1.0f / Mathf.Max(swapFalloff, 0.001f)));

					offset += batch.Count;
				}
			}

			stData.StaticDirty = false;
		}

		// FIXED: Refactored to accept the actual calculated Matrix4x4 instead of the raw Anchor Transform
		private static Bounds TransformBounds(Matrix4x4 mat, Bounds b)
		{
			var center  = mat.MultiplyPoint3x4(b.center);
			var extents = b.extents;
			var axisX   = mat.MultiplyVector(new Vector3(extents.x, 0, 0));
			var axisY   = mat.MultiplyVector(new Vector3(0, extents.y, 0));
			var axisZ   = mat.MultiplyVector(new Vector3(0, 0, extents.z));

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

			// Group into dynamically sized SuperTiles to optimize total instance batch limits
			int maxSpawn = GetApproximateMaximumSpawnCountPerTile();
			if (maxSpawn < 1) maxSpawn = 1;

			// Target roughly 1024 spawns per super tile. We group in 2D grid so we take square root
			superTileSize = Mathf.Max(1, Mathf.FloorToInt(Mathf.Sqrt(1024.0f / maxSpawn)));

			if (tempProperties == null) tempProperties = new MaterialPropertyBlock();
		}

		private void ClearPrefabPool()
		{
			foreach (var instance in prefabPool)
			{
				if (instance != null && instance.GameObject != null)
				{
					if (Application.isPlaying) Destroy(instance.GameObject);
					else DestroyImmediate(instance.GameObject);
				}
			}
			prefabPool.Clear();
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			foreach (var stData in activeSuperTiles)
			{
				CompleteJob(stData);
				stData.DisposeArrays();
				foreach (var data in stData.ActiveTiles)
				{
					data.ClearSpawns(prefabPool);
					data.Dispose();
				}

				stData.Reset(); 
				SuperTileData.Pool.Push(stData);
			}

			tileDataMap.Clear();
			activeSuperTiles.Clear();
			superTiles.Clear();
			ClearPrefabPool();
		}

		protected virtual void LateUpdate()
		{
			UpdateFading();

			foreach (var stData in activeSuperTiles)
			{
				if (stData.PositionsDirty) RebuildJobArrays(stData);
				
				UpdateJobs(stData);

				if (stData.StaticDirty == true) RebuildBatches(stData);
			}

			if (staticMesh == null || staticMaterial == null) return;

			var targetTransform = parent.GetSpawnAnchor();
			var l2w             = targetTransform.localToWorldMatrix;

			foreach (var stData in activeSuperTiles)
			{
				var currentOffset = parent.SpawnOffset;
				var drift = (Vector3)(float3)(stData.BakedOffset - currentOffset);
				var driftMat = Matrix4x4.Translate(drift);
        
				// Combine the Anchor's world matrix with the drift adjustment
				var finalMat = l2w * driftMat;

				foreach (var batch in stData.Batches)
				{
					if (batch.Count > 0)
					{
						batch.Properties.SetVectorArray(_SGT_TileOpacities, tileOpacities);
						batch.Properties.SetMatrix(_SGT_ObjectToWorld, finalMat);

						// FIXED: The GPU has instances mapped relative to BakedOffset. 
						// To correctly transform the culling bounds using our exact final matrix,
						// we simply subtract BakedOffset from the absolute bound positions here.
						var boundsCenterShaderSpace = batch.Bounds.center - (Vector3)(float3)stData.BakedOffset;
						var worldBounds = TransformBounds(finalMat, new Bounds(boundsCenterShaderSpace, batch.Bounds.size));
                
						Graphics.DrawMeshInstancedProcedural(staticMesh, 0, staticMaterial, worldBounds, batch.Count, batch.Properties);
					}
				}
			}
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
				Draw("staticMaterial", "The material that will be rendered.");
			EndError();

			Separator();

			Draw("swapPrefab", "The prefab to spawn when in range.");
			Draw("swapRange", ref markStaticDirty, "The range in meters to replace the instance with a prefab.");
			Draw("swapFalloff", ref markStaticDirty, "The distance over which the crossfade occurs.");
			Draw("fadeSpeed", "The speed at which tiles fade in and out when spawning/despawning.");

			if (Any(tgts, t => t.SwapPrefab != null && t.StaticMesh == null && t.StaticMaterial == null))
			{
				if (Button("Bake Prefab") == true) Each(tgts, t => TryBakePrefab(t), true, true);
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
			}
		}
	}
}
#endif