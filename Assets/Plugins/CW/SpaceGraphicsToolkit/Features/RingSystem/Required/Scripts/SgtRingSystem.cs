using System.Collections.Generic;
using UnityEngine;
using Unity.Collections;
using Unity.Mathematics;
using CW.Common;
using SpaceGraphicsToolkit.Volumetrics;
using SpaceGraphicsToolkit.LightAndShadow;

namespace SpaceGraphicsToolkit.RingSystem
{
	/// <summary>This component allows you to render a volumetric planetary ring system.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Ring System")]
	public class SgtRingSystem : MonoBehaviour, SgtLightOccluder.IOccluder
	{
		/// <summary>The material used to render this component.
		/// NOTE: This material must use the <b>Space Graphics Toolkit/Ring</b> shader. You cannot use a normal shader.</summary>
		public Material SourceMaterial { set { if (sourceMaterial != value) { sourceMaterial = value; } } get { return sourceMaterial; } } [SerializeField] private Material sourceMaterial;

		/// <summary>This allows you to set the overall color of the ring.</summary>
		public Color Color { set { color = value; } get { return color; } } [SerializeField] private Color color = Color.white;

		/// <summary>The <b>Color.rgb</b> values will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 1.0f;

		/// <summary>The texture used to render the rings.
		/// RGB = Color, A = Density.
		/// NOTE: This texture should be horizontal, like 256x1 pixels.
		/// NOTE: If you enable the <b>Bands</b> setting, then this will be ignored.</summary>
		public Texture MainTex { set { mainTex = value; } get { return mainTex; } } [SerializeField] private Texture mainTex;

		/// <summary>The texture used to define the right thickness.
		/// R = Thickness.
		/// NOTE: This texture should be horizontal, like 256x1 pixels.
		/// NOTE: If you enable the <b>Bands</b> setting, then this will be ignored.</summary>
		public Texture ThicknessTex { set { thicknessTex = value; } get { return thicknessTex; } } [SerializeField] private Texture thicknessTex;

		/// <summary>The radius of the inner edge of the ring in local space.</summary>
		public float RadiusInner { set { radiusInner = value; } get { return radiusInner; } } [SerializeField] private float radiusInner = 110.0f;

		/// <summary>The radius of the outer edge of the ring in local space.</summary>
		public float RadiusOuter { set { radiusOuter = value; } get { return radiusOuter; } } [SerializeField] private float radiusOuter = 200.0f;

		/// <summary>The thickness of the ring in local space.</summary>
		public float Thickness { set { thickness = value; } get { return thickness; } } [SerializeField] private float thickness = 0.5f;

		/// <summary>The maximum density of the rings. The <b>MainTex</b> alpha channel is also used to control this.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 0.5f;

		/// <summary>The <b>SgtLightOccluder</b>'s calculated occlusion value will be multiplied by this.</summary>
		public float Occlusion { set { occlusion = value; } get { return occlusion; } } [SerializeField] private float occlusion = 1.0f;

		/// <summary>The higher you set this, the more densely packed the horizontal plane of the ring will be.</summary>
		public float Weight { set { weight = value; } get { return weight; } } [SerializeField] [Range(0.0f, 2.0f)] private float weight = 1.0f;

		/// <summary>This allows you to control how much the <b>Thickness</b> value can be squashed by the <b>ThicknessTex</b>.
		/// For example, if you set squash to 0.9, then <b>Thickness</b> can be squashed by up to 90% in areas where the <b>ThicknessTex</b> is at the maximum value.</summary>
		public float Squash { set { squash = value; } get { return squash; } } [SerializeField] [Range(0.0f, 1.0f)] private float squash = 0.5f;

		/// <summary>The detail of the ray marching. If you notice grain/noise in the rings, then increase this until it's almost gone.</summary>
		public float Detail { set { detail = value; } get { return detail; } } [SerializeField] [Range(0.0f, 1.0f)] private float detail = 0.0f;

		/// <summary>If your ring is extremely wide and thin, then rendering of the mesh will break. To fix this, you must set this to be larger than <b>Thickness</b>.
		/// For example, in my testing with a Saturn sized ring 213,000km outer radius with 1km thickness, a <b>MeshThickness</b> of around 10km (10,000) is necessary.</summary>
		public float MeshThickness { set { meshThickness = value; } get { return meshThickness; } } [SerializeField] private float meshThickness = -1.0f;

		/// <summary>Generate the ring texture?</summary>
		public bool Bands { set { bands = value; } get { return bands; } } [SerializeField] private bool bands;

		/// <summary>The ring texture will be based on this texture.</summary>
		public Texture2D BandsTex { set { bandsTex = value; } get { return bandsTex; } } [SerializeField] private Texture2D bandsTex;

		/// <summary>The width of the generated texture.</summary>
		public int BandsResolution { set { bandsResolution = value; } get { return bandsResolution; } } [SerializeField] private int bandsResolution = 64;

		/// <summary>The starting UV for the inside of the ring.</summary>
		public Vector2 BandsVariation { set { bandsVariation = value; } get { return bandsVariation; } } [SerializeField] private Vector2 bandsVariation;

