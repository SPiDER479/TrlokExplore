#if __URP__ && UNITY_6000_0_OR_NEWER
	#define __HAS_RENDER_GRAPH__
#endif

#if __URP__
using UnityEngine.Rendering.Universal;
#elif __HDRP__
using UnityEngine.Rendering.HighDefinition;
#endif
#if __HAS_RENDER_GRAPH__
using UnityEngine.Rendering.RenderGraphModule;
#endif
using UnityEngine;
using UnityEngine.Rendering;

namespace SpaceGraphicsToolkit.Volumetrics
{
	/// <summary>This component can be added alongside your scene camera to render volumetric effects.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Volume Camera")]
	public class SgtVolumeCamera : MonoBehaviour
	{
#if __HDRP__
		private CustomPassVolume customPassVolume;

		private CustomDepthPass customDepthPass;

		private static RenderTargetIdentifier[] identifiers = new RenderTargetIdentifier[2];

		public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth, Color defaultColor)
		{
			identifiers[0] = a;
			identifiers[1] = b;

			CustomDepthPass.CurrentContext.cmd.SetRenderTarget(identifiers, depth);
			CustomDepthPass.CurrentContext.cmd.ClearRenderTarget(true, true, defaultColor);
		}

		public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth)
		{
			identifiers[0] = a;
			identifiers[1] = b;

			CustomDepthPass.CurrentContext.cmd.SetRenderTarget(identifiers, depth);
		}

		public static void AddDrawMesh(Mesh mesh, int submesh, Matrix4x4 matrix, Material material, int pass, bool invert)
		{
			CustomDepthPass.CurrentContext.cmd.SetInvertCulling(invert);
			CustomDepthPass.CurrentContext.cmd.DrawMesh(mesh, matrix, material, submesh, pass);
		}

		public static void AddDrawMeshInstancedProcedural(Mesh mesh, int submesh, Material material, int pass, bool invert, int count, MaterialPropertyBlock properties)
		{
			CustomDepthPass.CurrentContext.cmd.SetInvertCulling(invert);
			CustomDepthPass.CurrentContext.cmd.DrawMeshInstancedProcedural(mesh, submesh, material, pass, count, properties);
		}

		public virtual void OnEnable()
		{
			if (customPassVolume == null)
			{
				customPassVolume = gameObject.GetComponent<CustomPassVolume>();
			}

			if (customPassVolume == null)
			{
				customPassVolume = gameObject.AddComponent<CustomPassVolume>();

				customPassVolume.hideFlags      = HideFlags.DontSave;
				customPassVolume.injectionPoint = CustomPassInjectionPoint.AfterOpaqueDepthAndNormal;
			}

			if (customDepthPass == null)
			{
				customDepthPass = customPassVolume.customPasses.Find(p => p is CustomDepthPass) as CustomDepthPass;
			}

			if (customDepthPass == null)
			{
				customDepthPass = (CustomDepthPass)customPassVolume.AddPassOfType<CustomDepthPass>();
			}

			customPassVolume.enabled = true;

			customDepthPass.parent = this;

			var cam = GetComponent<Camera>();

			if (cam != null)
			{
				cam.depthTextureMode |= DepthTextureMode.Depth;
			}
		}

		public virtual void OnDisable()
		{
			customPassVolume.enabled = false;
		}
