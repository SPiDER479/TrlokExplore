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

		private List<PendingSpawn> pendingSpawns = new List<PendingSpawn>();

		private static LinkedList<SgtLandscapePrefabSpawner> instances = new LinkedList<SgtLandscapePrefabSpawner>();

		private LinkedListNode<SgtLandscapePrefabSpawner> instanceNode;

		private static Transform poolRoot;

		private static Dictionary<Object, List<GameObject>> pool = new Dictionary<Object, List<GameObject>>();

		private static int frameSpawnCount;

		private struct PendingSpawn
		{
			public Tile         TargetTile;
			public float3[]     Positions;
			public quaternion[] Rotations;
			public float3[]     Scales;
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			instanceNode = instances.AddLast(this);
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			instances.Remove(instanceNode);

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

						clone.transform.SetParent(transform, false);
						clone.transform.localPosition = pending.Positions[index];
						clone.transform.localRotation = pending.Rotations[index];
						clone.transform.localScale    = Vector3.Scale(prefab.localScale, pending.Scales[index]);
						clone.SetActive(true);

						list.Add(clone);
						frameSpawnCount++;
					}
				}

				pendingSpawns.RemoveAt(i);
			}
		}

		protected override void HandleSpawn(Tile tile, NativeList<float3> pos, NativeList<quaternion> rot, NativeList<float3> scale)
		{
			if (prefabs == null || prefabs.Count == 0) return;

			var list = new List<GameObject>(tile.spawnCount);
			spawnedObjects[tile] = list;

			var pending = new PendingSpawn
			{
				TargetTile = tile,
				Positions  = new float3[tile.spawnCount],
				Rotations  = new quaternion[tile.spawnCount],
				Scales     = new float3[tile.spawnCount]
			};

			for (var i = 0; i < tile.spawnCount; i++)
			{
				var index = tile.spawnIndex + i;
				pending.Positions[i] = pos[index];
				pending.Rotations[i] = rot[index];
				pending.Scales[i]    = scale[index];
			}

			pendingSpawns.Add(pending);
		}

		protected override void HandleDespawn(Tile tile)
		{
			for (var i = pendingSpawns.Count - 1; i >= 0; i--)
			{
				if (pendingSpawns[i].TargetTile.Equals(tile))
				{
					pendingSpawns.RemoveAt(i);
				}
			}

			if (spawnedObjects.Remove(tile, out var list))
			{
				foreach (var obj in list)
				{
					if (obj != null)
					{
						if (usePooling == true) ReleaseInstance(obj); else DestroyImmediate(obj);
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
			var sourcePrefab = prefabs.Find(p => p.name == instance.name.Replace("(Clone)", "").Trim());

			if (sourcePrefab != null)
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