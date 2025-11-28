using UnityEngine;
using CW.Common;
using Unity.Mathematics;
using Unity.Jobs;
using UnityEngine.Jobs;
using Unity.Burst;
using Unity.Collections;
using Unity.Collections.LowLevel.Unsafe;
using System.Collections.Generic;
using Rand = Unity.Mathematics.Random;

namespace SpaceGraphicsToolkit.RingSystem
{
	/// <summary>This component can be added alongside <b>SgtRingSystem</b> to add particles to the ring bands.</summary>
	[RequireComponent(typeof(SgtRingSystem))]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ring Particles")]
	public class SgtRingParticles : MonoBehaviour
	{
		private struct CameraData
		{
			public Quaternion PreviousRotation;
			public float      TotalRoll;

			[System.NonSerialized]
			public static Dictionary<Camera, CameraData> Instances = new Dictionary<Camera, CameraData>();

			public static CameraData Update(Camera camera)
			{
				var instance = Instances.GetValueOrDefault(camera);
				var rotation = camera.transform.rotation;

				instance.TotalRoll       += (Quaternion.Inverse(rotation) * instance.PreviousRotation).eulerAngles.z;
				instance.PreviousRotation = rotation;

				Instances[camera] = instance;

				return instance;
			}
		}

		public struct SearchResult
		{
			public ParticleCoord Coord;
			public double3       LocalPosition;
		}

		public struct Chunk
		{
			public int                Index;
			public int                Samples;
			public Rand               Rng;
			public ChunkCoord         Coord;
			public double3            LocalMin;
			public double3            LocalMax;
			public UnsafeList<float4> Billboards;

			public void Dispose()
			{
				Billboards.Dispose();
			}
		}

		public struct JobData
		{
			public int ParticleCount;

			public ChunkCoord SearchCoord;
			public int        SearchIndex;
		}

		[System.Serializable]
		public struct ChunkCoord : System.IEquatable<ChunkCoord>
		{
			public long x, y, z;
			public byte o;

			public ChunkCoord(long newX, long newY, long newZ, byte newO)
			{
				x = newX; y = newY; z = newZ; o = newO;
			}

			public bool Equals(ChunkCoord other)
			{
				return x == other.x && y == other.y && z == other.z && o == other.o;
			}

			public override bool Equals(object obj)
			{
				return obj is ChunkCoord other && Equals(other);
			}

			public override int GetHashCode()
			{
				long hash = 17;
				hash = hash * 31 + x;
				hash = hash * 31 + y;
				hash = hash * 31 + z;
				hash = hash * 31 + o;
				return (int)hash;
			}

			public override string ToString()
			{
				return $"ChunkCoord({x}, {y}, {z}, {o})";
			}
		}

		[System.Serializable]
		public struct ParticleCoord : System.IEquatable<ParticleCoord>
		{
			public ChunkCoord c;
			public int        i;

			public ParticleCoord(ChunkCoord newC, int newI)
			{
				c = newC; i = newI;
			}

			public bool Equals(ParticleCoord other)
			{
				return c.Equals(other.c) && i == other.i;
			}

			public override bool Equals(object obj)
			{
				return obj is ParticleCoord other && Equals(other);
			}

			public override int GetHashCode()
			{
				long hash = 17;
				hash = hash * 31 + c.x;
				hash = hash * 31 + c.y;
				hash = hash * 31 + c.z;
				hash = hash * 31 + c.o;
				hash = hash * 31 + i;
				return (int)hash;
			}

			public override string ToString()
			{
				return $"ChunkCoord({c.x}, {c.y}, {c.z}, {c.o}, {i})";
			}
		}

		/// <summary>The material used to render the particles.
		/// NOTE: This must use the <b>SGT / RingParticles</b> shader.</summary>
		public Material Material { set { material = value; } get { return material; } } [SerializeField] private Material material;

		/// <summary>The particle brightness will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 0.1f;

		/// <summary>The texture applied to the particles.
		/// NOTE: If <b>Material</b> uses the <b>RingParticles_Additive</b> shader, then this should be a 2D texture of a particle, or grid of particles.
		/// NOTE: If <b>Material</b> uses the <b>RingParticles_March</b> shader, then this should be a 3D texture SDF of a particle like an asteroid.</summary>
		public Texture MainTex { set { mainTex = value; } get { return mainTex; } } [SerializeField] private Texture mainTex;

		/// <summary>The amount of columns and rows in the <b>MainTex</b>.
		/// NOTE: This is only used when <b>Material</b> uses the <b>RingParticles_Additive</b> shader.</summary>
		public Vector2Int Cells { set { cells = value; } get { return cells; } } [SerializeField] private Vector2Int cells = new Vector2Int(1, 1);

		/// <summary>The maximum camera distance particles can appear in world space.</summary>
		public float Range { set { range = value; } get { return range; } } [SerializeField] private float range = 5.0f;

		/// <summary>The amount of particles that will be spawned.</summary>
		public int Density { set { density = value; } get { return density; } } [SerializeField] private int density = 10000;

		/// <summary>The radius of particles in world space.</summary>
		public float Radius { set { radius = value; } get { return radius; } } [SerializeField] private float radius = 0.01f;