#elif __URP__
		#if __HAS_RENDER_GRAPH__
			private static RenderTargetIdentifier[] identifiers2 = new RenderTargetIdentifier[2];

			public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth)
			{
				identifiers2[0] = a;
				identifiers2[1] = b;

				CustomDepthPass.CurrentContext.cmd.SetRenderTarget(identifiers2, depth);
			}

			public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth, Color defaultColor)
			{
				identifiers2[0] = a;
				identifiers2[1] = b;

				CustomDepthPass.CurrentContext.cmd.SetRenderTarget(identifiers2, depth);
				CustomDepthPass.CurrentContext.cmd.ClearRenderTarget(true, true, defaultColor);
			}

			public static void AddDrawMesh(Mesh mesh, int submesh, Matrix4x4 matrix, Material material, int pass, bool invert)
			{
				CustomDepthPass.CurrentContext.cmd.SetInvertCulling(invert);
				CustomDepthPass.CurrentContext.cmd.DrawMesh(mesh, matrix, material, submesh, pass);
			}

			public static void AddDrawMeshInstancedProcedural(Mesh mesh, int submesh, Material material, int pass, bool invert, int count, MaterialPropertyBlock properties)
			{
				CustomDepthPass.CurrentContext.cmd.SetInvertCulling(invert);
				CustomDepthPass.CurrentContext.cmd.DrawMeshInstancedProcedural(mesh, submesh, material, pass, count, properties);
			}
		#else
			private static RenderTargetIdentifier[] identifiers2 = new RenderTargetIdentifier[2];

			public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth)
			{
				identifiers2[0] = a;
				identifiers2[1] = b;

				CustomDepthPass.CurrentCommands.SetRenderTarget(identifiers2, depth);
			}

			public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth, Color defaultColor)
			{
				identifiers2[0] = a;
				identifiers2[1] = b;

				CustomDepthPass.CurrentCommands.SetRenderTarget(identifiers2, depth);
				CustomDepthPass.CurrentCommands.ClearRenderTarget(true, true, defaultColor);
			}

			public static void AddDrawMesh(Mesh mesh, int submesh, Matrix4x4 matrix, Material material, int pass, bool invert)
			{
				CustomDepthPass.CurrentCommands.SetInvertCulling(invert);
				CustomDepthPass.CurrentCommands.DrawMesh(mesh, matrix, material, submesh, pass);
			}

			public static void AddDrawMeshInstancedProcedural(Mesh mesh, int submesh, Material material, int pass, bool invert, int count, MaterialPropertyBlock properties)
			{
				CustomDepthPass.CurrentCommands.SetInvertCulling(invert);
				CustomDepthPass.CurrentCommands.DrawMeshInstancedProcedural(mesh, submesh, material, pass, count, properties);
			}
		#endif

		private CustomDepthPass pass;

		public virtual void OnEnable()
		{
			RenderPipelineManager.beginCameraRendering += HandleCameraRendering;

			pass = new CustomDepthPass();
			pass.renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;

			var cam = GetComponent<Camera>();

			if (cam != null)
			{
				cam.depthTextureMode |= DepthTextureMode.Depth;
			}
		}

		public virtual void OnDisable()
		{
			RenderPipelineManager.beginCameraRendering -= HandleCameraRendering;
		}

		private void HandleCameraRendering(ScriptableRenderContext context, Camera camera)
		{
			if (camera.gameObject == gameObject)
			{
				var data = camera.GetComponent<UniversalAdditionalCameraData>();

				if (data == null)
				{
					data = camera.gameObject.AddComponent<UniversalAdditionalCameraData>();
				}

				data.requiresDepthTexture = true;

				SgtVolumeManager.CurrentCamera = camera;

				data.scriptableRenderer.EnqueuePass(pass);
			}
		}
