using System.Collections;
using TMPro;
using UnityEngine;

public class DataTrigger : MonoBehaviour
{
    private float elapsedTime, duration;
    
    [SerializeField] private RectTransform rectTransform;
    [SerializeField] private TMP_Text text;

    private void Awake()
    {
        rectTransform.sizeDelta = new Vector2(0, 0);
        rectTransform.gameObject.SetActive(false);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("DataUITrigger"))
        {
            StopAllCoroutines();
            if (SceneHandler.Instance.currentLanguage == languages.English)
            {
                text.font = SceneHandler.Instance.englishFont;
                text.text = other.GetComponent<DataContainer>().dataSet.english;
            }
            else if (SceneHandler.Instance.currentLanguage == languages.Hindi)
            {
                text.font = SceneHandler.Instance.hindiFont;
                text.text = other.GetComponent<DataContainer>().dataSet.hindi;
            }
            StartCoroutine(AnimateOpen());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.CompareTag("DataUITrigger"))
        {
            StopAllCoroutines();
            StartCoroutine(AnimateClose());
        }
    }

    private IEnumerator AnimateOpen()
    {
        float width = 0, height = 0;
        
        rectTransform.gameObject.SetActive(true);
        
        SetElapsedAndDuration(1f);
        while (elapsedTime < duration)
        {
            float t = Mathf.Clamp01(elapsedTime / duration) * Mathf.Clamp01(elapsedTime / duration);

            width = Mathf.Lerp(width, 500, t);
            height = Mathf.Lerp(height, 500, t);
            
            rectTransform.sizeDelta = new Vector2(width, height);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        rectTransform.sizeDelta = new Vector2(500, 500);
    }

    private IEnumerator AnimateClose()
    {
        float width = 500, height = 500;
        
        SetElapsedAndDuration(0.3f);
        while (elapsedTime < duration)
        {
            float t = Mathf.Clamp01(elapsedTime / duration) * Mathf.Clamp01(elapsedTime / duration);

            width = Mathf.Lerp(width, 0, t);
            height = Mathf.Lerp(height, 0, t);
            
            rectTransform.sizeDelta = new Vector2(width, height);
            
            elapsedTime += Time.deltaTime;
            yield return null;
        }
        
        rectTransform.sizeDelta = new Vector2(0, 0);
        rectTransform.gameObject.SetActive(false);
    }
    
    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }
}