		/// <summary>Each octave will render the particles again, but at double the range and size of the previous octave.</summary>
		public int Octaves { set { octaves = value; } get { return octaves; } } [SerializeField] [Range(1, 8)] private int octaves = 1;

		/// <summary>The maximum amount of particles that can spawn per frame.</summary>
		public int SpawnRate { set { spawnRate = value; } get { return spawnRate; } } [SerializeField] private int spawnRate = 1000;

		/// <summary>The particles will spawn using this seed.</summary>
		public int Seed { set { seed = value; } get { return seed; } } [SerializeField] [CwSeed] private int seed;

		/// <summary>The maximum distance particles can drift in world space.</summary>
		public float DriftDistance { set { driftDistance = value; } get { return driftDistance; } } [SerializeField] [UnityEngine.Serialization.FormerlySerializedAs("drift")] private float driftDistance = 1.0f;

		/// <summary>The speed the particles can drift.</summary>
		public float DriftSpeed { set { driftSpeed = value; } get { return driftSpeed; } } [SerializeField] private float driftSpeed = 0.01f;

		/// <summary>The current time used by the particle drift.</summary>
		public float DriftOffset { set { driftOffset = value; } get { return driftOffset; } } [SerializeField] private float driftOffset;

		/// <summary>The speed the particles spin at.</summary>
		public float SpinSpeed { set { spinSpeed = value; } get { return spinSpeed; } } [SerializeField] private float spinSpeed = 0.1f;

		/// <summary>The current time used by the particle spin.</summary>
		public float SpinOffset { set { spinOffset = value; } get { return spinOffset; } } [SerializeField] private float spinOffset;

		/// <summary>Should this component keep track of particles that are near the camera?</summary>
		public bool Search { set { search = value; } get { return search; } } [SerializeField] private bool search;

		/// <summary>Particles within this local space radius will be found.</summary>
		public float SearchRadius { set { searchRadius = value; } get { return searchRadius; } } [SerializeField] private float searchRadius = 0.1f;

		/// <summary>How many particles should be scanned for each loop?</summary>
		public int SearchSpeed { set { searchSpeed = value; } get { return searchSpeed; } } [SerializeField] private int searchSpeed = 100;

		/// <summary>The maximum amount of particles within the <b>SearchRadius</b> that will be stored.</summary>
		public int SearchCapacity { set { searchCapacity = value; } get { return searchCapacity; } } [SerializeField] private int searchCapacity = 100;

		/// <summary>Debug the particle search results to the <b>Scene</b> view.</summary>
		public bool SearchDebug { set { searchDebug = value; } get { return searchDebug; } } [SerializeField] private bool searchDebug;

		public event System.Action<NativeList<SearchResult>> OnSearchResults;

		[System.NonSerialized]
		private static Mesh generatedMesh;

		[System.NonSerialized]
		private Texture2D instanceData;

		[System.NonSerialized]
		private NativeArray<int> countData;

		[System.NonSerialized]
		private NativeArray<JobData> jobData;

		[System.NonSerialized]
		private NativeArray<double4> planeData;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private SgtRingSystem cachedRingSystem;

		[System.NonSerialized]
		private static LinkedList<SgtRingParticles> instances = new LinkedList<SgtRingParticles>();

		[System.NonSerialized]
		private static LinkedListNode<SgtRingParticles> node;

		[System.NonSerialized]
		private NativeParallelHashMap<ChunkCoord, Chunk> curChunks;

		[System.NonSerialized]
		private NativeParallelHashMap<ChunkCoord, Chunk> oldChunks;

		[System.NonSerialized]
		private NativeList<SearchResult> searchResults;

		[System.NonSerialized]
		private NativeList<Chunk> chunkPool;

		[System.NonSerialized]
		private static Vector4[] chunkDeltas = new Vector4[1000];

		[System.NonSerialized]
		private static Vector4[] octavePivots = new Vector4[8];

		[System.NonSerialized]
		private static Vector4[] octaveRanges = new Vector4[8];

		[System.NonSerialized]
		private static ChunkCoord[] octaveCoords = new ChunkCoord[8];

		[System.NonSerialized]
		private static Plane[] tempPlanes = new Plane[6];

		[System.NonSerialized]
		private JobHandle chunkJobHandle;

		[System.NonSerialized]
		private bool chunkJobRunning;
		
		private static int _SGT_WrapSize      = Shader.PropertyToID("_SGT_WrapSize");
		private static int _SGT_MainTex       = Shader.PropertyToID("_SGT_MainTex");
		private static int _SGT_WorldToLocal  = Shader.PropertyToID("_SGT_WorldToLocal");
		private static int _SGT_Data          = Shader.PropertyToID("_SGT_Data");
		private static int _SGT_Cells         = Shader.PropertyToID("_SGT_Cells");
		private static int _SGT_Roll          = Shader.PropertyToID("_SGT_Roll");
		private static int _SGT_ParticleCount = Shader.PropertyToID("_SGT_ParticleCount");
		private static int _SGT_OctavePivots  = Shader.PropertyToID("_SGT_OctavePivots");
		private static int _SGT_OctaveRanges  = Shader.PropertyToID("_SGT_OctaveRanges");
		private static int _SGT_AxisX         = Shader.PropertyToID("_SGT_AxisX");
		private static int _SGT_AxisY         = Shader.PropertyToID("_SGT_AxisY");
		private static int _SGT_AxisZ         = Shader.PropertyToID("_SGT_AxisZ");
		private static int _SGT_Deltas        = Shader.PropertyToID("_SGT_Deltas");
		private static int _SGT_AnimationData = Shader.PropertyToID("_SGT_AnimationData");
		private static int _SGT_InstanceData  = Shader.PropertyToID("_SGT_InstanceData");
		private static int _SGT_InstanceSize  = Shader.PropertyToID("_SGT_InstanceSize");