#else // BiRP
		private static RenderTargetIdentifier[] buffers2 = new RenderTargetIdentifier[2];

		private static System.Collections.Generic.LinkedList<SgtVolumeCamera> instances = new System.Collections.Generic.LinkedList<SgtVolumeCamera>();

		private System.Collections.Generic.LinkedListNode<SgtVolumeCamera> node;

		private CommandBuffer commandBuffer;

		private Camera registeredCamera;

		public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth)
		{
			buffers2[0] = a;
			buffers2[1] = b;

			foreach (var instance in instances)
			{
				instance.commandBuffer.SetRenderTarget(buffers2, depth);
			}
		}

		public static void AddMRT(RenderBuffer a, RenderBuffer b, RenderBuffer depth, Color defaultColor)
		{
			buffers2[0] = a;
			buffers2[1] = b;

			foreach (var instance in instances)
			{
				instance.commandBuffer.SetRenderTarget(buffers2, depth);
				instance.commandBuffer.ClearRenderTarget(true, true, defaultColor);
			}
		}

		public static void AddDrawMesh(Mesh mesh, int submesh, Matrix4x4 matrix, Material material, int pass, bool invert)
		{
			foreach (var instance in instances)
			{
				instance.commandBuffer.SetInvertCulling(invert);
				instance.commandBuffer.DrawMesh(mesh, matrix, material, submesh, pass);
			}
		}

		public static void AddDrawMeshInstancedProcedural(Mesh mesh, int submesh, Material material, int pass, bool invert, int count, MaterialPropertyBlock properties)
		{
			foreach (var instance in instances)
			{
				instance.commandBuffer.SetInvertCulling(invert);
				instance.commandBuffer.DrawMeshInstancedProcedural(mesh, submesh, material, pass, count, properties);
			}
		}

		public virtual void OnEnable()
		{
			node = instances.AddLast(this);

			commandBuffer = new CommandBuffer();

			registeredCamera = GetComponent<Camera>();

			if (registeredCamera != null)
			{
				registeredCamera.AddCommandBuffer(CameraEvent.AfterImageEffectsOpaque, commandBuffer);

				registeredCamera.depthTextureMode |= DepthTextureMode.Depth;
			}
		}

		public virtual void OnDisable()
		{
			instances.Remove(node); node = null;

			if (registeredCamera != null)
			{
				registeredCamera.RemoveCommandBuffer(CameraEvent.AfterImageEffectsOpaque, commandBuffer);
			}

			commandBuffer.Release();
		}

		private void HandlePreRender(Camera camera)
		{
			commandBuffer.Clear();

			if (camera.gameObject == gameObject)
			{
				var vm = SgtVolumeManager.Instances.First.Value;

				if (vm.PrepareEffects() == true)
				{
					commandBuffer.Blit(default(Texture), vm.SceneDepth, vm.DepthMaterial, vm.PassSceneDepth);

					vm.UpdateEffects();
				}
			}
		}

		[ImageEffectOpaque]
		private void OnRenderImage(RenderTexture src, RenderTexture dest)
		{
			commandBuffer.Clear();

			Graphics.Blit(src, dest);

			SgtVolumeManager.CurrentCamera = Camera.current;

			if (SgtVolumeManager.Instances.Count > 0)
			{
				var vm = SgtVolumeManager.Instances.First.Value;

				if (vm.PrepareEffects() == true)
				{
					commandBuffer.Blit(default(Texture), vm.SceneDepth, vm.DepthMaterial, vm.PassSceneDepth);

					vm.UpdateEffects();
				}
			}

			RenderTexture.active = dest;
		}
#endif
	}

#if __URP__
	public class CustomDepthPass : ScriptableRenderPass
	{
		#if __HAS_RENDER_GRAPH__
			public static UnsafeGraphContext CurrentContext;

			private class PassData
			{
				internal Camera camera;
			}

			public override void RecordRenderGraph(UnityEngine.Rendering.RenderGraphModule.RenderGraph renderGraph, ContextContainer frameContext)
			{
				using (var builder = renderGraph.AddUnsafePass<PassData>("Draw normals", out var passData))
				{
					ConfigureInput(ScriptableRenderPassInput.Depth);

					UniversalResourceData resourceData = frameContext.Get<UniversalResourceData>();

					passData.camera = SgtVolumeManager.CurrentCamera;

					builder.UseTexture(resourceData.cameraDepthTexture);

					builder.AllowPassCulling(false);

					builder.SetRenderFunc((PassData data, UnsafeGraphContext context) => ExecutePass(data, context));
				}

				static void ExecutePass(PassData passData, UnsafeGraphContext context)
				{
					CurrentContext = context;

					CommandBuffer cmd = CommandBufferHelpers.GetNativeCommandBuffer(context.cmd);

					SgtVolumeManager.CurrentCamera = passData.camera;

					if (SgtVolumeManager.Instances.Count > 0)
					{
						var vm = SgtVolumeManager.Instances.First.Value;

						if (vm.PrepareEffects() == true)
						{
							cmd.SetRenderTarget(vm.SceneDepth.colorBuffer, vm.SceneDepth.depthBuffer);
							cmd.DrawMesh(CW.Common.CwHelper.GetQuadMesh(), Matrix4x4.identity, vm.DepthMaterial, 0, vm.PassSceneDepth);

							vm.UpdateEffects();
						}
					}
				}
			}
		#else
			public static CommandBuffer CurrentCommands;

			public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
			{
				SgtVolumeManager.CurrentCamera = renderingData.cameraData.camera;

				if (SgtVolumeManager.Instances.Count > 0)
				{
					var vm = SgtVolumeManager.Instances.First.Value;

					if (vm.PrepareEffects() == true)
					{
						CurrentCommands = CommandBufferPool.Get("SgtVolumeCamera");

						CurrentCommands.Blit(default(Texture), vm.SceneDepth, vm.DepthMaterial, vm.PassSceneDepth);

						vm.UpdateEffects();

						context.ExecuteCommandBuffer(CurrentCommands);
						CommandBufferPool.Release(CurrentCommands);
					}
				}
			}
		#endif
	}
