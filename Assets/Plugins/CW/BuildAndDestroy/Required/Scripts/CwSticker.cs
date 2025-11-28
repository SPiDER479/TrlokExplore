using System.Collections.Generic;
using UnityEngine;
using CW.Common;

namespace CW.BuildAndDestroy
{
	/// <summary>This component allows you to apply a sticker to your design at the current <b>Transform</b>.
	/// NOTE: This component must be in a child GameObject of the <b>CwDesign</b> component.</summary>
	[HelpURL(CwCommon.HelpUrlPrefix + "CwSticker")]
	[AddComponentMenu(CwCommon.ComponentMenuPrefix + "Sticker")]
	public class CwSticker : MonoBehaviour
	{
		/// <summary>This sticker will use this texture index from the sticker pack set in the parent <b>CwDesign</b> component.</summary>
		public int TextureIndex { set { textureIndex = value; } get { return textureIndex; } } [SerializeField] private int textureIndex;

		/// <summary>This sticker will use this color index from the colors list set in the parent <b>CwDesign</b> component.</summary>
		public int ColorIndex { set { colorIndex = value; } get { return colorIndex; } } [SerializeField] private int colorIndex;

		/// <summary>This allows you to hide the pixels of the sticker that lie on surfaces that are too steep relative to the back of the sticker.</summary>
		public float NormalBack { set { normalBack = value; } get { return normalBack; } } [SerializeField] [Range(-1.0f, 1.0f)] private float normalBack = 0.5f;

		/// <summary>This allows you to hide the pixels of the sticker that lie on surfaces that are too steep relative to the front of the sticker.</summary>
		public float NormalFront { set { normalFront = value; } get { return normalFront; } } [SerializeField] [Range(-1.0f, 1.0f)] private float normalFront = 0.5f;

		/// <summary>This allows you to shrink or expand the outer edge of the decal shape, similar to the threshold setting of a cutout shader.</summary>
		public float Offset { set { offset = value; } get { return offset; } } [SerializeField] [Range(0.0f, 1.0f)] private float offset = 0.5f;

		/// <summary>This allows you to control the edge transition sharpness/smoothness.</summary>
		public float Sharpness { set { sharpness = value; } get { return sharpness; } } [SerializeField] [Range(0.0f, 100.0f)] private float sharpness = 10.0f;

		public Matrix4x4 GetMatrix()
		{
			return Matrix4x4.Translate(new Vector3(0.5f, 0.5f, 0.0f)) * transform.worldToLocalMatrix;
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			var matrix = transform.localToWorldMatrix;

			Gizmos.matrix = matrix;

			Gizmos.DrawWireCube(Vector3.zero, new Vector3(1.0f, 1.0f, 0.0f));
			Gizmos.DrawWireCube(Vector3.zero, new Vector3(1.0f, 1.0f, 1.0f));

			var design = GetComponentInParent<CwDesign>();

			if (design != null && design.StickerPack != null)
			{
				var stickerTexture = design.StickerPack.GeneratedTexture;

				if (stickerTexture != null)
				{
					var coords = design.StickerPack.PackedStickerCoords;

					if (textureIndex >= 0 && textureIndex < coords.Count)
					{
						var coord = coords[textureIndex];
						var color = Color.white;

						if (colorIndex >= 0 && colorIndex < design.Colors.Count)
						{
							color = design.Colors[colorIndex];
						}

						for (var i = 0; i < 16; i++)
						{
							var subMatrix = matrix * Matrix4x4.Translate(new Vector3(0.0f, 0.0f, Mathf.Lerp(-0.5f, 0.5f, i / 15.0f)));

							CwHelper.DrawShapeOutline(stickerTexture, 3, subMatrix, coord, color);
						}
					}
				}
			}
		}
#endif
	}
}

#if UNITY_EDITOR
namespace CW.BuildAndDestroy
{
	using UnityEditor;
	using TARGET = CwSticker;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(TARGET))]
	public class CwSticker_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			TARGET tgt; TARGET[] tgts; GetTargets(out tgt, out tgts);

			var design       = tgt.GetComponentInParent<CwDesign>();
			var textureCount = 0;
			var colorCount   = 0;

			if (design != null)
			{
				if (design.StickerPack != null)
				{
					textureCount = design.StickerPack.PackedStickerCoords.Count;
				}

				colorCount = design.Colors.Count;
			}

			DrawIntSlider("textureIndex", 0, textureCount - 1, "This sticker will use this texture index from the sticker pack set in the parent <b>CwDesign</b> component.");
			DrawIntSlider("colorIndex", 0, colorCount - 1, "This sticker will use this color index from the colors list set in the parent <b>CwDesign</b> component.");
			Draw("normalBack", "This allows you to hide the pixels of the sticker that lie on surfaces that are too steep relative to the back of the sticker.");
			Draw("normalFront", "This allows you to hide the pixels of the sticker that lie on surfaces that are too steep relative to the front of the sticker.");
			Draw("offset", "This allows you to shrink or expand the outer edge of the decal shape, similar to the threshold setting of a cutout shader.");
			Draw("sharpness", "This allows you to control the edge transition sharpness/smoothness.");
		}
	}
}
#endif