		public bool IsAdditive
		{
			get
			{
				return material != null && material.shader.name.EndsWith("_Additive") == true;
			}
		}

		public bool IsMarch
		{
			get
			{
				return material != null && material.shader.name.EndsWith("_March") == true;
			}
		}

		public bool ParticleExists(ParticleCoord coord)
		{
			var chunk = default(Chunk);

			if (curChunks.TryGetValue(coord.c, out chunk) == true && coord.i < chunk.Billboards.Length)
			{
				return true;
			}

			return false;
		}

		public void SetParticleVisibility(ParticleCoord coord, bool visible)
		{
			var chunk = default(Chunk);

			if (curChunks.TryGetValue(coord.c, out chunk) == true && coord.i < chunk.Billboards.Length)
			{
				var billboard = chunk.Billboards[coord.i];

				billboard.w = visible == true ? chunk.Index : -chunk.Index;

				chunk.Billboards[coord.i] = billboard;
			}
		}

		protected virtual void OnEnable()
		{
			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			node = instances.AddLast(this);

			TryGenerateMesh();

			cachedRingSystem = GetComponent<SgtRingSystem>();

			instanceData = new Texture2D(512, 16, TextureFormat.RGBAFloat, false, true);
			instanceData.filterMode = FilterMode.Point;

			countData = new NativeArray<int>(1, Allocator.Persistent);
			planeData = new NativeArray<double4>(6, Allocator.Persistent);
			jobData   = new NativeArray<JobData>(1, Allocator.Persistent);

			curChunks     = new NativeParallelHashMap<ChunkCoord, Chunk>(64, Allocator.Persistent);
			oldChunks     = new NativeParallelHashMap<ChunkCoord, Chunk>(64, Allocator.Persistent);
			chunkPool     = new NativeList<Chunk>(256, Allocator.Persistent);
			searchResults = new NativeList<SearchResult>(searchCapacity, Allocator.Persistent);

			for (var i = 0; i < chunkPool.Capacity; i++)
			{
				AddToChunkPool();
			}

			Camera.onPreCull += HandleCameraPreRender;
			UnityEngine.Rendering.RenderPipelineManager.beginCameraRendering += HandleCameraPreRender;
		}

		private void AddToChunkPool()
		{
			var chunk = new Chunk();

			chunk.Index      = curChunks.Count() + chunkPool.Length + 1;
			chunk.Billboards = new UnsafeList<float4>(128, Allocator.Persistent);

			chunkPool.Add(chunk);
		}

		protected virtual void OnDisable()
		{
			Camera.onPreCull -= HandleCameraPreRender;
			UnityEngine.Rendering.RenderPipelineManager.beginCameraRendering -= HandleCameraPreRender;

			DestroyImmediate(instanceData);

			countData.Dispose();
			planeData.Dispose();
			jobData.Dispose();

			foreach (var pair in curChunks)
			{
				pair.Value.Dispose();
			}

			foreach (var chunk in chunkPool)
			{
				chunk.Dispose();
			}

			curChunks.Dispose();
			oldChunks.Dispose();
			chunkPool.Dispose();
			searchResults.Dispose();

			CameraData.Instances.Clear();

			instances.Remove(node); node = null;

			if (instances.Count == 0)
			{
				DestroyImmediate(generatedMesh);
			}
		}

		private static Camera[] tempCameras = new Camera[512];

		private void TryCompleteChunkJob()
		{
			if (chunkJobRunning == true)
			{
				chunkJobHandle.Complete();
				chunkJobRunning = false;
			}
		}

