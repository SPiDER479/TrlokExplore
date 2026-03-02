using UnityEngine;
using System.Collections.Generic;
using System;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component allows you to bake a prefab into a cross-impostor.</summary>
	public class SgtLandscapeCrossImpostorBuilder : ScriptableObject
	{
		/// <summary>The prefab that will be baked.</summary>
		public GameObject SourcePrefab { set { sourcePrefab = value; } get { return sourcePrefab; } } [SerializeField] private GameObject sourcePrefab;

		/// <summary>The material used by the generated mesh.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The baked mesh asset.</summary>
		public Mesh BakedMesh { set { bakedMesh = value; } get { return bakedMesh; } } [SerializeField] private Mesh bakedMesh;

		/// <summary>The maximum size of a single view frame in pixels.</summary>
		public int MaxFrameSize { set { maxFrameSize = value; } get { return maxFrameSize; } } [SerializeField] private int maxFrameSize = 512;

		/// <summary>The number of padding pixels around each frame in the atlas.</summary>
		public int FramePadding { set { framePadding = value; } get { return framePadding; } } [SerializeField] private int framePadding = 4;

		// Baked Results
		public Vector3 BakedOffset;
		public Vector3 BakedExtents;
		[HideInInspector] public Vector4[] FrameUVRects = new Vector4[6];
		[HideInInspector] public int AtlasWidth;
		[HideInInspector] public int AtlasHeight;
		[HideInInspector] public Vector2Int[] AxisFrameSizes = new Vector2Int[3];
		[HideInInspector] public Vector2[] AxisWorldHalfSizes = new Vector2[3];
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	using UnityEditor;
	using CW.Common;

	[CustomEditor(typeof(SgtLandscapeCrossImpostorBuilder))]
	public class SgtLandscapeCrossImpostorBuilder_Editor : CwEditor
	{
		private static readonly Vector3[] ViewDirs = { Vector3.right, Vector3.left, Vector3.up, Vector3.down, Vector3.forward, Vector3.back };
		private static readonly Vector3[] ViewUps = { Vector3.up, Vector3.up, Vector3.forward, Vector3.forward, Vector3.up, Vector3.up };

		[MenuItem("Assets/Create/CW/Space Graphics Toolkit/Cross Impostor Builder")]
		private static void CreateAsset()
		{
			var guids = Selection.assetGUIDs;
			var path  = guids.Length > 0 ? AssetDatabase.GUIDToAssetPath(guids[0]) : default(string);

			CreateImpostorAsset(string.IsNullOrEmpty(path) == false ? AssetDatabase.LoadAssetAtPath<GameObject>(path) : null, path);
		}

		public static SgtLandscapeCrossImpostorBuilder CreateImpostorAsset(GameObject prefab, string path)
		{
			var asset = CreateInstance<SgtLandscapeCrossImpostorBuilder>();
			var name  = "CrossImpostor";

			if (string.IsNullOrEmpty(path) == true || path.StartsWith("Library/", System.StringComparison.InvariantCultureIgnoreCase))
			{
				path = "Assets";
			}
			else if (AssetDatabase.IsValidFolder(path) == false)
			{
				path = System.IO.Path.GetDirectoryName(path);
			}

			if (prefab != null)
			{
				name = prefab.name + "_" + name;

				asset.SourcePrefab = prefab;
			}

			var assetPathAndName = AssetDatabase.GenerateUniqueAssetPath(path + "/" + name + ".asset");

			AssetDatabase.CreateAsset(asset, assetPathAndName);

			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh();
			EditorUtility.FocusProjectWindow();

			EditorGUIUtility.PingObject(asset);

			return asset;
		}

		protected override void OnInspector()
		{
			var data = (SgtLandscapeCrossImpostorBuilder)target;

			BeginError(data.SourcePrefab == null);
				Draw("sourcePrefab", "The prefab that will be baked.");
			EndError();

			using (new EditorGUI.DisabledScope(true))
			{
				Draw("material", "The material used by the generated mesh.");
				Draw("bakedMesh", "The baked mesh asset.");
			}

			Draw("maxFrameSize", "The maximum size of a single view frame in pixels.");
			Draw("framePadding", "The number of padding pixels around each frame in the atlas.");

			if (data.BakedExtents.sqrMagnitude > 0f)
			{
				Separator();
				EditorGUILayout.LabelField("Bake Results", EditorStyles.boldLabel);
				using (new EditorGUI.DisabledScope(true))
				{
					EditorGUILayout.Vector3Field("Extents", data.BakedExtents);
					EditorGUILayout.Vector3Field("Offset", data.BakedOffset);
					EditorGUILayout.LabelField("Atlas: " + data.AtlasWidth + "x" + data.AtlasHeight);
				}
			}

			Separator();

			using (new EditorGUI.DisabledScope(data.SourcePrefab == null))
			{
				if (GUILayout.Button("Bake"))
				{
					Bake(data);
				}
			}
		}

		public static void Bake(SgtLandscapeCrossImpostorBuilder data)
		{
			var go = (GameObject)PrefabUtility.InstantiatePrefab(data.SourcePrefab);
			if (go != null)
			{
				try
				{
					EditorUtility.DisplayProgressBar("Baking Landscape Impostor", data.SourcePrefab.name, 0);
					Capture(go.transform, data);
				}
				catch (Exception e)
				{
					Debug.LogException(e);
				}
				finally
				{
					EditorUtility.ClearProgressBar();
					DestroyImmediate(go);
				}
			}
		}

		private static Shader GetShader(ref Shader cache, string shaderPath)
		{
			if (cache == null)
			{
				cache = Shader.Find(shaderPath);
			}
			return cache;
		}

		private static Bounds ComputeBounds(Transform root)
		{
			var bounds = new Bounds(root.position, Vector3.zero);
			foreach (var mr in root.GetComponentsInChildren<MeshRenderer>())
			{
				if (mr.enabled == false) continue;
				var mf = mr.GetComponent<MeshFilter>();
				if (mf != null && mf.sharedMesh != null)
				{
					foreach (var v in mf.sharedMesh.vertices)
					{
						bounds.Encapsulate(mf.transform.localToWorldMatrix.MultiplyPoint3x4(v));
					}
				}
			}
			return bounds;
		}

		private static void SetLayersRecursive(Transform t, int layer, Dictionary<GameObject, int> store)
		{
			store[t.gameObject] = t.gameObject.layer;
			t.gameObject.layer = layer;
			foreach (Transform c in t)
			{
				SetLayersRecursive(c, layer, store);
			}
		}

		private static void RestoreLayers(Dictionary<GameObject, int> s)
		{
			foreach (var kv in s)
			{
				if (kv.Key != null) kv.Key.layer = kv.Value;
			}
		}

		private static void Dilate(Color32[] px, bool[] mask, int w, int h, int iters)
		{
			var filled = (bool[])mask.Clone();
			var queue = new Queue<int>();
			for (var i = 0; i < px.Length; i++)
			{
				if (mask[i] == true) queue.Enqueue(i);
			}

			int[] off = { -1, 1, -w, w };
			for (var iter = 0; iter < iters && queue.Count > 0; iter++)
			{
				var count = queue.Count;
				for (var q = 0; q < count; q++)
				{
					var i = queue.Dequeue();
					var x = i % w;
					var y = i / w;

					for (var d = 0; d < 4; d++)
					{
						if ((d == 0 && x == 0) || (d == 1 && x == w - 1) || (d == 2 && y == 0) || (d == 3 && y == h - 1)) continue;
						var ni = i + off[d];
						if (filled[ni] == true) continue;
						filled[ni] = true;
						px[ni] = px[i];
						queue.Enqueue(ni);
					}
				}
			}
		}

		private static RenderTexture TempRT(int w, int h, int depth, bool srgb)
		{
			return RenderTexture.GetTemporary(w, h, depth, RenderTextureFormat.ARGB32, srgb ? RenderTextureReadWrite.sRGB : RenderTextureReadWrite.Linear);
		}

		private static Texture2D ReadTex(RenderTexture rt, int size, bool isLinear)
		{
			var oldActive = RenderTexture.active;
			var tex = new Texture2D(size, size, TextureFormat.ARGB32, false, isLinear);
			RenderTexture.active = rt;
			tex.ReadPixels(new Rect(0, 0, size, size), 0, 0);
			tex.Apply();
			RenderTexture.active = oldActive;
			return tex;
		}

		private static Material EnsureMaterial(SgtLandscapeCrossImpostorBuilder data)
		{
			var dir  = System.IO.Path.GetDirectoryName(AssetDatabase.GetAssetPath(data));
			var name = string.IsNullOrEmpty(data.name) ? data.SourcePrefab.name : data.name;
			var path = dir + "/" + name + "_Material.mat";

			var mat = data.Material;
			if (mat == null)
			{
				mat = AssetDatabase.LoadAssetAtPath<Material>(path);
			}

			if (mat == null)
			{
				var shader = Shader.Find("Space Graphics Toolkit/LandscapeStaticSingle");
				if (shader == null)
				{
					Debug.LogError("Shader 'Space Graphics Toolkit/LandscapeStaticSingle' not found.");
					return null;
				}
				mat = new Material(shader);
				AssetDatabase.CreateAsset(mat, path);
			}

			// Set Keywords and Features
			mat.EnableKeyword("_SGT_CROSS_IMPOSTOR");
			mat.SetFloat("_SGT_CrossImpostor", 1.0f);

			mat.EnableKeyword("_SGT_STATIC");
			mat.SetFloat("_SGT_Static", 1.0f);

			EditorUtility.SetDirty(mat);
			data.Material = mat;
			return mat;
		}

		private static void UpdateTextureImportSettings(string path, bool isNormalMap, bool isSRGB, bool alphaIsT)
		{
			var importer = AssetImporter.GetAtPath(path) as TextureImporter;
			if (importer != null)
			{
				importer.textureType         = isNormalMap ? TextureImporterType.NormalMap : TextureImporterType.Default;
				importer.sRGBTexture         = isSRGB;
				importer.alphaIsTransparency = alphaIsT;
				importer.SaveAndReimport();
			}
		}

		private static Texture2D CropAndDownsample(Texture2D src, RectInt crop, int dstW, int dstH, bool srgb)
		{
			var oldActive = RenderTexture.active;

			var srcRT = TempRT(src.width, src.height, 0, srgb);
			Graphics.Blit(src, srcRT);
			var cropped = new Texture2D(crop.width, crop.height, TextureFormat.ARGB32, false, !srgb);
			RenderTexture.active = srcRT;
			cropped.ReadPixels(new Rect(crop.x, crop.y, crop.width, crop.height), 0, 0);
			cropped.Apply();
			RenderTexture.ReleaseTemporary(srcRT);

			var cropRT = TempRT(crop.width, crop.height, 0, srgb);
			Graphics.Blit(cropped, cropRT);
			DestroyImmediate(cropped);

			var dstRT = TempRT(dstW, dstH, 0, srgb);
			Graphics.Blit(cropRT, dstRT);
			RenderTexture.ReleaseTemporary(cropRT);

			var result = new Texture2D(dstW, dstH, TextureFormat.ARGB32, false, !srgb);
			RenderTexture.active = dstRT;
			result.ReadPixels(new Rect(0, 0, dstW, dstH), 0, 0);
			result.Apply();
			RenderTexture.ReleaseTemporary(dstRT);

			RenderTexture.active = oldActive;

			return result;
		}

		private static void BuildMesh(SgtLandscapeCrossImpostorBuilder data, Mesh mesh)
		{
			var verts = new List<Vector3>();
			var uv0   = new List<Vector2>();
			var uv1   = new List<Vector2>();
			var tris  = new List<int>();

			for (var vi = 0; vi < 6; vi++)
			{
				var axis   = vi / 2;
				var wh     = data.AxisWorldHalfSizes[axis];
				var uvR    = data.FrameUVRects[vi];
				var camRot = Quaternion.LookRotation(-ViewDirs[vi], ViewUps[vi]);
				var right  = camRot * Vector3.right;
				var up     = camRot * Vector3.up;
				var r      = right * wh.x;
				var u      = up * wh.y;
				var c      = data.BakedOffset;
				var b      = verts.Count;

				verts.Add(c - r - u); verts.Add(c + r - u); verts.Add(c + r + u); verts.Add(c - r + u);

				for (var i = 0; i < 4; i++) uv1.Add(new Vector2((vi + 0.5f) / 6f, 0));

				uv0.Add(new Vector2(uvR.x, uvR.y));
				uv0.Add(new Vector2(uvR.x + uvR.z, uvR.y));
				uv0.Add(new Vector2(uvR.x + uvR.z, uvR.y + uvR.w));
				uv0.Add(new Vector2(uvR.x, uvR.y + uvR.w));

				tris.Add(b); tris.Add(b + 2); tris.Add(b + 1);
				tris.Add(b); tris.Add(b + 3); tris.Add(b + 2);
			}

			mesh.Clear(); // Important: Clear data to reuse the existing asset reference
			mesh.SetVertices(verts);
			mesh.SetUVs(0, uv0);
			mesh.SetUVs(1, uv1);
			mesh.SetTriangles(tris, 0);
			mesh.RecalculateBounds();
			mesh.RecalculateNormals();
			mesh.RecalculateTangents();
		}

		private static RectInt FindTrimRect(Color32[] px, int size)
		{
			var minX = size; var maxX = 0; var minY = size; var maxY = 0;
			for (var p = 0; p < px.Length; p++)
			{
				if (px[p].a == 0) continue;
				var x = p % size; var y = p / size;
				minX = Mathf.Min(minX, x); maxX = Mathf.Max(maxX, x);
				minY = Mathf.Min(minY, y); maxY = Mathf.Max(maxY, y);
			}
			if (maxX < minX) { minX = size / 2 - 1; maxX = size / 2 + 1; minY = size / 2 - 1; maxY = size / 2 + 1; }
			minX = Mathf.Max(0, minX - 2); maxX = Mathf.Min(size - 1, maxX + 2);
			minY = Mathf.Max(0, minY - 2); maxY = Mathf.Min(size - 1, maxY + 2);
			return new RectInt(minX, minY, maxX - minX + 1, maxY - minY + 1);
		}

		private static readonly string[] AlbedoTexNames = {
            "_MainTex", "_BaseMap", "_BaseColorMap", "_AlbedoMap", "_Albedo",
            "_DiffuseMap", "_Diffuse"
        };
        private static readonly string[] NormalTexNames = {
            "_BumpMap", "_NormalMap", "_NormalMapOS", "_DetailNormalMap",
            "_NormalTex"
        };
        private static readonly string[] MetallicTexNames = {
            "_MetallicGlossMap", "_MaskMap", "_MetallicMap", "_SpecGlossMap",
            "_MetallicSmoothnessMap"
        };
        private static readonly string[] EmissionTexNames = {
            "_EmissionMap", "_EmissiveMap", "_EmissiveColorMap", "_EmissionTex"
        };
        private static readonly string[] AlphaCutoffNames = {
            "_Cutoff", "_AlphaCutoff", "_AlphaClip", "_AlphaClipThreshold"
        };

        private static Texture FindTexture(Material mat, string[] candidates)
        {
            if (mat == null || mat.shader == null) return null;

            var shader = mat.shader;
            foreach (var name in candidates)
            {
                // Verify the property actually exists on the shader and is a texture type
                int idx = shader.FindPropertyIndex(name);
                if (idx < 0) continue;
                if (shader.GetPropertyType(idx) != UnityEngine.Rendering.ShaderPropertyType.Texture) continue;

                try
                {
                    var tex = mat.GetTexture(name);
                    if (tex != null) return tex;
                }
                catch
                {
                    // Skip any remaining edge cases
                }
            }
            return null;
        }

        private static float FindAlphaCutoff(Material mat)
        {
            foreach (var name in AlphaCutoffNames)
            {
                if (mat.HasProperty(name))
                    return mat.GetFloat(name);
            }
            return 0.5f;
        }

        private static bool IsAlphaCutout(Material mat)
        {
            // Check common ways to detect cutout mode
            if (mat.IsKeywordEnabled("_ALPHATEST_ON")) return true;
            if (mat.IsKeywordEnabled("_ALPHA_CUTOUT")) return true;
            if (mat.HasProperty("_AlphaClip") && mat.GetFloat("_AlphaClip") > 0.5f) return true;
            if (mat.HasProperty("_Mode") && Mathf.Approximately(mat.GetFloat("_Mode"), 1f)) return true; // Cutout in BIRP
            if (mat.HasProperty("_Surface") && mat.renderQueue < 3000 && mat.renderQueue >= 2450) return true;
            return false;
        }

        private struct MeshRenderInfo
        {
            public Mesh mesh;
            public Matrix4x4 transform;
            public Material[] materials;
        }

        private static List<MeshRenderInfo> GatherMeshes(Transform root)
        {
            var result = new List<MeshRenderInfo>();

            var meshFilters = root.GetComponentsInChildren<MeshFilter>(false);
            foreach (var mf in meshFilters)
            {
                var mr = mf.GetComponent<MeshRenderer>();
                if (mr == null || !mr.enabled || mf.sharedMesh == null) continue;
                result.Add(new MeshRenderInfo
                {
                    mesh = mf.sharedMesh,
                    transform = mf.transform.localToWorldMatrix,
                    materials = mr.sharedMaterials
                });
            }

            var smrs = root.GetComponentsInChildren<SkinnedMeshRenderer>(false);
            foreach (var smr in smrs)
            {
                if (!smr.enabled) continue;
                var bakedMesh = new Mesh();
                smr.BakeMesh(bakedMesh);
                result.Add(new MeshRenderInfo
                {
                    mesh = bakedMesh,
                    transform = smr.transform.localToWorldMatrix,
                    materials = smr.sharedMaterials
                });
            }

            return result;
        }

        private static void RenderMeshesWithBakeMat(
            List<MeshRenderInfo> meshes,
            Material bakeMat,
            int bakeMode,
            float nearClip,
            float farClip)
        {
            bakeMat.SetFloat("_BakeMode", bakeMode);
            bakeMat.SetFloat("_NearClip", nearClip);
            bakeMat.SetFloat("_FarClip", farClip);

            foreach (var mri in meshes)
            {
                int subMeshCount = mri.mesh.subMeshCount;
                for (int sub = 0; sub < subMeshCount; sub++)
                {
                    var srcMat = (sub < mri.materials.Length && mri.materials[sub] != null)
                        ? mri.materials[sub]
                        : null;

                    // Find albedo texture
                    Texture albedoTex = srcMat != null ? FindTexture(srcMat, AlbedoTexNames) : null;
                    bakeMat.SetTexture("_AlbedoTex", albedoTex != null ? albedoTex : Texture2D.whiteTexture);

                    // Find the specific bake texture based on mode
                    Texture bakeTex = null;
                    if (srcMat != null)
                    {
                        switch (bakeMode)
                        {
                            case 0: // Albedo - bake tex is same as albedo
                                bakeTex = albedoTex;
                                break;
                            case 1: // Normal
                                bakeTex = FindTexture(srcMat, NormalTexNames);
                                break;
                            case 2: // Depth - no texture needed
                                break;
                            case 3: // Metallic
                                bakeTex = FindTexture(srcMat, MetallicTexNames);
                                break;
                            case 4: // Emission
                                bakeTex = FindTexture(srcMat, EmissionTexNames);
                                break;
                        }
                    }

                    // For normal mode, default to flat normal if no normal map
                    if (bakeMode == 1 && bakeTex == null)
                    {
                        // Create a 1x1 flat normal texture (0.5, 0.5, 1.0)
                        bakeMat.SetTexture("_BakeTex", Texture2D.normalTexture);
                    }
                    else
                    {
                        bakeMat.SetTexture("_BakeTex", bakeTex != null ? bakeTex : Texture2D.whiteTexture);
                    }

                    // Alpha cutout
                    bool cutout = srcMat != null && IsAlphaCutout(srcMat);
                    bakeMat.SetFloat("_UseAlphaCutout", cutout ? 1f : 0f);
                    bakeMat.SetFloat("_AlphaCutoff", srcMat != null ? FindAlphaCutoff(srcMat) : 0.5f);

                    bakeMat.SetPass(0);
                    Graphics.DrawMeshNow(mri.mesh, mri.transform, sub);
                }
            }
        }

        private static void Capture(Transform root, SgtLandscapeCrossImpostorBuilder data)
        {
            var bakeShader = Shader.Find("Hidden/SgtLandscape_BakePass");
            if (bakeShader == null)
            {
                Debug.LogError("Could not find Hidden/SgtLandscape_BakePass shader.");
                return;
            }

            var bakeMat = new Material(bakeShader);

            var maxFS = data.MaxFrameSize;
            var padding = Mathf.Max(0, data.FramePadding);
            var origScale = root.localScale;
            root.localScale = Vector3.one;

            var bounds = ComputeBounds(root);
            var extents = bounds.extents;
            var offset = bounds.center - root.position;

            if (extents.magnitude < 0.0001f)
            {
                Debug.LogError("Prefab has no valid bounds.");
                root.localScale = origScale;
                DestroyImmediate(bakeMat);
                return;
            }

            var renderSize = maxFS * 4;

            var superAlbedo   = TempRT(renderSize, renderSize, 32, true);
            var superNormal   = TempRT(renderSize, renderSize, 32, false);
            var superDepth    = TempRT(renderSize, renderSize, 32, false);
            var superMetallic = TempRT(renderSize, renderSize, 32, false);
            var superEmission = TempRT(renderSize, renderSize, 32, true);

            var meshes = GatherMeshes(root);
            var center = root.position + offset;

            var albedos   = new Texture2D[6];
            var normals   = new Texture2D[6];
            var depths    = new Texture2D[6];
            var metallics = new Texture2D[6];
            var emissions = new Texture2D[6];

            var trimRects = new RectInt[6];

            for (var vi = 0; vi < 6; vi++)
            {
                var axis = vi / 2;
                var camDist = extents[axis] * 2f;
                var orthoSize = Mathf.Max(extents.x, Mathf.Max(extents.y, extents.z));
                var nearClip = 0f;
                var farClip = camDist * 2f;

                var camPos = center + ViewDirs[vi] * camDist;
                var camRot = Quaternion.LookRotation(-ViewDirs[vi], ViewUps[vi]);

                // Build view and projection matrices manually
                var viewMatrix = Matrix4x4.TRS(camPos, camRot, Vector3.one).inverse;
                // Flip Z for Unity convention
                viewMatrix.m20 = -viewMatrix.m20;
                viewMatrix.m21 = -viewMatrix.m21;
                viewMatrix.m22 = -viewMatrix.m22;
                viewMatrix.m23 = -viewMatrix.m23;

                var projMatrix = Matrix4x4.Ortho(
                    -orthoSize, orthoSize,
                    -orthoSize, orthoSize,
                    nearClip, farClip);

                // Set GL matrices
                GL.PushMatrix();
                GL.LoadProjectionMatrix(projMatrix);
                Shader.SetGlobalMatrix("unity_MatrixV", viewMatrix);
                Shader.SetGlobalMatrix("unity_MatrixVP", projMatrix * viewMatrix);

                // We also need to set UNITY_MATRIX_V for the shader
                // Using GL.modelview is more reliable
                GL.modelview = viewMatrix;

                // Albedo (mode 0)
                Graphics.SetRenderTarget(superAlbedo);
                GL.Clear(true, true, Color.clear);
                GL.LoadProjectionMatrix(projMatrix);
                GL.modelview = viewMatrix;
                RenderMeshesWithBakeMat(meshes, bakeMat, 0, nearClip, farClip);
                albedos[vi] = ReadTex(superAlbedo, renderSize, false);

                // Normal (mode 1)
                Graphics.SetRenderTarget(superNormal);
                GL.Clear(true, true, new Color(0.5f, 0.5f, 1.0f, 0.0f));
                GL.LoadProjectionMatrix(projMatrix);
                GL.modelview = viewMatrix;
                RenderMeshesWithBakeMat(meshes, bakeMat, 1, nearClip, farClip);
                normals[vi] = ReadTex(superNormal, renderSize, true);

                // Depth (mode 2)
                Graphics.SetRenderTarget(superDepth);
                GL.Clear(true, true, Color.clear);
                GL.LoadProjectionMatrix(projMatrix);
                GL.modelview = viewMatrix;
                RenderMeshesWithBakeMat(meshes, bakeMat, 2, nearClip, farClip);
                depths[vi] = ReadTex(superDepth, renderSize, true);

                // Metallic (mode 3)
                Graphics.SetRenderTarget(superMetallic);
                GL.Clear(true, true, Color.clear);
                GL.LoadProjectionMatrix(projMatrix);
                GL.modelview = viewMatrix;
                RenderMeshesWithBakeMat(meshes, bakeMat, 3, nearClip, farClip);
                metallics[vi] = ReadTex(superMetallic, renderSize, true);

                // Emission (mode 4)
                Graphics.SetRenderTarget(superEmission);
                GL.Clear(true, true, Color.clear);
                GL.LoadProjectionMatrix(projMatrix);
                GL.modelview = viewMatrix;
                RenderMeshesWithBakeMat(meshes, bakeMat, 4, nearClip, farClip);
                emissions[vi] = ReadTex(superEmission, renderSize, false);

                GL.PopMatrix();

                trimRects[vi] = FindTrimRect(albedos[vi].GetPixels32(), renderSize);
            }

            RenderTexture.active = null;

            RenderTexture.ReleaseTemporary(superAlbedo);
            RenderTexture.ReleaseTemporary(superNormal);
            RenderTexture.ReleaseTemporary(superDepth);
            RenderTexture.ReleaseTemporary(superMetallic);
            RenderTexture.ReleaseTemporary(superEmission);

            // Clean up baked skinned meshes
            foreach (var mri in meshes)
            {
                if (!AssetDatabase.Contains(mri.mesh))
                    DestroyImmediate(mri.mesh);
            }

            DestroyImmediate(bakeMat);
            root.localScale = origScale;

            var axisTrims = new RectInt[3];
            for (var a = 0; a < 3; a++)
            {
                var r0 = trimRects[a * 2]; var r1 = trimRects[a * 2 + 1];
                var x0 = Mathf.Min(r0.xMin, r1.xMin); var x1 = Mathf.Max(r0.xMax, r1.xMax);
                var y0 = Mathf.Min(r0.yMin, r1.yMin); var y1 = Mathf.Max(r0.yMax, r1.yMax);
                axisTrims[a] = new RectInt(x0, y0, x1 - x0, y1 - y0);
            }

            var orthoUsed = Mathf.Max(extents.x, Mathf.Max(extents.y, extents.z));
            var worldPerPx = orthoUsed * 2f / renderSize;
            var axisWorldHalf = new Vector2[3];
            var maxWorldDim = 0f;

            for (var a = 0; a < 3; a++)
            {
                axisWorldHalf[a] = new Vector2(axisTrims[a].width * worldPerPx * 0.5f, axisTrims[a].height * worldPerPx * 0.5f);
                maxWorldDim = Mathf.Max(maxWorldDim, Mathf.Max(axisWorldHalf[a].x, axisWorldHalf[a].y) * 2f);
            }

            var texelsPerUnit = maxFS / maxWorldDim;
            var axisFinalSizes = new Vector2Int[3];
            for (var a = 0; a < 3; a++)
            {
                var fw = Mathf.Max(2, Mathf.Min(maxFS, Mathf.CeilToInt(axisWorldHalf[a].x * 2f * texelsPerUnit) / 2 * 2));
                var fh = Mathf.Max(2, Mathf.Min(maxFS, Mathf.CeilToInt(axisWorldHalf[a].y * 2f * texelsPerUnit) / 2 * 2));
                axisFinalSizes[a] = new Vector2Int(fw, fh);
            }

            var pad2 = padding * 2;
            var atlasW = (axisFinalSizes[0].x + pad2) + (axisFinalSizes[1].x + pad2) + (axisFinalSizes[2].x + pad2);
            var maxFrameH = Mathf.Max(axisFinalSizes[0].y, Mathf.Max(axisFinalSizes[1].y, axisFinalSizes[2].y));
            var atlasH = (maxFrameH + pad2) * 2;

            var albAtlasPx = new Color32[atlasW * atlasH];
            var nrmAtlasPx = new Color32[atlasW * atlasH];
            var depAtlasPx = new Color32[atlasW * atlasH];
            var metAtlasPx = new Color32[atlasW * atlasH];
            var emiAtlasPx = new Color32[atlasW * atlasH];

            var colOffsets = new int[] { padding, (axisFinalSizes[0].x + pad2) + padding, (axisFinalSizes[0].x + pad2) + (axisFinalSizes[1].x + pad2) + padding };
            var frameUVs = new Vector4[6];

            for (var vi = 0; vi < 6; vi++)
            {
                var axis = vi / 2;
                var fs = axisFinalSizes[axis];

                var cAlb = CropAndDownsample(albedos[vi],   axisTrims[axis], fs.x, fs.y, true);
                var cNrm = CropAndDownsample(normals[vi],   axisTrims[axis], fs.x, fs.y, false);
                var cDep = CropAndDownsample(depths[vi],    axisTrims[axis], fs.x, fs.y, false);
                var cMet = CropAndDownsample(metallics[vi], axisTrims[axis], fs.x, fs.y, false);
                var cEmi = CropAndDownsample(emissions[vi], axisTrims[axis], fs.x, fs.y, true);

                var albPx = cAlb.GetPixels32();
                var nrmPx = cNrm.GetPixels32();
                var depPx = cDep.GetPixels32();
                var metPx = cMet.GetPixels32();
                var emiPx = cEmi.GetPixels32();

                var mask = new bool[albPx.Length];
                var origA    = new byte[albPx.Length];
                var origNrmA = new byte[nrmPx.Length];
                var origDepA = new byte[depPx.Length];
                var origMetA = new byte[metPx.Length];
                var origEmiA = new byte[emiPx.Length];

                for (var i = 0; i < albPx.Length; i++)
                {
                    mask[i]     = albPx[i].a > 0;
                    origA[i]    = albPx[i].a;
                    origNrmA[i] = nrmPx[i].a;
                    origDepA[i] = depPx[i].a;
                    origMetA[i] = metPx[i].a;
                    origEmiA[i] = emiPx[i].a;
                }

                var dilateIter = Mathf.Max(4, Mathf.Max(fs.x, fs.y) / 32);
                Dilate(albPx, mask, fs.x, fs.y, dilateIter);
                Dilate(nrmPx, mask, fs.x, fs.y, dilateIter);
                Dilate(depPx, mask, fs.x, fs.y, dilateIter);
                Dilate(metPx, mask, fs.x, fs.y, dilateIter);
                Dilate(emiPx, mask, fs.x, fs.y, dilateIter);

                for (var i = 0; i < albPx.Length; i++)
                {
                    albPx[i].a = origA[i];
                    nrmPx[i].a = origNrmA[i];
                    depPx[i].a = origDepA[i];
                    metPx[i].a = origMetA[i];
                    emiPx[i].a = origEmiA[i];
                }

                var ox = colOffsets[axis];
                var oy = (vi % 2) * (maxFrameH + pad2) + padding;
                var yOff = (maxFrameH - fs.y) / 2;

                for (var py = 0; py < fs.y; py++)
                {
                    for (var px = 0; px < fs.x; px++)
                    {
                        var ai = (oy + yOff + py) * atlasW + ox + px;
                        var fi = py * fs.x + px;

                        albAtlasPx[ai] = albPx[fi];
                        nrmAtlasPx[ai] = nrmPx[fi];
                        depAtlasPx[ai] = depPx[fi];
                        metAtlasPx[ai] = metPx[fi];
                        emiAtlasPx[ai] = emiPx[fi];
                    }
                }

                frameUVs[vi] = new Vector4((float)ox / atlasW, (float)(oy + yOff) / atlasH, (float)fs.x / atlasW, (float)fs.y / atlasH);

                DestroyImmediate(cAlb); DestroyImmediate(cNrm); DestroyImmediate(cDep); DestroyImmediate(cMet); DestroyImmediate(cEmi);
                DestroyImmediate(albedos[vi]); DestroyImmediate(normals[vi]); DestroyImmediate(depths[vi]); DestroyImmediate(metallics[vi]); DestroyImmediate(emissions[vi]);
            }

            var atlasAlb = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, true, false); atlasAlb.SetPixels32(albAtlasPx); atlasAlb.Apply();
            var atlasNrm = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, true, true);  atlasNrm.SetPixels32(nrmAtlasPx); atlasNrm.Apply();
            var atlasDep = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, true, true);  atlasDep.SetPixels32(depAtlasPx); atlasDep.Apply();
            var atlasMet = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, true, true);  atlasMet.SetPixels32(metAtlasPx); atlasMet.Apply();
            var atlasEmi = new Texture2D(atlasW, atlasH, TextureFormat.ARGB32, true, false); atlasEmi.SetPixels32(emiAtlasPx); atlasEmi.Apply();

            data.BakedOffset = offset;
            data.BakedExtents = extents;
            data.FrameUVRects = frameUVs;
            data.AtlasWidth = atlasW;
            data.AtlasHeight = atlasH;
            data.AxisFrameSizes = axisFinalSizes;
            data.AxisWorldHalfSizes = axisWorldHalf;

            var dir = System.IO.Path.GetDirectoryName(AssetDatabase.GetAssetPath(data));
            var baseName = string.IsNullOrEmpty(data.name) ? data.SourcePrefab.name : data.name;

            var albPath = dir + "/" + baseName + "_Albedo.png";
            var nrmPath = dir + "/" + baseName + "_Normal.png";
            var depPath = dir + "/" + baseName + "_Depth.png";
            var metPath = dir + "/" + baseName + "_Metallic.png";
            var emiPath = dir + "/" + baseName + "_Emission.png";

            System.IO.File.WriteAllBytes(albPath, atlasAlb.EncodeToPNG());
            System.IO.File.WriteAllBytes(nrmPath, atlasNrm.EncodeToPNG());
            System.IO.File.WriteAllBytes(depPath, atlasDep.EncodeToPNG());
            System.IO.File.WriteAllBytes(metPath, atlasMet.EncodeToPNG());
            System.IO.File.WriteAllBytes(emiPath, atlasEmi.EncodeToPNG());

            DestroyImmediate(atlasAlb);
            DestroyImmediate(atlasNrm);
            DestroyImmediate(atlasDep);
            DestroyImmediate(atlasMet);
            DestroyImmediate(atlasEmi);

            AssetDatabase.Refresh();

            UpdateTextureImportSettings(albPath, false, true,  true);
            UpdateTextureImportSettings(nrmPath, true,  false, false);
            UpdateTextureImportSettings(depPath, false, false, false);
            UpdateTextureImportSettings(metPath, false, false, false);
            UpdateTextureImportSettings(emiPath, false, true,  false);

            // Update or Create Mesh
            var mesh = data.BakedMesh;
            var meshName = baseName + "_Mesh";
            if (mesh == null)
            {
                var meshPath = dir + "/" + meshName + ".asset";
                mesh = AssetDatabase.LoadAssetAtPath<Mesh>(meshPath);
                if (mesh == null)
                {
                    mesh = new Mesh();
                    AssetDatabase.CreateAsset(mesh, meshPath);
                }
                data.BakedMesh = mesh;
            }
            mesh.name = meshName;
            BuildMesh(data, mesh);
            EditorUtility.SetDirty(mesh);

            // Update Material
            var mat = EnsureMaterial(data);
            if (mat != null)
            {
                mat.SetTexture("_MainTex", AssetDatabase.LoadAssetAtPath<Texture2D>(albPath));
                mat.SetTexture("_BumpMap", AssetDatabase.LoadAssetAtPath<Texture2D>(nrmPath));
                mat.SetTexture("_DepthMap", AssetDatabase.LoadAssetAtPath<Texture2D>(depPath));
                mat.SetTexture("_MetallicGlossMap", AssetDatabase.LoadAssetAtPath<Texture2D>(metPath));
                mat.SetTexture("_EmissionMap", AssetDatabase.LoadAssetAtPath<Texture2D>(emiPath));

                mat.SetVector("_BoundsOffset", data.BakedOffset);
                mat.SetVector("_BoundsExtents", data.BakedExtents);
            }

            EditorUtility.SetDirty(data);
            AssetDatabase.SaveAssets();

            Debug.Log("Baked landscape impostor to " + dir);
        }
	}
}
#endif
