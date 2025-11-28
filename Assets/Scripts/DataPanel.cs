using UnityEngine;

public class DataPanel : MonoBehaviour
{
    [SerializeField] private GameObject panel;
    [SerializeField] private GameObject canvas;
    [SerializeField] private GameObject line;

    private Camera mainCamera;

    private void Awake() => mainCamera = Camera.main;

    private void Update()
    {
        if (Vector3.Distance(mainCamera.transform.position, transform.position) < 2000)
        {
            canvas.SetActive(true);
            line.SetActive(true);
        }
        else
        {
            canvas.SetActive(false);
            line.SetActive(false);
        }
        
        panel.transform.LookAt(mainCamera.transform.position);
    }
}