		/// <summary>The change in UV toward the outside of the ring.</summary>
		public Vector2 BandsRange { set { bandsRange = value; } get { return bandsRange; } } [SerializeField] private Vector2 bandsRange = new Vector2(1.0f, 1.0f);

		/// <summary>The <b>BandsRange</b> setting will be multiplied by this.</summary>
		public float BandsScale { set { bandsScale = value; } get { return bandsScale; } } [SerializeField] private float bandsScale = 1.0f;

		/// <summary>The opacity of the bands will be based on the <b>BandsVariation</b> plus this.</summary>
		public Vector2 BandsOpacityOffset { set { bandsOpacityOffset = value; } get { return bandsOpacityOffset; } } [SerializeField] private Vector2 bandsOpacityOffset = new Vector2(0.0f, 0.0f);

		/// <summary>The opacity of the bands will be based on the <b>BandsRange</b> multiplied by this.</summary>
		public Vector2 BandsOpacityScale { set { bandsOpacityScale = value; } get { return bandsOpacityScale; } } [SerializeField] private Vector2 bandsOpacityScale = new Vector2(1.0f, 1.0f);

		/// <summary>Apply the generated texture to the <b>SgtShadowRing</b> component?</summary>
		public bool BandsOpacityShadow { set { bandsOpacityShadow = value; } get { return bandsOpacityShadow; } } [SerializeField] private bool bandsOpacityShadow;

		/// <summary>The resolution of the shadow texture.</summary>
		public int BandsOpacityShadowResolution { set { bandsOpacityShadowResolution = value; } get { return bandsOpacityShadowResolution; } } [SerializeField] private int bandsOpacityShadowResolution = 64;

		/// <summary>The amount of blur steps applied to the shadow.</summary>
		public int BandsOpacityShadowBlur { set { bandsOpacityShadowBlur = value; } get { return bandsOpacityShadowBlur; } } [SerializeField] private int bandsOpacityShadowBlur = 2;

		/// <summary>The shadow opacity.</summary>
		public float BandsOpacityShadowOpacity { set { bandsOpacityShadowOpacity = value; } get { return bandsOpacityShadowOpacity; } } [SerializeField] [Range(0.0f, 1.0f)] private float bandsOpacityShadowOpacity = 1.0f;

		/// <summary>Enable lighting?</summary>
		public bool Lighting { set { lighting = value; } get { return lighting; } } [SerializeField] private bool lighting;

		/// <summary>The size of each atmospheric scattering halo, where higher values make the halo smaller. Use negative values for back scattering.</summary>
		public Vector4 ScatteringTerms { set { scatteringTerms = value; } get { return scatteringTerms; } } [SerializeField] private Vector4 scatteringTerms = new Vector4(500.0f, 100.0f, 2.0f, -2.0f);

		/// <summary>The strength of each atmospheric scattering halo layer.</summary>
		public Vector4 ScatteringPower { set { scatteringPower = value; } get { return scatteringPower; } } [SerializeField] private Vector4 scatteringPower = new Vector4(0.5f, 0.25f, 0.25f, 0.1f);

		[System.NonSerialized]
		private MaterialPropertyBlock properties;

		[SerializeField] private Mesh         foregroundMesh;
		[SerializeField] private GameObject   foregroundGameObject;
		[SerializeField] private MeshFilter   foregroundMeshFilter;
		[SerializeField] private MeshRenderer foregroundMeshRenderer;

		[SerializeField] private Mesh         backgroundMesh;
		[SerializeField] private GameObject   backgroundGameObject;
		[SerializeField] private MeshFilter   backgroundMeshFilter;
		[SerializeField] private MeshRenderer backgroundMeshRenderer;

		private static List<Vector3> positions = new List<Vector3>();
		private static List<Vector2> coords    = new List<Vector2>();
		private static List<int>     indices   = new List<int>();
		private static List<float>   angles    = new List<float>();

		private static readonly int SEGMENT_COUNT = 33;

		private static int _SGT_Object2World     = Shader.PropertyToID("_SGT_Object2World");
		private static int _SGT_World2Object     = Shader.PropertyToID("_SGT_World2Object");
		private static int _SGT_BlueNoiseTex     = Shader.PropertyToID("_SGT_BlueNoiseTex");
		private static int _SGT_Color            = Shader.PropertyToID("_SGT_Color");
		private static int _SGT_Brightness       = Shader.PropertyToID("_SGT_Brightness");
		private static int _SGT_RingSize         = Shader.PropertyToID("_SGT_RingSize");
		private static int _SGT_RingData         = Shader.PropertyToID("_SGT_RingData");
		private static int _SGT_RingMainTex      = Shader.PropertyToID("_SGT_RingMainTex");
		private static int _SGT_RingThicknessTex = Shader.PropertyToID("_SGT_RingThicknessTex");
		private static int _SGT_Side             = Shader.PropertyToID("_SGT_Side");
		private static int _SGT_Detail           = Shader.PropertyToID("_SGT_Detail");
		private static int _SGT_Frame            = Shader.PropertyToID("_SGT_Frame");
		private static int _SGT_ScatteringTerms  = Shader.PropertyToID("_SGT_ScatteringTerms");
		private static int _SGT_ScatteringPower  = Shader.PropertyToID("_SGT_ScatteringPower");

