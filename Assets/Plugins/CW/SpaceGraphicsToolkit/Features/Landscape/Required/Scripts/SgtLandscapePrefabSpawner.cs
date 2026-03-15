using UnityEngine;
using Unity.Collections;
using Unity.Mathematics;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>Implementation of SgtLandscapeSpawner that spawns GameObjects.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Prefab Spawner")]
	public class SgtLandscapePrefabSpawner : SgtLandscapeSpawner
	{
		/// <summary>The prefabs that will be picked from.</summary>
		public List<Transform> Prefabs { get { if (prefabs == null) prefabs = new List<Transform>(); return prefabs; } } [SerializeField] private List<Transform> prefabs;

		/// <summary>Should spawned objects be pooled when they are despawned?</summary>
		public bool UsePooling { set { usePooling = value; } get { return usePooling; } } [SerializeField] private bool usePooling;

		/// <summary>The maximum number of prefabs that can be spawned per frame across all spawners. -1 = No limit.</summary>
		public int SpawnRate { set { spawnRate = value; } get { return spawnRate; } } [SerializeField] private int spawnRate = -1;

		private Dictionary<Tile, List<GameObject>> spawnedObjects = new Dictionary<Tile, List<GameObject>>();
		
		private Dictionary<GameObject, Transform> instanceToPrefab = new Dictionary<GameObject, Transform>();

		private List<PendingSpawn> pendingSpawns = new List<PendingSpawn>();
		private Stack<PendingSpawn> pendingSpawnPool = new Stack<PendingSpawn>();

		private static LinkedList<SgtLandscapePrefabSpawner> instances = new LinkedList<SgtLandscapePrefabSpawner>();

		private LinkedListNode<SgtLandscapePrefabSpawner> instanceNode;

		private static Transform poolRoot;

		private static Dictionary<Object, List<GameObject>> pool = new Dictionary<Object, List<GameObject>>();

		private static int frameSpawnCount;

		private class PendingSpawn
		{
			public Tile                   TargetTile;
			public NativeList<double3>    Positions;
			public NativeList<quaternion> Rotations;
			public NativeList<float>      Scales;
			public NativeList<float>      Seeds;

			public void Init()
			{
				if (!Positions.IsCreated) Positions = new NativeList<double3>(16, Allocator.Persistent);
				if (!Rotations.IsCreated) Rotations = new NativeList<quaternion>(16, Allocator.Persistent);
				if (!Scales.IsCreated)    Scales    = new NativeList<float>(16, Allocator.Persistent);
				if (!Seeds.IsCreated)     Seeds     = new NativeList<float>(16, Allocator.Persistent);

				Positions.Clear();
				Rotations.Clear();
				Scales.Clear();
				Seeds.Clear();
			}

			public void Dispose()
			{
				if (Positions.IsCreated) Positions.Dispose();
				if (Rotations.IsCreated) Rotations.Dispose();
				if (Scales.IsCreated) Scales.Dispose();
				if (Seeds.IsCreated) Seeds.Dispose();
			}
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			instanceNode = instances.AddLast(this);
		}

		protected override void OnDisable()
		{
			base.OnDisable(); // calls ForceComplete and HandleDespawn for everything

			instances.Remove(instanceNode);

			foreach (var pending in pendingSpawns)
			{
				pending.Dispose();
			}
			pendingSpawns.Clear();

			foreach (var pending in pendingSpawnPool)
			{
				pending.Dispose();
			}
			pendingSpawnPool.Clear();

			instanceToPrefab.Clear();

			if (instances.Count == 0 && poolRoot != null)
			{
				DestroyImmediate(poolRoot.gameObject);
				poolRoot = null;
				pool.Clear();
			}
		}

		protected virtual void LateUpdate()
		{
			frameSpawnCount = 0;

			for (var i = pendingSpawns.Count - 1; i >= 0; i--)
			{
				var pending = pendingSpawns[i];
				var list    = spawnedObjects[pending.TargetTile];

				while (list.Count < pending.Positions.Length)
				{
					if (spawnRate >= 0 && frameSpawnCount >= spawnRate) return;

					var prefab = prefabs[UnityEngine.Random.Range(0, prefabs.Count)];

					if (prefab != null)
					{
						var index = list.Count;
						var clone = GetInstance(prefab);
						
						instanceToPrefab[clone] = prefab;

						var pos   = pending.Positions[index];
						var rot   = pending.Rotations[index];
						var sca   = prefab.localScale * pending.Scales[index];

						parent.AddChild(clone.transform, pos, rot, sca);

						clone.SetActive(true);

						list.Add(clone);
						frameSpawnCount++;
					}
				}

				pendingSpawns.RemoveAt(i);
				pendingSpawnPool.Push(pending);
			}
		}

		protected override void HandleSpawn(Tile tile, NativeList<double3> positions, NativeList<quaternion> rotations, NativeList<float> scales, NativeList<float> seeds, NativeList<int> tileIDs)
		{
			if (prefabs == null || prefabs.Count == 0) return;

			var list = new List<GameObject>(tile.spawnCount);
			spawnedObjects[tile] = list;

			var pending = pendingSpawnPool.Count > 0 ? pendingSpawnPool.Pop() : new PendingSpawn();
			pending.Init();
			pending.TargetTile = tile;

			for (var i = 0; i < tile.spawnCount; i++)
			{
				var index = tile.spawnIndex + i;
				pending.Positions.Add(positions[index]);
				pending.Rotations.Add(rotations[index]);
				pending.Scales.Add(scales[index]);
				pending.Seeds.Add(seeds[index]);
			}

			pendingSpawns.Add(pending);
		}

		protected override void HandleDespawn(Tile tile)
		{
			for (var i = pendingSpawns.Count - 1; i >= 0; i--)
			{
				if (pendingSpawns[i].TargetTile.Equals(tile))
				{
					pendingSpawnPool.Push(pendingSpawns[i]);
					pendingSpawns.RemoveAt(i);
				}
			}

			if (spawnedObjects.Remove(tile, out var list))
			{
				foreach (var obj in list)
				{
					if (obj != null)
					{
						if (usePooling == true) 
						{
							ReleaseInstance(obj); 
						} 
						else 
						{
							instanceToPrefab.Remove(obj);
							DestroyImmediate(obj);
						}
					}
				}
			}
		}

		private GameObject GetInstance(Transform prefab)
		{
			if (usePooling == true)
			{
				if (pool.TryGetValue(prefab, out var list) == true && list.Count > 0)
				{
					var index    = list.Count - 1;
					var instance = list[index];
					list.RemoveAt(index);
					return instance;
				}
			}
			return Instantiate(prefab.gameObject);
		}

		private void ReleaseInstance(GameObject instance)
		{
			if (instanceToPrefab.TryGetValue(instance, out var sourcePrefab))
			{
				if (poolRoot == null)
				{
					poolRoot = new GameObject("SGT Landscape Pool").transform;
					poolRoot.gameObject.SetActive(false);
				}

				if (pool.TryGetValue(sourcePrefab, out var list) == false)
				{
					list = new List<GameObject>();
					pool.Add(sourcePrefab, list);
				}

				instance.SetActive(false);
				instance.transform.SetParent(poolRoot, false);
				list.Add(instance);
			}
			else
			{
				DestroyImmediate(instance);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtLandscapePrefabSpawner))]
	public class SgtLandscapePrefabSpawner_Editor : SgtLandscapeSpawner_Editor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			SgtLandscapePrefabSpawner tgt; SgtLandscapePrefabSpawner[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			Separator();

			Draw("usePooling", ref markAsDirty, "Should spawned objects be pooled when they are despawned?");
			Draw("spawnRate", "The maximum number of prefabs that can be spawned per frame across all spawners. -1 = No limit.");

			Separator();

			BeginError(Any(tgts, t => t.Prefabs.Count == 0));
				Draw("prefabs", ref markAsDirty, "Prefabs to spawn.");
			EndError();

			if (markAsDirty) Each(tgts, t => t.MarkAsDirty());
		}
	}
}
#endif