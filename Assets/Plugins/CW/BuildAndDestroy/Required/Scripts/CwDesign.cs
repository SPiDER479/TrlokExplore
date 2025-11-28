using UnityEngine;
using System.Collections.Generic;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component is the base of your object design. All parts of this object should be child GameObjects using the <b>CwPart</b> component. They can then be compiled into an optimized object.
	/// NOTE: This component is usually the root component in a prefab for a specific design.</summary>
	[DisallowMultipleComponent]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwDesign")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Design")]
	public class CwDesign : MonoBehaviour
	{
		struct PackPart
		{
			public int     Index;
			public Vector2 Size;
		}

		/// <summary>The parts of this design can have stickers from this sticker pack.</summary>
		public CwStickerPack StickerPack { set { stickerPack = value; } get { return stickerPack; } } [SerializeField] private CwStickerPack stickerPack;

		/// <summary>The parts and stickers will be colored based on this color palette.</summary>
		public List<Color> Colors { get { if (colors == null) colors = new List<Color>(); return colors; } } [SerializeField] private List<Color> colors;

		/// <summary>The compiled design's visual shape mesh will be stored here.</summary>
		public Mesh ShapeVisual { get { return shapeVisual; } } [SerializeField] private Mesh shapeVisual;

		/// <summary>The compiled design's visual decal mesh will be stored here.</summary>
		public Mesh DecalVisual { get { return decalVisual; } } [SerializeField] private Mesh decalVisual;

		/// <summary>The compiled design's damage atlas texture size in pixels.</summary>
		public int SecondarySize { set { secondarySize = value; } get { return secondarySize; } } [SerializeField] private int secondarySize;

		/// <summary>The compiled design's material set.</summary>
		public Material[] Materials { get { return materials; } } [SerializeField] private Material[] materials;

		/// <summary>The compiled design's sticker matrices.</summary>
		public Matrix4x4[] StickerMatrices { get { return stickerMatrices; } } [SerializeField] private Matrix4x4[] stickerMatrices;

		/// <summary>The compiled design's sticker UVs.</summary>
		public Vector4[] StickerCoords { get { return stickerCoords; } } [SerializeField] private Vector4[] stickerCoords;

		/// <summary>The compiled design's sticker color, offset, and sharpness data.</summary>
		public Vector4[] StickerDataA { get { return stickerDataA; } } [SerializeField] private Vector4[] stickerDataA;

		/// <summary>The compiled design's sticker normal data.</summary>
		public Vector4[] StickerDataB { get { return stickerDataB; } } [SerializeField] private Vector4[] stickerDataB;

		public List<CwCompiledPart> CompiledParts { get { if (compiledParts == null) compiledParts = new List<CwCompiledPart>(); return compiledParts; } } [SerializeField] private List<CwCompiledPart> compiledParts;

		private static CwDesignData tempShapeData = new CwDesignData(true);

		private static CwDesignData tempDecalData = new CwDesignData(true);

		private static List<CwPart> tempParts = new List<CwPart>();

		private static List<CwModule> tempModules = new List<CwModule>();

		private static List<Material> tempShapeMaterials = new List<Material>();

		private static List<Material> tempDecalMaterials = new List<Material>();

		public Vector4 GetStickerCoords(int index)
		{
			if (stickerPack != null && index >= 0 && index < stickerPack.PackedStickerCoords.Count)
			{
				return stickerPack.PackedStickerCoords[index];
			}

			return default(Vector4);
		}

#if UNITY_EDITOR
		[ContextMenu("Compile")]
		private void CompileContext()
		{
			UnityEditor.Undo.RecordObject(this, "Compile");

			Compile();

			UnityEditor.EditorUtility.SetDirty(this);
		}

		[ContextMenu("Clear")]
		private void ClearContext()
		{
			UnityEditor.Undo.RecordObject(this, "Clear");

			Clear();

			UnityEditor.EditorUtility.SetDirty(this);
		}
#endif

		/// <summary>This method will convert all child parts into a single visual mesh and data for colliders.</summary>
		public void Compile()
		{
			Clear();

			GetComponentsInChildren(tempParts);
			GetComponentsInChildren(tempModules);

			if (tempParts.Count > 0)
			{
				foreach (var tempPart in tempParts)
				{
					var matrix       = tempPart.transform.localToWorldMatrix;
					var matrix2      = Matrix4x4.TRS(tempPart.transform.position, tempPart.transform.rotation, Vector3.one);
					var compiledPart = CwCompiledPart.Pool.Count > 0 ? CwCompiledPart.Pool.Pop() : new CwCompiledPart();
					var shapeOffset  = tempShapeData.Positions.Count;
					var decalOffset  = tempDecalData.Positions.Count;

					compiledPart.ShapeRangeData = new CwRangeData(true);
					compiledPart.DecalRangeData = new CwRangeData(true);

					CompiledParts.Add(compiledPart); // NOTE: Property

					foreach (var indexList in tempShapeData.IndexLists)
					{
						indexList.Added = 0;
					}

					foreach (var indexList in tempDecalData.IndexLists)
					{
						indexList.Added = 0;
					}

					tempPart.ExtractVisual(0, tempShapeData, tempShapeMaterials, matrix, matrix2);
					tempPart.ExtractVisual(1, tempDecalData, tempDecalMaterials, matrix, matrix2);

					tempPart.ExtractColliders(this, compiledParts.Count, compiledPart.ColliderMeshes, matrix);

					compiledPart.Name                       = tempPart.name;
					compiledPart.Health                     = tempPart.Health;
					compiledPart.Material                   = tempPart.Material;
					compiledPart.Center                     = tempPart.transform.position;
					compiledPart.ShapeRangeData.VertexRange = new Vector2Int(shapeOffset, tempShapeData.Positions.Count);
					compiledPart.DecalRangeData.VertexRange = new Vector2Int(decalOffset, tempDecalData.Positions.Count);

					for (var i = 0; i < tempModules.Count; i++)
					{
						var tempModule = tempModules[i];

						if (tempModule.DesignPart == tempPart)
						{
							tempModule.CompiledPosition = tempModule.transform.position;
							tempModule.CompiledRotation = tempModule.transform.rotation;
							tempModule.CompiledScale    = tempModule.transform.lossyScale;

							compiledPart.Modules.Add(tempModule);
						}
					}

					for (var i = 0; i < tempShapeData.IndexLists.Count; i++)
					{
						var tempData = tempShapeData.IndexLists[i];

						compiledPart.ShapeRangeData.IndexRanges.Add(new Vector2Int(tempData.Indices.Count - tempData.Added, tempData.Indices.Count));
					}

					for (var i = 0; i < tempDecalData.IndexLists.Count; i++)
					{
						var tempData = tempDecalData.IndexLists[i];

						compiledPart.DecalRangeData.IndexRanges.Add(new Vector2Int(tempData.Indices.Count - tempData.Added, tempData.Indices.Count));
					}
				}

				tempParts.Clear();

				CalculateSecondaryUVs();

				// Build main visual
				shapeVisual = new Mesh();

				shapeVisual.name         = name + " (Main Visual)";
				shapeVisual.indexFormat  = UnityEngine.Rendering.IndexFormat.UInt32;
				shapeVisual.subMeshCount = tempShapeData.IndexLists.Count;

				shapeVisual.SetVertices(tempShapeData.Positions);
				shapeVisual.SetNormals(tempShapeData.Normals);
				shapeVisual.SetTangents(tempShapeData.Tangents);
				shapeVisual.SetColors(tempShapeData.Colors);
				shapeVisual.SetUVs(0, tempShapeData.Coords0);
				shapeVisual.SetUVs(1, tempShapeData.Coords1);

				shapeVisual.RecalculateBounds();

				// Build decal visual
				decalVisual = new Mesh();

				decalVisual.name         = name + " (Decal Visual)";
				decalVisual.indexFormat  = UnityEngine.Rendering.IndexFormat.UInt32;
				decalVisual.subMeshCount = tempDecalData.IndexLists.Count;

				decalVisual.SetVertices(tempDecalData.Positions);
				decalVisual.SetNormals(tempDecalData.Normals);
				decalVisual.SetTangents(tempDecalData.Tangents);
				decalVisual.SetColors(tempDecalData.Colors);
				decalVisual.SetUVs(0, tempDecalData.Coords0);
				decalVisual.SetUVs(1, tempDecalData.Coords1);

				decalVisual.RecalculateBounds();

				// Build materials
				materials = new Material[tempShapeMaterials.Count];

				for (var i = 0; i < tempShapeData.IndexLists.Count; i++)
				{
					shapeVisual.SetTriangles(tempShapeData.IndexLists[i].Indices, i);
					decalVisual.SetTriangles(tempDecalData.IndexLists[i].Indices, i);

					materials[i] = tempShapeMaterials[i];
				}

				var tempStickers = GetComponentsInChildren<CwSticker>();

				stickerMatrices = new Matrix4x4[tempStickers.Length];
				stickerCoords   = new Vector4[tempStickers.Length];
				stickerDataA    = new Vector4[tempStickers.Length];
				stickerDataB    = new Vector4[tempStickers.Length];

				for (var i = 0; i < tempStickers.Length; i++)
				{
					var tempSticker = tempStickers[i];

					stickerMatrices[i] = tempSticker.GetMatrix();
					stickerCoords[i] = GetStickerCoords(tempSticker.TextureIndex);
					stickerDataA[i] = new Vector4(tempSticker.ColorIndex, tempSticker.Offset, tempSticker.Sharpness, 0.0f);
					stickerDataB[i] = new Vector4(tempSticker.NormalBack, tempSticker.NormalFront, 0.0f, 0.0f);
				}

#if UNITY_EDITOR
				UnityEditor.AssetDatabase.AddObjectToAsset(shapeVisual, this);
				UnityEditor.AssetDatabase.AddObjectToAsset(decalVisual, this);

				//UnityEditor.AssetDatabase.ImportAsset(UnityEditor.AssetDatabase.GetAssetPath(visualMesh));
				//UnityEditor.AssetDatabase.SaveAssets();
#endif

				ClearMeshDataLists();
			}
		}

		private static List<PackPart> packParts = new List<PackPart>();

		private static List<Rect> packResults = new List<Rect>();

		private static List<Rect> bestResults = new List<Rect>();

		private static int bestSize;

		private void CalculateSecondaryUVs()
		{
			packParts.Clear();

			for (var i = 0; i < compiledParts.Count; i++)
			{
				var packPart = new PackPart();

				packPart.Index = i;
				packPart.Size  = new Vector2(100, 100); // TODO: Calculate actual size

				packParts.Add(packPart);
			}

			// TODO: Sort?

			bestResults.Clear();

			var sizes = packParts.ConvertAll(p => p.Size).ToArray();
			var size  = 128;
			var delta = 64;
			var last  = false;

			for (var i = 0; i < 100; i++)
			{
				var pack = Texture2D.GenerateAtlas(sizes, 1, size, packResults) == true && packResults[0].width > 0.0f;

				if (pack == true)
				{
					foreach (var packResult in packResults)
					{
						if (packResult.width <= 0.0f || packResult.max.x >= size || packResult.max.y >= size)
						{
							pack = false; break;
						}
					}
				}

				if (pack == true)
				{
					bestSize = size;

					bestResults.Clear();
					bestResults.AddRange(packResults);
				}

				if (pack == last)
				{
					size += delta;
				}
				else
				{
					delta /= -2;
				}

				last = pack;

				if (System.Math.Abs(delta) < 2)
				{
					break;
				}
			}

			if (bestResults.Count > 0)
			{
				/*
				Debug.DrawLine(Vector2.zero, Vector2.right * bestSize, Color.red, 1.0f);
				Debug.DrawLine(Vector2.zero, Vector2.up * bestSize, Color.red, 1.0f);
				Debug.DrawLine(Vector2.one * size, Vector2.up * bestSize, Color.red, 1.0f);
				Debug.DrawLine(Vector2.one * bestSize, Vector2.right * bestSize, Color.red, 1.0f);

				for (var i = 0; i < packParts.Count; i++)
				{
					var part   = packParts[i];
					var result = bestResults[i];
					var subset  = subsets[part.Index];

					Debug.DrawLine(result.min, result.min + Vector2.right * result.width, Color.white, 1.0f);
					Debug.DrawLine(result.min, result.min + Vector2.up  * result.height, Color.white, 1.0f);
					Debug.DrawLine(result.max, result.max - Vector2.right * result.width, Color.white, 1.0f);
					Debug.DrawLine(result.max, result.max - Vector2.up  * result.height, Color.white, 1.0f);

					var offsetX = result.x      / bestSize;
					var offsetY = result.y      / bestSize;
					var scaleX  = result.width  / bestSize;
					var scaleY  = result.height / bestSize;

					for (var j = subset.ShapeRangeData.VertexRange.x; j < subset.ShapeRangeData.VertexRange.y - 1; j++)
					{
						var coord1 = tempShapeData.Coords1[j];
						var coord2 = tempShapeData.Coords1[j + 1];

						//coord1.x = offsetX + scaleX * coord1.x;
						//coord1.y = offsetY + scaleY * coord1.y;

						//coord2.x = offsetX + scaleX * coord2.x;
						//coord2.y = offsetY + scaleY * coord2.y;
						
						var a = result.min + Vector2.right * result.size.x * coord1.x + Vector2.up * result.size.y * coord1.y;
						var b = result.min + Vector2.right * result.size.x * coord2.x + Vector2.up * result.size.y * coord2.y;

						Debug.DrawLine(a, b, Color.green, 1.0f);
					}
				}
				*/

				secondarySize = bestSize;

				for (var i = 0; i < packParts.Count; i++)
				{
					var subset  = compiledParts[packParts[i].Index];
					var result  = bestResults[i];
					var offsetX = result.x      / bestSize;
					var offsetY = result.y      / bestSize;
					var scaleX  = result.width  / bestSize;
					var scaleY  = result.height / bestSize;

					for (var j = subset.ShapeRangeData.VertexRange.x; j < subset.ShapeRangeData.VertexRange.y; j++)
					{
						var coord = tempShapeData.Coords1[j];

						coord.x = offsetX + scaleX * coord.x;
						coord.y = offsetY + scaleY * coord.y;

						tempShapeData.Coords1[j] = coord;
					}

					for (var j = subset.DecalRangeData.VertexRange.x; j < subset.DecalRangeData.VertexRange.y; j++)
					{
						var coord = tempDecalData.Coords1[j];

						coord.x = offsetX + scaleX * coord.x;
						coord.y = offsetY + scaleY * coord.y;

						tempDecalData.Coords1[j] = coord;
					}
				}
			}
		}

		public void Clear()
		{
			DestroyImmediate(shapeVisual, true);
			DestroyImmediate(decalVisual, true);

			shapeVisual = null;
			decalVisual = null;
			materials   = null;

			ClearMeshDataLists();

			if (compiledParts != null)
			{
				foreach (var compiledPart in compiledParts)
				{
					compiledPart.Clear();

					CwCompiledPart.Pool.Push(compiledPart);
				}

				compiledParts.Clear();
			}
		}

		private void ClearMeshDataLists()
		{
			tempShapeData.Clear();
			tempDecalData.Clear();
			tempShapeMaterials.Clear();
			tempDecalMaterials.Clear();
		}
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwDesign;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwDesign_Editor : CwEditor
	{
		[MenuItem("Assets/Create/CW/BuildAndDestroy/Design")]
		public static void CreateTexture()
		{
			var gameObject = CwHelper.CreatePrefabAsset("New Design");

			gameObject.AddComponent<CwDesign>();
		}

		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.StickerPack == null));
				Draw("stickerPack", "The parts of this design can have stickers from this sticker pack.");
			EndError();
			Draw("colors", "The parts and stickers will be colored based on this color palette.");

			Separator();

			BeginDisabled(tgt.gameObject.scene.name != null || tgt.gameObject.scene.path != null);
				if (Button("Compile") == true)
				{
					Each(tgts, t => t.Compile(), true, true);
				}
			EndDisabled();
		}
	}
}
#endif