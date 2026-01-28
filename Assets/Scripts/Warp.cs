using System.Collections;
using TMPro;
using UnityEngine;

public class Warp : MonoBehaviour
{
    private float elapsedTime, duration;

    [SerializeField] private Transform[] warpableObjects;

    public void WarpTo(Transform TargetObject)
    {
        StartCoroutine(Warping(TargetObject.position, TargetObject.rotation));
    }

    public void WarpTo(TMP_Dropdown dropdown)
    {
        int index = dropdown.value;
        
        if (index >= 0 && index < warpableObjects.Length)
        {
            StartCoroutine(Warping(warpableObjects[index].position, warpableObjects[index].rotation));
        }
    }

    private IEnumerator Warping(Vector3 targetPosition, Quaternion rotation)
    {
        SetElapsedAndDuration(1f);
        while (elapsedTime < duration)
        {
            float t = Mathf.Clamp01(elapsedTime / duration) * Mathf.Clamp01(elapsedTime / duration);
            transform.position = Vector3.Lerp(transform.position, targetPosition, t);
            transform.rotation = Quaternion.Slerp(transform.rotation, rotation, t);
            elapsedTime += Time.deltaTime;
            yield return null;
        }
    }
    
    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}