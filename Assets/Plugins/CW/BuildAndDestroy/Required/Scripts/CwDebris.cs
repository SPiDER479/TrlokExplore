using UnityEngine;
using System.Collections.Generic;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component allows damaged parts break off from the main mesh so they can be manipulated separately.</summary>
	[DisallowMultipleComponent]
	[RequireComponent(typeof(MeshFilter))]
	[RequireComponent(typeof(MeshRenderer))]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwDebris")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Debris")]
	public class CwDebris : MonoBehaviour
	{
		/// <summary>Should the debris detach from the main object?</summary>
		public bool Detach { set { detach = value; } get { return detach; } } [SerializeField] private bool detach;

		/// <summary>Should the debris rotate?</summary>
		public bool Rotate { set { rotate = value; } get { return rotate; } } [SerializeField] private bool rotate;

		/// <summary>When this debris is spawned, it will be given a random rotational velocity with this minimum speed in degrees per second.</summary>
		public float RotationSpeedMin { set { rotationSpeedMin = value; } get { return rotationSpeedMin; } } [SerializeField] private float rotationSpeedMin = 20.0f;

		/// <summary>When this debris is spawned, it will be given a random rotational velocity with this maximum speed in degrees per second.</summary>
		public float RotationSpeedMax { set { rotationSpeedMax = value; } get { return rotationSpeedMax; } } [SerializeField] private float rotationSpeedMax = 90.0f;

		/// <summary>The debris will stay alive for this many seconds.</summary>
		public float Life { set { life = value; } get { return life; } } [SerializeField] private float life = 2.0f;

		public float FadePower { set { fadePower = value; } get { return fadePower; } } [SerializeField] private float fadePower = 1.0f;

		public float FadeScale { set { fadeScale = value; } get { return fadeScale; } } [SerializeField] private float fadeScale = 1.1f;

		[System.NonSerialized]
		private static CwDesignData tempData = new CwDesignData(true);

		[SerializeField]
		private Vector3 center;

		[SerializeField]
		private Vector3 rotationAxis;

		[SerializeField]
		private float rotationSpeed;

		[SerializeField]
		private Rigidbody cachedRigidbody;

		[SerializeField]
		private MeshFilter cachedMeshFilter;

		[SerializeField]
		private MeshRenderer cachedMeshRenderer;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private float destructionCounter;

		private static int _CW_HeatFade = Shader.PropertyToID("_CW_HeatFade");
		private static int _CW_DamageCenter = Shader.PropertyToID("_CW_DamageCenter");

		public static CwDebris Create(CwLoadedPart loadedPart)
		{
			Clear();

			var loader = loadedPart.Parent;

			if (loader.DebrisPrefab != null)
			{
				var position = loadedPart.Parent.transform.TransformPoint(loadedPart.Center);
				var rotation = loadedPart.Parent.transform.rotation;
				var parent   = loader.DebrisPrefab.detach == true ? null : loader.transform;
				var debris   = Instantiate(loader.DebrisPrefab, position, rotation, parent);

				debris.center             = loadedPart.Center;
				debris.cachedMeshFilter   = debris.GetComponent<MeshFilter>();
				debris.cachedMeshRenderer = debris.GetComponent<MeshRenderer>();

				var mesh = new Mesh();

				debris.cachedMeshFilter.sharedMesh = mesh;

				debris.cachedMeshRenderer.sharedMaterials = loader.ShapeRenderer.sharedMaterials;

				debris.ApplyShaderVariables();

				var o = loadedPart.ShapeRangeData.VertexRange.x;

				for (var i = loadedPart.ShapeRangeData.VertexRange.x; i < loadedPart.ShapeRangeData.VertexRange.y; i++)
				{
					tempData.Positions.Add(loader.ShapeData.Positions[i] - loadedPart.Center);
					tempData.Normals.Add(loader.ShapeData.Normals[i]);
					tempData.Tangents.Add(loader.ShapeData.Tangents[i]);
					tempData.Colors.Add(loader.ShapeData.Colors[i]);
					tempData.Coords0.Add(loader.ShapeData.Coords0[i]);
					tempData.Coords1.Add(loader.ShapeData.Coords1[i]);
				}

				mesh.SetVertices(tempData.Positions);
				mesh.SetNormals(tempData.Normals);
				mesh.SetTangents(tempData.Tangents);
				mesh.SetColors(tempData.Colors);
				mesh.SetUVs(0, tempData.Coords0);
				mesh.SetUVs(1, tempData.Coords1);

				for (var i = 0; i < loadedPart.ShapeRangeData.IndexRanges.Count; i++)
				{
					var meshIndices = loader.ShapeData.IndexLists[i].Indices;
					var tempIndices = tempData.GetIndices();
					var indexRange  = loadedPart.ShapeRangeData.IndexRanges[i];

					for (var j = indexRange.x; j < indexRange.y; j++)
					{
						tempIndices.Add(meshIndices[j] - o);
					}

					mesh.SetTriangles(tempIndices, i);
				}

				mesh.RecalculateBounds();

				if (debris.rotate == true)
				{
					debris.cachedRigidbody = debris.GetComponent<Rigidbody>();

					if (debris.cachedRigidbody != null)
					{
						var x = Random.Range(debris.rotationSpeedMin, debris.rotationSpeedMax) * Mathf.Sign(Random.Range(-1.0f, 1.0f));
						var y = Random.Range(debris.rotationSpeedMin, debris.rotationSpeedMax) * Mathf.Sign(Random.Range(-1.0f, 1.0f));
						var z = Random.Range(debris.rotationSpeedMin, debris.rotationSpeedMax) * Mathf.Sign(Random.Range(-1.0f, 1.0f));

						debris.cachedRigidbody.angularVelocity = new Vector3(x, y, z);
					}
					else
					{
						debris.rotationAxis  = Random.onUnitSphere;
						debris.rotationSpeed = Random.Range(debris.rotationSpeedMin, debris.rotationSpeedMax);
					}
				}

				return debris;
			}

			return null;
		}

		private static void Clear()
		{
			tempData.Clear();
		}

		protected virtual void OnEnable()
		{
			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}
		}

		protected virtual void Update()
		{
			if (rotate == true && cachedRigidbody == null)
			{
				transform.Rotate(rotationAxis, rotationSpeed * Time.deltaTime);
			}

			destructionCounter += Time.deltaTime;

			if (destructionCounter >= life)
			{
				Destroy(gameObject);
			}

			ApplyShaderVariables();
		}

		private void ApplyShaderVariables()
		{
			var fade = Mathf.Pow(destructionCounter / life, fadePower) * fadeScale;

			for (var i = 0; i < cachedMeshFilter.sharedMesh.subMeshCount; i++)
			{
				cachedMeshRenderer.GetPropertyBlock(properties, i);

				properties.SetFloat(_CW_HeatFade, fade);
				properties.SetVector(_CW_DamageCenter, center);

				cachedMeshRenderer.SetPropertyBlock(properties, i);
			}
		}
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwDebris;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwDebris_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			Draw("detach", "Should the debris detach from the main object?");
			Draw("rotate", "Should the debris rotate?");
			if (Any(tgts, t => t.Rotate == true))
			{
				BeginIndent();
					Draw("rotationSpeedMin", "When this debris is spawned, it will be given a random rotational velocity with this minimum speed in degrees per second.");
					Draw("rotationSpeedMax", "When this debris is spawned, it will be given a random rotational velocity with this maximum speed in degrees per second.");
				EndIndent();
			}
			Draw("life", "The debris will stay alive for this many seconds.");
			Draw("fadePower");
			Draw("fadeScale");
		}
	}
}
#endif