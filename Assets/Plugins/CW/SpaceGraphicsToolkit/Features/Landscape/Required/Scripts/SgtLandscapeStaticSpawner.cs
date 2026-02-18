using Unity.Mathematics;
using UnityEngine;
using System.Collections.Generic;
using Unity.Collections;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component can be added alongside a terrain to procedurally render meshes on its surface. 
	/// This works similarly to <b>SgtLandscapePrefabSpawner</b>, but it uses GPU instancing for much higher performance.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Landscape Static Spawner")]
	public class SgtLandscapeStaticSpawner : SgtLandscapeSpawner
	{
		private class Batch
		{
			public MaterialPropertyBlock Properties = new MaterialPropertyBlock();
			public int Count;
			public Bounds Bounds;
			public static Stack<Batch> Pool = new Stack<Batch>();
		}

		/// <summary>The mesh that will be rendered.</summary>
		public Mesh Mesh { set { mesh = value; } get { return mesh; } } [SerializeField] private Mesh mesh;

		/// <summary>The material that will be rendered. 
		/// NOTE: This must use the <b>SGT / Landscape Static</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		[System.NonSerialized]
		private Dictionary<Tile, List<Matrix4x4>> tileMatrices = new Dictionary<Tile, List<Matrix4x4>>();

		[System.NonSerialized]
		private List<Batch> batches = new List<Batch>();

		private static readonly int _SGT_Transform = Shader.PropertyToID("_SGT_Transform");
		private static readonly int _SGT_Transforms = Shader.PropertyToID("_SGT_Transforms");

		private static Matrix4x4[] tempTransforms = new Matrix4x4[128];

		private bool dirty;

		protected override void Update()
		{
			base.Update();

			if (dirty == true)
			{
				RebuildBatches();
			}

			if (mesh == null || material == null) return;

			var matrix = transform.localToWorldMatrix;

			foreach (var batch in batches)
			{
				if (batch.Count > 0)
				{
					batch.Properties.SetMatrix(_SGT_Transform, matrix);
					var worldBounds = TransformBounds(transform, batch.Bounds);
					Graphics.DrawMeshInstancedProcedural(mesh, 0, material, worldBounds, batch.Count, batch.Properties);
				}
			}
		}

		protected override void HandleSpawn(Tile tile, NativeList<float3> pos, NativeList<quaternion> rot, NativeList<float3> scale)
		{
			var matrices = new List<Matrix4x4>(tile.spawnCount);
			
			for (var i = 0; i < tile.spawnCount; i++)
			{
				var index = tile.spawnIndex + i;
				matrices.Add(Matrix4x4.TRS(pos[index], rot[index], scale[index]));
			}

			tileMatrices[tile] = matrices;
			dirty = true;
		}

		protected override void HandleDespawn(Tile tile)
		{
			if (tileMatrices.Remove(tile))
			{
				dirty = true;
			}
		}

		private void RebuildBatches()
		{
			ClearBatches();
			var currentBatch = default(Batch);

			foreach (var matrices in tileMatrices.Values)
			{
				for (var i = 0; i < matrices.Count; i++)
				{
					if (currentBatch == null || currentBatch.Count >= tempTransforms.Length)
					{
						if (currentBatch != null)
							currentBatch.Properties.SetMatrixArray(_SGT_Transforms, tempTransforms);

						currentBatch = AddBatch();
						currentBatch.Bounds = new Bounds(matrices[i].GetColumn(3), Vector3.zero);
					}

					tempTransforms[currentBatch.Count] = matrices[i];
					currentBatch.Bounds.Encapsulate((Vector3)matrices[i].GetColumn(3));
					currentBatch.Count += 1;
				}
			}

			if (currentBatch != null)
			{
				currentBatch.Properties.SetMatrixArray(_SGT_Transforms, tempTransforms);
			}

			dirty = false;
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
			var axisX = t.TransformVector(extents.x, 0, 0);
			var axisY = t.TransformVector(0, extents.y, 0);
			var axisZ = t.TransformVector(0, 0, extents.z);
			extents.x = Mathf.Abs(axisX.x) + Mathf.Abs(axisY.x) + Mathf.Abs(axisZ.x);
			extents.y = Mathf.Abs(axisX.y) + Mathf.Abs(axisY.y) + Mathf.Abs(axisZ.y);
			extents.z = Mathf.Abs(axisX.z) + Mathf.Abs(axisY.z) + Mathf.Abs(axisZ.z);
			return new Bounds { center = center, extents = extents };
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtLandscapeStaticSpawner))]
	public class SgtLandscapeStaticSpawner_Editor : SgtLandscapeSpawner_Editor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			SgtLandscapeStaticSpawner tgt; SgtLandscapeStaticSpawner[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			Separator();

			BeginError(Any(tgts, t => t.Mesh == null));
				Draw("mesh", ref markAsDirty, "The mesh that will be rendered.");
			EndError();
			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", ref markAsDirty, "The material that will be rendered.");
			EndError();

			if (markAsDirty) Each(tgts, t => t.MarkAsDirty());
		}
	}
}
#endif