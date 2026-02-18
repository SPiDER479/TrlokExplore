using UnityEngine;
using Unity.Jobs;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Burst;
using RNG = Unity.Mathematics.Random;

namespace SpaceGraphicsToolkit.Landscape
{
	/// <summary>Base component for procedural landscape spawning using Burst Jobs.</summary>
	public abstract class SgtLandscapeSpawner : MonoBehaviour
	{
		public enum RotateType { Randomly, ToLandscapeCenter, ToSurfaceNormal }

		/// <summary>This allows you to define the spawn area. NOTE: Texture must be R8/Alpha8 and Read/Write enabled.</summary>
		public Texture2D MaskTex { set { if (maskTex != value) { maskTex = value; UpdateMaskData(); } } get { return maskTex; } } [SerializeField] private Texture2D maskTex;

		/// <summary>Invert the mask, so 0 values become 255 values, and 255 values become 0 values?</summary>
		public bool InvertMask { set { invertMask = value; } get { return invertMask; } } [SerializeField] private bool invertMask;

		/// <summary>The target size of each grid tile in world units. This will determine the slice count.</summary>
		public float TileSize { set { tileSize = value; } get { return tileSize; } } [SerializeField] private float tileSize = 10.0f;

		/// <summary>The world space distance the camera must be within for a grid cell to spawn.</summary>
		public float Range { set { range = value; } get { return range; } } [SerializeField] private float range = 20.0f;

		/// <summary>The density of spawned objects per square unit.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 0.1f;

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

		public struct Tile : System.IEquatable<Tile>
		{
			public long    u, v;
			public int     faceIndex;
			public double3 corner, tangent, bitangent, center;
			public int     tripletIndex, tripletCount;
			public int     spawnIndex, spawnCount;

			public bool Equals(Tile other)    => u == other.u && v == other.v && faceIndex == other.faceIndex;
			public override int GetHashCode() => unchecked((int)((17 * 23 + u) * 23 + v) * 23 + faceIndex);
		}

		[BurstCompile]
		struct GridJob : IJob
		{
			public NativeList<Tile>    current, added, removed;
			public NativeList<double3> spawnPoints;
			public double3   camWorld;
			public double    surfaceHeight;
			public double4x4 localToWorld, worldToLocal;
			public double    radius, maxDistSq, spawnOffset;
			public int       count;
			public uint      Seed;
			public float     spawnDensity;

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
				var prevSet   = new NativeParallelHashSet<Tile>(prev.Length, Allocator.Temp);
				var currSet   = new NativeParallelHashSet<Tile>(prev.Length, Allocator.Temp);
				var size      = radius * 2.0;
				var cs        = size / count;
				var eps       = 0.01;
				var searchRad = (int)math.ceil(math.sqrt(maxDistSq) / cs * 2.0);

				current.Clear(); added.Clear(); removed.Clear(); spawnPoints.Clear();

				for (var i = 0; i < prev.Length; i++) prevSet.Add(prev[i]);

				var camLocal  = math.transform(worldToLocal, camWorld);
				var camNormal = math.normalize(camLocal);

				camLocal -= camNormal * surfaceHeight;

				for (var f = 0; f < 6; f++)
				{
					GetFace(f, radius, out var fO, out var fU, out var fV, out var dominantAxis);

					// Map camera from sphere back to cube face
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

						if (math.distancesq(camWorld, math.transform(localToWorld, sc)) > maxDistSq)
							continue;

						var tile = new Tile {
							u = tu, v = tv, faceIndex = f, tangent = fU, bitangent = fV,
							corner = fO + fU * (tu * cs) + fV * (tv * cs), center = center
						};

						if (!currSet.Add(tile)) continue;

						if (!prevSet.Contains(tile))
						{
							var distSq    = math.lengthsq(center);
							var areaRatio = (radius * radius * radius) / (distSq * math.sqrt(distSq));
							var rng       = new RNG(math.hash(center) + Seed);

							var theoreticalCount = cs * cs * areaRatio * spawnDensity;
							var baseCount        = (int)math.floor(theoreticalCount);
							var fractionalChance = theoreticalCount - baseCount;

							if (rng.NextDouble() < fractionalChance)
							{
								baseCount += 1;
							}

							tile.tripletIndex = spawnPoints.Length;
							tile.tripletCount = baseCount;

							for (var p = 0; p < tile.tripletCount; p++)
							{
								var pU = tu * cs + rng.NextDouble() * cs;
								var pV = tv * cs + rng.NextDouble() * cs;
								spawnPoints.Add(math.normalize(fO + fU * pU + fV * pV) * radius);
								spawnPoints.Add(math.normalize(fO + fU * (pU + eps) + fV * pV) * radius);
								spawnPoints.Add(math.normalize(fO + fU * pU + fV * (pV + eps)) * radius);
							}
							added.Add(tile);
						}
						current.Add(tile);
					}
				}

