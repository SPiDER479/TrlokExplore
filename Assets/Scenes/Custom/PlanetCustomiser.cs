using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Landscape;
using SpaceGraphicsToolkit.Ocean;
using SpaceGraphicsToolkit.Sky;
using UnityEngine;

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
    
    public float RaleighColorR { set { raleighColorR = value; } get { return raleighColorR; } } [SerializeField] private float raleighColorR = 0.09f;
    public float RaleighColorG { set { raleighColorG = value; } get { return raleighColorG; } } [SerializeField] private float raleighColorG = 0.24f;
    public float RaleighColorB { set { raleighColorB = value; } get { return raleighColorB; } } [SerializeField] private float raleighColorB = 1f;
    public void SkyColor()
    {
        sky.RayleighColor = new Color(raleighColorR, raleighColorG, raleighColorB, 1);
    }
    
    public float CloudColorR { set { cloudColorR = value; } get { return cloudColorR; } } [SerializeField] private float cloudColorR = 1f;
    public float CloudColorG { set { cloudColorG = value; } get { return cloudColorG; } } [SerializeField] private float cloudColorG = 0.91f;
    public float CloudColorB { set { cloudColorB = value; } get { return cloudColorB; } } [SerializeField] private float cloudColorB = 0.5f;
    public void CloudColor()
    {
        cloud.Color = new Color(cloudColorR, cloudColorG, cloudColorB, 1);
    }
    
    public float OceanColorR { set { oceanColorR = value; } get { return oceanColorR; } } [SerializeField] private float oceanColorR = 0f;
    public float OceanColorG { set { oceanColorG = value; } get { return oceanColorG; } } [SerializeField] private float oceanColorG = 0.36f;
    public float OceanColorB { set { oceanColorB = value; } get { return oceanColorB; } } [SerializeField] private float oceanColorB = 0.5f;
    public void OceanColor()
    {
        ocean.SurfaceColor = new Color(oceanColorR, oceanColorG, oceanColorB, 1);
    }
}