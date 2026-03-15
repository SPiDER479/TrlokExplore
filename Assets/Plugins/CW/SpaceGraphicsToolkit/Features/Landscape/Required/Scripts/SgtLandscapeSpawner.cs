using UnityEngine;
using Unity.Jobs;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Burst;
using System.Collections.Generic;
using RNG = Unity.Mathematics.Random;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>Base component for procedural landscape spawning using Burst Jobs.</summary>
	public abstract class SgtLandscapeSpawner : MonoBehaviour
	{
		public enum RotateType { Randomly, ToLandscapeCenter, ToSurfaceNormal }
		public enum DistributionType { Random, Grid }

		/// <summary>This allows you to define the spawn area. NOTE: Texture must be R8/Alpha8 and Read/Write enabled.</summary>
		public Texture2D MaskTex { set { if (maskTex != value) { maskTex = value; UpdateMaskData(); } } get { return maskTex; } } [SerializeField] private Texture2D maskTex;

		/// <summary>Invert the mask, so 0 values become 255 values, and 255 values become 0 values?</summary>
		public bool InvertMask { set { invertMask = value; } get { return invertMask; } } [SerializeField] private bool invertMask;

		/// <summary>Objects are spawned on square tiles that are placed on the planet surface. This allows you to control the size of each tile across each edge in meters. Smaller tiles give better resolution spawning patterns, but may run slower and consume more memory.</summary>
		public float TileSize { set { tileSize = value; } get { return tileSize; } } [SerializeField] private float tileSize = 10.0f;

		/// <summary>The world space distance the camera must be within for a tile to spawn.</summary>
		public float Range { set { range = value; } get { return range; } } [SerializeField] private float range = 20.0f;

		/// <summary>The local space distance between the 3 samples used to calculate terrain slope.</summary>
		public float SampleStride { set { sampleStride = value; } get { return sampleStride; } } [SerializeField] private float sampleStride = 0.01f;

		/// <summary>Should the spawn point be positioned at the center of the 3 samples, rather than the position of the first?</summary>
		public bool SampleCenter { set { sampleCenter = value; } get { return sampleCenter; } } [SerializeField] private bool sampleCenter;

		/// <summary>The density of spawned objects per square unit.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 0.1f;

		/// <summary>How should the objects be distributed across the landscape?</summary>
		public DistributionType Distribution { set { distribution = value; } get { return distribution; } } [SerializeField] private DistributionType distribution = DistributionType.Random;

		/// <summary>When using the Grid distribution, should the objects be scaled to perfectly fit the grid spacing?</summary>
		public bool GridFit { set { gridFit = value; } get { return gridFit; } } [SerializeField] private bool gridFit;

		/// <summary>When using the Grid distribution, how much should the points be scattered on the XZ plane?</summary>
		public float GridScatter { set { gridScatter = value; } get { return gridScatter; } } [SerializeField] private float gridScatter;

		/// <summary>The random seed when procedurally spawning.</summary>
		public int Seed { set { seed = value; } get { return seed; } } [SerializeField] [CW.Common.CwSeed] private int seed;

		/// <summary>The spawned objects will have their localScale multiplied by at least this number.</summary>
		public float ScaleMin { set { scaleMin = value; } get { return scaleMin; } } [SerializeField] private float scaleMin = 0.75f;

		/// <summary>The spawned objects will have their localScale multiplied by at most this number.</summary>
		public float ScaleMax { set { scaleMax = value; } get { return scaleMax; } } [SerializeField] private float scaleMax = 1.25f;

		/// <summary>How should the spawned objects be rotated?</summary>
		public RotateType Rotate { set { rotate = value; } get { return rotate; } } [SerializeField] private RotateType rotate;

		/// <summary>The spawned objects will have their position offset by this local space distance.</summary>
		public float Offset { set { offset = value; } get { return offset; } } [SerializeField] private float offset;

		/// <summary>Adds an angle deviation up to this specified value in degrees when Rotate is set to ToLandscapeCenter or ToSurfaceNormal.</summary>
		public float AngleScatter { set { angleScatter = value; } get { return angleScatter; } } [SerializeField] private float angleScatter;

		/// <summary>Should the minimum height constraint be applied?</summary>
		public bool UseMinHeight { set { useMinHeight = value; } get { return useMinHeight; } } [SerializeField] private bool useMinHeight;

		/// <summary>The height at which objects start spawning (0% probability).</summary>
		public float MinHeight { set { minHeight = value; } get { return minHeight; } } [SerializeField] private float minHeight;

		/// <summary>The distance over which spawning probability fades in from 0 to 1.</summary>
		public float MinHeightFalloff { set { minHeightFalloff = value; } get { return minHeightFalloff; } } [SerializeField] private float minHeightFalloff;

		/// <summary>Should the maximum height constraint be applied?</summary>
		public bool UseMaxHeight { set { useMaxHeight = value; } get { return useMaxHeight; } } [SerializeField] private bool useMaxHeight;

		/// <summary>The height at which objects stop spawning (0% probability).</summary>
		public float MaxHeight { set { maxHeight = value; } get { return maxHeight; } } [SerializeField] private float maxHeight;

		/// <summary>The distance over which spawning probability fades out from 1 to 0.</summary>
		public float MaxHeightFalloff { set { maxHeightFalloff = value; } get { return maxHeightFalloff; } } [SerializeField] private float maxHeightFalloff;

		/// <summary>Should the minimum slope constraint be applied?</summary>
		public bool UseMinSlope { set { useMinSlope = value; } get { return useMinSlope; } } [SerializeField] private bool useMinSlope;

		/// <summary>The minimum slope angle (in degrees) required for spawning.</summary>
		public float MinSlope { set { minSlope = value; } get { return minSlope; } } [Range(0, 90)] [SerializeField] private float minSlope = 0.0f;

		/// <summary>The angular distance over which spawning probability fades in from 0 to 1.</summary>
		public float MinSlopeFalloff { set { minSlopeFalloff = value; } get { return minSlopeFalloff; } } [SerializeField] private float minSlopeFalloff = 5.0f;

		/// <summary>Should the maximum slope constraint be applied?</summary>
		public bool UseMaxSlope { set { useMaxSlope = value; } get { return useMaxSlope; } } [SerializeField] private bool useMaxSlope;

		/// <summary>The maximum slope angle (in degrees) allowed for spawning.</summary>
		public float MaxSlope { set { maxSlope = value; } get { return maxSlope; } } [Range(0, 90)] [SerializeField] private float maxSlope = 90.0f;

		/// <summary>The angular distance over which spawning probability fades out from 1 to 0.</summary>
		public float MaxSlopeFalloff { set { maxSlopeFalloff = value; } get { return maxSlopeFalloff; } } [SerializeField] private float maxSlopeFalloff = 5.0f;

		[System.NonSerialized] protected SgtSphereLandscape parent;

		[System.NonSerialized] private double surfaceHeight;

		[System.NonSerialized] private Vector3 currentObserverWorldPosition;

		public struct Tile : System.IEquatable<Tile>
		{
			public long    u, v;
			public int     faceIndex, id;
			public double3 corner, tangent, bitangent, center;
			public int     tripletIndex, tripletCount;
			public int     spawnIndex, spawnCount;
			public double3 localMin, localMax;
			public float   scaleMultiplier;

			public bool Equals(Tile other)
			{
				return u == other.u && v == other.v && faceIndex == other.faceIndex;
			}

			public override int GetHashCode()
			{
				return unchecked((int)((17 * 23 + u) * 23 + v) * 23 + faceIndex);
			}
		}

		[BurstCompile]
		struct GridJob : IJob
		{
			public NativeList<Tile>    current, added, removed;
			public NativeList<double3> spawnPoints;
			public NativeQueue<int>    unusedIDs;
			public double3   camWorld;
			public double    surfaceHeight;
			public double4x4 localToWorld, worldToLocal;
			public double    radius, maxDistSq, spawnOffset;
			public int       count;
			public uint      Seed;
			public float     spawnDensity;
			public float     sampleStride;
			public DistributionType distribution;
			public float     gridScatter;

			static void GetFace(int f, double h, out double3 o, out double3 u, out double3 v, out int dominantAxis)
			{
				o = u = v = 0;
				dominantAxis = 0;
				switch (f)
				{
					case 0: o = new(-h,-h, h); u = new( 1,0,0); v = new(0, 1,0); dominantAxis = 2; break;
					case 1: o = new( h,-h,-h); u = new(-1,0,0); v = new(0, 1,0); dominantAxis = 2; break;
					case 2: o = new( h,-h, h); u = new(0,0,-1); v = new(0, 1,0); dominantAxis = 0; break;
					case 3: o = new(-h,-h,-h); u = new(0,0, 1); v = new(0, 1,0); dominantAxis = 0; break;
					case 4: o = new(-h, h,-h); u = new( 1,0,0); v = new(0,0, 1); dominantAxis = 1; break;
					case 5: o = new(-h,-h, h); u = new( 1,0,0); v = new(0,0,-1); dominantAxis = 1; break;
				}
			}

			public void Execute()
			{
				var prev      = new NativeArray<Tile>(current.AsArray(), Allocator.Temp);
				var prevMap   = new NativeParallelHashMap<Tile, Tile>(prev.Length, Allocator.Temp);
				var currSet   = new NativeParallelHashSet<Tile>(prev.Length, Allocator.Temp);
				var size      = radius * 2.0;
				var cs        = size / count;
				var searchRad = (int)math.ceil(math.sqrt(maxDistSq) / cs * 2.0);

				current.Clear(); added.Clear(); removed.Clear(); spawnPoints.Clear();

				for (var i = 0; i < prev.Length; i++) 
					prevMap.TryAdd(prev[i], prev[i]);

				var camLocal  = math.transform(worldToLocal, camWorld);
				var camNormal = math.normalize(camLocal);

				// Create a version of the camera clamped perfectly to the base sphere
				var camBaseLocal = camNormal * radius;
				var camBaseWorld = math.transform(localToWorld, camBaseLocal);

				for (var f = 0; f < 6; f++)
				{
					GetFace(f, radius, out var fO, out var fU, out var fV, out var dominantAxis);

					var dominantValue = camLocal[dominantAxis];
					if (math.abs(dominantValue) < 0.0001) continue;

					var faceSign = (fO[dominantAxis] > 0) ? 1.0 : -1.0;
					if (math.sign(dominantValue) != faceSign) continue;

					var camCube = camLocal * (radius / math.abs(dominantValue));

					var d    = camCube - fO;
					var uVal = math.clamp(math.dot(d, fU), 0, size);
					var vVal = math.clamp(math.dot(d, fV), 0, size);

					var cU   = math.clamp((int)math.floor(uVal / cs), 0, count - 1);
					var cV   = math.clamp((int)math.floor(vVal / cs), 0, count - 1);
					var uMin = math.max(0, cU - searchRad);
					var uMax = math.min(count - 1, cU + searchRad);
					var vMin = math.max(0, cV - searchRad);
					var vMax = math.min(count - 1, cV + searchRad);

					for (var tu = uMin; tu <= uMax; tu++)
					for (var tv = vMin; tv <= vMax; tv++)
					{
						var center = fO + fU * (tu * cs + cs * 0.5) + fV * (tv * cs + cs * 0.5);
						var sc     = math.normalize(center) * radius;

						// Check distance against the projected camera, NOT the floating camera
						if (math.distancesq(camBaseWorld, math.transform(localToWorld, sc)) > maxDistSq)
							continue;

						var tileLookup   = new Tile { u = tu, v = tv, faceIndex = f };
						var existingTile = default(Tile);

						if (!currSet.Add(tileLookup)) continue;

						if (prevMap.TryGetValue(tileLookup, out existingTile) == true)
						{
							current.Add(existingTile);
						}
						else // New tile
						{
							var newTile          = new Tile { u = tu, v = tv, faceIndex = f, tangent = fU, bitangent = fV, corner = fO + fU * (tu * cs) + fV * (tv * cs), center = center };
							var distSq           = math.lengthsq(center);
							var areaRatio        = (radius * radius * radius) / (distSq * math.sqrt(distSq));
							var rng              = new RNG(math.hash(center) + Seed);
							var theoreticalCount = cs * cs * areaRatio * spawnDensity;

							if (distribution == DistributionType.Grid)
							{
								var gridRes = (int)math.round(math.sqrt(theoreticalCount));
								if (gridRes < 1) gridRes = 1;

								newTile.tripletIndex    = spawnPoints.Length;
								newTile.tripletCount    = gridRes * gridRes;
								newTile.scaleMultiplier = (float)(math.sqrt(theoreticalCount) / gridRes);

								var step  = cs / gridRes;
								var start = step * 0.5;

								for (var x = 0; x < gridRes; x++)
								for (var y = 0; y < gridRes; y++)
								{
									var pU = tu * cs + start + x * step;
									var pV = tv * cs + start + y * step;

									if (gridScatter > 0.0f)
									{
										var cellHash = math.hash(center) + (uint)(x + y * gridRes);
										var cellRng  = new RNG(cellHash + Seed);
										pU += (cellRng.NextDouble() - 0.5) * step * gridScatter;
										pV += (cellRng.NextDouble() - 0.5) * step * gridScatter;
									}

									spawnPoints.Add(math.normalize(fO + fU * pU + fV * pV) * radius);
									spawnPoints.Add(math.normalize(fO + fU * (pU + sampleStride) + fV * pV) * radius);
									spawnPoints.Add(math.normalize(fO + fU * pU + fV * (pV + sampleStride)) * radius);
								}
							}
							else
							{
								var baseCount        = (int)math.floor(theoreticalCount);
								var fractionalChance = theoreticalCount - baseCount;

								if (rng.NextDouble() < fractionalChance)
								{
									baseCount += 1;
								}

								newTile.tripletIndex    = spawnPoints.Length;
								newTile.tripletCount    = baseCount;
								newTile.scaleMultiplier = 1.0f;

								for (var p = 0; p < newTile.tripletCount; p++)
								{
									var pU = tu * cs + rng.NextDouble() * cs;
									var pV = tv * cs + rng.NextDouble() * cs;
									spawnPoints.Add(math.normalize(fO + fU * pU + fV * pV) * radius);
									spawnPoints.Add(math.normalize(fO + fU * (pU + sampleStride) + fV * pV) * radius);
									spawnPoints.Add(math.normalize(fO + fU * pU + fV * (pV + sampleStride)) * radius);
								}
							}

							added.Add(newTile);
						}
					}
				}

				for (var i = 0; i < prev.Length; i++)
				{
					if (currSet.Contains(prev[i]) == false)
					{
						unusedIDs.Enqueue(prev[i].id);

						removed.Add(prev[i]);
					}
				}

				for (var i = 0; i < added.Length; i++)
				{
					if (unusedIDs.Count == 0) break; // Too many tiles!

					var tile = added[i];
					
					tile.id = unusedIDs.Dequeue();

					added[i] = tile;

					current.Add(tile);
				}

				prev.Dispose();
				prevMap.Dispose();
				currSet.Dispose();

				// Keep the camera request for surface height evaluation
				spawnPoints.Add(camBaseLocal);
			}
		}

		[BurstCompile]
		struct SpawnJob : IJob
		{
			public NativeList<Tile> Tiles; 
			[ReadOnly] public NativeArray<double3> InputPoints, InputDirections;
			[ReadOnly] public NativeArray<double>  InputHeights;
			[ReadOnly] public NativeArray<double4> InputDataA;
			[ReadOnly] public NativeArray<byte>    MaskPixels;
			
			[ReadOnly] public int                    HoleCount;
			[ReadOnly] public NativeArray<float4>    HoleDatas;
			[ReadOnly] public NativeArray<double4x4> HoleMatrices;

			public uint Seed;
			public int2 MaskSize;
			public bool InvertMask;
			public float Offset;
			public float ScaleMin, ScaleMax;
			public bool GridFit;
			public RotateType RotateMode;
			public bool SampleCenter;
			public float AngleScatter;

			public float UseMinHeight, MinHeight, MinHeightFalloff;
			public float UseMaxHeight, MaxHeight, MaxHeightFalloff;
			public float UseMinSlope, MinSlope, MinSlopeFalloff;
			public float UseMaxSlope, MaxSlope, MaxSlopeFalloff;

			public NativeList<double3>    OutPositions;
			public NativeList<quaternion> OutRotations;
			public NativeList<float>      OutScales;
			public NativeList<float>      OutSeeds;
			public NativeList<int>        OutIDs;

			private bool PointInHole(double3 point)
			{
				for (var h = 0; h < HoleCount; h++)
				{
					var entrancePoint = math.transform(HoleMatrices[h], point);
					var circleDist    = math.dot(entrancePoint.xz, entrancePoint.xz);
					var boxDist       = math.max(math.abs(entrancePoint.x), math.abs(entrancePoint.z));
					var finalDist     = math.lerp(circleDist, boxDist, HoleDatas[h].x);

					if (finalDist < 1.0 && math.abs(entrancePoint).y < 1.0)
					{
						return true;
					}
				}

				return false;
			}

			public void Execute()
			{
				OutPositions.Clear();
				OutRotations.Clear();
				OutScales.Clear();
				OutSeeds.Clear();
				OutIDs.Clear();

				for (var i = 0; i < Tiles.Length; i++)
				{
					var tile = Tiles[i];
					tile.spawnIndex = OutPositions.Length;
					tile.spawnCount = 0;

					for (var s = 0; s < tile.tripletCount; s++)
					{
						var globalIdx   = tile.tripletIndex + s * 3;
						var p0          = GetPosition(globalIdx + 0);
						var p1          = GetPosition(globalIdx + 1);
						var p2          = GetPosition(globalIdx + 2);
						var height      = (float)InputHeights[globalIdx];
						var uv          = InputDataA[globalIdx].xy;
						var rng         = new RNG(math.hash(p0) + Seed);
						var upDir       = (float3)InputDirections[globalIdx];
						var norm        = math.normalize(math.cross(p1 - p0, p2 - p0)); if (math.dot(norm, upDir) < 0f) norm = -norm;
						var slope       = math.degrees(math.acos(math.saturate(math.abs(math.dot(norm, upDir)))));
						var probability = (float)SampleMask(uv);

						var hMinP  = math.saturate((height - MinHeight) / math.max(MinHeightFalloff, 0.0001f));
						var hMaxP  = math.saturate((MaxHeight - height) / math.max(MaxHeightFalloff, 0.0001f));
				
						probability *= math.lerp(1.0f, hMinP, UseMinHeight);
						probability *= math.lerp(1.0f, hMaxP, UseMaxHeight);

						var sMinP = math.saturate((slope - MinSlope) / math.max(MinSlopeFalloff, 0.0001f));
						var sMaxP = math.saturate((MaxSlope - slope) / math.max(MaxSlopeFalloff, 0.0001f));

						probability *= math.lerp(1.0f, (float)sMinP, UseMinSlope);
						probability *= math.lerp(1.0f, (float)sMaxP, UseMaxSlope);

						if (probability < rng.NextFloat()) continue;

						var rot   = quaternion.identity;
						var spin  = quaternion.RotateY(rng.NextFloat(0, math.PI * 2.0f));
						var seed  = rng.NextFloat();
						var scale = math.lerp(ScaleMin, ScaleMax, seed);

						if (GridFit) scale *= tile.scaleMultiplier;

						switch (RotateMode)
						{
							case RotateType.Randomly: rot = rng.NextQuaternionRotation(); break;
							case RotateType.ToLandscapeCenter: rot = math.mul(FromToRotation(new float3(0,1,0), upDir), spin); break;
							case RotateType.ToSurfaceNormal:   rot = math.mul(FromToRotation(new float3(0,1,0), (float3)norm), spin); break;
						}

						if (RotateMode != RotateType.Randomly && AngleScatter > 0.0f)
						{
							var scatterAxis = rng.NextFloat3Direction();
							var scatterRot  = quaternion.AxisAngle(scatterAxis, rng.NextFloat(0, math.radians(AngleScatter)));
							rot = math.mul(rot, scatterRot);
						}

						var finalPos = (SampleCenter ? (p0 + p1 + p2) / 3.0 : p0) + math.rotate(rot, new float3(0, Offset, 0));

						if (PointInHole(finalPos) == true)
						{
							continue;
						}

						OutPositions.Add(finalPos);
						OutRotations.Add(rot);
						OutScales.Add(scale);
						OutSeeds.Add(seed);
						OutIDs.Add(tile.id);

						if (tile.spawnCount == 0)
						{
							tile.localMin = tile.localMax = finalPos;
						}
						else
						{
							tile.localMin = math.min(tile.localMin, finalPos);
							tile.localMax = math.max(tile.localMax, finalPos);
						}
		
						tile.spawnCount += 1;
					}
					Tiles[i] = tile;
				}
			}

			private double3 GetPosition(int i) 
			{
				return InputPoints[i] + InputDirections[i] * InputHeights[i];
			}

			private quaternion FromToRotation(float3 from, float3 to)
			{
				var dot = math.dot(from, to);
				if (dot > 0.999999f) return quaternion.identity;
				if (dot < -0.999999f)
				{
					var axis = math.abs(from.z) < 0.9f ? new float3(-from.y, from.x, 0) : new float3(0, -from.z, from.y);
					return quaternion.AxisAngle(math.normalize(axis), math.PI);
				}
				return math.normalize(new quaternion(new float4(math.cross(from, to), 1.0f + dot)));
			}

			private double SampleMask(double2 uv)
			{
				if (!MaskPixels.IsCreated) return 1.0;
				var m = SgtLandscape.Sample_Linear_WrapX(MaskPixels, MaskSize, uv);
				return InvertMask ? 1.0 - m : m;
			}
		}

		[System.NonSerialized] private NativeList<Tile>    currentTiles;
		[System.NonSerialized] private NativeList<Tile>    addedTiles;
		[System.NonSerialized] private NativeList<Tile>    removedTiles;
		[System.NonSerialized] private NativeList<double3> spawnPoints;
		[System.NonSerialized] private NativeQueue<int>    availableTileIds;

		[System.NonSerialized] private NativeArray<byte> maskPixels;
		[System.NonSerialized] private int               maskWidth;
		[System.NonSerialized] private int               maskHeight;

		private JobHandle gridHandle;
		private JobHandle spawnHandle;
		private bool gridRunning;
		private bool spawnRunning;

		private SgtSphereLandscape.PendingPoints pendingData;

		private NativeList<double3>    spawnPositions;
		private NativeList<quaternion> spawnRotations;
		private NativeList<float>      spawnScales;
		private NativeList<float>      spawnSeeds;
		private NativeList<int>        spawnTileIDs;
		private NativeList<float4>     spawnHoleDatas;
		private NativeList<double4x4>  spawnHoleMatrices;

		public int GetSlices()
		{
			if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
			if (parent == null || tileSize <= 0.001f) return 1;
			return math.max(1, (int)math.round((parent.Radius * 2.0) / tileSize));
		}

		public float GetApproxSpawnSpacing()
		{
			if (density > 0.0f)
			{
				return math.sqrt(1.0f / density);
			}

			return 0.0f;
		}

		public int GetApproximateMaximumTileCount()
		{
			if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
			if (parent == null) return -1;

			int slices = GetSlices();
			var planetArea = 4.0 * math.PI * parent.Radius * parent.Radius;
			var tileArea   = planetArea / (6.0 * slices * slices);
			var searchArea = math.PI * range * range;
			
			return (int)math.ceil(searchArea / tileArea);
		}

		public int GetApproximateMaximumSpawnCount()
		{
			if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
			if (parent == null) return -1;

			int slices = GetSlices();
			var planetArea = 4.0 * math.PI * parent.Radius * parent.Radius;
			var tileArea   = planetArea / (6.0 * slices * slices);
			var tileCount  = GetApproximateMaximumTileCount();

			return (int)math.ceil(tileCount * (tileArea * density));
		}

		public int GetApproximateMaximumSpawnCountPerTile()
		{
			if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
			if (parent == null) return -1;

			int slices = GetSlices();
			var planetArea = 4.0 * math.PI * parent.Radius * parent.Radius;
			var tileArea   = planetArea / (6.0 * slices * slices);
			var tileCount  = GetApproximateMaximumTileCount();

			return (int)math.ceil(tileArea * density);
		}

		protected virtual void OnEnable()
		{
			parent = GetComponentInParent<SgtSphereLandscape>();
			UpdateMaskData();
			currentTiles = new NativeList<Tile>(128, Allocator.Persistent);
			addedTiles   = new NativeList<Tile>(128, Allocator.Persistent);
			removedTiles = new NativeList<Tile>(128, Allocator.Persistent);
			spawnPoints  = new NativeList<double3>(512, Allocator.Persistent);
			availableTileIds = new NativeQueue<int>(Allocator.Persistent);
			spawnPositions = new NativeList<double3>(1024, Allocator.Persistent);
			spawnRotations = new NativeList<quaternion>(1024, Allocator.Persistent);
			spawnScales = new NativeList<float>(1024, Allocator.Persistent);
			spawnSeeds = new NativeList<float>(1024, Allocator.Persistent);
			spawnTileIDs = new NativeList<int>(1024, Allocator.Persistent);
			spawnHoleDatas = new NativeList<float4>(64, Allocator.Persistent);
			spawnHoleMatrices = new NativeList<double4x4>(64, Allocator.Persistent);

			for (int i = 999; i >= 0; i--) availableTileIds.Enqueue(i);
		}

		protected virtual void OnDisable()
		{
			ForceComplete();
			foreach (var tile in currentTiles)
				HandleDespawn(tile);
			maskPixels.Dispose();
			currentTiles.Dispose();
			addedTiles.Dispose();
			removedTiles.Dispose();
			spawnPoints.Dispose();
			availableTileIds.Dispose();
			spawnPositions.Dispose();
			spawnRotations.Dispose();
			spawnScales.Dispose();
			spawnSeeds.Dispose();
			spawnTileIDs.Dispose();
			spawnHoleDatas.Dispose();
			spawnHoleMatrices.Dispose();
		}

		public void MarkAsDirty()
		{
			if (currentTiles.IsCreated == true)
			{
				OnDisable();
				OnEnable();
			}
		}

		private void ForceComplete()
		{
			if (gridRunning)
			{
				gridHandle.Complete();
				gridRunning = false;
			}
			if (spawnRunning)
			{
				spawnHandle.Complete();
				pendingData.Dispose();
				spawnRunning = false;
			}
		}

		protected virtual void Update()
		{
			var observerExists = parent != null && parent.TryGetFirstObserverWorldPosition(ref currentObserverWorldPosition);
			if (gridRunning)
			{
				if (!gridHandle.IsCompleted) return;
				gridHandle.Complete();
				gridRunning = false;
				StartSpawnPipeline();
				foreach (var tile in removedTiles)
					HandleDespawn(tile);
				return;
			}
			if (spawnRunning)
			{
				if (!spawnHandle.IsCompleted) return;
				spawnHandle.Complete();
				spawnRunning = false;
				int camIdx = pendingData.Points.Length - 1;
				if (camIdx >= 0) surfaceHeight = pendingData.Heights[camIdx];
				foreach (var tile in addedTiles)
				{
					HandleSpawn(tile, spawnPositions, spawnRotations, spawnScales, spawnSeeds, spawnTileIDs);
				}
				pendingData.Dispose();
				return;
			}
			if (observerExists == true) StartGridPipeline(currentObserverWorldPosition);
		}

		private void StartGridPipeline(Vector3 observerWorldPosition)
		{
			var job = new GridJob
			{
				current       = currentTiles,
				added         = addedTiles,
				removed       = removedTiles,
				spawnPoints   = spawnPoints,
				unusedIDs     = availableTileIds,
				camWorld      = new double3(observerWorldPosition),
				surfaceHeight = surfaceHeight,
				worldToLocal  = new double4x4(transform.worldToLocalMatrix),
				localToWorld  = new double4x4(transform.localToWorldMatrix),
				radius        = parent.Radius,
				maxDistSq     = range * range,
				Seed          = (uint)seed,
				count         = GetSlices(),
				spawnDensity  = density,
				spawnOffset   = offset,
				sampleStride  = sampleStride,
				distribution  = distribution,
				gridScatter   = gridScatter
			};
			gridHandle = job.Schedule();
			gridRunning = true;
		}

		private void StartSpawnPipeline()
		{
			pendingData = parent.SchedulePoints(spawnPoints);
			spawnPositions.Clear();
			spawnRotations.Clear();
			spawnScales.Clear();
			spawnSeeds.Clear();
			spawnTileIDs.Clear();
			spawnHoleDatas.Clear();
			spawnHoleMatrices.Clear();

			spawnHoleDatas.AddRange(parent.ActiveHoleDatasNA);
			spawnHoleMatrices.AddRange(parent.ActiveHoleMatricesNA);

			var job = new SpawnJob()
			{
				Tiles            = addedTiles,
				InputPoints      = pendingData.Points,
				InputDirections  = pendingData.Directions,
				InputHeights     = pendingData.Heights,
				InputDataA       = pendingData.DataA,
				MaskPixels       = maskPixels,
				MaskSize         = new int2(maskWidth, maskHeight),
				HoleCount        = parent.ActiveHoleCount,
				HoleDatas        = spawnHoleDatas.AsArray(),
				HoleMatrices     = spawnHoleMatrices.AsArray(),
				InvertMask       = invertMask,
				Seed             = (uint)seed,
				Offset           = offset,
				ScaleMin         = scaleMin,
				ScaleMax         = scaleMax,
				GridFit          = gridFit,
				RotateMode       = rotate,
				SampleCenter     = sampleCenter,
				AngleScatter     = angleScatter,
				OutPositions     = spawnPositions,
				OutRotations     = spawnRotations,
				OutScales        = spawnScales,
				OutSeeds         = spawnSeeds,
				OutIDs           = spawnTileIDs,
				UseMinHeight     = useMinHeight ? 1 : 0,
				MinHeight        = minHeight,
				MinHeightFalloff = minHeightFalloff,
				UseMaxHeight     = useMaxHeight ? 1 : 0,
				MaxHeight        = maxHeight,
				MaxHeightFalloff = maxHeightFalloff,
				UseMinSlope      = useMinSlope ? 1 : 0,
				MinSlope         = minSlope,
				MinSlopeFalloff  = minSlopeFalloff,
				UseMaxSlope      = useMaxSlope ? 1 : 0,
				MaxSlope         = maxSlope,
				MaxSlopeFalloff  = maxSlopeFalloff,
			};
			spawnHandle = job.Schedule(pendingData.Handle);
			spawnRunning = true;
		}

		private void UpdateMaskData()
		{
			if (maskTex != null)
			{
				maskWidth  = maskTex.width;
				maskHeight = maskTex.height;
				maskPixels = new NativeArray<byte>(maskTex.GetPixelData<byte>(0), Allocator.Persistent);
			}
			else
			{
				maskWidth  = 1;
				maskHeight = 1;
				maskPixels = new NativeArray<byte>(1, Allocator.Persistent);
				maskPixels[0] = 255;
			}
		}

		protected abstract void HandleSpawn(Tile tile, NativeList<double3> pos, NativeList<quaternion> rot, NativeList<float> scale, NativeList<float> seed, NativeList<int> id);
		protected abstract void HandleDespawn(Tile tile);
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Landscape
{
	public abstract class SgtLandscapeSpawner_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtLandscapeSpawner tgt; SgtLandscapeSpawner[] tgts; GetTargets(out tgt, out tgts);
			var markAsDirty = false;

			Draw("maskTex", ref markAsDirty, "This allows you to define the spawn area. NOTE: Texture must be R8/Alpha8 and Read/Write enabled.");
			Draw("invertMask", ref markAsDirty, "Invert the mask, so 0 values become 255 values, and 255 values become 0 values?");

			BeginError(Any(tgts, t => t.TileSize <= 0.0f));
				Draw("tileSize", ref markAsDirty, "Objects are spawned on square tiles that are placed on the planet surface. This allows you to control the size of each tile across each edge in meters. Smaller tiles give better resolution spawning patterns, but may run slower and consume more memory.");
			EndError();

			BeginError(Any(tgts, t => t.Range <= 0.0f));
				Draw("range", "The world space distance the camera must be within for a tile to spawn.");
			EndError();

			Draw("sampleStride", ref markAsDirty, "The local space distance between the 3 samples used to calculate terrain slope.");
			Draw("sampleCenter", ref markAsDirty, "Should the spawn point be positioned at the center of the 3 samples, rather than the position of the first?");

			BeginError(Any(tgts, t => t.Density <= 0.0f));
				Draw("density", ref markAsDirty, "The density of spawned objects per square unit.");
			EndError();

			Draw("distribution", ref markAsDirty, "How should the objects be distributed across the landscape?");
			if (Any(tgts, t => t.Distribution == SgtLandscapeSpawner.DistributionType.Grid))
			{
				BeginIndent();
					Draw("gridFit", ref markAsDirty, "When using the Grid distribution, should the objects be scaled to perfectly fit the grid spacing?");
					Draw("gridScatter", ref markAsDirty, "When using the Grid distribution, how much should the points be scattered on the XZ plane?");
				EndIndent();
			}

			BeginDisabled();
				var maxTileCount = tgt.GetApproximateMaximumTileCount();
				BeginError(Any(tgts, t => t.GetApproximateMaximumTileCount() > 900));
					UnityEditor.EditorGUILayout.IntField("Approx Max Tile Count", maxTileCount);
				EndError();
				UnityEditor.EditorGUILayout.IntField("Approx Max Spawn Count", tgt.GetApproximateMaximumSpawnCount());
				UnityEditor.EditorGUILayout.FloatField("Approx Spawn Spacing", tgt.GetApproxSpawnSpacing());
			EndDisabled();

			Draw("seed", ref markAsDirty, "The random seed when procedurally spawning.");

			Separator();

			Draw("scaleMin", ref markAsDirty, "The spawned objects will have their localScale multiplied by at least this number.");
			Draw("scaleMax", ref markAsDirty, "The spawned objects will have their localScale multiplied by at most this number.");
			Draw("rotate", ref markAsDirty, "How should the spawned objects be rotated?");
			Draw("offset", ref markAsDirty, "The spawned objects will have their position offset by this local space distance.");

			if (Any(tgts, t => t.Rotate == SgtLandscapeSpawner.RotateType.ToLandscapeCenter || t.Rotate == SgtLandscapeSpawner.RotateType.ToSurfaceNormal))
			{
				Draw("angleScatter", ref markAsDirty, "Adds an angle deviation up to this specified value in degrees when Rotate is set to ToLandscapeCenter or ToSurfaceNormal.");
			}

			Separator();

			Draw("useMinHeight", ref markAsDirty, "Should the minimum height constraint be applied?");
			if (Any(tgts, t => t.UseMinHeight))
			{
				BeginIndent();
					Draw("minHeight", ref markAsDirty, "The height at which objects start spawning (0% probability).");
					Draw("minHeightFalloff", ref markAsDirty, "The distance over which spawning probability fades in from 0 to 1.");
				EndIndent();
			}

			Draw("useMaxHeight", ref markAsDirty, "Should the maximum height constraint be applied?");
			if (Any(tgts, t => t.UseMaxHeight))
			{
				BeginIndent();
					Draw("maxHeight", ref markAsDirty, "The height at which objects stop spawning (0% probability).");
					Draw("maxHeightFalloff", ref markAsDirty, "The distance over which spawning probability fades out from 1 to 0.");
				EndIndent();
			}

			Separator();

			Draw("useMinSlope", ref markAsDirty, "Should the minimum slope constraint be applied?");
			if (Any(tgts, t => t.UseMinSlope))
			{
				BeginIndent();
					Draw("minSlope", ref markAsDirty, "The minimum slope angle (in degrees) required for spawning.");
					Draw("minSlopeFalloff", ref markAsDirty, "The angular distance over which spawning probability fades in from 0 to 1.");
				EndIndent();
			}

			Draw("useMaxSlope", ref markAsDirty, "Should the maximum slope constraint be applied?");
			if (Any(tgts, t => t.UseMaxSlope))
			{
				BeginIndent();
					Draw("maxSlope", ref markAsDirty, "The maximum slope angle (in degrees) allowed for spawning.");
					Draw("maxSlopeFalloff", ref markAsDirty, "The angular distance over which spawning probability fades out from 1 to 0.");
				EndIndent();
			}

			if (markAsDirty == true) Each(tgts, t => t.MarkAsDirty(), true);
		}
	}
}
#endif