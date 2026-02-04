using System;
using System.Collections;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Landscape;
using SpaceGraphicsToolkit.Ocean;
using SpaceGraphicsToolkit.Sky;
using UnityEngine;
using Random = UnityEngine.Random;

public class PlanetCustomiser : MonoBehaviour
{
    [SerializeField] private SgtLandscapeBundle landscape;
    [SerializeField] private SgtSky sky;
    [SerializeField] private SgtCloud cloud;
    [SerializeField] private SgtOcean ocean;
    [SerializeField] private SgtOceanRays oceanRays;
    [SerializeField] private SgtOceanDebris oceanDebris;

    [SerializeField] private Texture2D[] heightmaps;
    public void RandomizeHeight()
    {
        landscape.HeightTextures[0] = heightmaps[Random.Range(0, heightmaps.Length)];
        
        landscape.MarkAsDirty();
        landscape.Regenerate();
    }
    
    [SerializeField] private Texture2D[] gradients;
    public void RandomizeColor()
    {
        landscape.GradientTextures[0] = gradients[Random.Range(0, gradients.Length)];
        
        landscape.MarkAsDirty();
        landscape.Regenerate();
    }

    public float Nitrogen { set { nitrogen = value; } get { return nitrogen; } } [SerializeField] private float nitrogen = 0.001f;
    public float Oxygen { set { oxygen = value; } get { return oxygen; } } [SerializeField] private float oxygen = 0.001f;
    public float CarbonDioxide { set { carbonDioxide = value; } get { return carbonDioxide; } } [SerializeField] private float carbonDioxide = 0.001f;
    public float Methane { set { methane = value; } get { return methane; } } [SerializeField] private float methane = 0.001f;
    public float SulfurDioxide { set { sulfurDioxide = value; } get { return sulfurDioxide; } } [SerializeField] private float sulfurDioxide = 0.001f;
    public void CalculatePlanet()
    {
        CalculateAtmosphere();
        CalculateCloud();
        CalculateWater();
    }
    private void CalculateAtmosphere()
    {
        float total = nitrogen + oxygen + carbonDioxide + methane + sulfurDioxide;

        float n2 = nitrogen / total;
        float o2 = oxygen / total;
        float co2 = carbonDioxide / total;
        float ch4 = methane / total;
        float so2 = sulfurDioxide / total;

        float r = 0.3f * n2 + 0.4f * o2 + 1f * co2 + 0f * ch4 + 1f * so2;
        float g = 0.5f * n2 + 0.6f * o2 + 0.6f * co2 + 0.8f * ch4 + 1f * so2;
        float b = 1f * n2 + 1f * o2 + 0.6f * co2 + 1f * ch4 + 0.2f * so2;
        
        float M = n2 * 28.02f + o2 * 32.00f + co2 * 44.01f + ch4 * 16.04f + so2 * 64.07f;
        float relativeDensity = (M - 16f) / (64f - 16f);
        
        sky.RayleighColor = new Color(Mathf.Clamp01(r), Mathf.Clamp01(g), Mathf.Clamp01(b), 1f);
        sky.Density = Mathf.Clamp01(relativeDensity);
    }
    private void CalculateCloud()
    {
        float cloudWhiteness = Mathf.Clamp01((carbonDioxide + sulfurDioxide) / 200f);

        cloud.Color = Color.Lerp(sky.RayleighColor, Color.white, cloudWhiteness);
    }
    private void CalculateWater()
    {
        Color deepBlue = new Color(0.0f, 0.2f, 0.35f);

        float darkening = Mathf.Clamp01(methane / 150f);
        float muddy = Mathf.Clamp01(sulfurDioxide / 200f);

        Color deepColor = Color.Lerp(deepBlue, Color.black, darkening);
        deepColor = Color.Lerp(deepColor, new Color(0.3f, 0.3f, 0.2f), muddy);
        deepColor = new Color(Mathf.Clamp01(deepColor.r), Mathf.Clamp01(deepColor.g), Mathf.Clamp01(deepColor.b), 1f);

        Color reflectedSky = sky.RayleighColor * 0.7f;
        Color surfaceColor = Color.Lerp(reflectedSky + deepColor * 0.3f, deepColor, 0.1f);
        surfaceColor = new Color(Mathf.Clamp01(surfaceColor.r), Mathf.Clamp01(surfaceColor.g), Mathf.Clamp01(surfaceColor.b), 1f);
        
        ocean.SurfaceColor = surfaceColor;
        ocean.SurfaceScattering = deepColor;
    }
}