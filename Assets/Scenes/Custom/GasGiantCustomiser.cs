using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.RingSystem;
using SpaceGraphicsToolkit.Sky;
using UnityEngine;

public class GasGiantCustomiser : MonoBehaviour
{
    [SerializeField] private SgtSky sky;
    [SerializeField] private SgtCloud cloud;
    [SerializeField] private SgtCloudBundle cloudBundle;
    [SerializeField] private SgtRingSystem ring;
    
    [SerializeField] private SgtGasGiantFluid[] fluids;
    [SerializeField] private Texture2D[] rings;
    
    public void RandomizeSky()
    {
        sky.Color = new Color(Random.value, Random.value, Random.value, 1);
    }

    public void RandomizeCloud()
    {
        cloud.RandomizeColorHue();
        cloud.RandomizeColor2Hue();
    }

    public void RandomizeBands()
    {
        cloud.RandomizeCoverageLayers();
        cloudBundle.Slices[1] = fluids[Random.Range(0, fluids.Length)];
    }

    public void RandomizeRings()
    {
        ring.BandsTex = rings[Random.Range(0, rings.Length)];
        
        ring.MarkAsDirty();
    }
}