#elif __HDRP__
	public class CustomDepthPass : CustomPass
	{
		public SgtVolumeCamera parent;

		public static CustomPassContext CurrentContext;

		protected override void Setup(ScriptableRenderContext renderContext, CommandBuffer cmd)
		{
		}

		protected override void Execute(CustomPassContext ctx)
		{
			CurrentContext = ctx;

			if (parent != null)
			{
				var thisCamera = ctx.hdCamera.camera;

				if (parent.gameObject == thisCamera.gameObject)
				{
					SgtVolumeManager.CurrentCamera = thisCamera;

					if (SgtVolumeManager.Instances.Count > 0)
					{
						var vm = SgtVolumeManager.Instances.First.Value;

						if (vm.PrepareEffects() == true)
						{
							var oldActive = RenderTexture.active;

							//ctx.renderContext.ExecuteCommandBuffer(ctx.cmd);
							//ctx.cmd.Clear();

							//RenderTexture.active = vm.SceneDepth;

							//if (vm.DepthMaterial.SetPass(vm.PassSceneDepth) == true)
							//{
								//Graphics.DrawMeshNow(CW.Common.CwHelper.GetQuadMesh(), Matrix4x4.identity);
								//Graphics.Blit(default(Texture), vm.SceneDepth, vm.DepthMaterial, vm.PassSceneDepth);
							//}

							//RenderTexture.active = oldActive;
							ctx.cmd.Blit(ctx.cameraDepthBuffer, vm.SceneDepth, vm.DepthMaterial, vm.PassSceneDepth);
							//ctx.renderContext.ExecuteCommandBuffer(ctx.cmd);
							//ctx.cmd.Clear();

							vm.UpdateEffects();
						}
					}
				}
			}
		}

		protected override void Cleanup()
		{
		}
	}
#endif
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Volumetrics
{
	using CW.Common;

	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtVolumeCamera))]
	public class SgtVolumeCamera_Editor : CwEditor
	{
		public static void Require()
		{
			var found = false;

			foreach (var camera in Camera.allCameras)
			{
				if (camera.GetComponent<SgtVolumeCamera>() != null)
				{
					found = true; break;
				}
			}

			if (found == false)
			{
				Separator();

				if (Camera.main != null)
				{
					if (Camera.main.GetComponent<SgtVolumeCamera>() == null)
					{
						if (HelpButton("This component requires your camera to have the " + typeof(SgtVolumeCamera).Name + " component, but it doesn't.", UnityEditor.MessageType.Error, "Fix", 50.0f) == true)
						{
							CwHelper.GetOrAddComponent<SgtVolumeCamera>(Camera.main.gameObject);

							CW.Common.CwHelper.SelectAndPing(Camera.main);
						}
					}
				}
				else
				{
					Error("This component requires the main camera in your scene to have the " + typeof(SgtVolumeCamera).Name + " component, but it doesn't, nor is any camera tagged as MainCamera.");
				}
			}
		}

		protected override void OnInspector()
		{
			SgtVolumeCamera tgt; SgtVolumeCamera[] tgts; GetTargets(out tgt, out tgts);

			Info("This component will render volumetric effects to this camera.");
		}
	}
}
#endif