		[System.NonSerialized]
		private Texture2D generatedMainTexture;

		[System.NonSerialized]
		private Texture2D generatedShadowTexture;

		[System.NonSerialized]
		private NativeArray<float> generatedAlphaData;

		[System.NonSerialized]
		private NativeArray<float> generatedThicknessData;

		[System.NonSerialized]
		private bool dirty;

		public NativeArray<float> AlphaData
		{
			get
			{
				return generatedAlphaData;
			}
		}

		public NativeArray<float> ThicknessData
		{
			get
			{
				return generatedThicknessData;
			}
		}

		public void MarkAsDirty()
		{
			dirty = true;
		}

		private static float Sample1D(NativeArray<float> data, float u)
		{
			if (data.IsCreated == false)
			{
				return 1.0f;
			}

			var c = data.Length; if (c == 0) return 0.0f;
			var x = math.clamp(u, 0.0f, 1.0f) * (c - 1);
			var a = (int)math.floor(x);
			var b = math.min(a + 1, c - 1);

			return math.lerp(data[a], data[b], x - a);
		}

		public float GetWorldDensity(Vector3 worldPosition)
		{
			var opos = transform.InverseTransformPoint(worldPosition);

			return GetLocalDensity(opos);
		}

		public float GetLocalDensity(float3 opos)
		{
			var RingSize_x = radiusInner;
			var RingSize_y = radiusOuter - radiusInner;
			var RingSize_z = thickness * 0.5f;
			var RingSize_w = radiusOuter;
			var RingData_y = weight;
			var RingData_z = squash;
			var RingData_w = 1.0f - squash;

			var distance01 = (math.length(opos.xz) - RingSize_x) / RingSize_y;

			if (distance01 > 0.0f && distance01 < 1.0f)
			{
				var thickness = RingSize_z * (RingData_w + RingData_z * Sample1D(ThicknessData, distance01));

				if (thickness > 0.0f)
				{
					var alpha = Sample1D(AlphaData, distance01);

					alpha *= math.pow(1.0f - math.saturate(math.abs(opos.y) / thickness), RingData_y);

					return alpha;
				}
			}

			return 0.0f;
		}

		public void ApplyRingSettings(MaterialPropertyBlock properties, bool light, bool shadow)
		{
			properties.SetVector(_SGT_RingSize, new Vector4(radiusInner, radiusOuter - radiusInner, thickness * 0.5f, radiusOuter));
			properties.SetVector(_SGT_RingData, new Vector4(density, weight, squash, 1.0f - squash));

			if (bands == true && generatedMainTexture != null)
			{
				properties.SetTexture(_SGT_RingMainTex, generatedMainTexture);
			}
			else if (mainTex != null)
			{
				properties.SetTexture(_SGT_RingMainTex, mainTex);
			}

			if (thicknessTex != null)
			{
				properties.SetTexture(_SGT_RingThicknessTex, thicknessTex);
			}
			else
			{
				properties.SetTexture(_SGT_RingThicknessTex, Texture2D.whiteTexture);
			}

			if (lighting == true)
			{
				CwHelper.SetTempMaterial(properties);

				var mask   = 1 << gameObject.layer;
				var lights = SgtLight.Find(mask, transform.position);

				if (shadow == true)
				{
					SgtShadow.Find(true, mask, lights);
					SgtShadow.FilterOutRing(transform.position);
					SgtShadow.WriteSphere(SgtShadow.MAX_SPHERE_SHADOWS);
					SgtShadow.WriteRing(SgtShadow.MAX_RING_SHADOWS);
				}

				if (light == true)
				{
					SgtLight.FilterOut(transform.position);
					SgtLight.Write(transform.position, CwHelper.UniformScale(transform.lossyScale) * radiusOuter, transform, null, SgtLight.MAX_LIGHTS);
				}
			}
		}

		public static SgtRingSystem Create(int layer = 0, Transform parent = null)
		{
			return Create(layer, parent, Vector3.zero, Quaternion.identity, Vector3.one);
		}

		public static SgtRingSystem Create(int layer, Transform parent, Vector3 localPosition, Quaternion localRotation, Vector3 localScale)
		{
			return CwHelper.CreateGameObject("Rings", layer, parent, localPosition, localRotation, localScale).AddComponent<SgtRingSystem>();
		}

		public float CalculateOcclusion(int layers, Vector3 worldEye, Vector3 worldTgt)
		{
			var localEye = transform.InverseTransformPoint(worldEye);
			var localTgt = transform.InverseTransformPoint(worldTgt);
			var localDir = localTgt - localEye;

			if (localDir.y == 0.0f)
			{
				return 0.0f;
			}

			var t0   = (thickness * -0.5f - localEye.y) / localDir.y;
			var t1   = (thickness *  0.5f - localEye.y) / localDir.y;
			var near = Mathf.Max(0.0f, Mathf.Min(t0, t1));
			var far  = Mathf.Max(0.0f, Mathf.Max(t0, t1));
			var mid  = (near + far) * 0.5f;

			if (far <= near)
			{
				return 0.0f;
			}

			return GetLocalDensity(localEye + localDir * mid) * occlusion;
		}

