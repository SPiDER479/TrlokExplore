using UnityEngine;
using System.Collections.Generic;
using Unity.Mathematics;

namespace SpaceGraphicsToolkit.Cloud
{
	/// <summary>This component allows you to add a texture animation sequence to a <b>SgtCloudBundle</b>.</summary>
	[RequireComponent(typeof(SgtCloud))]
	[AddComponentMenu("Space Graphics Toolkit/SGT Gas Giant Animation")]
	public class SgtGasGiantAnimation : MonoBehaviour
	{
		/// <summary>The current frame.</summary>
		public float Frame { get { return frame; } } [SerializeField] private float frame;

		/// <summary>The frame rate of the animation.</summary>
		public float FramesPerSecond { get { return framesPerSecond; } } [SerializeField] private float framesPerSecond = 10.0f;

		/// <summary>The texture that will be added to the bundle.
		/// NOTE: These texture should be horizontally seamless/tiling.
		/// NOTE: To save memory, these textures should have Advanced / Generate Mip Maps disabled.</summary>
		public List<Texture> SourceFrames { get { return sourceFrames; } } [SerializeField] private List<Texture> sourceFrames;

		[System.NonSerialized]
		private SgtCloud cachedCloud;

		[System.NonSerialized]
		private Material blitMaterial;

		[System.NonSerialized]
		private RenderTexture midTexture;

		protected virtual void OnEnable()
		{
			if (cachedCloud == null)
			{
				cachedCloud = GetComponent<SgtCloud>();
			}

			if (blitMaterial == null)
			{
				blitMaterial = new Material(Shader.Find("Hidden/SgtGasGiantFluid"));

				blitMaterial.hideFlags = HideFlags.DontSave;
			}
		}

		private static int _SGT_OldDataTex       = Shader.PropertyToID("_SGT_OldDataTex");
		private static int _SGT_NewDataTex       = Shader.PropertyToID("_SGT_NewDataTex");
		private static int _SGT_OldNewTransition = Shader.PropertyToID("_SGT_OldNewTransition");
		private static int _SGT_Power            = Shader.PropertyToID("_SGT_Power");
		private static int _SGT_DataSize         = Shader.PropertyToID("_SGT_DataSize");

		protected virtual void Update()
		{
			if (sourceFrames != null && sourceFrames.Count > 0)
			{
				frame += framesPerSecond * Time.deltaTime;

				frame %= sourceFrames.Count;

				if (frame >= 0.0f)
				{
					var frameA = (int)math.floor(frame);
					var frameB = frameA + 1;
					var frameM = math.frac(frame);

					var textureA = sourceFrames[frameA];
					var textureB = sourceFrames[frameB % sourceFrames.Count];

					if (textureA != null && textureB != null)
					{
						if (midTexture == null)
						{
							midTexture = new RenderTexture(textureA.width, textureA.height, 0, RenderTextureFormat.ARGB32, 0);
						}

						blitMaterial.SetTexture(_SGT_OldDataTex, textureA);
						blitMaterial.SetTexture(_SGT_NewDataTex, textureB);
						blitMaterial.SetVector(_SGT_DataSize, new Vector2(midTexture.width, midTexture.height));
						blitMaterial.SetFloat(_SGT_OldNewTransition, frameM);

						var oldActive = RenderTexture.active;

						Graphics.Blit(default(Texture), midTexture, blitMaterial, 4);

						RenderTexture.active = oldActive;

						cachedCloud.CoverageTex = midTexture;
					}
				}
			}
		}

		protected virtual void OnDestroy()
		{
			Destroy(blitMaterial);

			if (midTexture != null)
			{
				midTexture.Release();

				Destroy(midTexture);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Cloud
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtGasGiantAnimation))]
	public class SgtGasGiantAnimation_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtGasGiantAnimation tgt; SgtGasGiantAnimation[] tgts; GetTargets(out tgt, out tgts);

			Draw("frame", "The current frame.");
			Draw("framesPerSecond", "The frame rate of the animation.");

			Separator();

			Draw("sourceFrames");
		}
	}
}
#endif