		protected virtual void LateUpdate()
		{
			TryCompleteChunkJob();

			// Pool old chunks that weren't rendered last frame
			foreach (var pair in oldChunks)
			{
				var chunk = pair.Value;

				chunk.Billboards.Clear();
				chunk.Samples = 0;

				chunkPool.Add(chunk);
			}

			oldChunks.Clear();

			// Add to pool?
			if (chunkPool.Length < 16)
			{
				var remaining = 1000 - (curChunks.Count() + chunkPool.Length);

				if (remaining >= 16)
				{
					for (var i = 0; i < 16; i++)
					{
						AddToChunkPool();
					}
				}
			}

			// Move current chunks to old chunks
			foreach (var pair in curChunks)
			{
				oldChunks.Add(pair.Key, pair.Value);
			}

			curChunks.Clear();

			// Update chunks with current cameras
			var tempCameraCount = Camera.GetAllCameras(tempCameras);
			var layerMask       = 1 << gameObject.layer;
			var handle          = default(JobHandle);

			for (var i = 0; i < tempCameraCount; i++)
			{
				var tempCamera = tempCameras[i];

				if (tempCamera != null && tempCamera.isActiveAndEnabled == true)
				{
					if ((tempCamera.cullingMask & layerMask) != 0)
					{
						GeometryUtility.CalculateFrustumPlanes(tempCamera, tempPlanes);

						var chunkJob = new ChunkJob();

						chunkJob.Data              = jobData;
						chunkJob.Seed              = seed;
						chunkJob.WorldPlane0       = new float4(tempPlanes[0].normal, tempPlanes[0].distance);
						chunkJob.WorldPlane1       = new float4(tempPlanes[1].normal, tempPlanes[1].distance);
						chunkJob.WorldPlane2       = new float4(tempPlanes[2].normal, tempPlanes[2].distance);
						chunkJob.WorldPlane3       = new float4(tempPlanes[3].normal, tempPlanes[3].distance);
						chunkJob.WorldPlane4       = new float4(tempPlanes[4].normal, tempPlanes[4].distance);
						chunkJob.WorldPlane5       = new float4(tempPlanes[5].normal, tempPlanes[5].distance);
						chunkJob.LocalToWorld      = (float4x4)cachedRingSystem.transform.localToWorldMatrix;
						chunkJob.CellSize          = range * 0.5f;
						chunkJob.LocalCamera       = (float3)cachedRingSystem.transform.InverseTransformPoint(tempCamera.transform.position);
						chunkJob.Octaves           = octaves;
						chunkJob.OldChunks         = oldChunks;
						chunkJob.CurChunks         = curChunks;
						chunkJob.ChunkPool         = chunkPool;

						handle = chunkJob.Schedule(handle);
					}
				}
			}

			var spawnJob = new SpawnJob();

			spawnJob.Data              = jobData;
			spawnJob.SpawnRate         = spawnRate;
			spawnJob.MaxSamples        = density;
			spawnJob.CurChunks         = curChunks;
			spawnJob.RingAlphaData     = cachedRingSystem.AlphaData;
			spawnJob.RingThicknessData = cachedRingSystem.ThicknessData;
			spawnJob.RingSize          = new float4(cachedRingSystem.RadiusInner, cachedRingSystem.RadiusOuter - cachedRingSystem.RadiusInner, cachedRingSystem.Thickness * 0.5f, cachedRingSystem.RadiusOuter);
			spawnJob.RingData          = new float4(cachedRingSystem.Density, cachedRingSystem.Weight, cachedRingSystem.Squash, 1.0f - cachedRingSystem.Squash);

			handle = spawnJob.Schedule(handle);

			chunkJobHandle  = handle;
			chunkJobRunning = true;

			// Apply material properties
			driftOffset += driftSpeed * Time.deltaTime;
			spinOffset  +=  spinSpeed * Time.deltaTime;

			properties.SetTexture(_SGT_MainTex, mainTex != null ? mainTex : Texture2D.whiteTexture);
			properties.SetVector(_SGT_WrapSize, new Vector4(range * 2.0f, CwHelper.Reciprocal(range * 2.0f), 0.0f, 0.0f));
			properties.SetMatrix(_SGT_WorldToLocal, cachedRingSystem.transform.worldToLocalMatrix);
			properties.SetVector(_SGT_Data, new Vector4(brightness, radius, 0.0f, 1.0f / range));
			properties.SetVector(_SGT_Cells, new Vector4(cells.x, cells.y, 0.0f, 0.0f));
			properties.SetVector(_SGT_AxisX, cachedRingSystem.transform.right  );
			properties.SetVector(_SGT_AxisY, cachedRingSystem.transform.up     );
			properties.SetVector(_SGT_AxisZ, cachedRingSystem.transform.forward);
			properties.SetVector(_SGT_AnimationData, new Vector4(driftOffset, driftDistance, spinOffset, 0.0f));

			cachedRingSystem.ApplyRingSettings(properties, false, true);
		}

		private void HandleCameraPreRender(UnityEngine.Rendering.ScriptableRenderContext context, Camera camera)
		{
			HandleCameraPreRender(camera);
		}

		[BurstCompile]
		private struct SearchJob : IJob
		{
			public NativeArray<JobData> Data;

			public NativeArray<float4> Pixels;

			public NativeParallelHashMap<ChunkCoord, Chunk> Chunks;

			public double3                  SearchPos;
			public float                    SearchRadius;
			public int                      SearchSpeed;
			public int                      SearchCapacity;
			public NativeList<SearchResult> SearchResults;

			public float DriftDistance;
			public float DriftOffset;

			public double3 GetLocalPosition(Chunk chunk, int index)
			{
				var pData    = chunk.Billboards[index];
				var seed     = math.dot(pData.x, 1000.0f) % 1.0f;
				var localPos = math.lerp(chunk.LocalMin, chunk.LocalMax, pData.xyz);

				// Drift
				float  angle1    = seed * 6.2831853f;
				float  angle2    = math.frac(seed * 5 + DriftOffset) * 6.2831853f;
				float3 direction = new float3(math.cos(angle1) * math.sin(angle2), math.cos(angle2), math.sin(angle1) * math.sin(angle2));
				localPos += direction * DriftDistance; // _SGT_Data.z = drift

				return localPos;
			}

