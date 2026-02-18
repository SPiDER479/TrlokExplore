using System.Collections;
using UnityEngine;

public class CameraShake : MonoBehaviour
{
    public static CameraShake Instance;
    
    private float elapsedTime, duration;
    private Camera camera;

    private void Awake()
    {
        Instance = this;
        camera = Camera.main;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }

    public IEnumerator Shake(float duration, float strength)
    {
        SetElapsedAndDuration(duration);

        while (elapsedTime < duration)
        {
            camera.transform.position += new Vector3(strength * Random.Range(-1f, 1f), strength * Random.Range(-1f, 1f), 0);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
    }
}