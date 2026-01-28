using UnityEngine;
using Unity.Burst;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Jobs;
using CW.Common;

namespace SpaceGraphicsToolkit.Cloud
{
    public class SgtCloudTileBuilder : ScriptableObject
    {
        /// <summary>The shape of this cloud.
		/// NOTE: Only the red channel is used.</summary>
		public Texture2D Shape { set { shape = value; } get { return shape; } } [SerializeField] private Texture2D shape;

		/// <summary>Only pixels with a red value above this will have visible clouds.</summary>
		public float Threshold { set { threshold = value; } get { return threshold; } } [SerializeField] [Range(0.0f, 1.0f)] private float threshold = 0.5f;

		[BurstCompile]
		private struct DistanceJob : IJob
		{
			[ReadOnly] public NativeArray<byte> src;
			public int w,h; public byte th;
			public NativeArray<byte> sdf;
			const float INF = 1e20f;

			public void Execute()
			{
				var f = new NativeArray<float>(w * h, Allocator.Temp);
				var g = new NativeArray<float>(w * h, Allocator.Temp);
				var tmpCol = new NativeArray<float>(h, Allocator.Temp); // for column EDT

				// mask -> distance to foreground
				for (var i = 0; i < f.Length; i++) f[i] = (src[i] > th) ? 0f : INF;
				EDT2D(f, g, w, h, tmpCol);
				var df = new NativeArray<float>(g, Allocator.Temp);

				// mask -> distance to background
				for (var i = 0; i < f.Length; i++) f[i] = (src[i] <= th) ? 0f : INF;
				EDT2D(f, g, w, h, tmpCol);

				for (var i = 0; i < src.Length; i++)
				{
					var dist   = math.sqrt(df[i]) - math.sqrt(g[i]);
					var dist01 = (dist / 128.0f) + 0.5f;
					var weig01 = 1.0f - math.exp(math.max(0.0f, -dist) * -0.1f);

					sdf[i * 3 + 0] = (byte)math.clamp(dist01 * 255.0f, 0.0f, 255.0f);
					sdf[i * 3 + 1] = src[i];
					sdf[i * 3 + 2] = (byte)math.clamp(weig01 * 255.0f, 0.0f, 255.0f);
				}

				f.Dispose();
				g.Dispose();
				df.Dispose();
				tmpCol.Dispose();
			}

			static void EDT2D(NativeArray<float> f, NativeArray<float> outp, int w, int h, NativeArray<float> tmpCol)
			{
				var tmpRow = new NativeArray<float>(w, Allocator.Temp);
				var resRow = new NativeArray<float>(w, Allocator.Temp);

				// row-wise EDT
				for (int y = 0; y < h; y++)
				{
					int rowOffset = y * w;
					for (int x = 0; x < w; x++) tmpRow[x] = f[rowOffset + x];
					EDT1D(tmpRow, resRow, w);
					for (int x = 0; x < w; x++) f[rowOffset + x] = resRow[x];
				}
				resRow.Dispose();
				tmpRow.Dispose();

				// column-wise EDT
				for (int x = 0; x < w; x++)
				{
					for (int y = 0; y < h; y++) tmpCol[y] = f[y * w + x];
					var resCol = new NativeArray<float>(h, Allocator.Temp);
					EDT1D(tmpCol, resCol, h);
					for (int y = 0; y < h; y++) outp[y * w + x] = resCol[y];
					resCol.Dispose();
				}
			}

			static void EDT1D(NativeArray<float> f, NativeArray<float> d, int n)
			{
				var v = new NativeArray<int>(n, Allocator.Temp);
				var z = new NativeArray<float>(n + 1, Allocator.Temp);
				int k = 0;
				v[0] = 0; z[0] = -INF; z[1] = INF;

				for (int q = 1; q < n; q++)
				{
					float s;
					while (true)
					{
						int p = v[k];
						float denom = 2f * (q - p);
						s = (denom == 0f) ? ((f[q] + q * q > f[p] + p * p) ? INF : -INF)
										  : ((f[q] + q * q - f[p] - p * p) / denom);
						if (s <= z[k]) { k--; if (k < 0) { k = 0; v[0] = q; z[0] = -INF; z[1] = INF; break; } }
						else { k++; v[k] = q; z[k] = s; z[k + 1] = INF; break; }
					}
				}

				int idx = 0;
				for (int q = 0; q < n; q++)
				{
					while (z[idx + 1] < q) idx++;
					int p = v[idx];
					float diff = q - p;
					d[q] = diff * diff + f[p];
				}

				v.Dispose();
				z.Dispose();
			}
		}