			public void Execute()
			{
				var searchRadiusSq  = SearchRadius * SearchRadius;
				var existingResults = new NativeParallelHashSet<ParticleCoord>(SearchResults.Length, Allocator.Temp);

				// Remove invalid or out of range search results
				for (var i = SearchResults.Length - 1; i >= 0; i--)
				{
					var searchResult = SearchResults[i];
					var chunk        = default(Chunk);

					if (Chunks.TryGetValue(searchResult.Coord.c, out chunk) == true)
					{
						if (searchResult.Coord.i < chunk.Billboards.Length)
						{
							var localPos = GetLocalPosition(chunk, searchResult.Coord.i);

							if (math.distancesq(localPos, SearchPos) <= searchRadiusSq)
							{
								searchResult.LocalPosition = localPos;

								SearchResults[i] = searchResult;

								existingResults.Add(searchResult.Coord);

								continue;
							}
						}
					}

					SearchResults.RemoveAtSwapBack(i);
				}

				var jobData   = Data[0];
				var remaining = SearchSpeed;

				if (Chunks.ContainsKey(jobData.SearchCoord) == false)
				{
					jobData.SearchCoord = new ChunkCoord(0, 0, 0, 255);
				}

				foreach (var pair in Chunks)
				{
					var chunk = pair.Value;

					if (jobData.SearchCoord.o == 255 || pair.Key.Equals(jobData.SearchCoord) == true)
					{
						jobData.SearchCoord = chunk.Coord;

						while (remaining > 0 && SearchResults.Length < SearchCapacity)
						{
							// Finished searching this chunk?
							if (jobData.SearchIndex >= chunk.Billboards.Length)
							{
								jobData.SearchIndex = 0;
								jobData.SearchCoord = new ChunkCoord(0, 0, 0, 255);

								break;
							}

							// Check particle?
							if (existingResults.Contains(new ParticleCoord(chunk.Coord, jobData.SearchIndex)) == false)
							{
								var localPos = GetLocalPosition(chunk, jobData.SearchIndex);

								if (math.distancesq(localPos, SearchPos) <= searchRadiusSq)
								{
									SearchResults.Add(new SearchResult() { Coord = new ParticleCoord(chunk.Coord, jobData.SearchIndex), LocalPosition = localPos });
								}
							}

							// Continue to next
							jobData.SearchIndex += 1;

							remaining -= 1;
						}
					}
				}

				Data[0] = jobData;
			}
		}

		[BurstCompile]
		private struct PixelJob : IJob
		{
			public NativeArray<float4> Pixels;

			public NativeParallelHashMap<ChunkCoord, Chunk> Chunks;

			public void Execute()
			{
				var particleIndex = 0;

				foreach (var pair in Chunks)
				{
					foreach (var particle in pair.Value.Billboards)
					{
						Pixels[particleIndex++] = particle;
					}
				}
			}
		}

		[BurstCompile]
		private struct ChunkJob : IJob
		{
			public NativeParallelHashMap<ChunkCoord, Chunk> OldChunks;
			public NativeParallelHashMap<ChunkCoord, Chunk> CurChunks;
			public NativeList<Chunk>                        ChunkPool;
			public NativeArray<JobData>                     Data;

			[ReadOnly] public int                     Seed;
			[ReadOnly] public double3                 CellSize;
			[ReadOnly] public int                     Octaves;
			[ReadOnly] public double4x4               LocalToWorld;
			[ReadOnly] public float4                  WorldPlane0;
			[ReadOnly] public float4                  WorldPlane1;
			[ReadOnly] public float4                  WorldPlane2;
			[ReadOnly] public float4                  WorldPlane3;
			[ReadOnly] public float4                  WorldPlane4;
			[ReadOnly] public float4                  WorldPlane5;
			[ReadOnly] public double3      LocalCamera;

			private bool TestPlanesAABB(NativeArray<double4> localPlanes, double3 aabbMin, double3 aabbMax)
			{
				for (int i = 0; i < localPlanes.Length; i++)
				{
					var localPlane = localPlanes[i];

					// Get the negative vertex (the one farthest in direction of plane normal)
					var negativeVertex = math.select(aabbMax, aabbMin, localPlane.xyz < 0);

					// If the negative vertex is outside the plane, the AABB is completely outside
					if (math.dot(localPlane.xyz, negativeVertex) + localPlane.w < 0)
						return false;
				}

				return true;
			}

			private double4 ConvertPlane(double4x4 inverseTranspose, float4 worldPlane)
			{
				var localPlane  = math.mul(inverseTranspose, worldPlane);
				var localLength = math.length(localPlane.xyz);

				return localLength > 0.0f ? localPlane / localLength : localPlane;
			}

