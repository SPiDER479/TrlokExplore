using UnityEngine;
using CW.Common;
using System.Collections.Generic;

namespace CW.BuildAndDestroy
{
	/// <summary>This component is used in-game to load a from previously built design.
	/// This component also handles visual damage, and allows you to override materials or colors from the design.</summary>
	[DisallowMultipleComponent]
	[HelpURL(CwCommon.HelpUrlPrefix + "CwLoader")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Loader")]
	public class CwLoader : MonoBehaviour, ISerializationCallbackReceiver
	{
		[System.Serializable]
		public struct MaterialOverride
		{
			public int Index;

			public Material Replacement;
		}

		[System.Serializable]
		public struct ColorOverride
		{
			public int Index;

			public Color Replacement;
		}

		[System.Serializable]
		public struct ColliderPartPair
		{
			public Collider Collider;
			public int      PartIndex;
		}

		/// <summary>This allows you to choose which design will be loaded by this component.</summary>
		public CwDesign Design { set { design = value; } get { return design; } } [SerializeField] private CwDesign design;

		/// <summary>Do you want to allow damage mark and holes?
		/// NOTE: Marks can be applied manually using the <b>ApplyMark/All</b> methods, or in the editor using the <b>CwExplosion</b> component.</summary>
		public bool AllowMarks { set { allowMarks = value; } get { return allowMarks; } } [SerializeField] private bool allowMarks;

		/// <summary>This allows you to replace any of the materials used in the design during loading.</summary>
		public List<MaterialOverride> MaterialOverrides { get { if (materialOverrides == null) materialOverrides = new List<MaterialOverride>(); return materialOverrides; } } [SerializeField] private List<MaterialOverride> materialOverrides;

		/// <summary>This allows you to replace any of the colors used in the design during loading.</summary>
		public List<ColorOverride> ColorOverrides { get { if (colorOverrides == null) colorOverrides = new List<ColorOverride>(); return colorOverrides; } } [SerializeField] private List<ColorOverride> colorOverrides;

		/// <summary>After a design is loaded, all of its parts are stored here.</summary>
		public List<CwLoadedPart> LoadedParts { get { if (loadedParts == null) loadedParts = new List<CwLoadedPart>(); return loadedParts; } } [SerializeField] private List<CwLoadedPart> loadedParts;

		/// <summary>The visual damage data will be stored in this texture.</summary>
		public RenderTexture MarkTexture { get { return markTex; } } [SerializeField] private RenderTexture markTex;

		/// <summary>The <b>MeshRenderer</b> used to draw the shape mesh.</summary>
		public MeshRenderer ShapeRenderer { set { shapeRenderer = value; } get { return shapeRenderer; } } [SerializeField] private MeshRenderer shapeRenderer;

		/// <summary>The <b>MeshRenderer</b> used to draw the decal mesh.</summary>
		public MeshRenderer DecalRenderer { set { decalRenderer = value; } get { return decalRenderer; } } [SerializeField] private MeshRenderer decalRenderer;

		/// <summary>If you enable this setting then damaged parts can be broken off.</summary>
		public bool AllowRemoval { set { allowRemoval = value; } get { return allowRemoval; } } [SerializeField] private bool allowRemoval;

		/// <summary>When a part is destroyed it can break off and become debris. This setting allows you to choose what the debris settings will be based on.
		/// None/null = Immediately destroy.</summary>
		public CwDebris DebrisPrefab { set { debrisPrefab = value; } get { return debrisPrefab; } } [SerializeField] private CwDebris debrisPrefab;

		[SerializeField]private bool loaded;

		[SerializeField] private GameObject shapeRoot;

		[SerializeField] private MeshFilter shapeMF;

		[SerializeField] private Mesh shapeVisual;

		[SerializeField] private GameObject decalRoot;

		[SerializeField] private MeshFilter decalMF;

		[SerializeField] private Mesh decalVisual;

		[SerializeField] private GameObject colliderRoot;

		[SerializeField] private List<CwModule> modules;

		[SerializeField] private Material[] materials;

		[SerializeField] private Color[] colors;

		[SerializeField] private CwDesignData shapeData = new CwDesignData(true);

		[SerializeField] private CwDesignData decalData = new CwDesignData(true);

		[SerializeField] private List<ColliderPartPair> colliderToPartData;

		[System.NonSerialized]
		private Dictionary<Collider, int> colliderToPartIndex = new Dictionary<Collider, int>();

		[System.NonSerialized]
		private Dictionary<Collider, CwLoadedPart> colliderToPart = new Dictionary<Collider, CwLoadedPart>();

		public static LinkedList<CwLoader> Instances = new LinkedList<CwLoader>(); [System.NonSerialized] private LinkedListNode<CwLoader> node;

		private static List<Material> tempMaterials = new List<Material>();

		private static Material damageMaterial;

		private static int _CW_MarkTex = Shader.PropertyToID("_CW_MarkTex");
		private static int _CW_Colors = Shader.PropertyToID("_CW_Colors");
		private static int _CW_Matrix = Shader.PropertyToID("_CW_Matrix");
		private static int _CW_Texture = Shader.PropertyToID("_CW_Texture");
		private static int _CW_StickerCount = Shader.PropertyToID("_CW_StickerCount");
		private static int _CW_StickerOpacityTex = Shader.PropertyToID("_CW_StickerOpacityTex");
		private static int _CW_StickerMatrices = Shader.PropertyToID("_CW_StickerMatrices");
		private static int _CW_StickerCoords = Shader.PropertyToID("_CW_StickerCoords");
		private static int _CW_StickerDataA = Shader.PropertyToID("_CW_StickerDataA");
		private static int _CW_StickerDataB = Shader.PropertyToID("_CW_StickerDataB");

		public bool Loaded
		{
			get
			{
				return loaded;
			}
		}

		public Mesh ShapeVisual
		{
			get
			{
				return shapeVisual;
			}
		}

		public Mesh DecalVisual
		{
			get
			{
				return decalVisual;
			}
		}

		public CwDesignData ShapeData
		{
			get
			{
				return shapeData;
			}
		}

		public CwDesignData DecalData
		{
			get
			{
				return decalData;
			}
		}

		public int MaterialCount
		{
			get
			{
				return design != null ? design.Materials.Length : 0;
			}
		}

		public int ColorCount
		{
			get
			{
				return design != null ? design.Colors.Count : 0;
			}
		}

		public static void ApplyDamage(Collider collider, float damage)
		{
			if (collider != null)
			{
				var loader = collider.GetComponentInParent<CwLoader>();

				if (loader != null)
				{
					loader.DamagePart(collider, damage);
				}
			}
		}

		public static void ApplyMarkAll(LayerMask layers, Vector3 worldPoint, Quaternion worldRotation, Vector3 worldSize, Texture texture)
		{
			var matrix = Matrix4x4.TRS(worldPoint, worldRotation, worldSize);

			foreach (var loader in Instances)
			{
				if (CwHelper.IndexInMask(loader.gameObject.layer, layers) == true)
				{
					loader.ApplyMark(matrix, texture);
				}
			}
		}

		public void DamagePart(Collider collider, float damage)
		{
			var loadedPart = default(CwLoadedPart);

			if (colliderToPart.TryGetValue(collider, out loadedPart) == true)
			{
				loadedPart.Damage += damage;
			}
		}

		public void ApplyMark(Vector3 worldPoint, Quaternion worldRotation, Vector3 worldSize, Texture texture)
		{
			var matrix = Matrix4x4.TRS(worldPoint, worldRotation, worldSize);

			ApplyMark(matrix, texture);
		}

		private void ApplyMark(Matrix4x4 matrix, Texture texture)
		{
			if (markTex != null)
			{
				if (damageMaterial == null)
				{
					damageMaterial = CwHelper.CreateTempMaterial("Damage", "Hidden/BuildAndDestroy/CwDamage");
				}

				damageMaterial.SetMatrix(_CW_Matrix, matrix.inverse * transform.localToWorldMatrix);
				damageMaterial.SetTexture(_CW_Texture, texture);

				CwHelper.BeginActive(markTex);
					if (damageMaterial.SetPass(0) == true)
					{
						for (var i = 0; i < ShapeVisual.subMeshCount; i++)
						{
							Graphics.DrawMeshNow(design.ShapeVisual, Matrix4x4.identity, i);
						}
					}
				CwHelper.EndActive();

				markTex.GenerateMips();
			}
		}

		public Material GetDesignMaterial(int i)
		{
			if (design != null && i >= 0 && i < design.Materials.Length)
			{
				return design.Materials[i];
			}

			return null;
		}

		private Material GetMaterialClone(int i)
		{
			if (materialOverrides != null)
			{
				foreach (var materialOverride in materialOverrides)
				{
					if (materialOverride.Index == i)
					{
						return Instantiate(materialOverride.Replacement);
					}
				}
			}

			return Instantiate(design.Materials[i]);
		}

		public Color GetDesignColor(int i)
		{
			if (design != null && i >= 0 && i < design.Colors.Count)
			{
				return design.Colors[i];
			}

			return default(Color);
		}

		public Color GetColor(int i)
		{
			if (colorOverrides != null)
			{
				foreach (var colorOverride in colorOverrides)
				{
					if (colorOverride.Index == i)
					{
						return colorOverride.Replacement;
					}
				}
			}

			return design.Colors[i];
		}

		[ContextMenu("Load From Design")]
		public void LoadFromDesign()
		{
			Clear();

			loaded      = true;
			shapeVisual = Instantiate(design.ShapeVisual);
			decalVisual = Instantiate(design.DecalVisual);

			shapeData.FillFrom(shapeVisual);
			decalData.FillFrom(decalVisual);

			shapeRoot     = CwHelper.CreateGameObject("Shape Visual", gameObject.layer, transform);
			shapeMF       = shapeRoot.AddComponent<MeshFilter>();
			shapeRenderer = shapeRoot.AddComponent<MeshRenderer>();

			materials = new Material[design.Materials.Length];

			for (var i = 0; i < materials.Length; i++)
			{
				materials[i] = GetMaterialClone(i);
			}

			colors = new Color[design.Colors.Count];

			for (var i = 0; i < colors.Length; i++)
			{
				colors[i] = GetColor(i);
			}

			shapeMF.sharedMesh      = shapeVisual;
			shapeRenderer.sharedMaterials = materials;

			decalRoot     = CwHelper.CreateGameObject("Decal Visual", gameObject.layer, transform);
			decalMF       = decalRoot.AddComponent<MeshFilter>();
			decalRenderer = decalRoot.AddComponent<MeshRenderer>();

			decalMF.sharedMesh        = decalVisual;
			decalRenderer.sharedMaterials   = materials;
			decalRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;

			colliderRoot = CwHelper.CreateGameObject("Colliders", gameObject.layer, transform);

			foreach (var subset in design.CompiledParts)
			{
				var loadedPart = CwLoadedPart.Create();

				LoadedParts.Add(loadedPart); // NOTE: Property

				loadedPart.Parent   = this;
				loadedPart.Name        = subset.Name;
				loadedPart.Health      = subset.Health;
				loadedPart.Center      = subset.Center;
				loadedPart.Material    = subset.Material;

				loadedPart.ShapeRangeData.VertexRange = subset.ShapeRangeData.VertexRange;

				foreach (var indexRange in subset.ShapeRangeData.IndexRanges)
				{
					loadedPart.ShapeRangeData.IndexRanges.Add(indexRange);
				}

				loadedPart.DecalRangeData.VertexRange = subset.DecalRangeData.VertexRange;

				foreach (var indexRange in subset.DecalRangeData.IndexRanges)
				{
					loadedPart.DecalRangeData.IndexRanges.Add(indexRange);
				}

				foreach (var module in subset.Modules)
				{
					module.LoadedPart = loadedPart;

					var clone = Instantiate(module, transform);

					clone.transform.localPosition = module.CompiledPosition;
					clone.transform.localRotation = module.CompiledRotation;
					clone.transform.localScale    = module.CompiledScale;

					modules.Add(clone);
				}

				foreach (var colliderMesh in subset.ColliderMeshes)
				{
					var meshCollider = colliderRoot.AddComponent<MeshCollider>();

					loadedPart.MeshColliders.Add(meshCollider);

					meshCollider.convex     = true;
					meshCollider.sharedMesh = colliderMesh;

					colliderToPart.Add(meshCollider, loadedPart);
					colliderToPartIndex.Add(meshCollider, LoadedParts.Count - 1);
				}
			}
		}

		[ContextMenu("Clear")]
		public void Clear()
		{
			if (loadedParts != null)
			{
				foreach (var loadedPart in loadedParts)
				{
					CwLoadedPart.Delete(loadedPart);
				}

				loadedParts.Clear();
			}

			if (markTex != null)
			{
				markTex = CwHelper.Destroy(markTex);
			}

			if (modules != null)
			{
				foreach (var module in modules)
				{
					if (module != null)
					{
						CwHelper.Destroy(module.gameObject);
					}
				}
			}
			else
			{
				modules = new List<CwModule>();
			}

			colliderToPart.Clear();
			colliderToPartIndex.Clear();

			shapeRoot    = CwHelper.Destroy(shapeRoot);
			decalRoot    = CwHelper.Destroy(decalRoot);
			colliderRoot = CwHelper.Destroy(colliderRoot);

			shapeData.Clear();
			decalData.Clear();

			loaded = false;
		}

		private static List<MeshRenderer> tempMeshRenderers = new List<MeshRenderer>();

		private void ApplyShaderVariables()
		{
			/*
			GetComponentsInChildren(tempMeshRenderers);

			foreach (var tempMeshRenderer in tempMeshRenderers)
			{
				ApplyShaderVariables(tempMeshRenderer);
			}
			*/

			ApplyShaderVariables(shapeRenderer);
			ApplyShaderVariables(decalRenderer);
		}

		public void ApplyShaderVariables(Renderer renderer)
		{
			if (renderer != null)
			{
				renderer.GetSharedMaterials(tempMaterials);

				foreach (var tempMaterial in tempMaterials)
				{
					tempMaterial.SetTexture(_CW_MarkTex, markTex != null ? (Texture)markTex : (Texture)Texture2D.blackTexture);
					tempMaterial.SetColorArray(_CW_Colors, colors);
					tempMaterial.SetInt(_CW_StickerCount, design.StickerMatrices.Length);

					if (design.StickerPack != null && design.StickerPack.GeneratedTexture != null)
					{
						tempMaterial.SetTexture(_CW_StickerOpacityTex, design.StickerPack.GeneratedTexture);
					}

					if (design.StickerMatrices.Length > 0)
					{
						tempMaterial.SetMatrixArray(_CW_StickerMatrices, design.StickerMatrices);
						tempMaterial.SetVectorArray(_CW_StickerCoords, design.StickerCoords);
						tempMaterial.SetVectorArray(_CW_StickerDataA, design.StickerDataA);
						tempMaterial.SetVectorArray(_CW_StickerDataB, design.StickerDataB);
					}
				}
			}
		}

		/// <summary>If this object has damage marks, then this method will heal them all.</summary>
		[ContextMenu("Clear MarksTex")]
		public void ClearMarksTex()
		{
			if (markTex != null)
			{
				CwHelper.BeginActive(markTex);
					GL.Clear(false, true, new Color(0.0f, 0.0f, 0.0f, 0.0f));
				CwHelper.EndActive();

				markTex.GenerateMips();
			}
		}

		public void CreateMarksTex()
		{
			if (markTex == null)
			{
				var desc = new RenderTextureDescriptor(1024, 1024, RenderTextureFormat.ARGB32, 0);

				desc.sRGB             = false;
				desc.useMipMap        = true;
				desc.mipCount         = 8;
				desc.autoGenerateMips = false;

				markTex = new RenderTexture(desc);

				markTex.Create();
				markTex.DiscardContents();

				ClearMarksTex();

				ApplyShaderVariables();
			}
		}

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);

			LoadFromDesign();

			if (markTex == null && allowMarks == true)
			{
				CreateMarksTex();
			}

			ApplyShaderVariables();
		}

