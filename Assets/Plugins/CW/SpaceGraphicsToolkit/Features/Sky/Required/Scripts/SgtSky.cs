using UnityEngine;
using CW.Common;
using SpaceGraphicsToolkit.LightAndShadow;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Volumetrics;

namespace SpaceGraphicsToolkit.Sky
{
	/// <summary>This component allows you to draw a volumetric atmosphere around a planet.</summary>
	[ExecuteInEditMode]
	[AddComponentMenu("Space Graphics Toolkit/SGT Sky")]
	public class SgtSky : SgtVolumeEffect, CwChild.IHasChildren, SgtLightOccluder.IOccluder
	{
		/// <summary>The material used to render this component.
		/// NOTE: This material must use the <b>Space Graphics Toolkit/Atmosphere</b> shader. You cannot use a normal shader.</summary>
		public Material SourceMaterial { set { if (sourceMaterial != value) { sourceMaterial = value; } } get { return sourceMaterial; } } [SerializeField] private Material sourceMaterial;

		/// <summary>This allows you to set the color of the atmosphere at high altitudes.</summary>
		public Color UpperColor { set { upperColor = value; } get { return upperColor; } } [SerializeField] private Color upperColor = Color.blue;

		/// <summary>This allows you to set the color of the atmosphere at low altitudes.</summary>
		public Color LowerColor { set { lowerColor = value; } get { return lowerColor; } } [SerializeField] private Color lowerColor = Color.white;

		/// <summary>The <b>Color.rgb</b> values will be multiplied by this.</summary>
		public float Brightness { set { brightness = value; } get { return brightness; } } [SerializeField] private float brightness = 1.0f;

		/// <summary>The radius of the meshes set in the SgtSharedMaterial.</summary>
		public float InnerMeshRadius { set { innerMeshRadius = value; } get { return innerMeshRadius; } } [SerializeField] private float innerMeshRadius = 100.0f;

		/// <summary>This allows you to set the mesh used to render the atmosphere. This should be a sphere.</summary>
		public Mesh OuterMesh { set { outerMesh = value; } get { return outerMesh; } } [SerializeField] private Mesh outerMesh;

		/// <summary>This allows you to set the radius of the OuterMesh. If this is incorrectly set then the atmosphere will render incorrectly.</summary>
		public float OuterMeshRadius { set { outerMeshRadius = value; } get { return outerMeshRadius; } } [SerializeField] private float outerMeshRadius = 1.0f;

		/// <summary>This allows you to set how high the atmosphere extends above the surface of the planet in local space.</summary>
		public float Height { set { height = value; } get { return height; } } [SerializeField] private float height = 10.0f;

		/// <summary>This allows you to adjust the fog level of the atmosphere.</summary>
		public float Density { set { density = value; } get { return density; } } [SerializeField] private float density = 10.0f;

		/// <summary>If your planet has clouds, set it here so they can be rendered with the sky.</summary>
		public SgtCloud Clouds { set { clouds = value; } get { return clouds; } } [SerializeField] private SgtCloud clouds;

		/// <summary>This allows you to set the weight of the atmosphere, where higher values concentrate the particles toward the surface of the planet, and lower values give a more even distribution.</summary>
		public float Weight { set { weight = value; } get { return weight; } } [SerializeField] [Range(1.0f, 10.0f)] private float weight = 3.0f;

		/// <summary>This allows you to set the weight of the atmosphere colors, where higher values push the <b>Upper Color</b> lower in the atmosphere.</summary>
		public float ColorWeight { set { colorWeight = value; } get { return colorWeight; } } [SerializeField] [Range(1.0f, 10.0f)] private float colorWeight = 3.0f;

		/// <summary>This allows you to adjust how many samples are used to ray march the atmosphere/clouds.</summary>
		public float Detail { set { detail = value; } get { return detail; } } [SerializeField] [Range(0.0f, 10.0f)] private float detail = 2.0f;

		/// <summary>This allows you adjust how how atmospheric scattering applies on top of the planet surface.</summary>
		public float SurfaceScattering { set { surfaceScattering = value; } get { return surfaceScattering; } } [SerializeField] [Range(0.001f, 1.0f)] private float surfaceScattering = 0.01f;