		protected virtual void OnEnable()
		{
			CheckChild(ref foregroundGameObject, ref foregroundMeshFilter, ref foregroundMeshRenderer);
			CheckChild(ref backgroundGameObject, ref backgroundMeshFilter, ref backgroundMeshRenderer);

			if (properties == null)
			{
				properties = new MaterialPropertyBlock();
			}

			SgtLightOccluder.Register(this);

			Update();
			UpdateAlphaData();
			UpdateThicknessData();
		}

		protected virtual void OnDisable()
		{
			SgtLightOccluder.Unregister(this);

			if (generatedAlphaData.IsCreated == true)
			{
				generatedAlphaData.Dispose();
			}

			if (generatedThicknessData.IsCreated == true)
			{
				generatedThicknessData.Dispose();
			}
		}

		protected virtual void Update()
		{
			if (Camera.main == null)
			{
				return;
			}

			UpdateBands();

			if (bands == true && bandsOpacityShadow == true && generatedShadowTexture != null)
			{
				var shadowRing = GetComponent<SgtShadowRing>();

				if (shadowRing != null)
				{
					shadowRing.RadiusMin = radiusInner;
					shadowRing.RadiusMax = radiusOuter;
					shadowRing.Texture   = generatedShadowTexture;
				}
			}
		}

		protected virtual void LateUpdate()
		{
			UpdateMeshes(Camera.main.transform.position);
		}

		private void UpdateAlphaData()
		{
			if (generatedMainTexture != null)
			{
				UpdateData(ref generatedAlphaData, generatedMainTexture);
			}
			else
			{
				UpdateData(ref generatedAlphaData, mainTex);
			}
		}

		private void UpdateThicknessData()
		{
			UpdateData(ref generatedThicknessData, thicknessTex);
		}

		private void UpdateData(ref NativeArray<float> data, Texture tex)
		{
			if (tex != null && tex.isReadable == true)
			{
				var tex2D = tex as Texture2D;

				if (tex2D != null)
				{
					if (data.IsCreated == true && data.Length != tex2D.width)
					{
						data.Dispose();
					}

					if (data.IsCreated == false)
					{
						data = new NativeArray<float>(tex2D.width, Allocator.Persistent);
					}

					var channel = 3;

					if (tex2D.format == TextureFormat.R8 || tex2D.format == TextureFormat.R16 || tex2D.format == TextureFormat.RFloat || tex2D.format == TextureFormat.RHalf || tex2D.format == TextureFormat.BC4)
					{
						channel = 0;
					}

					for (var i = 0; i < tex2D.width; i++)
					{
						data[i] = tex2D.GetPixel(i, 0)[channel];
					}
				}
			}

			if (data.IsCreated == false)
			{
				data = new NativeArray<float>(0, Allocator.Persistent);
			}
		}

		private void UpdateBands()
		{
			if (bands == true && bandsResolution > 0 && bandsTex != null && bandsTex.isReadable == true)
			{
				if (generatedMainTexture == null)
				{
					generatedMainTexture = new Texture2D(bandsResolution, 1, TextureFormat.RGBA32, false, false);

					generatedMainTexture.name     = "SgtRingSystem Generated MainTex";
					generatedMainTexture.wrapMode = TextureWrapMode.Clamp;

					dirty = true;
				}
				else if (generatedMainTexture.width != bandsResolution)
				{
					generatedMainTexture.Reinitialize(bandsResolution, 1);

					dirty = true;
				}

				if (dirty == true)
				{
					WriteMainBands(generatedMainTexture.GetPixelData<Color32>(0));

					generatedMainTexture.Apply();

					UpdateAlphaData();
				}
			}
			else if (generatedMainTexture != null)
			{
				DestroyImmediate(generatedMainTexture);

				generatedMainTexture = null;
			}

			if (bands == true && generatedMainTexture != null)
			{
				if (generatedShadowTexture == null)
				{
					generatedShadowTexture = new Texture2D(bandsOpacityShadowResolution, 1, TextureFormat.RGBA32, false, false);

					generatedShadowTexture.name     = "SgtRingSystem Generated ShadowTex";
					generatedShadowTexture.wrapMode = TextureWrapMode.Clamp;

					dirty = true;
				}
				else if (generatedShadowTexture.width != bandsOpacityShadowResolution)
				{
					generatedShadowTexture.Reinitialize(bandsOpacityShadowResolution, 1);

					dirty = true;
				}

				if (dirty == true)
				{
					WriteShadowBands(generatedShadowTexture.GetPixelData<Color32>(0), generatedMainTexture.GetPixelData<Color32>(0));

					generatedShadowTexture.Apply();
				}
			}
			else if (generatedShadowTexture != null)
			{
				DestroyImmediate(generatedShadowTexture);

				generatedShadowTexture = null;
			}

			dirty = false;
		}

