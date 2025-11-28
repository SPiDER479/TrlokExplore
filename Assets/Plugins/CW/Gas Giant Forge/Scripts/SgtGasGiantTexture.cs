using UnityEngine;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add a texture to a <b>SgtCloudBundle</b>.</summary>
	[AddComponentMenu("Space Graphics Toolkit/SGT Gas Giant Texture")]
	public class SgtGasGiantTexture : SgtCloudBundleSlice
	{
		/// <summary>The texture that will be added to the bundle.
		/// NOTE: This texture should be horizontally seamless/tiling.
		/// NOTE: This texture's import settings should have Texture Type = Single Channel.
		/// NOTE: This texture's import settings should have Channel = Red.
		/// NOTE: To save memory, this texture should have Advanced / Generate Mip Maps disabled.</summary>
		public Texture2D Source { set { source = value; } get { return source; } } [SerializeField] private Texture2D source;

		[System.NonSerialized]
		private RenderTexture createdTexture;

		public override SliceInstance TryCreate(int width, int offset)
		{
			if (source != null)
			{
				var instance = new SliceInstance();
				var scale    = width / (float)source.width;
				var height   = (int)(source.height * scale);

				instance.Parent        = this;
				instance.CreatedHeight = height;

				var desc = new RenderTextureDescriptor(width, height, RenderTextureFormat.R8, 0, 0);

				desc.sRGB = false;

				createdTexture = new RenderTexture(desc);

				createdTexture.hideFlags = HideFlags.DontSave;

				Graphics.Blit(source, createdTexture);

				return instance;
			}

			return null;
		}

		public override void Write(SliceInstance sliceInstance, RenderTexture target)
		{
			Graphics.CopyTexture(createdTexture, 0, 0, 0, 0, createdTexture.width, createdTexture.height, target, 0, 0, 0, sliceInstance.CreatedOffset);
		}

		public override void Dispose(SliceInstance sliceInstance)
		{
			sliceInstances.Remove(sliceInstance);

			if (sliceInstances.Count == 0)
			{
				if (createdTexture != null)
				{
					createdTexture.Release();

					Object.DestroyImmediate(createdTexture);

					createdTexture = null;
				}
			}
		}

		public override void HandleLateUpdate(SliceInstance sliceInstance, RenderTexture target)
		{
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtGasGiantTexture))]
	public class SgtGasGiantTexture_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtGasGiantTexture tgt; SgtGasGiantTexture[] tgts; GetTargets(out tgt, out tgts);

			Draw("source");
		}
	}
}
#endif