			public void Execute()
			{
				var localPlanes      = new NativeArray<double4>(6, Allocator.Temp);
				var octaveSize       = CellSize;
				var jobData          = Data[0]; jobData.ParticleCount = 0;
				var inverseTranspose = math.transpose(LocalToWorld);

				localPlanes[0] = ConvertPlane(inverseTranspose, WorldPlane0);
				localPlanes[1] = ConvertPlane(inverseTranspose, WorldPlane1);
				localPlanes[2] = ConvertPlane(inverseTranspose, WorldPlane2);
				localPlanes[3] = ConvertPlane(inverseTranspose, WorldPlane3);
				localPlanes[4] = ConvertPlane(inverseTranspose, WorldPlane4);
				localPlanes[5] = ConvertPlane(inverseTranspose, WorldPlane5);

				for (var o = 0; o < Octaves; o++)
				{
					var cameraX  = (long)math.floor(LocalCamera.x / octaveSize.x);
					var cameraY  = (long)math.floor(LocalCamera.y / octaveSize.y);
					var cameraZ  = (long)math.floor(LocalCamera.z / octaveSize.z);
					var cameraC  = new ChunkCoord(cameraX, cameraY, cameraZ, (byte)o);

					for (var z = -2; z <= 2; z++)
					{
						for (var y = -2; y <= 2; y++)
						{
							for (var x = -2; x <= 2; x++)
							{
								var localCoord = cameraC;

								localCoord.x += x;
								localCoord.y += y;
								localCoord.z += z;

								var localMin = new double3(localCoord.x, localCoord.y, localCoord.z) * octaveSize;
								var localMax = localMin + octaveSize;

								if (TestPlanesAABB(localPlanes, localMin, localMax) == true)
								{
									var chunk = default(Chunk);

									if (OldChunks.TryGetValue(localCoord, out chunk) == true)
									{
										OldChunks.Remove(localCoord);

										chunk.Coord    = localCoord;
										chunk.LocalMin = localMin;
										chunk.LocalMax = localMax;

										CurChunks.Add(localCoord, chunk);
									}
									else if (CurChunks.ContainsKey(localCoord) == true)
									{
										continue;
									}
									else if (ChunkPool.Length > 0)
									{
										chunk = ChunkPool[ChunkPool.Length - 1];

										var seed = (uint)(Seed + localCoord.GetHashCode());

										chunk.Rng      = new Rand(seed > 0 ? seed : 1);
										chunk.Coord    = localCoord;
										chunk.LocalMin = localMin;
										chunk.LocalMax = localMax;

										ChunkPool.RemoveAt(ChunkPool.Length - 1);

										CurChunks.Add(localCoord, chunk);
									}
								}
							}
						}
					}

					octaveSize *= 2;
				}
			}
		}

		[BurstCompile]
		private struct SpawnJob : IJob
		{
			public NativeParallelHashMap<ChunkCoord, Chunk> CurChunks;
			public NativeArray<JobData>                     Data;

			[ReadOnly] public int                     MaxSamples;
			[ReadOnly] public int                     SpawnRate;
			[ReadOnly] public float4                  RingSize;
			[ReadOnly] public float4                  RingData;
			[ReadOnly] public NativeArray<float>      RingAlphaData;
			[ReadOnly] public NativeArray<float>      RingThicknessData;

			private static float Sample1D(NativeArray<float> data, float u)
			{
				var c = data.Length; if (c == 0) return 0.0f;
				var x = math.clamp(u, 0.0f, 1.0f) * (c - 1);
				var a = (int)math.floor(x);
				var b = math.min(a + 1, c - 1);

				return math.lerp(data[a], data[b], x - a);
			}

			private float GetDensity(float3 opos)
			{
				var distance01 = (math.length(opos.xz) - RingSize.x) / RingSize.y;

				if (distance01 > 0.0f && distance01 < 1.0f)
				{
					var thickness  = RingSize.z * (RingData.w + RingData.z * Sample1D(RingThicknessData, distance01));
					var alpha      = Sample1D(RingAlphaData, distance01);

					alpha *= math.pow(1.0f - math.saturate(math.abs(opos.y) / thickness), RingData.y);

					return alpha;
				}

				return 0.0f;
			}

			public void Execute()
			{
				var jobData          = Data[0]; jobData.ParticleCount = 0;
				var remainingSamples = 0;
				var samplesPerCell   = math.max(1, MaxSamples / 64);
				var tempChunks       = new NativeList<Chunk>(CurChunks.Count(), Allocator.Temp);

				foreach (var pair in CurChunks)
				{
					var chunk = pair.Value;

					remainingSamples += math.max(0, samplesPerCell - chunk.Samples);

					tempChunks.Add(chunk);
				}

				CurChunks.Clear();

				// Write chunks
				var spawnScale = remainingSamples > 0 ? SpawnRate / (float)remainingSamples : 0.0f; // Prevent spawning too many particles

				for (var c = 0; c < tempChunks.Length; c++)
				{
					var chunk    = tempChunks[c];
					var localMin = chunk.LocalMin;
					var localMax = chunk.LocalMax;

					// Spawn new particles?
					var remaining = math.max(0, samplesPerCell - chunk.Samples);

					if (remaining > 0)
					{
						var scaledRemaining = (int)math.ceil(remaining * spawnScale);

						remaining = math.clamp(scaledRemaining, 1, remaining);

						for (var i = 0; i < remaining; i++)
						{
							var rand     = chunk.Rng.NextFloat4();
							var localPos = (float3)math.lerp(localMin, localMax, rand.xyz);

							if (rand.w < GetDensity(localPos))
							{
								chunk.Billboards.Add(new float4(rand.xyz, chunk.Index));
							}

							chunk.Samples += 1;
						}
					}

					jobData.ParticleCount += chunk.Billboards.Length;

					CurChunks.Add(chunk.Coord, chunk);
				}

				Data[0] = jobData;
			}
		}