		private void WriteMainBands(NativeArray<Color32> data)
		{
			var coordA = bandsVariation;
			var coordB = coordA + bandsRange * bandsScale;
			var coordC = bandsVariation + new Vector2(bandsOpacityOffset.x, bandsOpacityOffset.y);
			var coordD = coordC + bandsRange * bandsScale * new Vector2(bandsOpacityScale.x, bandsOpacityScale.y);
			var coordS = 1.0f / (data.Length + 1);

			for (var i = 0; i < data.Length; i++)
			{
				var t = i * coordS;
				var c = Vector2.Lerp(coordA, coordB, t);
				var a = Vector2.Lerp(coordC, coordD, t);

				var sampleC = SamplePointWrapped(bandsTex, c);
				var sampleA = SamplePointWrapped(bandsTex, a);

				data[i] = new Color(sampleC.r, sampleC.g, sampleC.b, sampleA.grayscale);
			}

			var dataA = data[1              ];
			var dataB = data[data.Length - 2];

			dataA.a = 0;
			dataB.a = 0;

			data[0              ] = dataA;
			data[data.Length - 1] = dataB;
		}

		private void WriteShadowBands(NativeArray<Color32> data, NativeArray<Color32> main)
		{
			var dataWidth = data.Length;
			var mainWidth = main.Length;

			for (int x = 0; x < dataWidth; x++)
			{
				var srcX = (int)((float)x / dataWidth * mainWidth);

				if (srcX >= mainWidth) srcX = mainWidth - 1;

				data[x] = Color.white - ((Color)main[srcX] * bandsOpacityShadowOpacity);

				//data[x] = new Color32(data[x].a, data[x].a, data[x].a, data[x].a);
			}

			if (bandsOpacityShadowBlur > 0)
			{
				var temp = new NativeArray<Color32>(dataWidth, Allocator.Temp);

				for (var x = 0; x < dataWidth; x++)
				{
					var total = Color.clear;
					var count = 0;
					var minX  = x - bandsOpacityShadowBlur;
					var maxX  = x + bandsOpacityShadowBlur;

					for (var i = minX; i <= maxX; i++)
					{
						if (i >= 1 && i < dataWidth - 1)
						{
							total += data[i];
						}
						else
						{
							total += Color.white;
						}

						count++;
					}

					temp[x] = total / count;
				}

				for (var i = 0; i < dataWidth; i++)
				{
					data[i] = temp[i];
				}

				temp.Dispose();
			}

			data[0              ] = Color.white;
			data[data.Length - 1] = Color.white;
		}

		private static Color SamplePointWrapped(Texture2D texture, Vector2 uv)
		{
			uv.x = uv.x - Mathf.Floor(uv.x);
			uv.y = uv.y - Mathf.Floor(uv.y);

			var x = Mathf.FloorToInt(uv.x * texture.width );
			var y = Mathf.FloorToInt(uv.y * texture.height);

			x = Mathf.Clamp(x, 0, texture.width  - 1);
			y = Mathf.Clamp(y, 0, texture.height - 1);

			return texture.GetPixel(x, y);
		}

		private void CheckChild(ref GameObject childGameObject, ref MeshFilter childMeshFilter, ref MeshRenderer childMeshRenderer)
		{
			if (childGameObject == null)
			{
				childGameObject = new GameObject("SgtRingSystem TempChild");

				childGameObject.layer = gameObject.layer;

				childGameObject.hideFlags = HideFlags.DontSave;

				childGameObject.transform.SetParent(transform, false);
			}

			if (childMeshFilter == null)
			{
				if (childGameObject.TryGetComponent(out childMeshFilter) == false)
				{
					childMeshFilter = childGameObject.AddComponent<MeshFilter>();
				}
			}

			if (childMeshRenderer == null)
			{
				if (childGameObject.TryGetComponent(out childMeshRenderer) == false)
				{
					childMeshRenderer = childGameObject.AddComponent<MeshRenderer>();

					childMeshRenderer.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
				}
			}
		}

		protected virtual void OnDestroy()
		{
			if (foregroundMesh != null)
			{
				foregroundMesh.Clear(false);

				DestroyImmediate(foregroundMesh);
			}

			if (backgroundMesh != null)
			{
				backgroundMesh.Clear(false);

				DestroyImmediate(backgroundMesh);
			}

			//if (blitMaterial != null)
			//{
			//	DestroyImmediate(blitMaterial);
			//}

			if (generatedMainTexture != null)
			{
				DestroyImmediate(generatedMainTexture);

				generatedMainTexture = null;
			}
		}

