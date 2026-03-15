using Unity.Mathematics;
using UnityEngine;
using Unity.Jobs;
using Unity.Collections;
using Unity.Burst;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>This component manages global wind data for SGT landscape shaders, allowing for multi-layered animated wind displacement.</summary>
	[ExecuteInEditMode]
	[HelpURL("Space Graphics Toolkit/SGT Landscape Wind Manager")]
	public class SgtLandscapeWindManager : MonoBehaviour
	{
		/// <summary>The overall strength of the wind layers.</summary>
		public float WindStrength { set { windStrength = value; } get { return windStrength; } } [Range(0.0f, 5.0f)] [SerializeField] private float windStrength = 1.0f;

		/// <summary>The speed at which the wind direction and strength transitions when changed.</summary>
		public float TransitionSpeed { set { transitionSpeed = value; } get { return transitionSpeed; } } [Range(0.1f, 5.0f)] [SerializeField] private float transitionSpeed = 0.8f;

		private const int COUNT = 4;

		private static readonly int DataAID = Shader.PropertyToID("_SGT_WindDataA");
		private static readonly int DataBID = Shader.PropertyToID("_SGT_WindDataB");

		private NativeArray<float>  phases;
		private NativeArray<float4> currentB;
		private NativeArray<float4> outA;
		private NativeArray<float4> outB;
		private readonly Vector4[]  managedA = new Vector4[COUNT];
		private readonly Vector4[]  managedB = new Vector4[COUNT];
		private bool                initialized;

		protected virtual void OnEnable()
		{
			phases      = new NativeArray<float>(COUNT, Allocator.Persistent);
			currentB    = new NativeArray<float4>(COUNT, Allocator.Persistent);
			outA        = new NativeArray<float4>(COUNT, Allocator.Persistent);
			outB        = new NativeArray<float4>(COUNT, Allocator.Persistent);
			initialized = false;
		}

		protected virtual void OnDisable()
		{
			if (phases.IsCreated)   phases.Dispose();
			if (currentB.IsCreated) currentB.Dispose();
			if (outA.IsCreated)     outA.Dispose();
			if (outB.IsCreated)     outB.Dispose();

			System.Array.Clear(managedA, 0, COUNT);
			System.Array.Clear(managedB, 0, COUNT);

			Shader.SetGlobalVectorArray(DataAID, managedA);
			Shader.SetGlobalVectorArray(DataBID, managedB);

			initialized = false;
		}

		protected virtual void Update()
		{
			var dt = Application.isPlaying ? Time.deltaTime : 0.016f;

			new WindJob
			{
				windDir    = math.normalizesafe((float3)transform.forward),
				strength   = windStrength,
				transition = transitionSpeed,
				dt         = dt,
				snap       = !initialized,
				phases     = phases,
				currentB   = currentB,
				outA       = outA,
				outB       = outB,
			}.Run();

			initialized = true;

			for (var i = 0; i < COUNT; i++)
			{
				managedA[i] = (Vector4)outA[i];
				managedB[i] = (Vector4)outB[i];
			}

			Shader.SetGlobalVectorArray(DataAID, managedA);
			Shader.SetGlobalVectorArray(DataBID, managedB);
		}

		[BurstCompile(FloatPrecision.Low, FloatMode.Fast)]
		struct WindJob : IJob
		{
			public float3 windDir;
			public float  strength, transition, dt;
			public bool   snap;

			public NativeArray<float>           phases;
			public NativeArray<float4>          currentB;
			[WriteOnly] public NativeArray<float4> outA;
			[WriteOnly] public NativeArray<float4> outB;

			public void Execute()
			{
				var perp = Perp(windDir);

				// Layers: spatialDir, spread, amp, speed, scale
				Layer(0, perp, new float3( 0.83f, 0.13f, 0.55f),  0.0f, 0.20f, 1.8f, 0.10f);
				Layer(1, perp, new float3(-0.45f, 0.07f, 0.89f), 40.0f, 0.08f, 3.1f, 0.18f);
				Layer(2, perp, new float3( 0.62f, 0.09f,-0.78f),-15.0f, 0.14f, 0.7f, 0.04f);
				Layer(3, perp, new float3(-0.31f, 0.19f,-0.64f), 65.0f, 0.03f, 7.5f, 0.45f);
			}

			static float3 Perp(float3 v)
			{
				var up = math.select(new float3(0, 1, 0), new float3(1, 0, 0), math.abs(math.dot(v, new float3(0, 1, 0))) > 0.9f);
				
				return math.normalize(math.cross(up, v));
			}

			void Layer(int i, float3 perp, float3 spatialDir, float spreadDeg, float amp, float speed, float scale)
			{
				math.sincos(math.radians(spreadDeg), out var s, out var c);
				
				var dir     = math.normalize(windDir * c + perp * s);
				var targetB = new float4(dir, amp * strength);
				var curB    = snap ? targetB : math.lerp(currentB[i], targetB, 1.0f - math.exp(-transition * dt));
				
				currentB[i] = curB;

				var phase = phases[i] + speed * dt;
				phase    -= math.round(phase / 512.0f) * 512.0f;
				phases[i] = phase;

				outA[i] = new float4(math.normalize(spatialDir) * scale, phase);
				outB[i] = curB;
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtLandscapeWindManager))]
	public class SgtLandscapeWindManager_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtLandscapeWindManager tgt; SgtLandscapeWindManager[] tgts; GetTargets(out tgt, out tgts);

			Draw("windStrength", "The overall strength of the wind layers.");
			Draw("transitionSpeed", "The speed at which the wind direction and strength transitions when changed.");
		}
	}
}
#endif