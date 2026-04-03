using System.Collections;
using TMPro;
using UnityEngine;

public class TourMoon : MonoBehaviour
{
    private AudioSource audioSource;
    private float elapsedTime, duration;
    private Camera camera;
    
    [SerializeField] private TMP_Text infoBox;

    [SerializeField] private TourDataSet terrain;
    [SerializeField] private TourDataSet atmosphere;
    [SerializeField] private TourDataSet moons;
    [SerializeField] private TourDataSet missions;
    
    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
        camera = Camera.main;
    }
    
    private IEnumerator Start()
    {
        if (SceneHandler.Instance.currentLanguage == languages.English) infoBox.font = SceneHandler.Instance.englishFont;
        else infoBox.font = SceneHandler.Instance.hindiFont;

        AudioClip clip;
        
        yield return new WaitForSeconds(1);

        if (SceneHandler.Instance.currentLanguage == languages.English)
        {
            clip = atmosphere.englishClip;
            infoBox.text = atmosphere.english;
        }
        else
        {
            clip = atmosphere.hindiClip;
            infoBox.text = atmosphere.hindi;
        }
        
        audioSource.PlayOneShot(clip);
        
        SetElapsedAndDuration(clip.length + 0.5f);
        while (elapsedTime < duration)
        {
            camera.transform.position = Vector3.Lerp(Vector3.zero, new Vector3(-1630, 0, 4500), elapsedTime / duration);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        if (SceneHandler.Instance.currentLanguage == languages.English)
        {
            clip = terrain.englishClip;
            infoBox.text = terrain.english;
        }
        else
        {
            clip = terrain.hindiClip;
            infoBox.text = terrain.hindi;
        }
        
        audioSource.PlayOneShot(clip);
        
        SetElapsedAndDuration(clip.length + 0.5f);
        while (elapsedTime < duration)
        {
            camera.transform.position = Vector3.Lerp(new Vector3(-1630, 0, 4500), new Vector3(-2000, 300, 5300), elapsedTime / duration);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        if (SceneHandler.Instance.currentLanguage == languages.English)
        {
            clip = moons.englishClip;
            infoBox.text = moons.english;
        }
        else
        {
            clip = moons.hindiClip;
            infoBox.text = moons.hindi;
        }
        
        audioSource.PlayOneShot(clip);
        
        SetElapsedAndDuration(clip.length + 0.5f);
        while (elapsedTime < duration)
        {
            camera.transform.position = Vector3.Lerp(new Vector3(-2000, 300, 5300), Vector3.zero, elapsedTime / duration);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        if (SceneHandler.Instance.currentLanguage == languages.English)
        {
            clip = missions.englishClip;
            infoBox.text = missions.english;
        }
        else
        {
            clip = missions.hindiClip;
            infoBox.text = missions.hindi;
        }
        
        audioSource.PlayOneShot(clip);
        
        SetElapsedAndDuration(clip.length + 0.5f);
        while (elapsedTime < duration)
        {
            camera.transform.position = Vector3.Lerp(Vector3.zero, new Vector3(3980, 77, 1800), elapsedTime / duration);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        yield return null;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}