using System;
using SpaceGraphicsToolkit.Cloud;
using SpaceGraphicsToolkit.Landscape;
using SpaceGraphicsToolkit.Ocean;
using SpaceGraphicsToolkit.Sky;
using UnityEngine;

public class PlanetCustomiser : MonoBehaviour
{
    [SerializeField] private SgtSphereLandscape landscape;
    [SerializeField] private SgtSky sky;
    [SerializeField] private SgtCloud cloud;
    [SerializeField] private SgtOcean ocean;
    [SerializeField] private SgtOceanRays oceanRays;
    [SerializeField] private SgtOceanDebris oceanDebris;

    [SerializeField] [Range(0f, 2f)] private float wavesDisplacement;

    private void Update()
    {
        ocean.WavesDisplacement = wavesDisplacement;
    }
}