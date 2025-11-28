using UnityEngine;
using System.Reflection;
using System.Collections.Generic;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component is applied to raw design parts and is usually the root component of each part.
	/// NOTE: This component must be in a child GameObject of the <b>CwDesign</b> component.</summary>
	[ExecuteAlways]
	[DisallowMultipleComponent]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwPart")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Part")]
	public class CwPart : MonoBehaviour
	{
		public enum OffsetType
		{
			Manual,
			PositionHash
		}

		/// <summary>This design part is based on this raw model.</summary>
		public string ModelGuid { set { modelGuid = value; } get { return modelGuid; } } [SerializeField] private string modelGuid;

		/// <summary>The Material used to render this part.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The maximum health value of this part.</summary>
		public float Health { set { health = value; } get { return health; } } [SerializeField] private float health = 1.0f;

		/// <summary>If you have multiple copies of the same part then their base texture can look repetitive. This setting allows you to offset the UV so they look slightly different.
		/// Manual = You can manually specify the UV offset.
		/// PositionHash = The UV offset will automatically be generated based on the position.</summary>
		public OffsetType OffsetMode { set { offsetMode = value; } get { return offsetMode; } } [SerializeField] private OffsetType offsetMode = OffsetType.PositionHash;

		/// <summary>If you have multiple copies of the same part then their base texture can look repetitive. This setting allows you to offset the UV so they look slightly different.</summary>
		public Vector2 Offset { set { offset = value; } get { return offset; } } [SerializeField] private Vector2 offset;

		/// <summary>The base texture scale of this part.
		/// NOTE: This is automatically calculated when updating the part from the model.</summary>
		public float Tiling { set { tiling = value; } get { return tiling; } } [SerializeField] private float tiling;

		/// <summary>This is multiplied by the <b>Tiling</b> value, and allows you to manually modify the U and V tiling values.</summary>
		public Vector2 TilingUV { set { tilingUV = value; } get { return tilingUV; } } [SerializeField] private Vector2 tilingUV = Vector2.one;

		/// <summary>The base color of this part based on the color list in the root design component.</summary>
		public int ColorIndex { set { colorIndex = value; } get { return colorIndex; } } [SerializeField] private int colorIndex;

		[System.NonSerialized]
		private Material previewMaterial;

		private static List<MeshCollider> tempColliders = new List<MeshCollider>();

		private static Mesh          rayMesh;
		private static List<Vector4> rayCoords  = new List<Vector4>();
		private static List<Vector3> rayPoints  = new List<Vector3>();
		private static List<int>     rayIndices = new List<int>();

		private static CwDesignData tempData = new CwDesignData(true);

		private static CwDesignData meshData = new CwDesignData(true);

		private static List<Material> tempMaterials = new List<Material>();

		private static List<Mesh> tempMeshes = new List<Mesh>();

		private static List<MeshRenderer> tempMeshRenderers = new List<MeshRenderer>();

		private static List<Matrix4x4> tempStickerMatrices = new List<Matrix4x4>();

		private static List<Vector4> tempStickerCoords = new List<Vector4>();

		private static List<Vector4> tempStickerDataA = new List<Vector4>();

		private static List<Vector4> tempStickerDataB = new List<Vector4>();

		private static List<CwSticker> tempStickers = new List<CwSticker>();

		private static int _CW_Colors = Shader.PropertyToID("_CW_Colors");

		private static int _CW_PreviewColor = Shader.PropertyToID("_CW_PreviewColor");
		private static int _CW_PreviewOffset = Shader.PropertyToID("_CW_PreviewOffset");
		private static int _CW_PreviewTiling = Shader.PropertyToID("_CW_PreviewTiling");
		
		private static int _CW_StickerOpacityTex = Shader.PropertyToID("_CW_StickerOpacityTex");
		private static int _CW_StickerCount = Shader.PropertyToID("_CW_StickerCount");
		private static int _CW_StickerMatrices = Shader.PropertyToID("_CW_StickerMatrices");
		private static int _CW_StickerCoords = Shader.PropertyToID("_CW_StickerCoords");
		private static int _CW_StickerDataA = Shader.PropertyToID("_CW_StickerDataA");
		private static int _CW_StickerDataB = Shader.PropertyToID("_CW_StickerDataB");

		protected virtual void Update()
		{
			switch (offsetMode)
			{
				case OffsetType.PositionHash:
				{
					CwHelper.BeginSeed(transform.position.GetHashCode());

					offset.x = Random.value;
					offset.y = Random.value;

					CwHelper.EndSeed();
				}
				break;
			}

			// Delete preview material if it's different from the source
			if (previewMaterial != null)
			{
				if (material == null || material.shader != previewMaterial.shader)
				{
					DestroyImmediate(previewMaterial);
				}
			}

			// Update preview material
			if (material != null)
			{
				if (previewMaterial == null)
				{
					previewMaterial = Instantiate(material);

					previewMaterial.hideFlags = HideFlags.DontSave;
				}
				else
				{
					previewMaterial.CopyPropertiesFromMaterial(material);
				}

				previewMaterial.EnableKeyword("_CW_PREVIEW");

				var design = GetComponentInParent<CwDesign>();

				if (design != null)
				{
					previewMaterial.SetColorArray(_CW_Colors, design.Colors);

					if (design.StickerPack != null && design.StickerPack.GeneratedTexture != null)
					{
						previewMaterial.SetTexture(_CW_StickerOpacityTex, design.StickerPack.GeneratedTexture);
					}
				}

				previewMaterial.SetVector(_CW_PreviewColor, new Vector4(colorIndex, 0, 0, 0) / 255.0f);
				previewMaterial.SetVector(_CW_PreviewOffset, offset);
				previewMaterial.SetVector(_CW_PreviewTiling, tilingUV * tiling * CwHelper.UniformScale(transform.localScale));

				// Stickers
				tempStickerMatrices.Clear();
				tempStickerCoords.Clear();
				tempStickerDataA.Clear();
				tempStickerDataB.Clear();

				foreach (var designSticker in FindStickers())
				{
					tempStickerMatrices.Add(designSticker.GetMatrix());
					tempStickerCoords.Add(design.GetStickerCoords(designSticker.TextureIndex));
					tempStickerDataA.Add(new Vector4(designSticker.ColorIndex, designSticker.Offset, designSticker.Sharpness, 0.0f));
					tempStickerDataB.Add(new Vector4(designSticker.NormalBack, designSticker.NormalFront, 0.0f, 0.0f));
				}

				previewMaterial.SetInt(_CW_StickerCount, tempStickers.Count);

				if (tempStickers.Count > 0)
				{
					previewMaterial.SetMatrixArray(_CW_StickerMatrices, tempStickerMatrices);
					previewMaterial.SetVectorArray(_CW_StickerCoords, tempStickerCoords);
					previewMaterial.SetVectorArray(_CW_StickerDataA, tempStickerDataA);
					previewMaterial.SetVectorArray(_CW_StickerDataB, tempStickerDataB);
				}
			}

			// Apply preview material to all child renderers
			GetComponentsInChildren(tempMeshRenderers);

			foreach (var tempMeshRenderer in tempMeshRenderers)
			{
				tempMeshRenderer.sharedMaterial = previewMaterial;
			}
		}

#if UNITY_EDITOR
		/*
		protected virtual void OnValidate()
		{
			GetComponentsInChildren(tempMeshRenderers);

			foreach (var tempMeshRenderer in tempMeshRenderers)
			{
				if (tempMeshRenderer.sharedMaterial != material)
				{
					tempMeshRenderer.sharedMaterial = material;
				}
			}
		}
		*/

		protected virtual void OnDisable()
		{
			GetComponentsInChildren(tempMeshRenderers);

			foreach (var tempMeshRenderer in tempMeshRenderers)
			{
				if (tempMeshRenderer.sharedMaterial != material)
				{
					tempMeshRenderer.sharedMaterial = material;
				}
			}
		}
#endif

		public List<CwSticker> FindStickers()
		{
			tempStickers.Clear();

			var design = GetComponentInParent<CwDesign>();

			if (design != null)
			{
				foreach (var designSticker in design.GetComponentsInChildren<CwSticker>())
				{
					tempStickers.Add(designSticker);
				}
			}

			return tempStickers;
		}

#if UNITY_EDITOR
		private static MethodInfo method_IntersectRayMesh;

		static CwPart() 
		{
			method_IntersectRayMesh = typeof(UnityEditor.HandleUtility).GetMethod("IntersectRayMesh", BindingFlags.Static | BindingFlags.NonPublic);
		}

		private static bool IntersectRayMesh(Ray ray, MeshFilter meshFilter, out RaycastHit hit)
		{
			return IntersectRayMesh(ray, meshFilter.mesh, meshFilter.transform.localToWorldMatrix, out hit);
		}

		private static bool IntersectRayMesh(Ray ray, Mesh mesh, Matrix4x4 matrix, out RaycastHit hit)
		{
			var parameters = new object[] { ray, mesh, matrix, null };
			var result     = (bool)method_IntersectRayMesh.Invoke(null, parameters);

			hit = (RaycastHit)parameters[3];

			return result;
		}

		private static Vector4 IntersectCoord(Ray ray)
		{
			var hit = default(RaycastHit);

			ray.origin -= ray.direction * 0.1f;

			if (IntersectRayMesh(ray, rayMesh, Matrix4x4.identity, out hit) == true)
			{
				var indexA = rayIndices[hit.triangleIndex * 3 + 0];
				var indexB = rayIndices[hit.triangleIndex * 3 + 1];
				var indexC = rayIndices[hit.triangleIndex * 3 + 2];

				var bary = hit.barycentricCoordinate;

				bary = Barycentric(hit.point, rayPoints[indexA], rayPoints[indexB], rayPoints[indexC]);

				var coordA = rayCoords[indexA];
				var coordB = rayCoords[indexB];
				var coordC = rayCoords[indexC];
				var coordD = coordA * bary.x + coordB * bary.y + coordC * bary.z;

				Debug.DrawLine(coordA, coordB, Color.red, 1.0f);
				Debug.DrawLine(coordB, coordC, Color.red, 1.0f);
				Debug.DrawLine(coordC, coordA, Color.red, 1.0f);
				Debug.DrawLine(coordA, coordD, Color.blue, 1.0f);
				Debug.DrawLine(coordB, coordD, Color.blue, 1.0f);
				Debug.DrawLine(coordC, coordD, Color.blue, 1.0f);

				//Debug.DrawLine(coordC, coordA, Color.red, 1.0f);

				//Debug.Log(hit.barycentricCoordinate + " - " + hit.triangleIndex + " - " + hit.point + " - " + (coordA + coordB + coordC));
				Debug.DrawLine(ray.origin, hit.point, Color.green, 1.0f);

				return coordD;
			}

			return default(Vector4);
		}

		private static Vector3 Barycentric(Vector3 p, Vector3 a, Vector3 b, Vector3 c)
		{
			Vector3 v0 = b - a, v1 = c - a, v2 = p - a;
			float d00 = Vector3.Dot(v0, v0);
			float d01 = Vector3.Dot(v0, v1);
			float d11 = Vector3.Dot(v1, v1);
			float d20 = Vector3.Dot(v2, v0);
			float d21 = Vector3.Dot(v2, v1);
			float denom = d00 * d11 - d01 * d01;

			var v = (d11 * d20 - d01 * d21) / denom;
			var w = (d00 * d21 - d01 * d20) / denom;
			var u = 1.0f - v - w;

			return new Vector3(u, v, w);
		}

		public void Clear()
		{
			var path     = UnityEditor.AssetDatabase.GetAssetPath(gameObject);
			var instance = UnityEditor.PrefabUtility.LoadPrefabContents(path).GetComponent<CwPart>();

			Clear(instance, path);

			UnityEditor.PrefabUtility.SaveAsPrefabAsset(instance.gameObject, path);
			UnityEditor.PrefabUtility.UnloadPrefabContents(instance.gameObject);
		}

		public void UpdateFromModel()
		{
			var path     = UnityEditor.AssetDatabase.GetAssetPath(gameObject);
			var instance = UnityEditor.PrefabUtility.LoadPrefabContents(path).GetComponent<CwPart>();

			Clear(instance, path);

			tempMeshes.Clear();

			var source = CwHelper.LoadAssetAtGUID<Transform>(modelGuid);

			if (source != null)
			{
				var mainVisual   = CreateChild(instance, "Main Visual");
				var decalVisual  = CreateChild(instance, "Decal Visual");
				var colliders    = CreateChild(instance, "Colliders");
				var mainFilters  = new List<MeshFilter>(); foreach (var meshFilter in source.GetComponentsInChildren<MeshFilter>()) { if (meshFilter.name.Contains("Collider") == false && meshFilter.name.Contains("Decal") == false)  mainFilters.Add(meshFilter); }
				var decalFilters = new List<MeshFilter>(); foreach (var meshFilter in source.GetComponentsInChildren<MeshFilter>()) { if (meshFilter.name.Contains("Decal") == true) decalFilters.Add(meshFilter); }

				ClearLists();

				instance.ExtractMainVisual(mainFilters);

				instance.BuildMesh(mainVisual, "Main Visual");

				ClearLists();

				instance.ExtractDecalVisual(decalFilters);

				instance.BuildMesh(decalVisual, "Decal Visual");

				foreach (var meshFilter in source.GetComponentsInChildren<MeshFilter>()) { if (meshFilter.name.Contains("Collider") == true) ExtractCollider(colliders, meshFilter, meshFilter.sharedMesh); }
			}

			foreach (var tempMesh in tempMeshes)
			{
				UnityEditor.AssetDatabase.AddObjectToAsset(tempMesh, this);
			}
			
			UnityEditor.PrefabUtility.SaveAsPrefabAsset(instance.gameObject, path);
			UnityEditor.PrefabUtility.UnloadPrefabContents(instance.gameObject);
		}

		private static void Clear(CwPart root, string path)
		{
			foreach (var asset in UnityEditor.AssetDatabase.LoadAllAssetsAtPath(path))
			{
				if (asset is Mesh)
				{
					DestroyImmediate(asset, true);
				}
			}

			for (var i = root.transform.childCount - 1; i >= 0; i--)
			{
				DestroyImmediate(root.transform.GetChild(i).gameObject);
			}
		}

		private static GameObject CreateChild(CwPart root, string title)
		{
			var child = new GameObject(title);

			child.transform.parent = root.transform;

			return child.gameObject;
		}

		private void ClearLists()
		{
			tempData.Clear();
			meshData.Clear();
		}

		private void ExtractMainVisual(List<MeshFilter> meshFilters)
		{
			foreach (var meshFilter in meshFilters)
			{
				ExtractMesh(meshFilter);

				var matrix      = meshFilter.transform.localToWorldMatrix;
				var indexOffset = meshData.Positions.Count;

				for (var j = 0; j < tempData.Positions.Count; j++)
				{
					var tempTangent4 = tempData.Tangents[j];
					var tempTangent3 = matrix.MultiplyVector(tempTangent4);

					tempTangent4.x = tempTangent3.x;
					tempTangent4.y = tempTangent3.y;
					tempTangent4.z = tempTangent3.z;

					meshData.Positions.Add(matrix.MultiplyPoint(tempData.Positions[j]));
					meshData.Normals.Add(matrix.MultiplyVector(tempData.Normals[j]));
					meshData.Tangents.Add(tempTangent4);

					meshData.Coords0.Add(new Vector4(tempData.Coords0[j].x, tempData.Coords0[j].y, 0.0f, 0.0f));
				}

				var tempIndices = tempData.GetIndices();
				var meshIndices = meshData.GetIndices();

				foreach (var index in tempIndices)
				{
					meshIndices.Add(index + indexOffset);
				}

				for (var i = 0; i < tempIndices.Count - 1; i++)
				{
					var index0    = tempIndices[i];
					var index1    = tempIndices[i + 1];
					var position0 = tempData.Positions[index0];
					var position1 = tempData.Positions[index1];
					var coord0    = tempData.Coords0[index0];
					var coord1    = tempData.Coords0[index1];

					if (position0 != position1 && coord0 != coord1)
					{
						tiling = CwHelper.Divide(Vector3.Distance(position0, position1), Vector2.Distance(coord0, coord1));

						break;
					}
				}
			}
		}

		private void ExtractDecalVisual(List<MeshFilter> meshFilters)
		{
			foreach (var meshFilter in meshFilters)
			{
				ExtractMesh(meshFilter);

				var matrix      = meshFilter.transform.localToWorldMatrix;
				var tempIndices = tempData.GetIndices();
				var meshIndices = meshData.GetIndices();
				var baseVertex  = meshData.Positions.Count;
				var baseIndex   = meshIndices.Count;

				for (var j = 0; j < tempData.Positions.Count; j++)
				{
					var tempTangent4 = tempData.Tangents[j];
					var tempTangent3 = matrix.MultiplyVector(tempTangent4);

					tempTangent4.x = tempTangent3.x;
					tempTangent4.y = tempTangent3.y;
					tempTangent4.z = tempTangent3.z;

					meshData.Positions.Add(matrix.MultiplyPoint(tempData.Positions[j]));
					meshData.Normals.Add(matrix.MultiplyVector(tempData.Normals[j]));
					meshData.Tangents.Add(tempTangent4);

					meshData.Coords0.Add(new Vector4(0.0f, 0.0f, tempData.Coords0[j].x, tempData.Coords0[j].y));
				}

				if (meshFilter.transform.lossyScale.y < 0.0f)
				{
					for (var j = 0; j < tempIndices.Count; j += 3)
					{
						meshIndices.Add(tempIndices[j + 2] + baseVertex);
						meshIndices.Add(tempIndices[j + 1] + baseVertex);
						meshIndices.Add(tempIndices[j    ] + baseVertex);
					}
				}
				else
				{
					for (var j = 0; j < tempIndices.Count; j++)
					{
						meshIndices.Add(tempIndices[j] + baseVertex);
					}
				}

				// Generate coord0.xy to match visual mesh
				for (var j = baseIndex; j < meshIndices.Count; j += 3)
				{
					var indexA = meshIndices[j + 0];
					var indexB = meshIndices[j + 1];
					var indexC = meshIndices[j + 2];

					var pointA = meshData.Positions[indexA];
					var pointB = meshData.Positions[indexB];
					var pointC = meshData.Positions[indexC];
					var pointD = -Vector3.Cross(pointB - pointA, pointC - pointA);
					var pointM = (pointA + pointB + pointC) / 3.0f;

					//var coordM = IntersectCoord(new Ray(pointM, pointD));
					//var coordA = coordM + (IntersectCoord(new Ray(pointM + (pointA - pointM) * 0.5f, pointD)) - coordM) * 2.0f;
					//var coordB = coordM + (IntersectCoord(new Ray(pointM + (pointB - pointM) * 0.5f, pointD)) - coordM) * 2.0f;
					//var coordC = coordM + (IntersectCoord(new Ray(pointM + (pointC - pointM) * 0.5f, pointD)) - coordM) * 2.0f;
					var coordA = IntersectCoord(new Ray(pointA, pointD));
					var coordB = IntersectCoord(new Ray(pointB, pointD));
					var coordC = IntersectCoord(new Ray(pointC, pointD));

					meshData.Coords0[indexA] = new Vector4(coordA.x, coordA.y, meshData.Coords0[indexA].z, meshData.Coords0[indexA].w);
					meshData.Coords0[indexB] = new Vector4(coordB.x, coordB.y, meshData.Coords0[indexB].z, meshData.Coords0[indexB].w);
					meshData.Coords0[indexC] = new Vector4(coordC.x, coordC.y, meshData.Coords0[indexC].z, meshData.Coords0[indexC].w);

					//Debug.Log(coordA + " - " + coordB + " - " + coordC);
					//Debug.DrawRay(pointM, pointD, Color.green, 1.0f);
					//break;
					//Debug.DrawLine(pointA, pointB, Color.red, 1.0f);
					//Debug.DrawLine(pointB, pointC, Color.red, 1.0f);
					//Debug.DrawLine(pointC, pointA, Color.red, 1.0f);
				}
			}
		}

		private void ExtractMesh(MeshFilter meshFilter)
		{
			var childMesh = meshFilter.sharedMesh;

			tempData.FillFrom(childMesh);
			childMesh.GetTriangles(tempData.GetIndices(), 0);
		}

		private void BuildMesh(GameObject root, string title)
		{
			var meshFilter   = root.AddComponent<MeshFilter>();
			var meshRenderer = root.AddComponent<MeshRenderer>();

			meshRenderer.sharedMaterial = material;

			var mesh = new Mesh();

			mesh.name = title;

			mesh.SetVertices(meshData.Positions);
			mesh.SetNormals(meshData.Normals);
			mesh.SetTangents(meshData.Tangents);
			mesh.SetUVs(0, meshData.Coords0);
			mesh.SetTriangles(meshData.GetIndices(), 0);
			mesh.RecalculateBounds();

			meshFilter.sharedMesh = mesh;

			tempMeshes.Add(mesh);

			rayMesh = mesh;
			rayMesh.GetUVs(0, rayCoords);
			rayMesh.GetVertices(rayPoints);
			rayMesh.GetTriangles(rayIndices, 0);
		}

		private void ExtractCollider(GameObject root, MeshFilter childMeshFilter, Mesh childMesh)
		{
			var meshCollider  = root.AddComponent<MeshCollider>();
			var mesh          = new Mesh();
			var meshPositions = new List<Vector3>();
			var meshIndices   = new List<int>();
			var tempIndices   = tempData.GetIndices();

			mesh.name = childMesh.name;

			childMesh.GetVertices(tempData.Positions);
			childMesh.GetTriangles(tempIndices, 0);

			var matrix      = childMeshFilter.transform.localToWorldMatrix;
			var indexOffset = meshPositions.Count;

			for (var j = 0; j < tempData.Positions.Count; j++)
			{
				meshPositions.Add(matrix.MultiplyPoint(tempData.Positions[j]));
			}

			for (var j = 0; j < tempIndices.Count; j++)
			{
				meshIndices.Add(tempIndices[j] + indexOffset);
			}

			mesh.SetVertices(meshPositions);
			mesh.SetTriangles(meshIndices, 0);
			mesh.RecalculateBounds();

			meshCollider.sharedMesh = mesh;

			tempMeshes.Add(mesh);
		}
#endif

		public void ExtractVisual(int submesh, CwDesignData outData, List<Material> materials, Matrix4x4 matrix, Matrix4x4 matrix2)
		{
			var root         = transform.Find(submesh == 0 ? "Main Visual" : "Decal Visual"); if (root == null) return;
			var meshFilter   = root.GetComponent<MeshFilter>();
			var meshRenderer = root.GetComponent<MeshRenderer>();
			var tempMesh     = meshFilter.sharedMesh;
			var flip         = meshFilter.transform.lossyScale.x * meshFilter.transform.lossyScale.y * meshFilter.transform.lossyScale.z < 0.0f;
			var tilingScale  = tilingUV * tiling * CwHelper.UniformScale(transform.localScale);

			tempMaterials.Clear();
			tempMaterials.Add(material);
			//meshRenderer.GetSharedMaterials(tempMaterials);

			if (tempMesh != null)
			{
				var tempIndices = tempData.GetIndices();
				var count       = System.Math.Min(tempMaterials.Count, tempMesh.subMeshCount);

				for (var i = 0; i < count; i++)
				{
					var indexData  = GetIndices(outData, materials, tempMaterials[i]);
					var baseVertex = outData.Positions.Count;

					tempData.FillFrom(tempMesh);
					tempMesh.GetTriangles(tempIndices, i);

					for (var j = 0; j < tempData.Positions.Count; j++)
					{
						outData.Positions.Add(matrix.MultiplyPoint(tempData.Positions[j]));
					}

					for (var j = 0; j < tempData.Normals.Count; j++)
					{
						outData.Normals.Add(matrix.MultiplyVector(tempData.Normals[j]) );
					}

					for (var j = 0; j < tempData.Tangents.Count; j++)
					{
						var tempTangent4 = tempData.Tangents[j];
						var tempTangent3 = matrix2.MultiplyVector(tempTangent4);

						tempTangent4.x = tempTangent3.x;
						tempTangent4.y = tempTangent3.y;
						tempTangent4.z = tempTangent3.z;

						outData.Tangents.Add(tempTangent4);
					}

					for (var j = 0; j < tempData.Positions.Count; j++)
					{
						var tempColor = new Color32((byte)colorIndex, 0, 0, 0);

						outData.Colors.Add(tempColor);
					}

					for (var j = 0; j < tempData.Coords0.Count; j++)
					{
						var tempCoord0 = tempData.Coords0[j];
						var tempCoord1 = tempCoord0;

						tempCoord0.x *= tilingScale.x;
						tempCoord0.y *= tilingScale.y;

						tempCoord0.x += offset.x;
						tempCoord0.y += offset.y;

						outData.Coords0.Add(tempCoord0);
						outData.Coords1.Add(tempCoord1);
					}

					if (flip == true)
					{
						for (var j = 0; j < tempIndices.Count; j += 3)
						{
							indexData.Indices.Add(tempIndices[j + 2] + baseVertex);
							indexData.Indices.Add(tempIndices[j + 1] + baseVertex);
							indexData.Indices.Add(tempIndices[j    ] + baseVertex);
						}
					}
					else
					{
						for (var j = 0; j < tempIndices.Count; j++)
						{
							indexData.Indices.Add(tempIndices[j] + baseVertex);
						}
					}

					indexData.Added = tempIndices.Count;
				}
			}
		}

		private static CwDesignData.IndexList GetIndices(CwDesignData data, List<Material> materials, Material material)
		{
			for (var i = 0; i < materials.Count; i++)
			{
				if (materials[i] == material)
				{
					return data.IndexLists[i];
				}
			}

			var indexData = new CwDesignData.IndexList(true);

			data.IndexLists.Add(indexData);

			materials.Add(material);

			return indexData;
		}

		public void ExtractColliders(CwDesign design, int index, List<Mesh> output, Matrix4x4 matrix)
		{
			GetComponentsInChildren(tempColliders);

			foreach (var tempCollider in tempColliders)
			{
				var tempMesh = tempCollider.sharedMesh;

				if (tempMesh != null)
				{
					var colliderMesh = new Mesh();

					output.Add(colliderMesh);

					tempMesh.GetVertices(tempData.Positions);

					for (var i = 0; i < tempData.Positions.Count; i++)
					{
						tempData.Positions[i] = matrix.MultiplyPoint(tempData.Positions[i]);
					}

					colliderMesh.name = design.name + " (Part " + index + " Collider " + output.Count + ")";

					colliderMesh.SetVertices(tempData.Positions);
					colliderMesh.SetTriangles(tempMesh.triangles, 0);

#if UNITY_EDITOR
					UnityEditor.AssetDatabase.AddObjectToAsset(colliderMesh, design);
#endif
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwPart;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwPart_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			var design     = tgt.GetComponentInParent<CwDesign>();
			var colorCount = 0;

			if (design != null)
			{
				colorCount = design.Colors.Count;
			}

			DrawModel(tgt, tgts);

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The Material used to render this part.");
			EndError();
			Draw("health", "The maximum health value of this part.");
			Draw("offsetMode", "If you have multiple copies of the same part then their base texture can look repetitive. This setting allows you to offset the UV so they look slightly different.\n\nManual = You can manually specify the UV offset.\n\nPositionHash = The UV offset will automatically be generated based on the position.");
			if (Any(tgts, t => t.OffsetMode == TARGET.OffsetType.Manual))
			{
				BeginIndent();
					Draw("offset", "If you have multiple copies of the same part then their base texture can look repetitive. This setting allows you to offset the UV so they look slightly different.");
				EndIndent();
			}
			Draw("tiling", "The base texture scale of this part.\n\nNOTE: This is automatically calculated when updating the part from the model.");
			Draw("tilingUV", "This is multiplied by the <b>Tiling</b> value, and allows you to manually modify the U and V tiling values.");
			DrawIntSlider("colorIndex", 0, colorCount - 1, "The base color of this part based on the color list in the root design component.");

			Separator();

			if (Button("Clear") == true)
			{
				Each(tgts, t => t.Clear(), true, true, "Clear");
			}

			if (Button("Update From Model") == true)
			{
				Each(tgts, t => t.UpdateFromModel(), true, true, "Update From Model");
			}
		}

		private void DrawModel(TARGET tgt, TARGET[] tgts)
		{
			var model = CwHelper.LoadAssetAtGUID<GameObject>(tgt.ModelGuid);

			EditorGUI.BeginChangeCheck();

			model = (GameObject)EditorGUILayout.ObjectField("Model", model, typeof(GameObject), true);

			if (EditorGUI.EndChangeCheck() == true)
			{
				Each(tgts, t => t.ModelGuid = CwHelper.AssetToGUID(model), true, true);
			}
		}
	}
}
#endif