				for (var i = 0; i < prev.Length; i++)
				{
					if (currSet.Contains(prev[i]) == false)
					{
						removed.Add(prev[i]);
					}
				}

				prev.Dispose();
				prevSet.Dispose();
				currSet.Dispose();

				// Inject camera pos at end to calculate surfaceHeight for next time
				spawnPoints.Add(camLocal);
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

			public uint Seed;
			public int MaskWidth, MaskHeight;
			public bool InvertMask;
			public float ScaleMin, ScaleMax, Offset;
			public RotateType RotateMode;

			public float UseMinHeight, MinHeight, MinHeightFalloff;
			public float UseMaxHeight, MaxHeight, MaxHeightFalloff;
			public float UseMinSlope, MinSlope, MinSlopeFalloff;
			public float UseMaxSlope, MaxSlope, MaxSlopeFalloff;

			public NativeList<float3>     OutPositions;
			public NativeList<quaternion> OutRotations;
			public NativeList<float3>     OutScales;

			public void Execute()
			{
				OutPositions.Clear();
				OutRotations.Clear();
				OutScales.Clear();

				for (var i = 0; i < Tiles.Length; i++)
				{
					var tile = Tiles[i];
					tile.spawnIndex = OutPositions.Length;
					tile.spawnCount = 0;

					for (var s = 0; s < tile.tripletCount; s++)
					{
						var globalIdx   = tile.tripletIndex + s * 3;
						var p0          = (float3)GetPosition(globalIdx + 0);
						var p1          = (float3)GetPosition(globalIdx + 1);
						var p2          = (float3)GetPosition(globalIdx + 2);
						var height      = (float)InputHeights[globalIdx];
						var uv          = InputDataA[globalIdx].xy;
						var rng         = new RNG(math.hash(p0) + Seed);
						var upDir       = (float3)InputDirections[globalIdx];
						var norm        = math.normalize(math.cross(p1 - p0, p2 - p0));
						var slope       = math.degrees(math.acos(math.clamp(math.dot(norm, upDir), -1.0f, 1.0f)));
						var probability = (float)SampleMask(uv);

						// Height Constraints
						var hMinP  = math.saturate((height - MinHeight) / math.max(MinHeightFalloff, 0.0001f));
						var hMaxP  = math.saturate((MaxHeight - height) / math.max(MaxHeightFalloff, 0.0001f));
				
						probability *= math.lerp(1.0f, hMinP, UseMinHeight);
						probability *= math.lerp(1.0f, hMaxP, UseMaxHeight);

						// Slope Constraints
						var sMinP = math.saturate((slope - MinSlope) / math.max(MinSlopeFalloff, 0.0001f));
						var sMaxP = math.saturate((MaxSlope - slope) / math.max(MaxSlopeFalloff, 0.0001f));

						probability *= math.lerp(1.0f, sMinP, UseMinSlope);
						probability *= math.lerp(1.0f, sMaxP, UseMaxSlope);

						if (probability < rng.NextFloat()) continue;

						var rot  = quaternion.identity;
						var spin = quaternion.RotateY(rng.NextFloat(0, math.PI * 2.0f));

						switch (RotateMode)
						{
							case RotateType.Randomly:          rot = rng.NextQuaternionRotation(); break;
							case RotateType.ToLandscapeCenter: rot = math.mul(FromToRotation(new float3(0,1,0), upDir), spin); break;
							case RotateType.ToSurfaceNormal:   rot = math.mul(FromToRotation(new float3(0,1,0), norm), spin); break;
						}

						OutPositions.Add(p0 + math.rotate(rot, new float3(0, Offset, 0)));
						OutRotations.Add(rot);
						OutScales.Add(new float3(rng.NextFloat(ScaleMin, ScaleMax)));
		
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
				if (!MaskPixels.IsCreated || MaskWidth <= 0) return 1.0;
				var x = math.clamp((int)(uv.x * MaskWidth), 0, MaskWidth - 1);
				var y = math.clamp((int)(uv.y * MaskHeight), 0, MaskHeight - 1);
				var m = (double)MaskPixels[x + y * MaskWidth] / 255.0;
				return InvertMask ? 1.0 - m : m;
			}
		}

		[System.NonSerialized] private NativeList<Tile>    currentTiles;
		[System.NonSerialized] private NativeList<Tile>    addedTiles;
		[System.NonSerialized] private NativeList<Tile>    removedTiles;
		[System.NonSerialized] private NativeList<double3> spawnPoints;

		[System.NonSerialized] private NativeArray<byte> maskPixels;
		[System.NonSerialized] private int               maskWidth;
		[System.NonSerialized] private int               maskHeight;

		private JobHandle gridHandle;
		private JobHandle spawnHandle;
		private bool gridRunning;
		private bool spawnRunning;

		private SgtSphereLandscape.PendingPoints pendingData;

		// Reusable persistent buffers
		private NativeList<float3> spawnP;
		private NativeList<quaternion> spawnR;
		private NativeList<float3> spawnS;

		public int GetSlices()
        {
            if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
            if (parent == null || tileSize <= 0.001f) return 1;

            return math.max(1, (int)math.round((parent.Radius * 2.0) / tileSize));
        }

		/// <summary>Returns the approximate maximum number of objects that can spawn with these settings when the camera is on the surface, if all height and slope checks pass.</summary>
		public int GetApproximateMaximumSpawnCount()
		{
			if (parent == null) parent = GetComponentInParent<SgtSphereLandscape>();
			if (parent == null) return -1;

            int slices = GetSlices();
			var planetArea = 4.0 * math.PI * parent.Radius * parent.Radius;
			var tileArea   = planetArea / (6.0 * slices * slices);
			var searchArea = math.PI * range * range;
			var tileCount  = searchArea / tileArea;

			return (int)math.ceil(tileCount * (tileArea * density));
		}

		protected virtual void OnEnable()
		{
			parent = GetComponentInParent<SgtSphereLandscape>();

			UpdateMaskData();

			currentTiles = new NativeList<Tile>(128, Allocator.Persistent);
			addedTiles   = new NativeList<Tile>(128, Allocator.Persistent);
			removedTiles = new NativeList<Tile>(128, Allocator.Persistent);
			spawnPoints  = new NativeList<double3>(512, Allocator.Persistent);
	
			spawnP = new NativeList<float3>(1024, Allocator.Persistent);
			spawnR = new NativeList<quaternion>(1024, Allocator.Persistent);
			spawnS = new NativeList<float3>(1024, Allocator.Persistent);
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

			spawnP.Dispose();
			spawnR.Dispose();
			spawnS.Dispose();
		}

		public void MarkAsDirty()
		{
			if (currentTiles.IsCreated == true)
			{
				ForceComplete();

				foreach (var tile in currentTiles)
					HandleDespawn(tile);

				currentTiles.Clear();
				addedTiles.Clear();
				removedTiles.Clear();

				maskPixels.Dispose();

				UpdateMaskData();
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
			// 1. Check Grid Status
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

				// Extract injected cam pos
				int camIdx = pendingData.Points.Length - 1;
				if (camIdx >= 0)
				{
					surfaceHeight = pendingData.Heights[camIdx];
				}

				foreach (var tile in addedTiles)
					HandleSpawn(tile, spawnP, spawnR, spawnS);

				pendingData.Dispose();
				return;
			}

			// 3. Start new cycle if camera exists
			var cam = Camera.main;
			if (cam == null) return;

			StartGridPipeline(cam);
		}

		private void StartGridPipeline(Camera cam)
		{
			var job = new GridJob
			{
				current       = currentTiles,
				added         = addedTiles,
				removed       = removedTiles,
				spawnPoints   = spawnPoints,
				camWorld      = new double3(cam.transform.position),
				surfaceHeight = surfaceHeight,
				worldToLocal  = new double4x4(transform.worldToLocalMatrix),
				localToWorld  = new double4x4(transform.localToWorldMatrix),
				radius        = parent.Radius,
				maxDistSq     = range * range,
				Seed          = (uint)seed,
				count         = GetSlices(),
				spawnDensity  = density,
				spawnOffset   = offset
			};

			gridHandle = job.Schedule();
			gridRunning = true;
		}

		private void StartSpawnPipeline()
		{
			pendingData = parent.SchedulePoints(spawnPoints);
	
			spawnP.Clear();
			spawnR.Clear();
			spawnS.Clear();

			var job = new SpawnJob()
			{
				Tiles           = addedTiles,
				InputPoints     = pendingData.Points,
				InputDirections = pendingData.Directions,
				InputHeights    = pendingData.Heights,
				InputDataA      = pendingData.DataA,

				MaskPixels      = maskPixels,
				MaskWidth       = maskWidth,
				MaskHeight      = maskHeight,
				InvertMask      = invertMask,

				Seed            = (uint)seed,
				ScaleMin        = scaleMin,
				ScaleMax        = scaleMax,
				Offset          = offset,
				RotateMode      = rotate,
				OutPositions    = spawnP,
				OutRotations    = spawnR,
				OutScales       = spawnS,

				UseMinHeight     = useMinHeight ? 1 : 0,
				MinHeight        = minHeight,
				MinHeightFalloff = minHeightFalloff, // Fixed
				UseMaxHeight     = useMaxHeight ? 1 : 0,
				MaxHeight        = maxHeight,
				MaxHeightFalloff = maxHeightFalloff, // Fixed

				UseMinSlope     = useMinSlope ? 1 : 0,
				MinSlope        = minSlope,
				MinSlopeFalloff = minSlopeFalloff,
				UseMaxSlope     = useMaxSlope ? 1 : 0,
				MaxSlope        = maxSlope,
				MaxSlopeFalloff = maxSlopeFalloff,
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

		protected abstract void HandleSpawn(Tile tile, NativeList<float3> pos, NativeList<quaternion> rot, NativeList<float3> scale);

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

			Draw("maskTex", ref markAsDirty, "The spawn area mask (R8/Alpha8).");
			Draw("invertMask", ref markAsDirty, "Invert the mask?");
			BeginError(Any(tgts, t => t.TileSize <= 0.0f));
				Draw("tileSize", ref markAsDirty, "The target size for each grid tile. Smaller tiles increase grid precision but use more CPU.");
			EndError();
			BeginError(Any(tgts, t => t.Range <= 0.0f));
				Draw("range", "The world space distance the camera must be within for a grid cell to spawn.");
			EndError();
			BeginError(Any(tgts, t => t.Density <= 0.0f));
				Draw("density", ref markAsDirty, "Objects per square unit.");
			EndError();
			BeginDisabled();
				UnityEditor.EditorGUILayout.IntField("Approx Max Spawn Count", tgt.GetApproximateMaximumSpawnCount());
			EndDisabled();
			Draw("seed", ref markAsDirty, "Random seed.");

			Separator();

			Draw("scaleMin", ref markAsDirty);
			Draw("scaleMax", ref markAsDirty);
			Draw("rotate", ref markAsDirty);
			Draw("offset", ref markAsDirty);

			Separator();

			Draw("useMinHeight", ref markAsDirty, "Enable to clip or fade out spawning below a specific height.");

			if (Any(tgts, t => t.UseMinHeight))
			{
				BeginIndent();
					Draw("minHeight", ref markAsDirty, "The absolute height value where spawning probability is 0%.");
					Draw("minHeightFalloff", ref markAsDirty, "The distance above <b>MinHeight</b> it takes for the spawning probability to reach 100%. \n\nSet to 0 for an abrupt cutoff.");
				EndIndent();
			}

			Draw("useMaxHeight", ref markAsDirty, "Enable to clip or fade out spawning above a specific height.");

			if (Any(tgts, t => t.UseMaxHeight))
			{
				BeginIndent();
					Draw("maxHeight", ref markAsDirty, "The absolute height value where spawning probability returns to 0%.");
					Draw("maxHeightFalloff", ref markAsDirty, "The distance below <b>MaxHeight</b> where the spawning probability begins to fade out. \n\nSet to 0 for an abrupt cutoff.");
				EndIndent();
			}

			Separator();

			Draw("useMinSlope", ref markAsDirty, "Enable to clip or fade out spawning on flat terrain.");
			if (Any(tgts, t => t.UseMinSlope))
			{
				BeginIndent();
					Draw("minSlope", ref markAsDirty, "Minimum angle (0-90).");
					Draw("minSlopeFalloff", ref markAsDirty, "Angular fade-in distance.");
				EndIndent();
			}

			Draw("useMaxSlope", ref markAsDirty, "Enable to clip or fade out spawning on steep terrain.");
			if (Any(tgts, t => t.UseMaxSlope))
			{
				BeginIndent();
					Draw("maxSlope", ref markAsDirty, "Maximum angle (0-90).");
					Draw("maxSlopeFalloff", ref markAsDirty, "Angular fade-out distance.");
				EndIndent();
			}

			if (markAsDirty == true)
			{
				Each(tgts, t => t.MarkAsDirty(), true);
			}
		}
	}
}
#endif