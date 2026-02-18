using System.Collections;
using UnityEngine;

public class TourSolarSystem : MonoBehaviour
{
    private AudioSource audioSource;
    private float elapsedTime, duration;
    private Camera camera;

    [SerializeField] private GameObject sun;
    
    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
        camera = Camera.main;
    }

    private IEnumerator Start()
    {
        audioSource.clip = TourManager.Instance.GetAudio();
        camera.transform.position = Vector3.zero;

        yield return null;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}