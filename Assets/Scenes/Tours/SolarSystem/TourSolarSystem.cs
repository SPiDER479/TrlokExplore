using System.Collections;
using UnityEngine;

[System.Serializable] struct TourPlanet
{
    public GameObject planet;
    public float scale;
    public Vector3 startPos;
    public Vector3 endPos;
    public float time;
}

public class TourSolarSystem : MonoBehaviour
{
    private AudioSource audioSource;
    private float elapsedTime, duration;
    private Camera camera;

    [SerializeField] private TourPlanet[] planets;

    private int currentPlanetIndex = -1;
    private TourPlanet previousPlanet;
    private TourPlanet currentPlanet;
    
    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
        camera = Camera.main;
    }

    private IEnumerator Start()
    {
        audioSource.clip = TourManager.Instance.GetAudio();
        camera.transform.position = Vector3.zero;

        while (currentPlanetIndex < planets.Length)
        {
            if (currentPlanetIndex != -1) previousPlanet = currentPlanet;
            currentPlanet = planets[++currentPlanetIndex];

            if (TourManager.Instance.language == languages.Hindi) currentPlanet.time *= 0.922f;
            if (TourManager.Instance.language == languages.Hindi && currentPlanetIndex == 5) currentPlanet.time -= 2.1f;
            
            currentPlanet.planet.SetActive(true);
            currentPlanet.planet.transform.position = currentPlanet.startPos;
            currentPlanet.planet.transform.localScale = Vector3.zero;
            
            SetElapsedAndDuration(1);
            while (elapsedTime < duration)
            {
                currentPlanet.planet.transform.localScale = Vector3.Lerp(Vector3.zero, currentPlanet.scale * Vector3.one, elapsedTime / duration);
                if (currentPlanetIndex != 0) previousPlanet.planet.transform.localScale = Vector3.Lerp(previousPlanet.scale * Vector3.one, Vector3.zero, elapsedTime / duration);
            
                elapsedTime += Time.deltaTime;
                yield return null;
            }
            
            if (currentPlanetIndex != 0) previousPlanet.planet.SetActive(false);
            if (currentPlanetIndex == 0) audioSource.Play();
            
            SetElapsedAndDuration(currentPlanet.time / 2);
            while (elapsedTime < duration)
            {
                currentPlanet.planet.transform.position = Vector3.Lerp(currentPlanet.startPos, currentPlanet.endPos, elapsedTime / duration);

                elapsedTime += Time.deltaTime;
                yield return null;
            }
            
            SetElapsedAndDuration(currentPlanet.time / 2);
            while (elapsedTime < duration)
            {
                currentPlanet.planet.transform.position = Vector3.Lerp(currentPlanet.endPos, currentPlanet.startPos, elapsedTime / duration);

                elapsedTime += Time.deltaTime;
                yield return null;
            }
        }
        
        currentPlanet.planet.SetActive(false);
        
        yield return null;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}