		/// <summary>This allows you to offset the camera distance in world space when rendering the atmosphere, giving you fine control over the render order.</summary>
		public float CameraOffset { set { cameraOffset = value; } get { return cameraOffset; } } [SerializeField] private float cameraOffset = 0.1f;

		/// <summary>This allows you to control how fast the opacity of the sky increases as the camera descends.</summary>
		public float DepthOpaque { set { depthOpaque = value; } get { return depthOpaque; } } [SerializeField] private float depthOpaque = 5.0f;

		/// <summary>Should the sky receive lighting?</summary>
		public bool Lighting { set { lighting = value; } get { return lighting; } } [SerializeField] private bool lighting;

		/// <summary>The start point of the day/sunset transition (0 = dark side, 1 = light side).</summary>
		public float LightingStart { set { if (lightingStart != value) { lightingStart = value; DirtyLightingTexture(); } } get { return lightingStart; } } [Range(0.0f, 1.0f)] [SerializeField] private float lightingStart = 0.45f;

		/// <summary>The end point of the sunset/night transition (0 = dark side, 1 = light side).</summary>
		public float LightingEnd { set { if (lightingEnd != value) { lightingEnd = value; DirtyLightingTexture(); } } get { return lightingEnd; } } [Range(0.0f, 1.0f)] [SerializeField] private float lightingEnd = 1.0f;

		/// <summary>The sharpness of the sunset red channel transition.</summary>
		public float LightingSharpnessR { set { if (lightingSharpnessR != value) { lightingSharpnessR = value; DirtyLightingTexture(); } } get { return lightingSharpnessR; } } [SerializeField] private float lightingSharpnessR = 3.0f;

		/// <summary>The sharpness of the sunset green channel transition.</summary>
		public float LightingSharpnessG { set { if (lightingSharpnessG != value) { lightingSharpnessG = value; DirtyLightingTexture(); } } get { return lightingSharpnessG; } } [SerializeField] private float lightingSharpnessG = 2.0f;

		/// <summary>The sharpness of the sunset blue channel transition.</summary>
		public float LightingSharpnessB { set { if (lightingSharpnessB != value) { lightingSharpnessB = value; DirtyLightingTexture(); } } get { return lightingSharpnessB; } } [SerializeField] private float lightingSharpnessB = 2.0f;

		/// <summary>The start point of the day/sunset transition (0 = dark side, 1 = light side).</summary>
		public float ScatteringStart { set { if (scatteringStart != value) { scatteringStart = value; DirtyScatteringTexture(); } } get { return scatteringStart; } } [Range(0.0f, 1.0f)] [SerializeField] private float scatteringStart = 0.35f;

		/// <summary>The end point of the sunset/night transition (0 = dark side, 1 = light side).</summary>
		public float ScatteringEnd { set { if (scatteringEnd != value) { scatteringEnd = value; DirtyScatteringTexture(); } } get { return scatteringEnd; } } [Range(0.0f, 1.0f)] [SerializeField] private float scatteringEnd = 0.6f;

		/// <summary>The sharpness of the sunset red channel transition.</summary>
		public float ScatteringSharpnessR { set { if (scatteringSharpnessR != value) { scatteringSharpnessR = value; DirtyScatteringTexture(); } } get { return scatteringSharpnessR; } } [SerializeField] private float scatteringSharpnessR = 2.0f;

		/// <summary>The sharpness of the sunset green channel transition.</summary>
		public float ScatteringSharpnessG { set { if (scatteringSharpnessG != value) { scatteringSharpnessG = value; DirtyScatteringTexture(); } } get { return scatteringSharpnessG; } } [SerializeField] private float scatteringSharpnessG = 2.0f;

		/// <summary>The sharpness of the sunset blue channel transition.</summary>
		public float ScatteringSharpnessB { set { if (scatteringSharpnessB != value) { scatteringSharpnessB = value; DirtyScatteringTexture(); } } get { return scatteringSharpnessB; } } [SerializeField] private float scatteringSharpnessB = 2.0f;

		/// <summary>The size of each atmospheric scattering halo, where higher values make the halo smaller. Use negative values for back scattering.</summary>
		public Vector4 ScatteringTerms { set { scatteringTerms = value; } get { return scatteringTerms; } } [SerializeField] private Vector4 scatteringTerms = new Vector4(500.0f, 100.0f, 2.0f, -2.0f);

