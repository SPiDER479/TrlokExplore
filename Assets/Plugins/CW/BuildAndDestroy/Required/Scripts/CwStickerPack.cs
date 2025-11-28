using System.Collections.Generic;
using UnityEngine;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component allows you to define a collection of textures that get packed into an atlas that can then be applied to spaceship designs.</summary>
    public class CwStickerPack : MonoBehaviour
    {
		[System.Serializable]
		public class Sticker
		{
			public string textureGuid;

#if UNITY_EDITOR
			public Texture2D Texture
			{
				set
				{
					textureGuid = CwHelper.AssetToGUID(value);
				}

				get
				{
					return CwHelper.LoadAssetAtGUID<Texture2D>(textureGuid);
				}
			}

			public Vector2 Size
			{
				get
				{
					var texture = Texture;

					if (texture != null)
					{
						return new Vector2(texture.width, texture.height);
					}

					return Vector2.zero;
				}
			}
#endif
		}

		[System.Serializable]
		public struct PackedSticker
		{
			public string Title;

			public Rect Rect;
		}

		public int DivideSize { set { divideSize = value; } get { return divideSize; } } [SerializeField] private int divideSize = 2;

		/// <summary>The stickers contained in this sticker pack.</summary>
		public List<Sticker> Stickers { get { if (stickers == null) stickers = new List<Sticker>(); return stickers; } } [SerializeField] private List<Sticker> stickers;

		public Dictionary<string, PackedSticker> PackedTitleToStickers
		{
			get
			{
				if (packedTitleToStickers.Count == 0 && packedStickers != null)
				{
					foreach (var packedSticker in packedStickers)
					{
						packedTitleToStickers.Add(packedSticker.Title, packedSticker);
					}
				}

				return packedTitleToStickers;
			}
		}

		public List<Vector4> PackedStickerCoords
		{
			get
			{
				if (packedStickerCoords.Count == 0 && packedStickers != null)
				{
					foreach (var packedSticker in packedStickers)
					{
						var x = packedSticker.Rect.xMin;
						var y = packedSticker.Rect.yMin;
						var z = packedSticker.Rect.xMax;
						var w = packedSticker.Rect.yMax;

						packedStickerCoords.Add(new Vector4(x, y, z, w));
					}
				}

				return packedStickerCoords;
			}
		}

		public Texture2D GeneratedTexture
		{
			get
			{
				return generatedTexture;
			}
		}

		[SerializeField]
		private Texture2D generatedTexture;

		[SerializeField]
		private List<Vector4> coords;

		[SerializeField]
		private List<PackedSticker> packedStickers;

		[System.NonSerialized]
		private Dictionary<string, PackedSticker> packedTitleToStickers = new Dictionary<string, PackedSticker>();

		[System.NonSerialized]
		private List<Vector4> packedStickerCoords = new List<Vector4>();

		private static List<Texture2D> packTextures = new List<Texture2D>();

		private static List<Rect> packResults = new List<Rect>();

		private static List<Rect> bestResults = new List<Rect>();

		private static int bestSize;

#if UNITY_EDITOR
		public void Compile()
		{
			Clear();

			packTextures.Clear();

			if (stickers != null)
			{
				foreach (var sticker in stickers)
				{
					var texture = sticker.Texture;

					if (texture != null)
					{
						var clone = new Texture2D(texture.width / divideSize, texture.height / divideSize, TextureFormat.Alpha8, false, true);

						clone.name      = texture.name;
						clone.hideFlags = HideFlags.DontSave;

						var stepU = 1.0f / (clone.width  - 1);
						var stepV = 1.0f / (clone.height - 1);

						for (var y = 0; y < clone.height; y++)
						{
							var v = y * stepU;

							for (var x = 0; x < clone.width; x++)
							{
								var u = x * stepU;

								clone.SetPixel(x, y, texture.GetPixelBilinear(u, v));
							}
						}

						packTextures.Add(clone);
					}
				}
			}

			bestResults.Clear();

			var sizes = packTextures.ConvertAll(p => new Vector2(p.width, p.height)).ToArray();
			var size  = 128;
			var delta = 64;
			var last  = false;

			for (var i = 0; i < 100; i++)
			{
				var pack = Texture2D.GenerateAtlas(sizes, 1, size, packResults) == true && packResults[0].width > 0.0f;

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
				generatedTexture = new Texture2D(bestSize, bestSize, TextureFormat.Alpha8, true, true);

				for (var y = 0; y < bestSize; y++)
				{
					for (var x = 0; x < bestSize; x++)
					{
						generatedTexture.SetPixel(x, y, Color.clear);
					}
				}

				var scaleU = 1.0f / generatedTexture.width;
				var scaleV = 1.0f / generatedTexture.height;

				for (var i = 0; i < packTextures.Count; i++)
				{
					var bestResult  = bestResults[i];
					var packOffset  = new Vector2Int((int)bestResult.x, (int)bestResult.y);
					var packTexture = packTextures[i];

					for (var y = 0; y < packTexture.height; y++)
					{
						for (var x = 0; x < packTexture.width; x++)
						{
							generatedTexture.SetPixel(packOffset.x + x, packOffset.y + y, packTexture.GetPixel(x, y));
						}
					}

					var xMin = bestResult.xMin * scaleU;
					var yMin = bestResult.yMin * scaleV;
					var xMax = bestResult.xMax * scaleU;
					var yMax = bestResult.yMax * scaleV;

					packedStickers.Add(new PackedSticker() { Title = packTexture.name, Rect = Rect.MinMaxRect(xMin, yMin, xMax, yMax) });
					Debug.Log("adding " + packedStickers[packedStickers.Count - 1].Title + " - " + packedStickers[packedStickers.Count - 1].Rect);
				}

				generatedTexture.Apply();

				UnityEditor.AssetDatabase.AddObjectToAsset(generatedTexture, this);
			}

			foreach (var packTexture in packTextures)
			{
				DestroyImmediate(packTexture);
			}

			packTextures.Clear();
		}
#endif

#if UNITY_EDITOR
		public void Clear()
		{
			DestroyImmediate(generatedTexture, true);

			generatedTexture = null;

			foreach (var s in UnityEditor.AssetDatabase.LoadAllAssetsAtPath(UnityEditor.AssetDatabase.GetAssetPath(this)))
			{
				if (s is Texture2D)
				{
					DestroyImmediate(s, true);
				}
			}

			if (packedStickers == null)
			{
				packedStickers = new List<PackedSticker>();
			}
			else
			{
				packedStickers.Clear();
			}

			packedStickerCoords.Clear();

			packedTitleToStickers.Clear();
		}
#endif
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwStickerPack;

	//[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwStickerPack_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			Draw("divideSize");

			DrawSticker(tgt, tgts);

			Separator();

			if (Button("Clear") == true)
			{
				Each(tgts, t => t.Clear(), true, true);
			}

			if (Button("Compile") == true)
			{
				Each(tgts, t => t.Compile(), true, true);
			}

			BeginDisabled();
				Draw("generatedTexture");
			EndDisabled();
		}

		private void DrawSticker(TARGET tgt, TARGET[] tgts)
		{
			var deleteIndex = -1;

			for (var i = 0; i < tgt.Stickers.Count; i++)
			{
				EditorGUILayout.BeginHorizontal();

				var oldTexture = tgt.Stickers[i].Texture;

				BeginError(oldTexture == null);
					var newTexture = EditorGUILayout.ObjectField("", oldTexture, typeof(Texture2D), false, GUILayout.Height(18)) as Texture2D;
				EndError();

				if (oldTexture != newTexture)
				{
					Each(tgts, t => t.Stickers[i].Texture = newTexture);
				}

				if (GUILayout.Button("x", GUILayout.Width(20)) == true)
				{
					deleteIndex = i;
				}

				EditorGUILayout.EndHorizontal();
			}

			if (deleteIndex >= 0)
			{
				Each(tgts, t => t.Stickers.RemoveAt(deleteIndex));
			}

			var addTexture = EditorGUILayout.ObjectField("Add Texture", default(Texture2D), typeof(Texture2D), false, GUILayout.Height(18)) as Texture2D;

			if (addTexture != null)
			{
				Each(tgts, t => t.Stickers.Add(new TARGET.Sticker() { Texture = addTexture }));
			}
		}
	}
}
#endif