		private void UpdateMeshes(Vector3 eye)
		{
			var view      = transform.InverseTransformPoint(eye); view.y = 0.0f;
			var bearing   = (float)Mathf.Atan2(view.x, view.z) * Mathf.Rad2Deg;
			var distance  = Vector3.Magnitude(view);
			var radiusMin = (double)radiusInner;
			var radiusMax = (double)radiusOuter;

			radiusMax /= Mathf.Cos(Mathf.PI / SEGMENT_COUNT);

			var visibleRadians = distance > 0.0 ? Mathf.Acos(radiusInner / distance) : Mathf.PI;
			var visibleDegrees = Mathf.Rad2Deg * Mathf.Max(visibleRadians, 0.1f);
			var inverseDegrees = 360.0f - visibleDegrees;
			var viewDist       = view.magnitude;
			var sortDistance   = -1.0f;

			if (viewDist < radiusMin)
			{
				sortDistance = (float)(radiusMin + radiusMax);
			}

			UpdateMesh(ref foregroundMesh, (float)radiusMin, (float)radiusMax, (bearing - visibleDegrees) * Mathf.Deg2Rad, (bearing + visibleDegrees) * Mathf.Deg2Rad, Mathf.CeilToInt(visibleDegrees / 180.0f * SEGMENT_COUNT), view, sortDistance);
			UpdateMesh(ref backgroundMesh, (float)radiusMin, (float)radiusMax, (bearing + visibleDegrees) * Mathf.Deg2Rad, (bearing + inverseDegrees) * Mathf.Deg2Rad, Mathf.CeilToInt(inverseDegrees / 360.0f * SEGMENT_COUNT), view, (float)radiusMax * 2);

			foregroundMeshFilter.sharedMesh = foregroundMesh;
			backgroundMeshFilter.sharedMesh = backgroundMesh;

			foregroundMeshRenderer.sharedMaterial = sourceMaterial;
			backgroundMeshRenderer.sharedMaterial = sourceMaterial;

			properties.SetVector(_SGT_Color, color);
			properties.SetFloat(_SGT_Brightness, brightness);
			properties.SetMatrix(_SGT_Object2World, transform.localToWorldMatrix);
			properties.SetMatrix(_SGT_World2Object, transform.worldToLocalMatrix);
			properties.SetTexture(_SGT_BlueNoiseTex, SgtVolumeManager.BlueNoiseTex);
			properties.SetFloat(_SGT_Frame, Time.frameCount);

			ApplyRingSettings(properties, true, true);

			if (lighting == true)
			{
				properties.SetVector(_SGT_ScatteringTerms, scatteringTerms);
				properties.SetVector(_SGT_ScatteringPower, scatteringPower);
			}

			properties.SetFloat(_SGT_Detail, Mathf.Lerp(1.0f, 0.001f, 1.0f - Mathf.Pow(1.0f - detail, 2.0f)));

			properties.SetFloat(_SGT_Side, 0.0f);
			foregroundMeshRenderer.SetPropertyBlock(properties);

			properties.SetFloat(_SGT_Side, 1.0f);
			backgroundMeshRenderer.SetPropertyBlock(properties);
		}

		private void UpdateMesh(ref Mesh mesh, float radiusMin, float radiusMax, float angleMin, float angleMax, int segments, Vector3 view, float distance)
		{
			if (mesh == null)
			{
				mesh = new Mesh();

				mesh.hideFlags = HideFlags.DontSaveInEditor | HideFlags.DontSaveInBuild;
			}
			else
			{
				mesh.Clear();
			}

			positions.Clear();
			coords.Clear();
			indices.Clear();
			angles.Clear();

			for (var i = 0; i <= segments; i++)
			{
				var frac  = i / (float)segments;
				var angle = Mathf.Lerp(angleMin, angleMax, frac);

				angles.Add(angle);
			}

			var finalThickness = meshThickness > 0.0f ? meshThickness : thickness;

			for (var i = 0; i <= segments; i++)
			{
				var angle = angles[i];
				var u     = angle / (Mathf.PI * 2.0f);
				var sin   = Mathf.Sin(angle);
				var cos   = Mathf.Cos(angle);
				var inner = new Vector3(sin * radiusMin, 0.0f, cos * radiusMin);
				var outer = new Vector3(sin * radiusMax, 0.0f, cos * radiusMax);

				positions.Add(inner - Vector3.up * finalThickness * 0.5f); // Bottom
				positions.Add(outer - Vector3.up * finalThickness * 0.5f);
				positions.Add(inner + Vector3.up * finalThickness * 0.5f); // Top
				positions.Add(outer + Vector3.up * finalThickness * 0.5f);

				coords.Add(new Vector2(radiusMin, u * radiusMin));
				coords.Add(new Vector2(radiusMax, u * radiusMax));
				coords.Add(new Vector2(radiusMin, u * radiusMin));
				coords.Add(new Vector2(radiusMax, u * radiusMax));
			}

			// Build quads (2 triangles each) between segments

			for (var i = 0; i < segments; i++)
			{
				var baseIndex = i * 4;
				var nextIndex = (i + 1) * 4;

				// Bottom face
				indices.Add(baseIndex + 0); indices.Add(baseIndex + 1); indices.Add(nextIndex + 0); // Bottom
				indices.Add(nextIndex + 1); indices.Add(nextIndex + 0); indices.Add(baseIndex + 1);
				indices.Add(baseIndex + 2); indices.Add(nextIndex + 2); indices.Add(baseIndex + 3); // Top
				indices.Add(nextIndex + 3); indices.Add(baseIndex + 3); indices.Add(nextIndex + 2);
				indices.Add(baseIndex + 0); indices.Add(nextIndex + 0); indices.Add(baseIndex + 2); // Inner
				indices.Add(nextIndex + 2); indices.Add(baseIndex + 2); indices.Add(nextIndex + 0);
				indices.Add(baseIndex + 3); indices.Add(nextIndex + 3); indices.Add(baseIndex + 1); // Outer
				indices.Add(nextIndex + 1); indices.Add(baseIndex + 1); indices.Add(nextIndex + 3);
			}

			mesh.SetVertices(positions);
			mesh.SetUVs(0, coords);
			mesh.SetTriangles(indices, 0);
			mesh.RecalculateBounds();

			//if (split == true)
			{
				var angle = (angleMin + angleMax) * 0.5f;
				var sin   = Mathf.Sin(angle);
				var cos   = Mathf.Cos(angle);
				var rad   = radiusMax * 2.0f;
				var dist  = view.magnitude;

				var b = mesh.bounds;

				if (distance > 0.0f)
				{
					b.center = new Vector3(sin * distance, 0.0f, cos * distance);
				}
				//b.center = new Vector3(sin * rad, 0.0f, cos * rad);

				b.Expand(Vector3.one * radiusOuter * 4);

				mesh.bounds = b;
			}
		}
	}
}

