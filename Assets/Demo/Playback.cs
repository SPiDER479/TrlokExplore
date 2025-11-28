using System.Collections;
using SpaceGraphicsToolkit.Landscape;
using SpaceGraphicsToolkit.Starfield;
using UnityEngine;

public class Playback : MonoBehaviour
{
    [Header("General")]
    [SerializeField] private GameObject Cam;
    [SerializeField] private AudioSource music;
    private float elapsedTime, duration;
    
    [Header("First Scene")]
    [SerializeField] private SgtStarfieldBox startingStars;
    private int minBrightness = 0, maxBrightness = 50;
    [SerializeField] private SgtStarfieldInfinite staticStars, stretchStars;

    [Header("Second Scene")]
    [SerializeField] private Material skybox;
    [SerializeField] private GameObject earth;
    [SerializeField] private GameObject sun;
    [SerializeField] private GameObject star;
    [SerializeField] private GameObject jupiter;
    [SerializeField] private GameObject saturn;
    
    [Header("Third Scene")]
    [SerializeField] private GameObject UI;
    
    private IEnumerator Start()
    {
        Cam.transform.position = Vector3.zero;
        startingStars.StarCount = 0;
            
        yield return new WaitForSeconds(1.3f);
        
        while (startingStars.StarCount < 4)
        {
            startingStars.StarCount++;
            startingStars.Brightness = maxBrightness;

            SetElapsedAndDuration(5.4f);
            while (elapsedTime < duration)
            {
                startingStars.Brightness = Mathf.Lerp(maxBrightness, minBrightness, elapsedTime / duration);
                elapsedTime += Time.deltaTime;
                yield return null;
            }
        }

        startingStars.gameObject.SetActive(false);
        staticStars.gameObject.SetActive(true);
        stretchStars.gameObject.SetActive(true);
        
        yield return new WaitForSeconds(1);
        
        SetElapsedAndDuration(20.1f);
        while (elapsedTime < duration)
        {
            float t = Mathf.Clamp01(elapsedTime / duration) * Mathf.Clamp01(elapsedTime / duration);
            Cam.transform.position = Vector3.Lerp(Vector3.zero, new Vector3(0, 0, 700), t);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        SetElapsedAndDuration(2.3f);
        while (elapsedTime < duration)
        {
            float t = Mathf.Clamp01(elapsedTime / duration) * Mathf.Clamp01(elapsedTime / duration);
            Cam.transform.position = Vector3.Lerp(new Vector3(0, 0, 700), new Vector3(0, 0, 1000), t);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        staticStars.gameObject.SetActive(false);
        stretchStars.gameObject.SetActive(false);
        earth.SetActive(true);
        sun.SetActive(true);
        star.SetActive(true);
        RenderSettings.skybox = skybox;
        
        SetElapsedAndDuration(15);
        while (elapsedTime < duration)
        {
            Cam.transform.position = Vector3.Lerp(new Vector3(0, 0, 1000), new Vector3(0, 1000, -1000), elapsedTime / duration);
            sun.transform.position = Vector3.Lerp(new Vector3(0, 0, 100000), new Vector3(100000, 0, 0), elapsedTime / duration);
            star.transform.position = Vector3.Lerp(new Vector3(0, 0, 100000), new Vector3(100000, 0, 0), elapsedTime / duration);
            skybox.SetFloat("_StarsEmissionPower", Mathf.Lerp(0, 0.18f, elapsedTime / duration));
            skybox.SetFloat("_CloudsOpacityPower", Mathf.Lerp(0, 0.02f, elapsedTime / duration));
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        earth.SetActive(false);
        jupiter.SetActive(true);
        
        SetElapsedAndDuration(7);
        while (elapsedTime < duration)
        {
            Cam.transform.position = Vector3.Lerp(new Vector3(0, 1000, -1000), new Vector3(0, 1500, -1000), elapsedTime / duration);
            sun.transform.position = Vector3.Lerp(new Vector3(100000, 0, 0), new Vector3(50000, 0, -50000), elapsedTime / duration);
            star.transform.position = Vector3.Lerp(new Vector3(100000, 0, 0), new Vector3(50000, 0, -50000), elapsedTime / duration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        jupiter.SetActive(false);
        saturn.SetActive(true);
        
        SetElapsedAndDuration(7.5f);
        while (elapsedTime < duration)
        {
            Cam.transform.position = Vector3.Lerp(new Vector3(0, 1500, -1000), new Vector3(0, 2000, -1000), elapsedTime / duration);
            sun.transform.position = Vector3.Lerp(new Vector3(50000, 0, -50000), new Vector3(0, 0, -100000), elapsedTime / duration);
            star.transform.position = Vector3.Lerp(new Vector3(50000, 0, -50000), new Vector3(0, 0, -100000), elapsedTime / duration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        SetElapsedAndDuration(13.3f);
        while (elapsedTime < duration)
        {
            Cam.transform.position = Vector3.Lerp(new Vector3(0, 2000, -1000), new Vector3(550, 450, 2250), elapsedTime / duration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        UI.SetActive(true);
        
        SetElapsedAndDuration(5);
        while (elapsedTime < duration)
        {
            saturn.transform.localScale = Vector3.Lerp(new Vector3(750, 750, 750), Vector3.zero, elapsedTime / duration);
            sun.transform.localScale = Vector3.Lerp(new Vector3(50000, 50000, 50000), Vector3.zero, elapsedTime / duration);
            UI.transform.localScale = Vector3.Lerp(Vector3.zero, Vector3.one, elapsedTime / duration);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        sun.SetActive(false);
        saturn.SetActive(false);
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}