		private void HandleCameraPreRender(Camera camera)
		{
			if (material != null)
			{
				TryCompleteChunkJob();

				var localPos     = cachedRingSystem.transform.InverseTransformPoint(camera.transform.position);
				var localToWorld = (double4x4)(float4x4)cachedRingSystem.transform.localToWorldMatrix;
				var octaveSize   = range * 0.5f;
				var octaveRadius = radius;

				for (var i = 0; i < 8; i++)
				{
					var cameraX  = (long)math.floor(localPos.x / (double)octaveSize);
					var cameraY  = (long)math.floor(localPos.y / (double)octaveSize);
					var cameraZ  = (long)math.floor(localPos.z / (double)octaveSize);
					var cameraC  = new ChunkCoord(cameraX, cameraY, cameraZ, (byte)i);
					var worldPos = (float3)math.transform(localToWorld, new double3(cameraX, cameraY, cameraZ) * octaveSize);

					octavePivots[i] = new Vector4(worldPos.x, worldPos.y, worldPos.z, octaveSize);
					octaveRanges[i] = new Vector4(octaveRadius, 1.0f / (octaveSize * 2.0f), 0.0f, 0.0f);
					octaveCoords[i] = cameraC;

					octaveSize   *= 2;
					octaveRadius *= 2;
				}

				var particleCount = jobData[0].ParticleCount;

				// Expand texture?
				if (particleCount > instanceData.width * instanceData.height)
				{
					var missingPixels  = particleCount - instanceData.width * instanceData.height;
					var missingColumns = (missingPixels + 511) / 512;

					instanceData.Reinitialize(instanceData.width, instanceData.height + missingColumns + 500);
				}

				var pixelJob = new PixelJob();

				pixelJob.Chunks = curChunks;
				pixelJob.Pixels = instanceData.GetPixelData<float4>(0);

				pixelJob.Schedule().Complete();

				if (search == true && searchRadius > 0 && searchCapacity > 0 && searchSpeed > 0)
				{
					if (searchResults.Capacity < searchCapacity)
					{
						searchResults.Capacity = searchCapacity;
					}

					var searchJob = new SearchJob();

					searchJob.Data           = jobData;
					searchJob.SearchPos      = (float3)localPos;
					searchJob.SearchRadius   = searchRadius;
					searchJob.SearchSpeed    = searchSpeed;
					searchJob.SearchResults  = searchResults;
					searchJob.SearchCapacity = searchCapacity;
					searchJob.Chunks         = curChunks;
					searchJob.DriftDistance  = driftDistance;
					searchJob.DriftOffset    = driftOffset;
					searchJob.Pixels         = instanceData.GetPixelData<float4>(0);

					searchJob.Schedule().Complete();

					if (OnSearchResults != null)
					{
						OnSearchResults.Invoke(searchResults);
					}

					if (searchDebug == true)
					{
						foreach (var searchResult in searchResults)
						{
							var wpos = cachedRingSystem.transform.TransformPoint((float3)searchResult.LocalPosition);

							Debug.DrawLine(wpos, wpos + Vector3.right   * radius, Color.red);
							Debug.DrawLine(wpos, wpos + Vector3.up      * radius, Color.green);
							Debug.DrawLine(wpos, wpos + Vector3.forward * radius, Color.blue);
						}
					}
				}
				else
				{
					searchResults.Clear();
				}

				if (particleCount > 0)
				{
					var chunkPivot = default(Vector4);

					foreach (var pair in curChunks)
					{
						var cameraC = octaveCoords[pair.Value.Coord.o];

						chunkPivot.x = pair.Key.x - cameraC.x;
						chunkPivot.y = pair.Key.y - cameraC.y;
						chunkPivot.z = pair.Key.z - cameraC.z;
						chunkPivot.w = pair.Key.o;

						chunkDeltas[pair.Value.Index] = chunkPivot;
					}

					instanceData.Apply();

					var cameraData   = CameraData.Update(camera);
					properties.SetFloat(_SGT_Roll, cameraData.TotalRoll * Mathf.Deg2Rad);
					properties.SetFloat(_SGT_ParticleCount, particleCount);
					properties.SetVectorArray(_SGT_OctavePivots, octavePivots);
					properties.SetVectorArray(_SGT_OctaveRanges, octaveRanges);
					properties.SetVectorArray(_SGT_Deltas, chunkDeltas);
					properties.SetTexture(_SGT_InstanceData, instanceData);
					properties.SetVector(_SGT_InstanceSize, new Vector4(instanceData.width, instanceData.height, 0.0f, 0.0f));

					var rparams = new RenderParams(material);

					rparams.camera               = camera;
					rparams.layer                = gameObject.layer;
					rparams.matProps             = properties;
					rparams.reflectionProbeUsage = UnityEngine.Rendering.ReflectionProbeUsage.BlendProbes;
					rparams.receiveShadows       = true;
					rparams.shadowCastingMode    = UnityEngine.Rendering.ShadowCastingMode.On;
					rparams.worldBounds          = new Bounds(Vector3.zero, Vector3.one * 10000000);
					rparams.matProps             = properties;

					Graphics.RenderMeshPrimitives(rparams, generatedMesh, 0, (particleCount + 23) / 24);
				}
			}
		}

