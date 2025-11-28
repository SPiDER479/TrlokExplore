using Unity.Mathematics;
using UnityEngine;
using Unity.Collections;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component can be added alongside a terrain to procedurally spawn prefabs on its surface.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Prefab Spawner")]
	public class SgtLandscapePrefabSpawner : MonoBehaviour
	{
		public enum RotateType
		{
			Randomly,
			ToLandscapeCenter,
			ToSurfaceNormal,
		}

		public class Chunk
		{
			public int RemainingSamples;

			public Unity.Mathematics.Random RNG;

			public SgtLandscape.TriangleHash TriangleHash;

			public List<Transform> Clones = new List<Transform>();

			public List<double3> Points = new List<double3>();

			public List<double3> Directions = new List<double3>();

			public List<double> Heights = new List<double>();

			public List<double4> DataA = new List<double4>();

			public static Stack<Chunk> Pool = new Stack<Chunk>();

			public double3 GetPosition(int index)
			{
				return Points[index] + Directions[index] * Heights[index];
			}
		}

		/// <summary>This allows you to define the spawn area.
		/// NOTE: This texture should be <b>Single Channel</b> using either the <b>R8</b> or <b>Alpha8</b> formats.
		/// NOTE: This texture should have <b>read/write</b> enabled.</summary>
		public Texture2D MaskTex { set { maskTex = value; } get { return maskTex; } } [SerializeField] private Texture2D maskTex;

		/// <summary>Invert the mask, so 0 values become 255 values, and 255 values become 0 values?</summary>
		public bool InvertMask { set { invertMask = value; } get { return invertMask; } } [SerializeField] private bool invertMask;

		/// <summary>Prefabs will spawn at the LOD level where triangles are approximately this size.</summary>
		public float TriangleSize { set { triangleSize = value; } get { return triangleSize; } } [SerializeField] private float triangleSize = 10.0f;

		/// <summary>The amount of prefabs that will be spawned per LOD chunk.</summary>
		public int Count { set { count = value; } get { return count; } } [SerializeField] private int count = 10;

		/// <summary>The random seed when procedurally spawning the prefabs.</summary>
		public int Seed { set { seed = value; } get { return seed; } } [SerializeField] [CW.Common.CwSeed] private int seed;

		/// <summary>The spawned prefabs will have their localScale multiplied by at least this number.</summary>
		public float ScaleMin { set { scaleMin = value; } get { return scaleMin; } } [SerializeField] private float scaleMin = 0.75f;

		/// <summary>The spawned prefabs will have their localScale multiplied by at most this number.</summary>
		public float ScaleMax { set { scaleMax = value; } get { return scaleMax; } } [SerializeField] private float scaleMax = 1.25f;

		/// <summary>How should the spawned prefabs be rotated?</summary>
		public RotateType Rotate { set { rotate = value; } get { return rotate; } } [SerializeField] private RotateType rotate;

		/// <summary>The spawned prefabs will have their position offset by this local space distance.</summary>
		public float Offset { set { offset = value; } get { return offset; } } [SerializeField] private float offset;

		/// <summary>The maximum amount of prefabs that can be spawned per frame.</summary>
		public int MaxPerFrame { set { maxPerFrame = value; } get { return maxPerFrame; } } [SerializeField] private int maxPerFrame = 2;

		/// <summary>The prefabs that will be picked from.</summary>
		public List<Transform> Prefabs { get { if (prefabs == null) prefabs = new List<Transform>(); return prefabs; } } [SerializeField] private List<Transform> prefabs;

		[System.NonSerialized]
		private SgtLandscape parent;

		[System.NonSerialized]
		private int depth;

		[System.NonSerialized]
		private Dictionary<SgtLandscape.TriangleHash, Chunk> chunks = new Dictionary<SgtLandscape.TriangleHash, Chunk>();

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

			depth = parent.CalculateLodDepth(triangleSize);
		}

		protected virtual void OnDisable()
		{
			parent.OnAddVisual    -= HandleAddVisual;
			parent.OnRemoveVisual -= HandleRemoveVisual;
		}

		protected virtual void Update()
		{
			var spawnCount = 0;

			foreach (var pair in chunks)
			{
				var chunk = pair.Value;

				while (chunk.RemainingSamples > 0)
				{
					chunk.RemainingSamples -= 1;

					if (SampleChunk(chunk) == true)
					{
						spawnCount += 1;

						if (spawnCount >= maxPerFrame)
						{
							return;
						}
					}
				}
			}
		}

		private float3 GetRandomBary(float2 rand)
		{
			var u = rand.x;
			var v = rand.y;

			if (u + v > 1)
			{
				u = 1 - u;
				v = 1 - v;
			}

			return new Vector3(u, v, 1.0f - u - v);
		}

		private bool SampleChunk(Chunk chunk)
		{
			var spawned = false;
			var center  = (float3)transform.position;

			var index  = chunk.RNG.NextInt(0, prefabs.Count);
			var prefab = prefabs[index];

			if (prefab != null)
			{
				var triangle = chunk.RNG.NextInt(0, SgtLandscape.TRIANGLE_COUNT) * 3;
				var indexA   = SgtLandscape.VERTEX_INDICES[triangle + 0];
				var indexB   = SgtLandscape.VERTEX_INDICES[triangle + 1];
				var indexC   = SgtLandscape.VERTEX_INDICES[triangle + 2];
				var bary     = GetRandomBary(chunk.RNG.NextFloat2());
				var coord    = chunk.DataA[indexA].xy * bary.x + chunk.DataA[indexB].xy * bary.y + chunk.DataA[indexC].xy * bary.z;

				if (SampleMask(coord) >= chunk.RNG.NextFloat())
				{
					var clone         = Instantiate(prefab, transform, false);
					var localPosition = (Vector3)(float3)(chunk.GetPosition(indexA) * bary.x + chunk.GetPosition(indexB) * bary.y + chunk.GetPosition(indexC) * bary.z);
					var localRotation = Quaternion.identity;
					var localScale    = clone.transform.localScale * chunk.RNG.NextFloat(scaleMin, scaleMax);

					switch (rotate)
					{
						case RotateType.Randomly:
						{
							localRotation = chunk.RNG.NextQuaternionRotation();
						}
						break;

						case RotateType.ToLandscapeCenter:
						{
							var point = chunk.Points[indexA] * bary.x + chunk.Points[indexB] * bary.y + chunk.Points[indexC] * bary.z;

							localRotation = Quaternion.FromToRotation(Vector3.up, (float3)point - center) * Quaternion.Euler(0.0f, chunk.RNG.NextFloat(-180.0f, 180.0f), 0.0f);
						}
						break;

						case RotateType.ToSurfaceNormal:
						{
							var direction = chunk.Directions[indexA] * bary.x + chunk.Directions[indexB] * bary.y + chunk.Directions[indexC] * bary.z;

							localRotation = Quaternion.FromToRotation(Vector3.up, (float3)direction) * Quaternion.Euler(0.0f, chunk.RNG.NextFloat(-180.0f, 180.0f), 0.0f);
						}
						break;
					}

					localPosition += localRotation * new Vector3(0.0f, offset, 0.0f);

					clone.localPosition = localPosition;
					clone.localRotation = localRotation;
					clone.localScale    = localScale;

					chunk.Clones.Add(clone);

					spawned = true;
				}
			}

			return spawned;
		}

		private float SampleMask(double2 uv)
		{
			if (maskTex != null)
			{
				var x = math.clamp((int)(uv.x * maskTex.width ), 0, maskTex.width  - 1);
				var y = math.clamp((int)(uv.y * maskTex.height), 0, maskTex.height - 1);
				var d = maskTex.GetPixelData<byte>(0);
				var m = d[x + y * maskTex.width] / 255.0f;

				if (invertMask == true)
				{
					m = 1.0f - m;
				}

				return m;
			}

			return 1.0f;
		}

		private void HandleAddVisual(SgtLandscape.Visual visual, SgtLandscape.PendingTriangle pendingTriangle)
		{
			if (pendingTriangle.Triangle.Fixer == false && pendingTriangle.Triangle.Depth == depth && prefabs != null && prefabs.Count > 0 && count > 0)
			{
				var chunk = Chunk.Pool.Count > 0 ? Chunk.Pool.Pop() : new Chunk();
				var rand  = (uint)(pendingTriangle.Triangle.Hash.GetHashCode() + seed);

				chunk.RemainingSamples = count;
				chunk.RNG              = new Unity.Mathematics.Random(rand > 0 ? rand : 1);

				chunk.Points.AddRange(pendingTriangle.Points);
				chunk.Directions.AddRange(pendingTriangle.Directions);
				chunk.Heights.AddRange(pendingTriangle.Heights);
				chunk.DataA.AddRange(pendingTriangle.DataA);

				chunks.Add(visual.Hash, chunk);
			}
		}

		private void HandleRemoveVisual(SgtLandscape.Visual visual)
		{
			var chunk = default(Chunk);

			if (chunks.Remove(visual.Hash, out chunk) == true)
			{
				foreach (var clone in chunk.Clones)
				{
					if (clone != null)
					{
						DestroyImmediate(clone.gameObject);
					}
				}

				chunk.Points.Clear();
				chunk.Directions.Clear();
				chunk.Heights.Clear();
				chunk.DataA.Clear();

				chunk.Clones.Clear();

				Chunk.Pool.Push(chunk);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtLandscapePrefabSpawner))]
	public class SgtLandscapePrefabSpawner_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtLandscapePrefabSpawner tgt; SgtLandscapePrefabSpawner[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			Draw("maskTex", ref markAsDirty, "This allows you to define the spawn area.\n\t\t/// NOTE: This texture should be <b>Single Channel</b> using either the <b>R8</b> or <b>Alpha8</b> formats.\n\t\t/// NOTE: This texture should have <b>read/write</b> enabled.");
			Draw("invertMask", ref markAsDirty, "Invert the mask, so 0 values become 255 values, and 255 values become 0 values?");
			BeginError(Any(tgts, t => t.TriangleSize <= 0.0f));
				Draw("triangleSize", ref markAsDirty, "Prefabs will spawn at the LOD level where triangles are approximately this size.");
			EndError();
			BeginError(Any(tgts, t => t.Count <= 0));
				Draw("count", ref markAsDirty, "The amount of prefabs that will be spawned per LOD chunk.");
			EndError();
			Draw("seed", ref markAsDirty, "The random seed when procedurally spawning the prefabs.");

			Separator();

			Draw("scaleMin", ref markAsDirty, "The spawned prefabs will have their localScale multiplied by at least this number.");
			Draw("scaleMax", ref markAsDirty, "The spawned prefabs will have their localScale multiplied by at most this number.");
			Draw("rotate", ref markAsDirty, "How should the spawned prefabs be rotated?");
			Draw("offset", ref markAsDirty, "The spawned prefabs will have their position offset by this local space distance.");

			Separator();

			Draw("maxPerFrame", "The maximum amount of prefabs that can be spawned per frame.");

			Separator();

			BeginError(Any(tgts, t => t.Prefabs.Count == 0));
				Draw("prefabs", ref markAsDirty, "The prefabs that will be picked from.");
			EndError();

			if (markAsDirty == true)
			{
				Each(tgts, t => t.MarkForRebuild());
			}
		}
	}
}
#endif