using TMPro;
using UnityEngine;

public class PlanetMotion : MonoBehaviour
{
    [SerializeField] private float orbitRadiansPerDay;
    [SerializeField] private float spinRadiansPerDay;
    [SerializeField] private Transform planetTransform;
    
    private float[] daysPerSeconds = new float[] { 0.000011574f, 0.1f, 0.5f, 1f, 10f };
    private int currentDaysPerSecond;
    private float daysPerSecond;

    private bool orbit;
    private bool spin;

    private void Update()
    {
        if (orbit) transform.RotateAround(Vector3.zero, Vector3.up, orbitRadiansPerDay * daysPerSecond * Mathf.Rad2Deg * Time.deltaTime);
        if (spin) planetTransform.Rotate(planetTransform.up, spinRadiansPerDay * daysPerSecond * Mathf.Rad2Deg * Time.deltaTime);
    }

    public void SetDaysPerSecond(TMP_Text textField)
    {
        ++currentDaysPerSecond;
        if (currentDaysPerSecond >= daysPerSeconds.Length) currentDaysPerSecond = 0;
        daysPerSecond = daysPerSeconds[currentDaysPerSecond];
        
        textField.text = "Days per second: " + daysPerSecond;
    }
    
    public void SetOrbit(bool orbit) => this.orbit = orbit;
    
    public void SetSpin(bool spin) => this.spin = spin;
}