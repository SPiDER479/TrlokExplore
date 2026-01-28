using UnityEngine;
using UnityEngine.Rendering;

namespace CW.SimpleShaderSystem
{
	/// <summary>If you're using the Built-in render pipeline, this component can be added to your main scene camera to add an opaque texture for ocean reflection and refraction effects.</summary>
	[ExecuteAlways]
	[RequireComponent(typeof(Camera))]
	public class CameraOpaqueTextureBIRP : MonoBehaviour
	{
		[System.NonSerialized]
		private Camera cachedCamera;

		[System.NonSerialized]
		private CommandBuffer setupCB;

		[System.NonSerialized]
		private CommandBuffer clearCB;

		private static readonly int _CameraOpaqueTexture = Shader.PropertyToID("_CameraOpaqueTexture");

		protected virtual void OnEnable()
		{
			if (GraphicsSettings.currentRenderPipeline == null)
			{
				cachedCamera = GetComponent<Camera>();

				CreateCommandBuffers();
				AddBuffers(cachedCamera);

				#if UNITY_EDITOR
					AddBuffersToSceneView();
				#endif
			}
		}

		protected virtual void OnDisable()
		{
			RemoveBuffers(cachedCamera);

			#if UNITY_EDITOR
				RemoveBuffersFromSceneView();
			#endif
		}

		private void CreateCommandBuffers()
		{
			if (setupCB == null)
			{
				setupCB = new CommandBuffer { name = "Setup Opaque Texture" };
				setupCB.GetTemporaryRT(_CameraOpaqueTexture, Screen.width, Screen.height, 0);
				setupCB.Blit(BuiltinRenderTextureType.CameraTarget, _CameraOpaqueTexture);
			}

			if (clearCB == null)
			{
				clearCB = new CommandBuffer { name = "Release Opaque Texture" };
				clearCB.ReleaseTemporaryRT(_CameraOpaqueTexture);
			}
		}

		private void AddBuffers(Camera c)
		{
			if (setupCB != null)
			{
				c.AddCommandBuffer(CameraEvent.AfterForwardOpaque, setupCB);
			}

			if (clearCB != null)
			{
				c.AddCommandBuffer(CameraEvent.AfterEverything, clearCB);
			}
		}

		private void RemoveBuffers(Camera c)
		{
			if (setupCB != null)
			{
				c.RemoveCommandBuffer(CameraEvent.AfterForwardOpaque, setupCB);
			}

			if (clearCB != null)
			{
				c.RemoveCommandBuffer(CameraEvent.AfterEverything, clearCB);
			}
		}

	#if UNITY_EDITOR
		private void AddBuffersToSceneView()
		{
			if (cachedCamera == null || cachedCamera.tag != "MainCamera") return;

			foreach (Camera c in UnityEditor.SceneView.GetAllSceneCameras())
			{
				AddBuffers(c);
			}
		}

		private void RemoveBuffersFromSceneView()
		{
			if (cachedCamera == null || cachedCamera.tag != "MainCamera") return;

			foreach (Camera c in UnityEditor.SceneView.GetAllSceneCameras())
			{
				RemoveBuffers(c);
			}
		}
	#endif
	}
}