		/// <summary>The strength of each atmospheric scattering halo layer.</summary>
		public Vector4 ScatteringPower { set { scatteringPower = value; } get { return scatteringPower; } } [SerializeField] private Vector4 scatteringPower = new Vector4(0.5f, 0.25f, 0.25f, 0.1f);

		[SerializeField]
		private SgtSkyModel model;

		[System.NonSerialized]
		private Material blitMaterial;

		[System.NonSerialized]
		private Texture2D lightingTexture;

		[System.NonSerialized]
		private Texture2D scatteringTexture;

		[System.NonSerialized]
		private Material clonedMaterial;

		private static int _SGT_Color                    = Shader.PropertyToID("_SGT_Color");
		private static int _SGT_Brightness               = Shader.PropertyToID("_SGT_Brightness");
		private static int _SGT_WorldToLocal             = Shader.PropertyToID("_SGT_WorldToLocal");
		private static int _SGT_LocalToWorld             = Shader.PropertyToID("_SGT_LocalToWorld");
		private static int _SGT_Density                  = Shader.PropertyToID("_SGT_Density");
		private static int _SGT_AltitudeScale            = Shader.PropertyToID("_SGT_AltitudeScale");
		private static int _SGT_Weight                   = Shader.PropertyToID("_SGT_Weight");
		private static int _SGT_Detail                   = Shader.PropertyToID("_SGT_Detail");
		private static int _SGT_LightingTex              = Shader.PropertyToID("_SGT_LightingTex");
		private static int _SGT_ScatteringTex            = Shader.PropertyToID("_SGT_ScatteringTex");
		private static int _SGT_ScatteringTerms          = Shader.PropertyToID("_SGT_ScatteringTerms");
		private static int _SGT_ScatteringPower          = Shader.PropertyToID("_SGT_ScatteringPower");

		private static int _SGT_Object2World         = Shader.PropertyToID("_SGT_Object2World");
		private static int _SGT_World2Object         = Shader.PropertyToID("_SGT_World2Object");
		private static int _SGT_Object2Local         = Shader.PropertyToID("_SGT_Object2Local");
		private static int _SGT_World2View           = Shader.PropertyToID("_SGT_World2View");
		private static int _SGT_WCam                 = Shader.PropertyToID("_SGT_WCam");
		private static int _SGT_CoverageTex          = Shader.PropertyToID("_SGT_CoverageTex");
		private static int _SGT_CloudAlbedoTex       = Shader.PropertyToID("_SGT_CloudAlbedoTex");
		private static int _SGT_Frame                = Shader.PropertyToID("_SGT_Frame");
		private static int _SGT_Resolution           = Shader.PropertyToID("_SGT_Resolution");
		
		private static int _SGT_CloudColor          = Shader.PropertyToID("_SGT_CloudColor");
		private static int _SGT_CloudLayerHeight    = Shader.PropertyToID("_SGT_CloudLayerHeight");
		private static int _SGT_CloudLayerThickness = Shader.PropertyToID("_SGT_CloudLayerThickness");
		private static int _SGT_CloudLayerDensity   = Shader.PropertyToID("_SGT_CloudLayerDensity");
		private static int _SGT_CloudLayerShape     = Shader.PropertyToID("_SGT_CloudLayerShape");
		private static int _SGT_CloudWarp           = Shader.PropertyToID("_SGT_CloudWarp");

		private static int _SGT_LightingDensity      = Shader.PropertyToID("_SGT_LightingDensity");
		private static int _SGT_LightingScale        = Shader.PropertyToID("_SGT_LightingScale");
		private static int _SGT_SilhouetteRange      = Shader.PropertyToID("_SGT_SilhouetteRange");
		private static int _SGT_DepthOpaque          = Shader.PropertyToID("_SGT_DepthOpaque");
		private static int _SGT_SmoothRange          = Shader.PropertyToID("_SGT_SmoothRange");
		private static int _SGT_BlueNoiseTex         = Shader.PropertyToID("_SGT_BlueNoiseTex");

		public float OuterRadius
		{
			get
			{
				return innerMeshRadius + height;
			}
		}

		public Material BlitMaterial
		{
			get
			{
				return blitMaterial;
			}
		}

		public bool HasChild(CwChild child)
		{
			return child == model;
		}

