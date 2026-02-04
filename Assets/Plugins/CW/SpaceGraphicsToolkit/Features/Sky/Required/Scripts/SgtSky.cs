using UnityEngine;
using CW.Common;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Volumetrics;
using Unity.Jobs;
using UnityEngine.Jobs;
using Unity.Collections;
using Unity.Mathematics;
using Unity.Burst;
using System.Collections.Generic;

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component allows you to draw a volumetric atmosphere around a planet.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Sky")]
	public class SgtSky : MonoBehaviour, CwChild.IHasChildren, SgtLightOccluder.IOccluder
	{
		/// <summary>The material used to render this component.
		/// NOTE: This material must use the <b>Space Graphics Toolkit/Atmosphere</b> shader. You cannot use a normal shader.</summary>
		public Material Material { set { if (material != value) { material = value; } } get { return material; } } [SerializeField] private Material material;

		/// <summary>The color tint of the sky.</summary>
		public Color Color { set { color = value; } get { return color; } } [SerializeField] private Color color = Color.white;

		/// <summary>The <b>Color.rgb</b> values will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 1.0f;

		/// <summary>The radius of the meshes set in the SgtSharedMaterial.</summary>
		public float InnerMeshRadius { set { innerMeshRadius = value; } get { return innerMeshRadius; } } [SerializeField] private float innerMeshRadius = 100.0f;

		/// <summary>This allows you to set how high the atmosphere extends above the surface of the planet in local space.</summary>
		public float Height { set { height = value; } get { return height; } } [SerializeField] private float height = 10.0f;

		/// <summary>This allows you to adjust the fog level of the atmosphere.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 1.0f;

		/// <summary>This allows you to offset the camera distance in world space when rendering the atmosphere, giving you fine control over the render order.</summary>
		public float CameraOffset { set { cameraOffset = value; } get { return cameraOffset; } } [SerializeField] private float cameraOffset = 0.1f;

		/// <summary>This allows you to control how fast the opacity of the sky increases as the camera descends.</summary>
		public float DepthOpaque { set { depthOpaque = value; } get { return depthOpaque; } } [SerializeField] private float depthOpaque = 50.0f;

		/// <summary>The Rayleigh scattering color.</summary>
		public Color RayleighColor { set { if (rayleighColor != value) { rayleighColor = value; lutDirty = true; } } get { return rayleighColor; } } [SerializeField] private Color rayleighColor = new Color(0.17522f, 0.4078f, 1.0f);

		/// <summary>The Rayleigh scattering color is multiplied by this.</summary>
		public float RayleighMultiplier { set { if (rayleighMultiplier != value) { rayleighMultiplier = value; lutDirty = true; } } get { return rayleighMultiplier; } } [SerializeField] private float rayleighMultiplier = 33.1f;

		/// <summary>The 0..1 altitude where Rayleigh scattering dominates.</summary>
		public float RayleighHeight { set { if (rayleighHeight != value) { rayleighHeight = value; lutDirty = true; } } get { return rayleighHeight; } } [SerializeField] [Range(0.001f, 1.0f)] private float rayleighHeight = 0.5f;

		/// <summary>The Mie absorption.</summary>
		public float MieAbsorb { set { if (mieAbsorb != value) { mieAbsorb = value; lutDirty = true; } } get { return mieAbsorb; } } [SerializeField] private float mieAbsorb = 4.4f;

		/// <summary>The Mie scattering color is multiplied by this.</summary>
		public float MieMultiplier { set { if (mieMultiplier != value) { mieMultiplier = value; lutDirty = true; } } get { return mieMultiplier; } } [SerializeField] private float mieMultiplier = 21.0f;

		/// <summary>The 0..1 altitude where Mie scattering dominates.</summary>
		public float MieHeight { set { if (mieHeight != value) { mieHeight = value; lutDirty = true; } } get { return mieHeight; } } [SerializeField] [Range(0.001f, 1.0f)] private float mieHeight = 0.08f;

		/// <summary>The Mie scattering asymmetry factor.</summary>
		public float MieAsymmetry { set { if (mieAsymmetry != value) { mieAsymmetry = value; lutDirty = true; } } get { return mieAsymmetry; } } [SerializeField] [Range(0.0f, 0.95f)] private float mieAsymmetry = 0.8f;

		/// <summary>The secondary Mie scattering asymmetry factor for the sun.</summary>
		public float MieAsymmetry2 { set { mieAsymmetry2 = value; } get { return mieAsymmetry2; } } [SerializeField] [Range(0.0f, 0.9995f)] private float mieAsymmetry2 = 0.999f;

		/// <summary>The ozone absorption color.</summary>
		public Color OzoneColor { set { if (ozoneColor != value) { ozoneColor = value; lutDirty = true; } } get { return ozoneColor; } } [SerializeField] private Color ozoneColor = new Color(0.345f, 1.0f, 0.045f);

		/// <summary>The ozone absorption color is multiplied by this.</summary>
		public float OzoneMultiplier { set { if (ozoneMultiplier != value) { ozoneMultiplier = value; lutDirty = true; } } get { return ozoneMultiplier; } } [SerializeField] private float ozoneMultiplier = 1.881f;

		/// <summary>The 0..1 altitude where ozone absorption dominates.</summary>
		public float OzoneHeight { set { ozoneHeight = value; } get { return ozoneHeight; } } [SerializeField] [Range(0.0f, 1.0f)] private float ozoneHeight = 0.25f;

		/// <summary>The 0..1 thickness ozone absorption dominates.</summary>
		public float OzoneThickness { set { ozoneThickness = value; } get { return ozoneThickness; } } [SerializeField] [Range(0.0f, 1.0f)] private float ozoneThickness = 0.15f;

		/// <summary>The albedo texture applied to the sky.
		/// NOTE: This requires <b>Material</b> to have the <b>ALBEDO</b> setting enabled.</summary>
		public Texture AlbedoTex { set { albedoTex = value; } get { return albedoTex; } } [SerializeField] private Texture albedoTex;

		/// <summary>The brightness applied before tone mapping.</summary>
		public float Exposure { set { exposure = value; } get { return exposure; } } [SerializeField] private float exposure = 20.0f;

		/// <summary>All activate and enabled SgtSky instances in the scene.</summary>
		public static LinkedList<SgtSky> Instances = new LinkedList<SgtSky>();

		[System.NonSerialized]
		private LinkedListNode<SgtSky> node;

		public Vector3 LightDirection
		{
			get
			{
				return lightDirection;
			}
		}

		public Color LightColor
		{
			get
			{
				return lightColor;
			}
		}

		public SgtSkyModel Model

		{
			get
			{
				return model;
			}
		}

		[SerializeField]
		private SgtSkyModel model;

		[System.NonSerialized]
		private static Mesh invertedSphereMesh;

		[System.NonSerialized]
		private static bool invertedSphereMeshCreated;

		private static float sphereInflate = 1.02f;

		[System.NonSerialized]
		private Material blitMaterial;

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[System.NonSerialized]
		private Texture2D transmittanceLut;

		[System.NonSerialized]
		private Texture3D radianceLut;

		[System.NonSerialized]
		private Texture2D lightingLut;

		[System.NonSerialized]
		private Vector3 lightDirection;

		[System.NonSerialized]
		private Color lightColor;

		[System.NonSerialized]
		private int jobStage;

		[System.NonSerialized]
		private JobHandle jobHandle;

		[System.NonSerialized]
		private bool jobRunning;

		[System.NonSerialized]
		private bool lutDirty = true;
		
		private static readonly int _SGT_WorldToSky        = Shader.PropertyToID("_SGT_WorldToSky");
		private static readonly int _SGT_SkyToWorld        = Shader.PropertyToID("_SGT_SkyToWorld");
		private static readonly int _SGT_SkyColor          = Shader.PropertyToID("_SGT_SkyColor");
		private static readonly int _SGT_SkyBrightness     = Shader.PropertyToID("_SGT_SkyBrightness");
		private static readonly int _SGT_SkyAltitudeData   = Shader.PropertyToID("_SGT_SkyAltitudeData");
		private static readonly int _SGT_SkyRadius         = Shader.PropertyToID("_SGT_SkyRadius");
		private static readonly int _SGT_SkyDensity        = Shader.PropertyToID("_SGT_SkyDensity");
		private static readonly int _SGT_SkyRadianceTex    = Shader.PropertyToID("_SGT_SkyRadianceTex");
		private static readonly int _SGT_SkyRadianceLod    = Shader.PropertyToID("_SGT_SkyRadianceLod");
		private static readonly int _SGT_SkyMieWeight      = Shader.PropertyToID("_SGT_SkyMieWeight");
		private static readonly int _SGT_SkyMieData        = Shader.PropertyToID("_SGT_SkyMieData");
		private static readonly int _SGT_SkyExposure       = Shader.PropertyToID("_SGT_SkyExposure");
		private static readonly int _SGT_SkyDepthOpaque    = Shader.PropertyToID("_SGT_SkyDepthOpaque");
		private static readonly int _SGT_SkyLightingTex    = Shader.PropertyToID("_SGT_SkyLightingTex");
		private static readonly int _SGT_SkyAlbedoTex      = Shader.PropertyToID("_SGT_SkyAlbedoTex");

		private struct ParticleData
		{
			public double  Height;
			public double3 Color;
			public double  Absorb;
			public double  Thickness;
		}

		[BurstCompile]
		private struct InterpolateJob : IJob
		{
			[ReadOnly] public int StepSize;
			[ReadOnly] public int StepIndex;

			public NativeArray<float4> Pixels;

			public void Execute()
			{
				var length = Pixels.Length;

				for (var i = 0; i < length; i++)
				{
					var subIndex = i % StepSize;

					if (subIndex > StepIndex)
					{
						var chunkStart = i - subIndex;
						var leftIndex  = chunkStart + StepIndex;
						var rightIndex = chunkStart + (StepSize - 1);
						var blendIndex = (float)(subIndex - StepIndex) / (StepSize - 1 - StepIndex);

						Pixels[i] = math.lerp(Pixels[leftIndex], Pixels[rightIndex], blendIndex);
					}
				}
			}
		}

		[BurstCompile]
		private struct TransmittanceJob : IJobParallelFor
		{
			[ReadOnly] public int2   Size;
			[ReadOnly] public double PlanetRadius;
			[ReadOnly] public double AtmosphereHeight;
			[ReadOnly] public double AltitudeScale;
			[ReadOnly] public double Density;

			[ReadOnly] public ParticleData Rayleigh; // (0.175, 0.409, 1.000) * 33.10,  8.0km, 0.0,  0km
			[ReadOnly] public ParticleData Mie;      // (1.000, 1.000, 1.000) * 3.996,  1.2km, 4.4,  0km
			[ReadOnly] public ParticleData Ozone;    // (0.345, 1.000, 0.045) * 1.881, 25.0km, 0.0, 15km

			[WriteOnly] public NativeArray<float4> Data;

			private double3 SGT_GetScattering(double3 pos, out double3 rayScattering, out double3 mieScattering)
			{
				var altitude     = math.max(0.0f, math.length(pos) - PlanetRadius);
				var rawR         = math.exp(-altitude / Rayleigh.Height);
				var topR         = math.exp(-AtmosphereHeight / Rayleigh.Height);
				var rayDensity   = (rawR - topR) / (1.0 - topR);
				var rawM         = math.exp(-altitude / Mie.Height);
				var topM         = math.exp(-AtmosphereHeight / Mie.Height);
				var mieDensity   = (rawM - topM) / (1.0 - topM);
				var ozoneDensity = math.max(0.0, 1.0 - math.abs(altitude - Ozone.Height) / Ozone.Thickness);

				rayScattering = rayDensity * Rayleigh.Color;
				mieScattering = mieDensity * Mie.Color;

				return rayScattering + Rayleigh.Absorb * rayDensity + mieScattering + Mie.Absorb * mieDensity + Ozone.Color * ozoneDensity;
			}

			private double3 SGT_SphereTest(double3 ray, double3 rayD, double radius)
			{
				var B = -math.dot(ray, rayD);
				var C = math.dot(ray, ray) - radius * radius;
				var D = B * B - C;
				var E = math.sqrt(math.max(D, 0.0));
				return new double3(B - E, B + E, D);
			}

			private double3 SGT_March(double3 rayPos, double3 rayDir)
			{
				var stepCount     = 64;
				var rayMax        = SGT_SphereTest(rayPos, rayDir, PlanetRadius + AtmosphereHeight).y;
				var rayStep       = rayMax / stepCount;
				var expMul        = rayStep / (PlanetRadius + AtmosphereHeight);
				var rayT          = rayStep * 0.5;
				var transmittance = new double3(1.0, 1.0, 1.0);

				for (var i = 0; i < stepCount; i++)
				{
					double3 rayScattering, mieScattering;

					transmittance *= math.exp(-SGT_GetScattering(rayPos + rayDir * rayT, out rayScattering, out mieScattering) * expMul);

					rayT += rayStep;
				}

				return transmittance;
			}

			public void Execute(int index)
			{
				var x = index % Size.x;
				var y = (index / Size.x) % Size.y;

				var ray01      = x / (Size.x - 1.0) * 0.99999;
				var altitude01 = y / (Size.y - 1.0) + 0.00001;

				var eyeHeight   = math.lerp(PlanetRadius, PlanetRadius + AtmosphereHeight, altitude01);
				var rayPos      = new double3(0.0, eyeHeight, 0.0);
				var sunCosTheta = 2.0 * ray01 - 1.0;
				var sunTheta    = math.acos(sunCosTheta);
				var sunDir      = math.normalize(new double3(0.0, sunCosTheta, -math.sin(sunTheta)));

				Data[index] = new float4((float3)SGT_March(rayPos, sunDir), 0.0f);
			}
		}

		[BurstCompile]
		struct LightingJob : IJobParallelFor
		{
			[ReadOnly] public int                 Blur;
			[ReadOnly] public int2                Size;
			[ReadOnly] public NativeArray<float4> Input;

			[WriteOnly] public NativeArray<float4> Output;

			public void Execute(int index)
			{
				var x = index % Size.x;
				var y = (index / Size.x) % Size.y;
				var o = y * Size.x;

				var sum    = Input[o + x];
				var count  = 1;

				for (var i = 1; i <= Blur; i++)
				{
					var xa = math.clamp(x - i, 0, Size.x - 1);
					var xb = math.clamp(x + i, 0, Size.x - 1);

					sum.xyz += Input[xa + y * Size.x].xyz;
					sum.xyz += Input[xb + y * Size.x].xyz;

					count += 2;
				}

				Output[index] = (float4)new double4(sum.xyz / count, 1.0);
			}
		}

		[BurstCompile]
		private struct RadianceJob : IJobParallelFor
		{
			[ReadOnly] public int3   Size;
			[ReadOnly] public double PlanetRadius;
			[ReadOnly] public double AtmosphereHeight;
			[ReadOnly] public double AltitudeScale;
			[ReadOnly] public double Density;

			[ReadOnly] public double  RayWeight;
			[ReadOnly] public double3 RayColor;
			[ReadOnly] public double  MieWeight;
			[ReadOnly] public double3 MieColor;

			[ReadOnly] public ParticleData Rayleigh; // (0.175, 0.409, 1.000) * 33.10,  8.0km, 0.0,  0km
			[ReadOnly] public ParticleData Mie;      // (1.000, 1.000, 1.000) * 3.996,  1.2km, 4.4,  0km
			[ReadOnly] public ParticleData Ozone;    // (0.345, 1.000, 0.045) * 1.881, 25.0km, 0.0, 15km

			[WriteOnly] public NativeArray<float4> Pixels;

			[ReadOnly] public int2                LutSize;
			[ReadOnly] public NativeArray<float4> LutPixels;

			public static float4 Sample_Clamp(NativeArray<float4> data, int2 size, long x, long y)
			{
				x = math.clamp(x, 0, size.x - 1);
				y = math.clamp(y, 0, size.y - 1);

				return data[(int)x + (int)y * size.x];
			}

			public static float4 Sample_Linear_Clamp(NativeArray<float4> data, int2 size, double2 pixel)
			{
				var fracX = (float)((pixel.x % 1.0 + 1.0) % 1.0);
				var fracY = (float)((pixel.y % 1.0 + 1.0) % 1.0);
				var x     = (long)math.floor(pixel.x % size.x);
				var y     = (long)math.floor(pixel.y % size.y);

				var bl0 = Sample_Clamp(data, size, x    , y    );
				var br0 = Sample_Clamp(data, size, x + 1, y    );
				var tl0 = Sample_Clamp(data, size, x    , y + 1);
				var tr0 = Sample_Clamp(data, size, x + 1, y + 1);

				var b0 = math.lerp(bl0, br0, fracX);
				var t0 = math.lerp(tl0, tr0, fracX);

				return math.lerp(b0, t0, fracY);
			}

			private double3 SGT_GetScattering(double3 pos, out double3 rayScattering, out double3 mieScattering)
			{
				var altitude     = math.max(0.0f, math.length(pos) - PlanetRadius);
				var rawR         = math.exp(-altitude / Rayleigh.Height);
				var topR         = math.exp(-AtmosphereHeight / Rayleigh.Height);
				var rayDensity   = (rawR - topR) / (1.0 - topR);
				var rawM         = math.exp(-altitude / Mie.Height);
				var topM         = math.exp(-AtmosphereHeight / Mie.Height);
				var mieDensity   = (rawM - topM) / (1.0 - topM);
				var ozoneDensity = math.max(0.0, 1.0 - math.abs(altitude - Ozone.Height) / Ozone.Thickness);

				rayScattering = rayDensity * Rayleigh.Color;
				mieScattering = mieDensity * Mie.Color;

				return rayScattering + Rayleigh.Absorb * rayDensity + mieScattering + Mie.Absorb * mieDensity + Ozone.Color * ozoneDensity;
			}

			private double3 SGT_SphereTest(double3 ray, double3 rayD, double radius)
			{
				var B = -math.dot(ray, rayD);
				var C = math.dot(ray, ray) - radius * radius;
				var D = B * B - C;
				var E = math.sqrt(math.max(D, 0.0));
				return new double3(B - E, B + E, D);
			}

			private double3 GetTransmittance(double3 rayPos, double3 rayDir)
			{
				var eyeHeight  = math.length(rayPos);

				if (eyeHeight >= PlanetRadius)
				{
					var up         = math.normalize(rayPos);
					var altitude01 = math.saturate(math.unlerp(PlanetRadius, PlanetRadius + AtmosphereHeight, eyeHeight));
					var sun01      = 0.5 + 0.5 * math.dot(rayDir, up);
		
					return Sample_Linear_Clamp(LutPixels, LutSize, LutSize * new double2(sun01, altitude01)).xyz;
				}
				
				var stepCount     = 16;
				var rayMax        = SGT_SphereTest(rayPos, rayDir, PlanetRadius + AtmosphereHeight).y;
				var rayStep       = rayMax / stepCount;
				var expMul        = rayStep / (PlanetRadius + AtmosphereHeight);
				var rayT          = rayStep * 0.5;
				var transmittance = new double3(1.0, 1.0, 1.0);

				for (var i = 0; i < stepCount; i++)
				{
					double3 rayScattering, mieScattering;

					transmittance *= math.exp(-SGT_GetScattering(rayPos + rayDir * rayT, out rayScattering, out mieScattering) * expMul);

					rayT += rayStep;
				}

				return transmittance;
			}

			private void SGT_March(double3 rayPos, double3 rayDir, double3 sunDir, double2 range, int stepCount, ref double3 transmittance, ref double4 radiance)
			{
				var rayStep = (range.y - range.x) / stepCount;
				var expMul = rayStep / (PlanetRadius + AtmosphereHeight);
				var t      = range.x + rayStep * 0.5;

				for (var i = 0; i < stepCount; i++)
				{
					var pos = rayPos + rayDir * t;

					double3 rayScattering, mieScattering;

					var extinction = SGT_GetScattering(pos, out rayScattering, out mieScattering);

					var sampleTransmittance = math.exp(-extinction * expMul);

					var sunTransmittance = GetTransmittance(pos, sunDir);

					var rayInScattering = rayScattering * sunTransmittance;
					var mieInScattering = mieScattering * sunTransmittance;

					var rayIntegral = (rayInScattering - rayInScattering * sampleTransmittance) / extinction;
					var mieIntegral = (mieInScattering - mieInScattering * sampleTransmittance) / extinction;

					radiance.xyz += rayIntegral * transmittance;
					radiance.w   += math.dot(mieIntegral * transmittance, 1.0 / 3.0);

					transmittance *= sampleTransmittance;

					t += rayStep;
				}
			}

			private double4 SGT_March(double3 rayPos, double3 rayDir, double3 sunDir)
			{
				var innerHit      = SGT_SphereTest(rayPos, rayDir, PlanetRadius);
				var outerHit      = SGT_SphereTest(rayPos, rayDir, PlanetRadius + AtmosphereHeight);
				var transmittance = new double3(1.0, 1.0, 1.0);
				var radiance      = new double4(0.0, 0.0, 0.0, 0.0);

				if (innerHit.z > 0.0 && innerHit.x > 0.0)
				{
					SGT_March(rayPos, rayDir, sunDir, new double2(       0.0, innerHit.x), 32, ref transmittance, ref radiance);
					SGT_March(rayPos, rayDir, sunDir, new double2(innerHit.x, innerHit.y),  1, ref transmittance, ref radiance);
					SGT_March(rayPos, rayDir, sunDir, new double2(innerHit.y, outerHit.y), 16, ref transmittance, ref radiance);
				}
				else
				{
					SGT_March(rayPos, rayDir, sunDir, new double2(0.0f, outerHit.y), 32, ref transmittance, ref radiance);
				}

				return radiance;
			}

			private double3 SGT_GetRayDir(double sun01, double eyeHeight)
			{
				var horizonAngleFromDown = -math.acos(PlanetRadius / eyeHeight);

				var rayAng = 0.0;
				var power = 2.0;

				if (sun01 < 0.5)
				{
					var t = sun01 / 0.5;
					rayAng = math.lerp(-math.PI_DBL * 0.5, horizonAngleFromDown, 1.0 - math.pow(1.0 - t, power));
				}
				else
				{
					var t = (sun01 - 0.5) / 0.5;
					rayAng = math.lerp(horizonAngleFromDown, math.PI_DBL * 0.5, math.pow(t, power));
				}

				return new double3(0.0, math.sin(rayAng), math.cos(rayAng));
			}

			public void Execute(int index)
			{
				var x = index % Size.x;
				var y = (index / Size.x) % Size.y;
				var z = index / (Size.x * Size.y);

				var pitch01    = x / (Size.x - 1.0) * 0.99999;
				var altitude01 = y / (Size.y - 1.0) + 0.00001;
				var sun01      = z / (Size.z - 1.0) * 0.99999;

				var eyeHeight = math.lerp(PlanetRadius, PlanetRadius + AtmosphereHeight, altitude01);

				var rayPos = new double3(0.0, eyeHeight, 0.0);

				var rayDir = SGT_GetRayDir(pitch01, eyeHeight);

				var sunDir = SGT_GetRayDir(sun01, eyeHeight);

				Pixels[index] = (float4)SGT_March(rayPos, rayDir, sunDir);
			}
		}

		public float OuterRadius
		{
			get
			{
				return innerMeshRadius + height;
			}
		}

		public float3 MieWeight
		{
			get
			{
				return math.pow(new float3(680.0f, 550.0f, 440.0f) / 550.0f, 4.0f - mieAsymmetry);
			}
		}

		public static Mesh InvertedSphereMesh
		{
			get
			{
				if (invertedSphereMeshCreated == false)
				{
					var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);

					go.hideFlags = HideFlags.DontSave;

					var originalMesh = go.GetComponent<MeshFilter>().sharedMesh;

					invertedSphereMesh = new Mesh();
					invertedSphereMesh.hideFlags = HideFlags.DontSave;
					invertedSphereMesh.vertices  = originalMesh.vertices;
					invertedSphereMesh.normals   = originalMesh.normals;
					invertedSphereMesh.uv        = originalMesh.uv;
	
					var triangles = originalMesh.triangles;
					for (int i = 0; i < triangles.Length; i += 3)
					{
						// Swap first and last index of each triangle
						(triangles[i], triangles[i + 2]) = (triangles[i + 2], triangles[i]);
					}
					invertedSphereMesh.triangles = triangles;

					DestroyImmediate(go);

					invertedSphereMeshCreated = true;
				}

				return invertedSphereMesh;
			}
		}

		public Material BlitMaterial
		{
			get
			{
				return blitMaterial;
			}
		}

		public Texture3D RadianceLut
		{
			get
			{
				return radianceLut;
			}
		}

		public Texture2D LightingLut
		{
			get
			{
				return lightingLut;
			}
		}

		public void MarkLutDirty()
		{
			lutDirty = true;
		}

		public bool HasChild(CwChild child)
		{
			return child == model;
		}

		public void RandomizeRayleighHue()
		{
			var h = 0.0f;
			var s = 0.0f;
			var v = 0.0f;

			Color.RGBToHSV(rayleighColor, out h, out s, out v);

			h = UnityEngine.Random.value;

			rayleighColor = Color.HSVToRGB(h, s, v);

			MarkLutDirty();
		}

		private void HandleCameraPreRender(Camera camera)
		{
			var eye = camera.transform.position;

			if (cameraOffset != 0.0f)
			{
				var direction = Vector3.Normalize(eye - transform.position);

				model.transform.position = transform.position + direction * cameraOffset;
			}
			else
			{
				model.transform.localPosition = Vector3.zero;
			}
		}

		public static SgtSky Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtSky Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CwHelper.CreateGameObject("Sky", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtSky>();
		}

		public float GetWorldDensity(Vector3 worldPosition)
		{
			var opos = transform.InverseTransformPoint(worldPosition);

			return GetLocalDensity(opos);
		}

		public float GetLocalDensity(Vector3 opos)
		{
			return 0.0f;
		}

		float SGT_GetPitch01(float3 rayDir, float3 up, float eyeHeight)
		{
			float power = 2.0f;
			float horizonAngleFromDown = -math.acos(math.clamp(innerMeshRadius / math.max(eyeHeight, 0.00001f), -1.0f, 1.0f));
			float rayAng = math.asin(math.clamp(math.dot(up, rayDir), -1.0f, 1.0f));
			float sun01;

			if (rayAng < horizonAngleFromDown)
			{
				sun01 = math.unlerp(-3.141592653f * 0.5f, horizonAngleFromDown, rayAng);
				sun01 = 1.0f - math.pow(1.0f - sun01, 1.0f / power);
				sun01 = sun01 * 0.5f;
			}
			else
			{
				sun01 = math.unlerp(horizonAngleFromDown, 3.141592653f * 0.5f, rayAng);
				sun01 = math.pow(sun01, 1.0f / power);
				sun01 = sun01 * 0.5f + 0.5f;
			}

			return sun01;
		}

		float3 GetLutCoord(float3 rayPos, float3 rayDir, float3 sunDir, float dither)
		{
			float3 up         = math.normalize(rayPos);
			float  eyeHeight  = math.length(rayPos);
			float  altitude01 = math.saturate(math.unlerp(innerMeshRadius, innerMeshRadius + height, eyeHeight));
			float  pitch01    = SGT_GetPitch01(rayDir, up, eyeHeight);
			float  sun01      = SGT_GetPitch01(sunDir, up, eyeHeight);
	
			pitch01 += (dither - 0.5f) / 128.0f;
			sun01   += (dither - 0.5f) /  64.0f;
	
			return new float3(pitch01, altitude01, sun01);
		}

		public Color GetSkyColor(Vector3 rayPos, Vector3 rayDir, Vector3 sunDir)
		{
			rayPos = transform.InverseTransformPoint(rayPos);
			rayDir = transform.InverseTransformDirection(rayDir).normalized;
			sunDir = transform.InverseTransformDirection(sunDir).normalized;

			var coord  = GetLutCoord(rayPos, rayDir, sunDir, 0.5f);
			var ray    = (float4)(Vector4)radianceLut.GetPixelBilinear(coord.x, coord.y, coord.z, jobStage);
			var mie    = math.normalize(ray.xyz * MieWeight + 1e-6f) * ray.w;
			var g      = new float2(mieAsymmetry, mieAsymmetry2);
			var c      = math.dot(rayDir, sunDir);
			var phaseR = 3.0f / (16.0f * 3.141592653f) * (1.0f + c * c);
			var phaseM = 3.0f / (8.0f * 3.141592653f) * ((1.0f - g * g) * (c * c + 1.0f)) / (math.pow(math.abs(1.0f + g * g - 2.0f * c * g), 1.5f) * (2.0f + g * g));
			var final  = ray.xyz * phaseR + mie * math.dot(phaseM, 1);

			final = 1.0f - math.exp(-final * exposure);

			return new Color(final.x, final.y, final.z, 1.0f) * color * brightness;
		}

		public Color GetSkyTransmittanceRaw(Vector3 rayPos, Vector3 sunDir)
		{
			rayPos = transform.InverseTransformPoint(rayPos);
			sunDir = transform.InverseTransformDirection(sunDir).normalized;

			float3 up         = math.normalize(rayPos);
			float  eyeHeight  = math.length(rayPos);
			float  altitude01 = math.saturate(math.unlerp(innerMeshRadius, innerMeshRadius + height, eyeHeight));
			float  sun01      = 0.5f + 0.5f * math.dot(sunDir, up);
		
			return lightingLut.GetPixelBilinear(sun01, altitude01, 0);
		}

		/// <summary>This will return a modified transmittance color, more closely matching perceptual color.</summary>
		public Color GetSkyTransmittance(Vector3 rayPos, Vector3 sunDir)
		{
			rayPos = transform.InverseTransformPoint(rayPos);
			sunDir = transform.InverseTransformDirection(sunDir).normalized;

			var up         = math.normalize((float3)rayPos);
			var sunHeight01   = math.saturate(math.dot(sunDir, up));
			var eyeHeight  = math.length(rayPos);
			var altitude01 = math.saturate(math.unlerp(innerMeshRadius, innerMeshRadius + height, eyeHeight));
			var sun01      = 0.5f + 0.5f * math.pow(sunHeight01, 0.5f); // Flatten the sun curve so it stays at noon for longer

			var rawTransmittance = lightingLut.GetPixelBilinear(sun01, altitude01, 0);
			var maxTransmittance = math.max(rawTransmittance.r, math.max(rawTransmittance.g, rawTransmittance.b));
			var tgtTransmittance = new Color(maxTransmittance, maxTransmittance, maxTransmittance);

			return Color.Lerp(rawTransmittance, tgtTransmittance, sunHeight01 * 0.8f); // Desaturate transmittance so it's closer to white during the day
		}

		public Color GetSkyAmbient(Vector3 rayPos, Vector3 sunDir)
		{
			var up = Vector3.Normalize(rayPos - transform.position);

			var zenithColor = GetSkyColor(rayPos, up, sunDir);

			var horizonDir = Vector3.Cross(sunDir, up).normalized;
			if (horizonDir.sqrMagnitude < 0.01f) horizonDir = Vector3.forward; // Fallback
	
			var horizonColor = GetSkyColor(rayPos, horizonDir, sunDir);

			// 3. Blend them
			// Most surfaces are horizontal, so we weight the Zenith higher (e.g., 70/30)
			var ambient = Color.Lerp(zenithColor, horizonColor, 0.3f);

			// 4. Boost/Dim based on Sun Height
			// This ensures ambient drops naturally during twilight
			var sunHeight = math.saturate(Vector3.Dot(sunDir, up));
			var ambientIntensity = math.lerp(0.05f, 1.0f, sunHeight);

			return ambient * ambientIntensity;
		}

		public float CalculateOcclusion(int layers, Vector3 worldEye, Vector3 worldTgt)
		{
			var localEye = transform.InverseTransformPoint(worldEye);
			var localTgt = transform.InverseTransformPoint(worldTgt);
			var localDir = localTgt - localEye;

			var a = Vector3.Dot(localDir, localDir);
			var b = 2.0f * Vector3.Dot(localEye, localDir);
			var c = Vector3.Dot(localEye, localEye) - OuterRadius * OuterRadius;
			var d = b * b - 4.0f * a * c;

			if (d < 0f)
			{
				return 0.0f;
			}

			var sd = Mathf.Sqrt(d);
			var t0 = (-b - sd) / (2.0f * a);
			var t1 = (-b + sd) / (2.0f * a);

			var near = Mathf.Max(0.0f, Mathf.Min(t0, t1));
			var far  = Mathf.Max(0.0f, Mathf.Max(t0, t1));
			var mid  = (near + far) * 0.5f;

			if (far <= near)
			{
				return 0.0f;
			}

			return GetLocalDensity(localEye + localDir * mid);
		}

		/// <summary>This will tell you the +- altitude of the input worldPoint relative to the inner mesh radius.</summary>
		public float CalculateWorldAltitude(Vector3 worldPoint)
		{
			var localPoint   = transform.InverseTransformPoint(worldPoint);
			var localSurface = localPoint.normalized * innerMeshRadius;
			var worldSurface = transform.TransformPoint(localSurface);

			return Vector3.Distance(worldPoint, worldSurface) * Mathf.Sign(localPoint.magnitude - innerMeshRadius);
		}

		public void ApplySettings(MaterialPropertyBlock properties, Camera finalCamera)
		{
			var worldToSky = Matrix4x4.Scale(Vector3.one * 2.0f * sphereInflate) * model.transform.worldToLocalMatrix;

			properties.SetMatrix(_SGT_WorldToSky, worldToSky);
			properties.SetMatrix(_SGT_SkyToWorld, worldToSky.inverse);
			properties.SetColor(_SGT_SkyColor, color);
			properties.SetFloat(_SGT_SkyBrightness, brightness);
			properties.SetVector(_SGT_SkyAltitudeData, new Vector4(1.0f / rayleighHeight, 1.0f / mieHeight, (innerMeshRadius + height) / height, 0.0f));

			if (radianceLut != null)
			{
				properties.SetTexture(_SGT_SkyRadianceTex, radianceLut);
				properties.SetFloat(_SGT_SkyRadianceLod, jobStage);
			}

			if (lightingLut != null)
			{
				properties.SetTexture(_SGT_SkyLightingTex, lightingLut);
			}

			var planetRadius   = innerMeshRadius / (double)(innerMeshRadius + height);
			var adjustedRadius = math.min(innerMeshRadius, innerMeshRadius + CalculateWorldAltitude(finalCamera.transform.position) - 100.0f);
			var clippedRadius  = adjustedRadius / (double)(innerMeshRadius + height);

			properties.SetVector(_SGT_SkyRadius, new Vector4(innerMeshRadius, innerMeshRadius + height, (float)planetRadius, (float)clippedRadius));
			properties.SetFloat(_SGT_SkyDepthOpaque, depthOpaque);
			properties.SetFloat(_SGT_SkyDensity, density);
			properties.SetFloat(_SGT_SkyExposure, exposure);

			if (albedoTex != null)
			{
				properties.SetTexture(_SGT_SkyAlbedoTex, albedoTex);
			}

			properties.SetVector(_SGT_SkyMieWeight, (Vector3)MieWeight);
			properties.SetVector(_SGT_SkyMieData, new Vector4(mieAsymmetry, mieAsymmetry2, 0.0f, 0.0f));

			// Write lights and shadows
			var mask   = 1 << gameObject.layer;
			var lights = SgtLight.Find(mask, transform.position);

			CwHelper.SetTempMaterial(properties);

			SgtShadow.Find(true, mask, lights);
			SgtShadow.FilterOutSphere(transform.position);
			SgtShadow.WriteSphere(SgtShadow.MAX_SPHERE_SHADOWS);
			SgtShadow.WriteRing(SgtShadow.MAX_RING_SHADOWS);

			SgtLight.FilterOut(transform.position);
			SgtLight.Write(transform.position, CwHelper.UniformScale(model.transform.lossyScale) * InnerMeshRadius, null, null, SgtLight.MAX_LIGHTS);

			if (lights.Count > 0)
			{
				var position  = default(Vector3);
				var intensity = default(float);
				var light0    = lights[0];

				SgtLight.Calculate(light0, Vector3.zero, innerMeshRadius, null, null, ref position, ref lightDirection, ref lightColor, ref intensity);
			}
		}

		public void UpdateSkyLut()
		{
			if (jobRunning == true)
			{
				if (jobHandle.IsCompleted == true)
				{
					CompleteAndApply();
				}
				else
				{
					return;
				}
			}

			var lutSize = new int3(128, 32, 64);

			if (transmittanceLut == null)
			{
				transmittanceLut = new Texture2D(256, 128, TextureFormat.RGBAFloat, false);
				transmittanceLut.wrapMode = TextureWrapMode.Clamp;

				lutDirty = true;
			}

			if (lightingLut == null)
			{
				lightingLut = new Texture2D(transmittanceLut.width, transmittanceLut.height, TextureFormat.RGBAFloat, false);
				lightingLut.wrapMode = TextureWrapMode.Clamp;

				lutDirty = true;
			}

			if (radianceLut == null)
			{
				radianceLut = new Texture3D(lutSize.x, lutSize.y, lutSize.z, TextureFormat.RGBAFloat, 4);
				radianceLut.wrapMode = TextureWrapMode.Clamp;

				lutDirty = true;
			}

			// Build lowest res lod immediately
			if (lutDirty == true)
			{
				jobStage  = 4;
				jobHandle = default(JobHandle);
				lutDirty  = false;

				ScheduleTransmittanceAndLighting(8);
				ScheduleRadiance(jobStage - 1, 8);

				CompleteAndApply();
			}

			// Schedule next LOD
			//if (jobRunning == false && jobProgress < lutSize.x / 2)
			if (jobStage > 0)
			{
				jobHandle = default(JobHandle);

				ScheduleRadiance(jobStage - 1, 4);
			}
		}

		private void CompleteAndApply()
		{
			jobHandle.Complete();

			jobRunning = false;

			jobStage -= 1;
			
			if (jobStage == 3)
			{
				lightingLut.Apply(false);
			}

			radianceLut.Apply(false);
		}

		private static int3 GetMipSize(int3 baseSize, int mipIndex)
		{
			var x = math.max(1, baseSize.x >> mipIndex);
			var y = math.max(1, baseSize.y >> mipIndex);
			var z = math.max(1, baseSize.z >> mipIndex);

			return new int3(x, y, z);
		}

		private void ScheduleTransmittanceAndLighting(int batches)
		{
			var transmittanceJob = new TransmittanceJob();

			transmittanceJob.PlanetRadius     = innerMeshRadius;
			transmittanceJob.AtmosphereHeight = height;
			transmittanceJob.AltitudeScale    = (innerMeshRadius + height) / height;
			transmittanceJob.Density          = density;
			transmittanceJob.Size             = new int2(transmittanceLut.width, transmittanceLut.height);
			transmittanceJob.Data             = transmittanceLut.GetPixelData<float4>(0);

			transmittanceJob.Rayleigh.Height = height * rayleighHeight;
			transmittanceJob.Rayleigh.Color  = rayleighMultiplier * new double3(rayleighColor.r, rayleighColor.g, rayleighColor.b);
			transmittanceJob.Rayleigh.Absorb = 0.0;

			transmittanceJob.Mie.Height = height * mieHeight;
			transmittanceJob.Mie.Color  = mieMultiplier * new double3(1.0, 1.0, 1.0);
			transmittanceJob.Mie.Absorb = mieAbsorb;

			transmittanceJob.Ozone.Height    = height * ozoneHeight;
			transmittanceJob.Ozone.Thickness = height * ozoneThickness;
			transmittanceJob.Ozone.Color     = ozoneMultiplier * new double3(ozoneColor.r, ozoneColor.g, ozoneColor.b);

			jobHandle = transmittanceJob.Schedule(transmittanceLut.width * transmittanceLut.height, transmittanceLut.width * transmittanceLut.height / batches, jobHandle);

			var lightingJob = new LightingJob();

			lightingJob.Input  = transmittanceLut.GetPixelData<float4>(0);
			lightingJob.Size   = new int2(transmittanceLut.width, transmittanceLut.height);
			lightingJob.Blur   = (int)math.round(lightingLut.width * math.saturate(height / innerMeshRadius));
			lightingJob.Output = lightingLut.GetPixelData<float4>(0);

			jobHandle = lightingJob.Schedule(lightingLut.width * lightingLut.height, lightingLut.width * lightingLut.height / batches, jobHandle);
		}

		private void ScheduleRadiance(int mip, int batches)
		{
			var radianceJob = new RadianceJob();
			var mipSize     = GetMipSize(new int3(radianceLut.width, radianceLut.height, radianceLut.depth), mip);

			radianceJob.PlanetRadius     = innerMeshRadius;
			radianceJob.AtmosphereHeight = height;
			radianceJob.AltitudeScale    = (innerMeshRadius + height) / height;
			radianceJob.RayWeight        = 1.0f / rayleighHeight;
			radianceJob.RayColor         = (float3)(Vector3)(Vector4)rayleighColor * rayleighMultiplier;
			radianceJob.MieWeight        = 1.0f / mieHeight;
			radianceJob.MieColor         = 1.0f * mieMultiplier;
			radianceJob.Density          = density;
			radianceJob.Size             = mipSize;
			radianceJob.Pixels           = radianceLut.GetPixelData<float4>(mip);

			radianceJob.Rayleigh.Height = height * rayleighHeight;
			radianceJob.Rayleigh.Color  = rayleighMultiplier * new double3(rayleighColor.r, rayleighColor.g, rayleighColor.b);
			radianceJob.Rayleigh.Absorb = 0.0;

			radianceJob.Mie.Height = height * mieHeight;
			radianceJob.Mie.Color  = mieMultiplier * new double3(1.0, 1.0, 1.0);
			radianceJob.Mie.Absorb = mieAbsorb;

			radianceJob.Ozone.Height    = height * ozoneHeight;
			radianceJob.Ozone.Thickness = height * ozoneThickness;
			radianceJob.Ozone.Color     = ozoneMultiplier * new double3(ozoneColor.r, ozoneColor.g, ozoneColor.b);
			
			radianceJob.LutPixels = transmittanceLut.GetPixelData<float4>(0);
			radianceJob.LutSize   = new int2(transmittanceLut.width, transmittanceLut.height);

			jobHandle  = radianceJob.Schedule(mipSize.x * mipSize.y * mipSize.z, mipSize.x * mipSize.y * mipSize.z / batches, jobHandle);
			jobRunning = true;
		}

		protected virtual void OnEnable()
		{
			node = Instances.AddLast(this);

			CwHelper.OnCameraPreRender += HandleCameraPreRender;

			if (model == null)
			{
				model = SgtSkyModel.Create(this);
			}

			model.CachedMeshRenderer.enabled = true;

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			SgtLightOccluder.Register(this);
		}

		protected virtual void OnDisable()
		{
			SgtLightOccluder.Unregister(this);

			CwHelper.OnCameraPreRender -= HandleCameraPreRender;

			if (model != null)
			{
				model.CachedMeshRenderer.enabled = false;
			}

			if (jobRunning == true)
			{
				CompleteAndApply();
			}

			DestroyImmediate(transmittanceLut);
			DestroyImmediate(lightingLut);
			DestroyImmediate(radianceLut);

			Instances.Remove(node); node = null;
		}

		protected virtual void OnDestroy()
		{
			DestroyImmediate(blitMaterial);
		}

		protected virtual void OnDidApplyAnimationProperties()
		{
		}

		protected virtual void LateUpdate()
		{
			if (model != null)
			{
				model.CachedMeshFilter.sharedMesh = InvertedSphereMesh;
			}

			model.transform.localScale = Vector3.one * CwHelper.Divide(OuterRadius, 0.5f / sphereInflate);

			UpdateSkyLut();

			var finalCamera = Camera.main;

			if (material != null && finalCamera != null)
			{
				model.CachedMeshRenderer.sharedMaterial = material;

				model.CachedMeshRenderer.GetPropertyBlock(properties);

				ApplySettings(properties, finalCamera);

				model.CachedMeshRenderer.SetPropertyBlock(properties);
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			if (isActiveAndEnabled == true)
			{
				Gizmos.matrix = transform.localToWorldMatrix;

				var r1 = innerMeshRadius;
				var r2 = OuterRadius;

				Gizmos.DrawWireSphere(Vector3.zero, innerMeshRadius);
				Gizmos.DrawWireSphere(Vector3.zero, innerMeshRadius + height);
			}
		}
#endif
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.Sky
{
	[UnityEditor.CanEditMultipleObjects]
	[UnityEditor.CustomEditor(typeof(SgtSky))]
	public class SgtSky_Editor : CwEditor
	{
		private static float GetBoundsRadius(Bounds b)
		{
			var min = b.min;
			var max = b.max;
			var avg = Mathf.Abs(min.x) + Mathf.Abs(min.y) + Mathf.Abs(min.z) + Mathf.Abs(max.x) + Mathf.Abs(max.y) + Mathf.Abs(max.z);

			return avg / 6.0f;
		}

		protected override void OnInspector()
		{
			SgtSky tgt; SgtSky[] tgts; GetTargets(out tgt, out tgts);

			var markLutDirty = false;

			BeginError(Any(tgts, t => t.Material == null));
				Draw("material", "The material used to render this component.\n\nNOTE: This material must use the <b>Space Graphics Toolkit/Sky</b> shader. You cannot use a normal shader.");
			EndError();
			Draw("color", "The color tint of the sky.");
			Draw("brightness", "The <b>Color.rgb</b> values will be multiplied by this.");

			Separator();

			BeginError(Any(tgts, t => t.InnerMeshRadius <= 0.0f));
				Draw("innerMeshRadius", ref markLutDirty, "The radius of the meshes set in the SgtSharedMaterial.");
			EndError();

			Separator();

			BeginError(Any(tgts, t => t.Height <= 0.0f));
				Draw("height", ref markLutDirty, "This allows you to set how high the atmosphere extends above the surface of the planet in local space.");
			EndError();
			BeginError(Any(tgts, t => t.Density <= 0.0f));
				Draw("density", ref markLutDirty, "This allows you to adjust the fog level of the atmosphere.");
			EndError();
			Draw("cameraOffset", "This allows you to offset the camera distance in world space when rendering the atmosphere, giving you fine control over the render order."); // Updated automatically
			Draw("depthOpaque", "This allows you to control how fast the opacity of the sky increases as the camera descends."); // Updated automatically

			Separator();

			Draw("rayleighColor", ref markLutDirty, "The Rayleigh scattering color.");
			Draw("rayleighMultiplier", ref markLutDirty, "The Rayleigh scattering color is multiplied by this.");
			Draw("rayleighHeight", ref markLutDirty, "The 0..1 altitude where Rayleigh scattering dominates.");

			Separator();

			Draw("mieAbsorb", ref markLutDirty, "The Mie absorption.");
			Draw("mieMultiplier", ref markLutDirty, "The Mie scattering color is multiplied by this.");
			Draw("mieHeight", ref markLutDirty, "The 0..1 altitude where Mie scattering dominates.");
			Draw("mieAsymmetry", "The Mie scattering asymmetry factor.");
			Draw("mieAsymmetry2", "The secondary Mie scattering asymmetry factor for the sun.");

			Separator();

			Draw("ozoneColor", ref markLutDirty, "The ozone absorption color.");
			Draw("ozoneMultiplier", ref markLutDirty, "The ozone absorption color is multiplied by this.");
			Draw("ozoneHeight", ref markLutDirty, "The 0..1 altitude where ozone absorption dominates.");
			Draw("ozoneThickness", ref markLutDirty, "The 0..1 thickness ozone absorption dominates.");

			Separator();

			Draw("albedoTex", "The albedo texture applied to the sky.\n\nNOTE: This requires <b>Material</b> to have the <b>ALBEDO</b> setting enabled.");
			Draw("exposure", "The brightness applied before tone mapping.");

			//Separator();
			//UnityEditor.EditorGUILayout.ObjectField(tgt.LightingLut, typeof(Texture2D), true);
			//UnityEditor.EditorGUILayout.ObjectField(tgt.RadianceLut, typeof(Texture3D), true);

			Separator();

			if (Button("Randomize Rayleigh Hue") == true)
			{
				Each(tgts, t => t.RandomizeRayleighHue(), true, true);
			}

			if (markLutDirty == true)
			{
				Each(tgts, t => t.MarkLutDirty());
			}

			SgtVolumeCamera_Editor.Require();
			SgtVolumeManager_Editor.Require();
		}

		[UnityEditor.MenuItem("GameObject/CW/Space Graphics Toolkit/Sky", false, 10)]
		public static void CreateMenuItem()
		{
			var parent   = CwHelper.GetSelectedParent();
			var instance = SgtSky.Create(parent != null ? parent.gameObject.layer : 0, parent);

			CwHelper.SelectAndPing(instance);
		}
	}
}
#endif