#if UNITY_EDITOR
namespace SpaceGraphicsToolkit.RingSystem
{
	using UnityEditor;

	[CanEditMultipleObjects]
	[CustomEditor(typeof(SgtRingSystem))]
	public class SgtRingSystem_Editor : CW.Common.CwEditor
	{
		protected override void OnInspector()
		{
			SgtRingSystem tgt; SgtRingSystem[] tgts; GetTargets(out tgt, out tgts);

			var markAsDirty = false;

			BeginError(Any(tgts, t => t.SourceMaterial == null));
				Draw("sourceMaterial", "The material used to render this component.\n\nNOTE: This material must use the <b>Space Graphics Toolkit/Ring</b> shader. You cannot use a normal shader.");
			EndError();
			Draw("color", "This allows you to set the overall color of the ring.");
			Draw("brightness", "The <b>Color.rgb</b> values will be multiplied by this.");
			Draw("mainTex", "The texture used to render the rings.\n\nRGB = Color, A = Density.\n\nNOTE: This texture should be horizontal, like 256x1 pixels.\n\nNOTE: If you enable the <b>Bands</b> setting, then this will be ignored.");
			Draw("thicknessTex", "The texture used to define the right thickness.\n\nR = Thickness.\n\nNOTE: This texture should be horizontal, like 256x1 pixels.\n\nNOTE: If you enable the <b>Bands</b> setting, then this will be ignored.");

			Separator();

			Draw("radiusInner", "The radius of the inner edge of the ring in local space.");
			Draw("radiusOuter", "The radius of the outer edge of the ring in local space.");
			Draw("thickness", "The thickness of the ring in local space.");
			Draw("density", "The maximum density of the rings. The <b>MainTex</b> alpha channel is also used to control this.");
			Draw("occlusion", "The <b>SgtLightOccluder</b>'s calculated occlusion value will be multiplied by this.");
			Draw("weight", "The higher you set this, the more densely packed the horizontal plane of the ring will be.");
			Draw("squash", "This allows you to control how much the <b>Thickness</b> value can be squashed by the <b>ThicknessTex</b>.\n\nFor example, if you set squash to 0.9, then <b>Thickness</b> can be squashed by up to 90% in areas where the <b>ThicknessTex</b> is at the maximum value.");

			Separator();

			Draw("detail", "The detail of the ray marching. If you notice grain/noise in the rings, then increase this until it's almost gone.");
			Draw("meshThickness", "If your ring is extremely wide and thin, then rendering of the mesh will break. To fix this, you must set this to be larger than <b>Thickness</b>.\n\nFor example, in my testing with a Saturn sized ring (213,000km outer radius, 1km thickness), a <b>MeshThickness</b> of at least 10km (10,000) is necessary.");

			Separator();

			Draw("bands", ref markAsDirty, "Generate the ring texture?");

			if (Any(tgts, t => t.Bands == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.BandsTex == null));
						Draw("bandsTex", ref markAsDirty, "The ring texture will be based on this texture.", "Tex");
					EndError();
					BeginError(Any(tgts, t => t.BandsResolution <= 3));
						Draw("bandsResolution", ref markAsDirty, "The width of the generated texture.", "Resolution");
					EndError();
					DrawVector2Slider("bandsVariation", ref markAsDirty, "The starting UV for the inside of the ring.", 0.0f, 1.0f, "Variation");
					BeginError(Any(tgts, t => t.BandsRange == Vector2.zero));
						DrawVector2Slider("bandsRange", ref markAsDirty, "The <b>BandsRange</b> setting will be multiplied by this.", -1.0f, 1.0f, "Range");
					EndError();
					BeginError(Any(tgts, t => t.BandsScale == 0.0f));
						Draw("bandsScale", ref markAsDirty, "The <b>BandsRange</b> setting will be multiplied by this.", "Scale");
					EndError();
					DrawVector2Slider("bandsOpacityOffset", ref markAsDirty, "The opacity of the bands will be based on the <b>BandsVariation</b> plus this.", 0.0f, 1.0f, "Opacity Offset");
					DrawVector2Slider("bandsOpacityScale", ref markAsDirty, "The opacity of the bands will be based on the <b>BandsRange</b> plus this.", 0.0f, 1.0f, "Opacity Scale");
					Draw("bandsOpacityShadow", ref markAsDirty, "Apply the generated texture to the <b>SgtShadowRing</b> component?", "Opacity Shadow");
					if (Any(tgts, t => t.BandsOpacityShadow == true))
					{
						BeginIndent();
							Draw("bandsOpacityShadowResolution", ref markAsDirty, "The resolution of the shadow texture.", "Resolution");
							Draw("bandsOpacityShadowBlur", ref markAsDirty, "The amount of blur steps applied to the shadow.", "Blur");
							Draw("bandsOpacityShadowOpacity", ref markAsDirty, "The shadow opacity.", "Opacity");
						EndIndent();
					}
				EndIndent();
			}