		public void DirtyLightingTexture()
		{
			DestroyImmediate(lightingTexture);
		}

		public void DirtyScatteringTexture()
		{
			DestroyImmediate(scatteringTexture);
		}

		public void RandomizeLightingSharpnessRGB()
		{
			var oldMid = (lightingSharpnessR + lightingSharpnessG + lightingSharpnessB) / 3.0f;

			lightingSharpnessR = Random.Range(1.0f, 3.0f);
			lightingSharpnessG = Random.Range(1.0f, 3.0f);
			lightingSharpnessB = Random.Range(1.0f, 3.0f);

			if (oldMid > 0.0f)
			{
				var newMid = (lightingSharpnessR + lightingSharpnessG + lightingSharpnessB) / 3.0f;
				var scale  = oldMid / newMid;

				lightingSharpnessR *= scale;
				lightingSharpnessG *= scale;
				lightingSharpnessB *= scale;
			}
		}

		private static float Ease(float t)
		{
			return t * t * (3.0f - 2.0f * t);
		}

		private void UpdateLightingTexture()
		{
			var width = 256;

			if (lightingTexture == null)
			{
				lightingTexture = CwHelper.CreateTempTexture2D("Lighting (Generated)", width, 1, TextureFormat.ARGB32);

				lightingTexture.wrapMode = TextureWrapMode.Clamp;
			}

			var stepU = 1.0f / (width  - 1);

			for (var x = 0; x < width; x++)
			{
				var sunsetU = Mathf.InverseLerp(lightingEnd, lightingStart, stepU * x);
				var color   = default(Color);

				color.r = Ease(1.0f - CwHelper.Sharpness(sunsetU, lightingSharpnessR));
				color.g = Ease(1.0f - CwHelper.Sharpness(sunsetU, lightingSharpnessG));
				color.b = Ease(1.0f - CwHelper.Sharpness(sunsetU, lightingSharpnessB));
				color.a = 0.0f;

				lightingTexture.SetPixel(x, 0, CwHelper.ToLinear(CwHelper.Saturate(color)));
			}

			lightingTexture.Apply();
		}

		private void UpdateScatteringTexture()
		{
			var width = 64;

			if (scatteringTexture == null)
			{
				scatteringTexture = CwHelper.CreateTempTexture2D("Scattering (Generated)", width, 1, TextureFormat.ARGB32);

				scatteringTexture.wrapMode = TextureWrapMode.Clamp;
			}

			var stepU = 1.0f / (width  - 1);

			for (var x = 0; x < width; x++)
			{
				var sunsetU = Mathf.InverseLerp(scatteringEnd, scatteringStart, stepU * x);
				var color   = default(Color);

				color.r = Ease(1.0f - CwHelper.Sharpness(sunsetU, scatteringSharpnessR));
				color.g = Ease(1.0f - CwHelper.Sharpness(sunsetU, scatteringSharpnessG));
				color.b = Ease(1.0f - CwHelper.Sharpness(sunsetU, scatteringSharpnessB));
				color.a = (color.r + color.g + color.b) / 3.0f;

				scatteringTexture.SetPixel(x, 0, CwHelper.ToLinear(CwHelper.Saturate(color)));
			}

			scatteringTexture.Apply();
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

		public override void RenderWaterBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
		}