		private void TryGenerateMesh()
		{
			if (generatedMesh == null)
			{
				var count     = 24;
				var vertices  = new Vector3[count * 4];
				var uv        = new Vector4[count * 4];
				var triangles = new int[count * 6];

				for (int i = 0; i < count; i++)
				{
					var position = new Vector3(i, 0, 0);

					vertices[i * 4 + 0] = position;
					vertices[i * 4 + 1] = position;
					vertices[i * 4 + 2] = position;
					vertices[i * 4 + 3] = position;

					uv[i * 4 + 0] = new Vector4(-1.0f,  1.0f,  0.5f, 0.0f);
					uv[i * 4 + 1] = new Vector4( 1.0f,  1.0f, -0.5f, 0.0f);
					uv[i * 4 + 2] = new Vector4(-1.0f, -1.0f,  0.5f, 0.0f);
					uv[i * 4 + 3] = new Vector4( 1.0f, -1.0f, -0.5f, 0.0f);

					triangles[i * 6 + 0] = i * 4 + 0;
					triangles[i * 6 + 1] = i * 4 + 1;
					triangles[i * 6 + 2] = i * 4 + 2;
					triangles[i * 6 + 3] = i * 4 + 3;
					triangles[i * 6 + 4] = i * 4 + 2;
					triangles[i * 6 + 5] = i * 4 + 1;
				}

				generatedMesh = new Mesh();

				generatedMesh.hideFlags   = HideFlags.HideAndDontSave;
				generatedMesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
				generatedMesh.bounds      = new Bounds(Vector3.zero, Vector3.one);

				generatedMesh.SetVertices(vertices);
				generatedMesh.SetUVs(0, uv);
				generatedMesh.SetTriangles(triangles, 0);
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.RingSystem
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtRingParticles))]
	public class SgtRingParticles_Editor : CwEditor
	{
		protected override void OnInspector()
		{
			base.OnInspector();

			Separator();

			SgtRingParticles tgt; SgtRingParticles[] tgts; GetTargets(out tgt, out tgts);

			Draw("material", "The material used to render the debris.\n\nNOTE: This must use the <b>SGT / RingParticles</b> shader.");
			Draw("brightness", "The particle brightness will be multiplied by this.");
			BeginError(Any(tgts, t => t.MainTex == null));
				Draw("mainTex", "The texture applied to the particles.");
			EndError();

			if (Any(tgts, t => t.IsAdditive))
			{
				BeginError(Any(tgts, t => t.IsAdditive == true && (t.Cells.x <= 0 || t.Cells.y <= 0)));
					Draw("cells", "The amount of columns and rows in the <b>MainTex</b>.");
				EndError();
			}

			if (Any(tgts, t => t.IsMarch))
			{
				if (Any(tgts, t => t.IsMarch == true && t.MainTex != null && t.MainTex.dimension != UnityEngine.Rendering.TextureDimension.Tex3D))
				{
					Error("The MainTex must be a 3D Texture SDF");
				}
			}

			Separator();

			Draw("range", "The maximum camera distance debris particles can appear in world space.");
			Draw("density", "The amount of particles that will be spawned.");
			Draw("radius", "The radius of debris particles in world space.");
			Draw("octaves", "Each octave will render the particles again, but at double the range and size of the previous octave.");
			Draw("spawnRate", "The maximum amount of particles that can spawn per frame.");
			Draw("seed", "The particles will spawn using this seed.");

			Separator();

			Draw("driftDistance", "The maximum distance particles can drift in world space.");
			Draw("driftSpeed", "The speed the particles can drift.");
			Draw("driftOffset", "The current time used by the particle drift.");
			Draw("spinSpeed", "The speed the particles spin at.");
			Draw("spinOffset", "The current time used by the particle spin.");

			Separator();

			Draw("search", "Should this component keep track of particles that are near the camera?");
			if (Any(tgts, t => t.Search == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.SearchRadius <= 0.0f));
						Draw("searchRadius", "Particles within this local space radius will be found.", "Radius");
					EndError();
					BeginError(Any(tgts, t => t.SearchSpeed <= 0));
						Draw("searchSpeed", "How many particles should be scanned for each loop?", "Speed");
					EndError();
					Draw("searchCapacity", "The maximum amount of particles within the <b>SearchRadius</b> that will be stored.", "Capacity");
					Draw("searchDebug", "Debug the particle search results to the <b>Scene</b> view.");
				EndIndent();
			}
		}
	}
}
#endif