		protected virtual void OnDestroy()
		{
			Instances.Remove(node); node = null;

			if (markTex != null)
			{
				markTex = CwHelper.Destroy(markTex);
			}
		}

		private static Mesh quadMesh;
		private static bool quadMeshSet;

		public static Mesh GetQuadMesh()
		{
			if (quadMeshSet == false)
			{
				var gameObject = GameObject.CreatePrimitive(PrimitiveType.Quad);

				quadMeshSet = true;
				quadMesh    = gameObject.GetComponent<MeshFilter>().sharedMesh;

				DestroyImmediate(gameObject);
			}

			return quadMesh;
		}

		public void OnBeforeSerialize()
		{
			if (colliderToPartData == null)
			{
				colliderToPartData = new List<ColliderPartPair>();
			}
			else
			{
				colliderToPartData.Clear();
			}

			foreach (var pair in colliderToPartIndex)
			{
				colliderToPartData.Add(new ColliderPartPair() { Collider = pair.Key, PartIndex = pair.Value });
			}
		}

		public void OnAfterDeserialize()
		{
			colliderToPart.Clear();
			colliderToPartIndex.Clear();

			if (colliderToPartData != null && loadedParts != null)
			{
				foreach (var pair in colliderToPartData)
				{
					if (pair.PartIndex >= 0 && pair.PartIndex < loadedParts.Count)
					{
						colliderToPart.Add(pair.Collider, loadedParts[pair.PartIndex]);
						colliderToPartIndex.Add(pair.Collider, pair.PartIndex);
					}
				}
			}
		}
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwLoader;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwLoader_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.Design == null));
				Draw("design", "This allows you to choose which design will be loaded by this component.");
			EndError();

			DrawAllowMarks();

			Draw("allowRemoval", "If you enable this setting then damaged parts can be broken off.");
			if (Any(tgts, t => t.AllowRemoval == true))
			{
				BeginIndent();
					Draw("debrisPrefab", "When a part is destroyed it can break off and become debris. This setting allows you to choose what the debris settings will be based on.\n\nNone/null = Immediately destroy.");
				EndIndent();
			}

			DrawMaterialOverrides(tgt, tgts);
			DrawColorOverrides(tgt, tgts);
		}

		protected virtual void DrawAllowMarks()
		{
			Draw("allowMarks", "Do you want to allow damage mark and holes?\n\nNOTE: Marks can be applied manually using the <b>ApplyMark/All</b> methods, or in the editor using the <b>CwExplosion</b> component.");
		}

		private void DrawMaterialOverrides(TARGET tgt, TARGET[] tgts)
		{
			var removeIndex = -1;

			Separator();

			EditorGUILayout.BeginHorizontal();
				EditorGUILayout.LabelField("Material Overrides", EditorStyles.boldLabel);
				if (GUILayout.Button("+", GUILayout.Width(20)) == true)
				{
					Each(tgts, t => t.MaterialOverrides.Add(new TARGET.MaterialOverride()), true, true);
				}
			EditorGUILayout.EndHorizontal();

			EditorGUI.BeginChangeCheck();

			BeginIndent();
				for (var i = 0; i < tgt.MaterialOverrides.Count; i++)
				{
					var materialOverride = tgt.MaterialOverrides[i];

					EditorGUILayout.BeginHorizontal();
						EditorGUILayout.LabelField("Replace", GUILayout.Width(70));
						materialOverride.Index = EditorGUILayout.IntSlider(materialOverride.Index, 0, tgt.MaterialCount - 1);
						BeginDisabled();
							EditorGUILayout.ObjectField(tgt.GetDesignMaterial(materialOverride.Index), typeof(Material), false, GUILayout.Width(150));
						EndDisabled();
						if (GUILayout.Button("x", GUILayout.Width(20)) == true)
						{
							removeIndex = i;
						}
					EditorGUILayout.EndHorizontal();
					EditorGUILayout.BeginHorizontal();
						EditorGUILayout.LabelField("With", GUILayout.Width(70));
						BeginError(materialOverride.Replacement == null);
							materialOverride.Replacement = (Material)EditorGUILayout.ObjectField(materialOverride.Replacement, typeof(Material), false);
						EndError();
					EditorGUILayout.EndHorizontal();

					tgt.MaterialOverrides[i] = materialOverride;
				}
			EndIndent();

			if (removeIndex >= 0)
			{
				tgt.MaterialOverrides.RemoveAt(removeIndex);
			}

			if (EditorGUI.EndChangeCheck() == true)
			{
				DirtyAndUpdate();
			}
		}

		private void DrawColorOverrides(TARGET tgt, TARGET[] tgts)
		{
			var removeIndex = -1;

			Separator();

			EditorGUILayout.BeginHorizontal();
				EditorGUILayout.LabelField("Color Overrides", EditorStyles.boldLabel);
				if (GUILayout.Button("+", GUILayout.Width(20)) == true)
				{
					Each(tgts, t => t.ColorOverrides.Add(new TARGET.ColorOverride()), true, true);
				}
			EditorGUILayout.EndHorizontal();

			EditorGUI.BeginChangeCheck();

			BeginIndent();
				for (var i = 0; i < tgt.ColorOverrides.Count; i++)
				{
					var colorOverride = tgt.ColorOverrides[i];

					EditorGUILayout.BeginHorizontal();
						EditorGUILayout.LabelField("Replace", GUILayout.Width(70));
						colorOverride.Index = EditorGUILayout.IntSlider(colorOverride.Index, 0, tgt.ColorCount - 1);
						BeginDisabled();
							EditorGUILayout.ColorField(tgt.GetDesignColor(colorOverride.Index), GUILayout.Width(150));
						EndDisabled();
						if (GUILayout.Button("x", GUILayout.Width(20)) == true)
						{
							removeIndex = i;
						}
					EditorGUILayout.EndHorizontal();
					EditorGUILayout.BeginHorizontal();
						EditorGUILayout.LabelField("With", GUILayout.Width(70));
						colorOverride.Replacement = EditorGUILayout.ColorField(colorOverride.Replacement);
					EditorGUILayout.EndHorizontal();

					tgt.ColorOverrides[i] = colorOverride;
				}
			EndIndent();

			if (removeIndex >= 0)
			{
				tgt.ColorOverrides.RemoveAt(removeIndex);
			}

			if (EditorGUI.EndChangeCheck() == true)
			{
				DirtyAndUpdate();
			}
		}
	}
}
#endif