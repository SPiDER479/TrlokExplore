using System.Collections;
using TMPro;
using UnityEngine;

[System.Serializable] struct TourPlanet
{
    public GameObject planet;
    public TourDataSet data;
}

public class TourSolarSystem : MonoBehaviour
{
    private AudioSource audioSource;
    private float elapsedTime, duration;
    private Camera camera;

    [SerializeField] private TMP_Text infoBox;
    [SerializeField] private TourPlanet[] planets;

    private int currentPlanetIndex;
    private TourPlanet currentPlanet;
    
    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
        camera = Camera.main;
    }

    private IEnumerator Start()
    {
        if (SceneHandler.Instance.currentLanguage == languages.English) infoBox.font = SceneHandler.Instance.englishFont;
        else infoBox.font = SceneHandler.Instance.hindiFont;
        
        while (currentPlanetIndex < planets.Length)
        {
            currentPlanet = planets[currentPlanetIndex++];

            AudioClip clip; string text;
            if (SceneHandler.Instance.currentLanguage == languages.English)
            {
                clip = currentPlanet.data.englishClip;
                text = currentPlanet.data.english;
            }
            else
            {
                clip = currentPlanet.data.hindiClip;
                text = currentPlanet.data.hindi;
            }

            Vector3 cameraPos = camera.transform.position;
            
            SetElapsedAndDuration(1);
            while (elapsedTime < duration)
            {
                camera.transform.position = Vector3.Lerp(cameraPos, new Vector3(currentPlanet.planet.transform.position.x, 0, currentPlanet.planet.transform.localScale.x * 2), elapsedTime / duration);
                
                elapsedTime += Time.deltaTime;
                yield return null;
            }
            
            audioSource.PlayOneShot(clip);
            infoBox.text = text;
            
            SetElapsedAndDuration(clip.length);
            while (elapsedTime < duration)
            {
                camera.transform.RotateAround(currentPlanet.planet.transform.position, Vector3.up, (360f / duration) * Time.deltaTime);
            
                elapsedTime += Time.deltaTime;
                yield return null;
            }
        }
        
        yield return null;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}