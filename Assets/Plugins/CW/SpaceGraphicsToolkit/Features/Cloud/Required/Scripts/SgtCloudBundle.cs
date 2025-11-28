using UnityEngine;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to combine multiple cloud textures into one larger atlas.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Cloud Bundle")]
	public class SgtCloudBundle : MonoBehaviour
	{
		/// <summary>The width of this texture bundle.
		/// NOTE: This should be the same size or smaller than the textures in the <b>Slices</b> list.</summary>
		public int Width { set { width = value; } get { return width; } } [SerializeField] private int width = 1024;

		/// <summary>This bundle contains these slices.</summary>
		public List<SgtCloudBundleSlice> Slices { get { if (slices == null) slices = new List<SgtCloudBundleSlice>(); return slices; } } [SerializeReference] private List<SgtCloudBundleSlice> slices;

		[System.NonSerialized]
		private RenderTexture generatedTexture;

		[System.NonSerialized]
		private List<SgtCloudBundleSlice.SliceInstance> createdSlices = new List<SgtCloudBundleSlice.SliceInstance>();

		[System.NonSerialized]
		private bool hasUpdated;

		public RenderTexture GeneratedTexture
		{
			get
			{
				return generatedTexture;
			}
		}

		public RenderTexture GetTexture()
		{
			if (generatedTexture == null)
			{
				Dispose();

				var totalHeight = 0;

				foreach (var slice in slices)
				{
					if (slice != null)
					{
						var createdSlice = slice.TryCreate(width, totalHeight);

						if (createdSlice != null)
						{
							createdSlices.Add(createdSlice);

							createdSlice.CreatedOffset = totalHeight;

							totalHeight += createdSlice.CreatedHeight;
						}
					}
				}

				if (totalHeight > 0)
				{
					var desc = new RenderTextureDescriptor(width, totalHeight, RenderTextureFormat.R8, 0, 0);

					desc.sRGB = false;

					generatedTexture = new RenderTexture(desc);
					generatedTexture.hideFlags = HideFlags.DontSave;
					generatedTexture.wrapModeU = TextureWrapMode.Repeat;

					var offset = 0;

					foreach (var createdSlice in createdSlices)
					{
						var locationA = offset;
						var locationB = offset + createdSlice.CreatedHeight;

						createdSlice.CreatedLocation = new Vector2(locationA / (float)totalHeight, locationB / (float)totalHeight);

						createdSlice.Parent.Write(createdSlice, generatedTexture);

						offset += createdSlice.CreatedHeight;
					}
				}
			}

			return generatedTexture;
		}

		public Vector2 GetCoords(int index)
		{
			if (createdSlices.Count > 0)
			{
				index = ((index % createdSlices.Count) + createdSlices.Count) % createdSlices.Count;

				return createdSlices[index].CreatedLocation;
			}

			return Vector2.zero;
		}

		public void HandleUpdate()
		{
			hasUpdated = false;
		}

		public void HandleLateUpdate()
		{
			if (hasUpdated == false)
			{
				hasUpdated = true;

				for (var i = createdSlices.Count - 1; i >= 0; i--)
				{
					var createdSlice = createdSlices[i];

					if (createdSlice != null && createdSlice.Parent != null)
					{
						createdSlice.Parent.HandleLateUpdate(createdSlice, generatedTexture);
					}
					else
					{
						createdSlices.RemoveAt(i);
					}
				}
			}
		}

		[ContextMenu("Mark As Dirty")]
		public void MarkAsDirty()
		{
			Dispose();
		}

		public void Dispose()
		{
			if (generatedTexture != null)
			{
				generatedTexture.Release();

				DestroyImmediate(generatedTexture);

				generatedTexture = null;
			}

			foreach (var createdSlice in createdSlices)
			{
				if (createdSlice != null && createdSlice.Parent != null)
				{
					createdSlice.Parent.Dispose(createdSlice);
				}
			}

			createdSlices.Clear();
		}

		protected virtual void OnDestroy()
		{
			Dispose();
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtCloudBundle))]
	public class SgtCloudBundle_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtCloudBundle tgt; SgtCloudBundle[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			Draw("width", "The width of this texture bundle.\n\nNOTE: This should be the same size or smaller than the textures in the <b>Slices</b> list.");

			Separator();

			Draw("slices", ref markAsDirty);

			if (markAsDirty == true)
			{
				Each(tgts, t => t.MarkAsDirty());
			}

			//BeginDisabled();
			//	UnityEditor.EditorGUILayout.ObjectField("GeneratedTexture", tgt.GeneratedTexture, typeof(RenderTexture), true);
			//EndDisabled();
		}
	}
}
#endif