		public override void RenderBuffers(SgtVolumeManager manager, Camera finalCamera, int frame, Vector2Int renderSize)
		{
			if (blitMaterial == null) blitMaterial = CwHelper.CreateTempMaterial("Blit Mat", "Hidden/SgtSky");
			if (blitMaterial == null) return;

			var colorDelta = (Vector4)lowerColor - (Vector4)upperColor;

			blitMaterial.SetMatrix(_SGT_Object2World, model.transform.localToWorldMatrix);
			blitMaterial.SetMatrix(_SGT_World2Object, model.transform.worldToLocalMatrix);
			blitMaterial.SetMatrix(_SGT_Object2Local, transform.worldToLocalMatrix * model.transform.localToWorldMatrix);
			blitMaterial.SetMatrix(_SGT_World2View, finalCamera.worldToCameraMatrix);
			blitMaterial.SetVector(_SGT_WCam, finalCamera.transform.position);
			blitMaterial.SetFloat(_SGT_Frame, Time.frameCount);
			blitMaterial.SetVector(_SGT_Resolution, (Vector2)renderSize);
			blitMaterial.SetColor(_SGT_Color, upperColor);
			blitMaterial.SetFloat(_SGT_Brightness, brightness);
			blitMaterial.SetVector(_SGT_Density, new Vector4(colorDelta.x, colorDelta.y, colorDelta.z, density));
			blitMaterial.SetVector(_SGT_Weight, new Vector4(colorWeight, colorWeight, colorWeight, weight));
			blitMaterial.SetFloat(_SGT_Detail, detail);
			blitMaterial.SetFloat(_SGT_AltitudeScale, (innerMeshRadius + height) / height);
			blitMaterial.SetFloat(_SGT_DepthOpaque, depthOpaque);

			blitMaterial.SetMatrix(_SGT_WorldToLocal, transform.worldToLocalMatrix);
			blitMaterial.SetMatrix(_SGT_LocalToWorld, transform.localToWorldMatrix);

			blitMaterial.SetTexture(_SGT_BlueNoiseTex, SgtVolumeManager.BlueNoiseTex);
			blitMaterial.SetFloat(_SGT_SilhouetteRange, surfaceScattering);

			if (clouds != null && clouds.isActiveAndEnabled == true)
			{
				var cloudHeight    = default(Vector4);
				var cloudThickness = default(Vector4);
				var cloudDensity   = default(Vector4);
				//var cloudOpacity   = default(Vector4);
				var cloudShape     = default(Vector4);

				for (var i = 0; i < 4; i++)
				{
					if (clouds.CloudLayers.Count > i)
					{
						var cloudLayer = clouds.CloudLayers[i];

						cloudHeight[i]    = cloudLayer.Height;
						cloudThickness[i] = cloudLayer.Thickness * 0.5f;
						cloudDensity[i]   = cloudLayer.Density * clouds.Density;
						//cloudOpacity[i]   = cloudLayer.Density * cloudLayer.Thickness * cloudLayer.Shadow;
						cloudShape[i]     = cloudLayer.Shape + 1.0f;
					}
				}
				
				blitMaterial.SetTexture(_SGT_CoverageTex, clouds.GeneratedTexture);

				blitMaterial.SetFloat(_SGT_CloudWarp, clouds.Warp);
				blitMaterial.SetColor(_SGT_CloudColor, clouds.Color);
				blitMaterial.SetVector(_SGT_CloudLayerHeight, cloudHeight);
				blitMaterial.SetVector(_SGT_CloudLayerThickness, cloudThickness);
				blitMaterial.SetVector(_SGT_CloudLayerDensity, cloudDensity);
				blitMaterial.SetVector(_SGT_CloudLayerShape, cloudShape);
				blitMaterial.SetFloat(_SGT_LightingDensity, clouds.ShadowDensity);
				blitMaterial.SetFloat(_SGT_LightingScale, clouds.ShadowOffset);

				if (clouds.Albedo == true)
				{
					blitMaterial.SetTexture(_SGT_CloudAlbedoTex, clouds.GeneratedAlbedoTexture);

					blitMaterial.EnableKeyword("_SGT_CLOUDS_ALBEDO");
					blitMaterial.DisableKeyword("_SGT_CLOUDS");
				}
				else
				{
					blitMaterial.EnableKeyword("_SGT_CLOUDS");
					blitMaterial.DisableKeyword("_SGT_CLOUDS_ALBEDO");
				}

				var carveLayerCount = 0;

				foreach (var carveLayer in clouds.CarveLayers)
				{
					if (carveLayer != null && carveLayer.Texture != null)
					{
						blitMaterial.SetTexture("_SGT_CarveTex" + carveLayerCount, carveLayer.Texture);
						blitMaterial.SetVector("_SGT_CarveData" + carveLayerCount, new Vector4(carveLayer.Tiling, carveLayer.Strength, 0.0f, 0.0f));
						blitMaterial.SetVector("_SGT_CarveWeights" + carveLayerCount, carveLayer.Channels * carveLayer.Strength);

						if (++carveLayerCount >= 2)
						{
							break;
						}
					}
				}

				blitMaterial.DisableKeyword("_SGT_CARVE0");
				blitMaterial.DisableKeyword("_SGT_CARVE1");
				blitMaterial.DisableKeyword("_SGT_CARVE2");
				blitMaterial.EnableKeyword("_SGT_CARVE" + carveLayerCount);
			}
			else
			{
				blitMaterial.DisableKeyword("_SGT_CLOUDS");
				blitMaterial.DisableKeyword("_SGT_CLOUDS_ALBEDO");
			}

			if (lighting == true)
			{
				// Write lights and shadows
				CwHelper.SetTempMaterial(blitMaterial);

				var mask   = 1 << gameObject.layer;
				var lights = SgtLight.Find(mask, transform.position);

				SgtShadow.Find(true, mask, lights);
				SgtShadow.FilterOutSphere(transform.position);
				SgtShadow.WriteSphere(SgtShadow.MAX_SPHERE_SHADOWS);
				SgtShadow.WriteRing(SgtShadow.MAX_RING_SHADOWS);

				SgtLight.FilterOut(transform.position);
				SgtLight.Write(transform.position, CwHelper.UniformScale(model.transform.lossyScale) * InnerMeshRadius, model.transform, null, SgtLight.MAX_LIGHTS);

				if (lightingTexture == null)
				{
					UpdateLightingTexture();
				}

				blitMaterial.SetTexture(_SGT_LightingTex, lightingTexture);

				if (scatteringTexture == null)
				{
					UpdateScatteringTexture();
				}

				blitMaterial.SetVector(_SGT_ScatteringTerms, scatteringTerms);
				blitMaterial.SetVector(_SGT_ScatteringPower, scatteringPower);
				blitMaterial.SetTexture(_SGT_ScatteringTex, scatteringTexture);

				blitMaterial.DisableKeyword("_SGT_UNLIT");
				blitMaterial.EnableKeyword("_SGT_ONE_LIGHT");
			}
			else
			{
				blitMaterial.EnableKeyword("_SGT_UNLIT");
			}

			var smooth = manager.Smooth != SgtVolumeManager.SmoothType.None;
			var range  = manager.SmoothRange;

			if (smooth == false && manager.Downscale > 1)
			{
				smooth = true;
				range  = 0.5f;
			}

			if (smooth == true)
			{
				blitMaterial.DisableKeyword("_SGT_SHARP");
				blitMaterial.EnableKeyword("_SGT_SMOOTH");

				blitMaterial.SetFloat(_SGT_SmoothRange, range);
			}
			else
			{
				blitMaterial.EnableKeyword("_SGT_SHARP");
			}

			SgtVolumeCamera.AddDrawMesh(outerMesh, 0, model.transform.localToWorldMatrix, blitMaterial, 0, false);
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			CwHelper.OnCameraPreRender += HandleCameraPreRender;

			if (model == null)
			{
				model = SgtSkyModel.Create(this);
			}

			model.CachedMeshRenderer.enabled = true;

			SgtLightOccluder.Register(this);

			UpdateMaterial();
		}

