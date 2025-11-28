using System;
using SpaceGraphicsToolkit;
using SpaceGraphicsToolkit.Atmosphere;
using SpaceGraphicsToolkit.Singularity;
using UnityEngine;
using UnityEngine.UI;

public class WaterSliders : MonoBehaviour
{
    [SerializeField] private SgtAtmosphere atmosphere;
    [SerializeField] private SgtPlanetWaterGradient waterGradient;
    [SerializeField] private GameObject BlackHole;
    private SgtLens blackHoleLens;

    private void Awake() => blackHoleLens = BlackHole.GetComponent<SgtLens>();
    
    [SerializeField] private Slider AtmosphereR, AtmosphereG, AtmosphereB;
    public void AtmosphereChanged() => atmosphere.Color = new Color(AtmosphereR.value, AtmosphereG.value, AtmosphereB.value);

    [SerializeField] private Slider ShallowWaterR, ShallowWaterG, ShallowWaterB;
    public void ShallowWaterChanged() => waterGradient.Shallow = new Color(ShallowWaterR.value, ShallowWaterG.value, ShallowWaterB.value);

    [SerializeField] private Slider DeepWaterR, DeepWaterG, DeepWaterB;
    public void DeepWaterChanged() => waterGradient.Deep = new Color(DeepWaterR.value, DeepWaterG.value, DeepWaterB.value);

    public void BlackHoleX(Slider slider) => BlackHole.transform.position = new Vector3(slider.value, 0, 3);

    private void LateUpdate()
    {
        if (BlackHole.activeSelf) blackHoleLens.UpdateCubemap();
    }
}