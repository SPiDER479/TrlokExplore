using UnityEngine;
using Unity.Jobs;
using Unity.Burst;
using Unity.Collections;
using Unity.Mathematics;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Ocean
{
	public partial class SgtOcean
	{
		private const int SOURCE_COUNT = 60;
		private const int SLICE_COUNT  = 24;
		
		[System.NonSerialized] private NativeArray<WaveData> sourceWaves;
		[System.NonSerialized] private JobHandle             waveJobHandle;
		[System.NonSerialized] private Vector4[]             waveDataA; // xyz = offset, w = period
		[System.NonSerialized] private NativeArray<Vector4>  waveDataAN; // Used in job
		[System.NonSerialized] private NativeArray<Vector4>  waveDataAC; // Always available copy
		[System.NonSerialized] private Vector4[]             waveDataB; // xyz = direction, w = amplitude
		[System.NonSerialized] private NativeArray<Vector4>  waveDataBN; // Used in job
		[System.NonSerialized] private NativeArray<Vector4>  waveDataBC; // Always available copy
		[System.NonSerialized] private Vector3               wavePendingDelta;

		private static float3[] fibonacciSpherePoints;

		// Internal representation of a wave
		private struct WaveData
		{
			public float3 Offset;
			public float3 Direction;
			public float  Period;
			public float  Size;
		}

		public struct WaveResult
		{
			public float3 Up;
			public float3 Position; // The world space position of the water surface
			public float3 Normal; // The world space normal of the water surface
			public float  Displacement; // The wave height in meters +- baseline
			public float  HeightAboveWater; // The sample point distance in meters +- from water surface
		}

		public static WaveResult ApplyWaves(
			float3 vertex,
			float3 normal,
			float3 tangent,
			float3 binormal,
			float  heightAboveBaseline,
			NativeArray<Vector4> waveDataA,
			NativeArray<Vector4> waveDataB)
		{
			float displacement = 0;
			float3 gradient = 0;

			for (int i = 0; i < waveDataA.Length; i++)
			{
				var offset    = (float3)(Vector3)waveDataA[i];
				var period    = waveDataA[i].w;
				var direction = (float3)(Vector3)waveDataB[i];
				var amplitude = waveDataB[i].w;
				var phase     = math.dot(vertex - offset, direction) * period;

				float s, c;
				math.sincos(phase, out s, out c);

				displacement += s * amplitude;
				gradient     += direction * (c * amplitude * period);
			}

			var dPdT = tangent  + math.dot(gradient, tangent ) * normal;
			var dPdB = binormal + math.dot(gradient, binormal) * normal;

			var surfacePosition = vertex + normal * displacement;
			var surfaceNormal   = math.normalize(math.cross(dPdT, dPdB));

			return new WaveResult
			{
				Up               = normal,
				Position         = surfacePosition,
				Normal           = surfaceNormal,
				Displacement     = displacement,
				HeightAboveWater = heightAboveBaseline - displacement
			};
		}

		[BurstCompile]
		struct UpdateWavesJob : IJob
		{
			[ReadOnly] public float  DeltaTime;
			[ReadOnly] public float  WavesAmplitude;
			[ReadOnly] public float  WavesSteepness;
			[ReadOnly] public float  WavesSpeed;
			[ReadOnly] public float3 WindDirection;
			[ReadOnly] public float  WindSpeed;
			[ReadOnly] public float3 PendingDelta;

			public NativeArray<WaveData> SourceWaves;
			public NativeArray<Vector4>  WaveDataA;
			public NativeArray<Vector4>  WaveDataB;

			public void Execute()
			{
				const float gravity    = 9.81f;
				const float baseSize   = 0.01f;
				const float sizeGrowth = 1.18f;
				const float tau        = 6.283185f;

				// 1. Resolve State
				var windVel = WindDirection * WindSpeed;
				var totalAmplitude = 0.0f;

				// 2. Simulation Loop
				for (var i = 0; i < SourceWaves.Length; i++)
				{
					var sw = SourceWaves[i];
					var physVel = math.sqrt((gravity * sw.Size) / tau);
            
					// Advance origin: (Phase Velocity + Wind) * Time
					var moveVec = (sw.Direction * physVel) + windVel;
					sw.Offset += moveVec * (WavesSpeed * DeltaTime) + PendingDelta;

					// Snap origin
					var d = math.dot(sw.Offset, sw.Direction);
					sw.Offset = sw.Direction * (d - math.round(d / sw.Size) * sw.Size);
            
					SourceWaves[i] = sw;
				}

				// 3. Sliding Window Logic
				var dominantLambda = WavesAmplitude / math.max(WavesSteepness, 0.001f);
				var targetIdx = math.log(dominantLambda / baseSize) / math.log(sizeGrowth);
				var windowStart = math.clamp(targetIdx - (WaveDataA.Length - 1), 0, SourceWaves.Length - WaveDataA.Length);
        
				var baseIdx = (int)math.floor(windowStart);
				var frac = windowStart - baseIdx;

				// 4. Packing Loop
				for (var i = 0; i < WaveDataA.Length; i++)
				{
					var srcIdx = math.clamp(baseIdx + i, 0, SourceWaves.Length - 1);
					var src = SourceWaves[srcIdx];

					// Amplitude decay and edge fading
					var amp = math.pow(0.8f, (WaveDataA.Length - 1) - i);
					if (i == 0) amp *= (1.0f - frac);
					if (i == WaveDataA.Length - 1) amp *= frac;
					totalAmplitude += amp;

					WaveDataA[i] = new Vector4(src.Offset.x, src.Offset.y, src.Offset.z, src.Period);
					WaveDataB[i] = new Vector4(src.Direction.x, src.Direction.y, src.Direction.z, amp);
				}

				// 5. Final Normalization
				var invTotalAmp = WavesAmplitude / math.max(totalAmplitude, 0.001f);
				for (var i = 0; i < WaveDataA.Length; i++)
				{
					var d = WaveDataB[i];
					d.w *= invTotalAmp;
					WaveDataB[i] = d;
				}
			}
		}

		/// <summary>This method returns the exact wave surface data from an input reference point.</summary>
		public WaveResult CalculateWaves(float3 worldPoint)
		{
			var mat = (double4x4)(float4x4)transform.localToWorldMatrix;
			var inv = math.inverse(mat);

			var localPoint   = math.transform(inv, (double3)worldPoint);
			var localSurface = math.normalize(localPoint) * radius;
			var worldSurface = math.transform(mat, localSurface);

			var worldCenter = (float3)transform.position;
			var worldNormal = math.normalize((float3)worldSurface - worldCenter);

			var worldUp       = math.abs(worldNormal.y) > 0.999f ? new float3(1,0,0) : new float3(0,1,0);
			var worldTangent  = math.normalize(math.cross(worldUp, worldNormal));
			var worldBinormal = math.cross(worldNormal, worldTangent);
			var worldHeight   = math.dot(worldPoint - (float3)worldSurface, worldNormal);

			return ApplyWaves((float3)worldSurface, worldNormal, worldTangent, worldBinormal, worldHeight, waveDataAC, waveDataBC);
		}

		private void InitializeWaves()
		{
			sourceWaves = new NativeArray<WaveData>(SOURCE_COUNT, Allocator.Persistent);
			waveDataA   = new Vector4[SLICE_COUNT];
			waveDataAN  = new NativeArray<Vector4>(SLICE_COUNT, Allocator.Persistent);
			waveDataAC  = new NativeArray<Vector4>(SLICE_COUNT, Allocator.Persistent);
			waveDataB   = new Vector4[SLICE_COUNT];
			waveDataBN = new NativeArray<Vector4>(SLICE_COUNT, Allocator.Persistent);
			waveDataBC = new NativeArray<Vector4>(SLICE_COUNT, Allocator.Persistent);

			if (fibonacciSpherePoints == null)
			{
				fibonacciSpherePoints = new float3[SOURCE_COUNT];

				var phi = math.PI * (3.0f - math.sqrt(5.0f)); 

				for (int i = 0; i < SOURCE_COUNT; i++)
				{
					var y      = 1.0f - (i / (float)(SOURCE_COUNT - 1)) * 2.0f;
					var radius = math.sqrt(1.0f - y * y);
					var theta = phi * i;

					fibonacciSpherePoints[i] = new float3(math.cos(theta) * radius, y, math.sin(theta) * radius);
				}
			}

			// Generate waves from Fibonacci Sphere so they all have unique directions
			for (var i = 0; i < SOURCE_COUNT; i++)
			{
				var shuffledIdx = (i * 23) % SOURCE_COUNT; // Use large steps so each neighboring wave has quite a large difference. 17 is a prime roughly 1/3 of SOURCE_COUNT
				var size        = 0.01f * math.pow(1.18f, i);

				sourceWaves[i] = new WaveData { Offset = float3.zero, Direction = fibonacciSpherePoints[shuffledIdx], Period = (2.0f * math.PI) / size, Size = size };
			}

			ScheduleWaves();
		}

		private void DisposeWaves()
		{
			waveJobHandle.Complete();

			sourceWaves.Dispose();
			waveDataAN.Dispose();
			waveDataAC.Dispose();
			waveDataBN.Dispose();
			waveDataBC.Dispose();
		}

		private void UpdateWaves()
		{
			waveJobHandle.Complete();

			waveDataAN.CopyTo(waveDataA);
			waveDataBN.CopyTo(waveDataB);
			waveDataAN.CopyTo(waveDataAC);
			waveDataBN.CopyTo(waveDataBC);

			if (wavePendingDelta != Vector3.zero)
			{
				for (var i = 0; i < SLICE_COUNT; i++)
				{
					var waveOrigin = waveDataA[i];

					waveOrigin.x += wavePendingDelta.x;
					waveOrigin.y += wavePendingDelta.y;
					waveOrigin.z += wavePendingDelta.z;

					waveDataA[i] = waveOrigin;
				}
			}

			ScheduleWaves();
		}

		private void ScheduleWaves()
		{
			waveJobHandle = new UpdateWavesJob
			{
				DeltaTime      = Time.deltaTime,
				WavesAmplitude = wavesAmplitude,
				WavesSteepness = wavesSteepness,
				WavesSpeed     = wavesSpeed,
				WindDirection  = windDirection,
				WindSpeed      = windSpeed,
				PendingDelta   = wavePendingDelta,
				SourceWaves    = sourceWaves,
				WaveDataA    = waveDataAN,
				WaveDataB = waveDataBN
			}.Schedule();

			wavePendingDelta = Vector3.zero;
		}

		private void WriteWaves(MaterialPropertyBlock p)
		{
			properties.SetVectorArray("_WaveDataA", waveDataA);
			properties.SetVectorArray("_WaveDataB", waveDataB);
		}
	}
}