		protected override void OnDisable()
		{
			base.OnDisable();

			SgtLightOccluder.Unregister(this);

			CwHelper.OnCameraPreRender -= HandleCameraPreRender;

			if (model != null)
			{
				model.CachedMeshRenderer.enabled = false;
			}

			DestroyImmediate(clonedMaterial);
		}

		protected virtual void OnDestroy()
		{
			CwHelper.Destroy(lightingTexture);
			CwHelper.Destroy(scatteringTexture);
			DestroyImmediate(blitMaterial);
		}

		protected virtual void OnDidApplyAnimationProperties()
		{
			DirtyLightingTexture();
			DirtyScatteringTexture();
		}

		/// <summary>If <b>SourceMaterial</b> changes, then you can call this method.</summary>
		[ContextMenu("Update Material")]
		public void UpdateMaterial()
		{
			if (sourceMaterial != null)
			{
				if (clonedMaterial == null)
				{
					clonedMaterial = Instantiate(sourceMaterial);

					clonedMaterial.hideFlags = HideFlags.HideAndDontSave;
				}
				else
				{
					if (clonedMaterial.shader != sourceMaterial.shader)
					{
						clonedMaterial.shader = sourceMaterial.shader;
					}

					clonedMaterial.CopyPropertiesFromMaterial(sourceMaterial);
				}
			}
		}

