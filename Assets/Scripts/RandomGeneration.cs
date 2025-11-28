using SpaceGraphicsToolkit.Landscape;
using UnityEngine;

public class RandomGeneration : MonoBehaviour
{
    [SerializeField] private SgtLandscapeBundle terrain;
    [SerializeField] private Texture2D[] heightmaps;
    [SerializeField] private Texture2D[] gradients;
    public void Generate()
    {
        terrain.HeightTextures[0] = heightmaps[Random.Range(0, heightmaps.Length)];
        terrain.GradientTextures[0] = gradients[Random.Range(0, gradients.Length)];
        
        terrain.MarkAsDirty();
        terrain.Regenerate();
    }
}