			Separator();

			Draw("lighting", "Enable lighting?");

			if (Any(tgts, t => t.Lighting == true))
			{
				Separator();

				BeginDisabled();
					UnityEditor.EditorGUILayout.Toggle("Scattering", true);
				EndDisabled();
				BeginIndent();
					DrawVector4("scatteringTerms", "The size of each atmospheric scattering halo, where higher values make the halo smaller. Use negative values for back scattering.", "Terms");
					DrawVector4("scatteringPower", "The strength of each atmospheric scattering halo layer.", "Power");
				EndIndent();
			}

			Separator();

			if (Any(tgts, t => t.MainTex != null) && Button("Randomize MainTex") == true)
			{
				Each(tgts, t => { if (t.MainTex != null) t.MainTex = Randomize(t.MainTex); }, true); markAsDirty = true;
			}

			if (Any(tgts, t => t.Bands == true && t.BandsTex != null) && Button("Randomize BandsTex") == true)
			{
				Each(tgts, t => { if (t.BandsTex != null) t.BandsTex = Randomize(t.BandsTex); }, true); markAsDirty = true;
			}

			if (Any(tgts, t => t.Bands == true) && Button("Randomize Bands Variation") == true)
			{
				Each(tgts, t => t.BandsVariation = new Vector2(UnityEngine.Random.value, UnityEngine.Random.value), true); markAsDirty = true;
			}

			if (Any(tgts, t => t.Bands == true) && Button("Randomize Bands Range") == true)
			{
				Each(tgts, t => t.BandsRange = new Vector2(UnityEngine.Random.Range(-1.0f, 1.0f), UnityEngine.Random.Range(-1.0f, 1.0f)), true); markAsDirty = true;
			}

			if (Any(tgts, t => t.Bands == true) && Button("Randomize Bands Opacity Offset") == true)
			{
				Each(tgts, t => t.BandsOpacityOffset = new Vector2(UnityEngine.Random.value, UnityEngine.Random.value), true); markAsDirty = true;
			}

			if (Any(tgts, t => t.Bands == true) && Button("Randomize Bands Opacity Scale") == true)
			{
				Each(tgts, t => t.BandsOpacityScale = new Vector2(UnityEngine.Random.Range(0.0f, 1.0f), UnityEngine.Random.Range(0.0f, 1.0f)), true); markAsDirty = true;
			}

			if (markAsDirty == true)
			{
				Each(tgts, t => t.MarkAsDirty());
			}
		}

		private static T Randomize<T>(T current)
			where T : Texture
		{
			if (current != null)
			{
				var currentPath = UnityEditor.AssetDatabase.GetAssetPath(current);
				var guids       = UnityEditor.AssetDatabase.FindAssets("t:Texture", new string[] { System.IO.Path.GetDirectoryName(currentPath) });

				if (guids.Length > 0)
				{
					var guid = guids[UnityEngine.Random.Range(0, guids.Length)];
					var path = UnityEditor.AssetDatabase.GUIDToAssetPath(guid);
					var next = UnityEditor.AssetDatabase.LoadAssetAtPath<T>(path);

					if (next != null && current != next)
					{
						current = next;
					}
				}
			}

			return current;
		}

		private void DrawVector2Slider(string propertyName, ref bool markAsDirty, string tooltip, float min, float max, string text)
		{
			var property = serializedObject.FindProperty(propertyName);
			var xProp    = property.FindPropertyRelative("x");
			var yProp    = property.FindPropertyRelative("y");

			EditorGUI.BeginChangeCheck();

			Rect rect = EditorGUILayout.GetControlRect();

			// Reserve space for the label
			float labelWidth = EditorGUIUtility.labelWidth;
			Rect labelRect = new Rect(rect.x, rect.y, labelWidth, rect.height);
			EditorGUI.PrefixLabel(labelRect, new GUIContent(text, tooltip));

			// Remaining space for sliders
			float sliderSpacing = 4f;
			float sliderWidth = (rect.width - labelWidth - sliderSpacing) * 0.5f;
			Rect xSliderRect = new Rect(labelRect.xMax, rect.y, sliderWidth, rect.height);
			Rect ySliderRect = new Rect(xSliderRect.xMax + sliderSpacing, rect.y, sliderWidth, rect.height);

			xProp.floatValue = GUI.HorizontalSlider(xSliderRect, xProp.floatValue, min, max);
			yProp.floatValue = GUI.HorizontalSlider(ySliderRect, yProp.floatValue, min, max);

			markAsDirty |= EditorGUI.EndChangeCheck();
		}

		[MenuItem("GameObject/CW/Space Graphics Toolkit/Ring System", false, 10)]
		public static void CreateMenuItem()
		{
			var parent   = CwHelper.GetSelectedParent();
			var instance = SgtRingSystem.Create(parent != null ? parent.gameObject.layer : 0, parent);

			CwHelper.SelectAndPing(instance);
		}
	}
}
#endif