		protected virtual void LateUpdate()
		{
			if (model != null)
			{
				model.CachedMeshFilter.sharedMesh = outerMesh;
			}

			var del = Vector3.Normalize(transform.InverseTransformVector(Camera.main.transform.position - model.transform.position));
			var lon = Mathf.Atan2(del.x, del.z) * Mathf.Rad2Deg;
			var lat = -Mathf.Asin(del.y) * Mathf.Rad2Deg;
			model.transform.localRotation = Quaternion.Euler(lat, lon, 0.0f);
			//model.transform.localScale = Vector3.one * (radius + height * 1.5f);
			model.transform.localScale = Vector3.one * CwHelper.Divide(OuterRadius, outerMeshRadius);

			var scale        = CwHelper.Divide(outerMeshRadius, OuterRadius);
			var worldToLocal = Matrix4x4.Scale(new Vector3(scale, scale, scale)) * transform.worldToLocalMatrix;

			if (clonedMaterial != null)
			{
				model.CachedMeshRenderer.sharedMaterial = clonedMaterial;

				clonedMaterial.SetMatrix(_SGT_WorldToLocal, worldToLocal);
				clonedMaterial.SetMatrix(_SGT_LocalToWorld, worldToLocal.inverse);

				if (SgtVolumeManager.Instances.Count > 0 && SgtVolumeManager.Instances.First.Value.Downscale > 1)
				{
					clonedMaterial.EnableKeyword("_SGT_DOWNSCALE");
				}
				else
				{
					clonedMaterial.DisableKeyword("_SGT_DOWNSCALE");
				}
			}
		}

#if UNITY_EDITOR
		protected virtual void OnDrawGizmosSelected()
		{
			if (isActiveAndEnabled == true)
			{
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
			var dirtyLightingTexture   = false;
			var dirtyScatteringTexture = false;

			SgtSky tgt; SgtSky[] tgts; GetTargets(out tgt, out tgts);

			BeginError(Any(tgts, t => t.SourceMaterial == null));
				Draw("sourceMaterial", "The material used to render this component.\n\nNOTE: This material must use the <b>Space Graphics Toolkit/Sky</b> shader. You cannot use a normal shader.");
			EndError();
			Draw("upperColor", "This allows you to set the color of the atmosphere at high altitudes.");
			Draw("lowerColor", "This allows you to set the color of the atmosphere at low altitudes.");
			Draw("brightness", "The <b>Color.rgb</b> values will be multiplied by this.");

			Separator();

			BeginError(Any(tgts, t => t.InnerMeshRadius <= 0.0f));
				Draw("innerMeshRadius", "The radius of the meshes set in the SgtSharedMaterial.");
			EndError();
			BeginError(Any(tgts, t => t.OuterMesh == null));
				Draw("outerMesh", "This allows you to set the mesh used to render the atmosphere. This should be a sphere.");
			EndError();
			UnityEditor.EditorGUILayout.BeginHorizontal();
				BeginError(Any(tgts, t => t.OuterMeshRadius <= 0.0f));
					Draw("outerMeshRadius", "This allows you to set the radius of the OuterMesh. If this is incorrectly set then the atmosphere will render incorrectly.");
				EndError();
				if (Any(tgts, t => t.OuterMesh != null) && GUILayout.Button("Calculate", GUILayout.Width(80)) == true)
				{
					Each(tgts, t => { if (t.OuterMesh != null) { t.OuterMeshRadius = GetBoundsRadius(t.OuterMesh.bounds); } });
				}
			UnityEditor.EditorGUILayout.EndHorizontal();
			Draw("clouds", "If your planet has clouds, set it here so they can be rendered with the sky.");

			Separator();

			BeginError(Any(tgts, t => t.Height <= 0.0f));
				Draw("height", "This allows you to set how high the atmosphere extends above the surface of the planet in local space.");
			EndError();
			BeginError(Any(tgts, t => t.Density <= 0.0f));
				Draw("density", "This allows you to adjust the fog level of the atmosphere.");
			EndError();
			Draw("weight", "This allows you to set the weight of the atmosphere, where higher values concentrate the articles toward the surface of the planet, and lower values give a more even distribution.");
			Draw("colorWeight", "This allows you to set the weight of the atmosphere colors, where higher values push the <b>Upper Color</b> lower in the atmosphere.");
			Draw("detail", "This allows you to adjust how many samples are used to ray march the atmosphere/clouds.");
			Draw("surfaceScattering", "This allows you adjust how how atmospheric scattering applies on top of the planet surface.");
			Draw("cameraOffset", "This allows you to offset the camera distance in world space when rendering the atmosphere, giving you fine control over the render order."); // Updated automatically
			Draw("depthOpaque", "This allows you to control how fast the opacity of the sky increases as the camera descends."); // Updated automatically

			Separator();

			Draw("lighting");

			if (Any(tgts, t => t.Lighting == true))
			{
				BeginIndent();
					BeginError(Any(tgts, t => t.LightingStart >= t.LightingEnd));
						Draw("lightingStart", ref dirtyLightingTexture, "The start point of the day/sunset transition (0 = dark side, 1 = light side).", "Start");
						Draw("lightingEnd", ref dirtyLightingTexture, "The end point of the sunset/night transition (0 = dark side, 1 = light side).", "End");
					EndError();
					Draw("lightingSharpnessR", ref dirtyLightingTexture, "The sharpness of the sunset red channel transition.", "Sharpness R");
					Draw("lightingSharpnessG", ref dirtyLightingTexture, "The sharpness of the sunset green channel transition.", "Sharpness G");
					Draw("lightingSharpnessB", ref dirtyLightingTexture, "The sharpness of the sunset blue channel transition.", "Sharpness B");
				EndIndent();
			}

			if (Any(tgts, t => t.Lighting == true))
			{
				Separator();

				BeginDisabled();
					UnityEditor.EditorGUILayout.Toggle("Scattering", true);
				EndDisabled();
				BeginIndent();
					BeginError(Any(tgts, t => t.ScatteringStart >= t.ScatteringEnd));
						Draw("scatteringStart", ref dirtyScatteringTexture, "The start point of the day/sunset transition (0 = dark side, 1 = light side).", "Start");
						Draw("scatteringEnd", ref dirtyScatteringTexture, "The end point of the sunset/night transition (0 = dark side, 1 = light side).", "End");
					EndError();
					Draw("scatteringSharpnessR", ref dirtyScatteringTexture, "The sharpness of the sunset red channel transition.", "Sharpness R");
					Draw("scatteringSharpnessG", ref dirtyScatteringTexture, "The sharpness of the sunset green channel transition.", "Sharpness G");
					Draw("scatteringSharpnessB", ref dirtyScatteringTexture, "The sharpness of the sunset blue channel transition.", "Sharpness B");
					DrawVector4("scatteringTerms", "The size of each atmospheric scattering halo, where higher values make the halo smaller. Use negative values for back scattering.", "Terms");
					DrawVector4("scatteringPower", "The strength of each atmospheric scattering halo layer.", "Power");
				EndIndent();
			}

			Separator();

			if (Any(tgts, t => t.SourceMaterial != null && t.SourceMaterial.IsKeywordEnabled("_SGT_LIGHTING") == true && SgtLight.InstanceCount == 0))
			{
				Separator();

				Warning("You need to add the SgtLight component to your scene lights for them to work with SGT.");
			}

			if (Any(tgts, t => SetOuterMeshAndOuterMeshRadius(t, false)))
			{
				Separator();

				if (Button("Set Outer Mesh & Outer Mesh Radius") == true)
				{
					Each(tgts, t => SetOuterMeshAndOuterMeshRadius(t, true));
				}
			}

			if (dirtyLightingTexture == true)
			{
				Each(tgts, t => t.DirtyLightingTexture());
			}

			if (dirtyScatteringTexture == true)
			{
				Each(tgts, t => t.DirtyScatteringTexture());
			}

			SgtVolumeCamera_Editor.Require();
			SgtVolumeManager_Editor.Require();
		}

		private bool SetOuterMeshAndOuterMeshRadius(SgtSky sky, bool apply)
		{
			if (sky.OuterMesh == null)
			{
				var mesh = CwHelper.LoadFirstAsset<Mesh>("Geosphere40 t:mesh");

				if (mesh != null)
				{
					if (apply == true)
					{
						sky.OuterMesh       = mesh;
						//atmosphere.OuterMeshRadius = SgtCommon.GetBoundsRadius(mesh.bounds);
					}

					return true;
				}
			}

			return false;
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