		public Texture2D BuildSDF()
		{
			if (shape != null && shape.isReadable == true)
			{
				var sdf = new Texture2D(shape.width, shape.height, TextureFormat.RGB24, false);

				var job = new DistanceJob();

				job.src = shape.GetPixelData<byte>(0);
				job.w   = shape.width;
				job.h   = shape.height;
				job.th  = (byte)(threshold * 255);
				job.sdf = sdf.GetPixelData<byte>(0);

				job.Run();

				sdf.Apply();

				return sdf;
			}

			return null;
		}
    }
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtCloudTileBuilder))]
	public class SgtCloudTileBuilder_Editor : CwEditor
	{
		[MenuItem("Assets/Create/CW/Space Graphics Toolkit/Cloud Tile Builder")]
		private static void CreateAsset()
		{
			var guids = Selection.assetGUIDs;
			var path  = guids.Length > 0 ? AssetDatabase.GUIDToAssetPath(guids[0]) : default(string);

			CreateCloudTileBuilderAsset(string.IsNullOrEmpty(path) == false ? AssetDatabase.LoadAssetAtPath<Texture2D>(path) : null, path);
		}

		public static void CreateCloudTileBuilderAsset(Texture2D texture, string path)
		{
			var asset = CreateInstance<SgtCloudTileBuilder>();
			var name  = "Cloud Tile Builder";

			if (string.IsNullOrEmpty(path) == true || path.StartsWith("Library/", System.StringComparison.InvariantCultureIgnoreCase))
			{
				path = "Assets";
			}
			else if (AssetDatabase.IsValidFolder(path) == false)
			{
				path = System.IO.Path.GetDirectoryName(path);
			}

			if (texture != null)
			{
				name += " (" + texture.name + ")";

				asset.Shape = texture;
			}

			var assetPathAndName = AssetDatabase.GenerateUniqueAssetPath(path + "/" + name + ".asset");

			AssetDatabase.CreateAsset(asset, assetPathAndName);

			AssetDatabase.SaveAssets();
			AssetDatabase.Refresh();
			EditorUtility.FocusProjectWindow();

			Selection.activeObject = asset; EditorGUIUtility.PingObject(asset);
		}

		protected override void OnInspector()
		{
			SgtCloudTileBuilder tgt; SgtCloudTileBuilder[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.Shape == null));
				Draw("shape", "The shape of this cloud.\n\nNOTE: Only the red channel is used.");
			EndError();
			Draw("threshold", "Only pixels with a red value above this will have visible clouds.");

			Separator();

			if (Button("Export") == true)
			{
				if (tgt.Shape != null)
				{
					var sdf = tgt.BuildSDF();

					if (sdf != null)
					{
						var defaultDir = "";

						if (tgt.Shape != null)
						{
							var shapePath = AssetDatabase.GetAssetPath(tgt.Shape);

							if (string.IsNullOrEmpty(shapePath) == false)
							{
								defaultDir = System.IO.Path.GetDirectoryName(shapePath);
							}
						}

						var path = EditorUtility.SaveFilePanelInProject("Save Texture as PNG", tgt.Shape.name + " SDF", "png", "Please enter a file name to save the texture to", defaultDir);

						if (string.IsNullOrEmpty(path) == false)
						{
							var oldImporter = AssetImporter.GetAtPath(path) as TextureImporter;

							System.IO.File.WriteAllBytes(path, sdf.EncodeToPNG());

							AssetDatabase.Refresh();

							if (oldImporter == null)
							{
								var importer = AssetImporter.GetAtPath(path) as TextureImporter;

								if (importer != null)
								{
									var tis = new TextureImporterSettings();

									importer.ReadTextureSettings(tis);

									tis.mipmapEnabled = false;
									tis.sRGBTexture   = false;

									importer.SetTextureSettings(tis);

									importer.SaveAndReimport();
								}
							}

							CwHelper.SelectAndPing(AssetDatabase.LoadAssetAtPath<Texture2D>(path));

							Debug.Log("Saved and configured R8 texture at: " + path);
						}
					}
				}
			}
		}
	}
}
#endif