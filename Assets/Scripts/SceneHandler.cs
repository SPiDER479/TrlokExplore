using System;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneHandler : MonoBehaviour
{
    public static SceneHandler Instance;
    
    private void Awake()
    {
        if (!Instance) Instance = this;
        else Destroy(gameObject);
        
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha0)) SceneManager.LoadSceneAsync("Solar System");
        if (Input.GetKeyDown(KeyCode.Alpha9)) SceneManager.LoadSceneAsync("Jupiter");
        if (Input.GetKeyDown(KeyCode.Alpha8)) SceneManager.LoadSceneAsync("Custom");
        if (Input.GetKeyDown(KeyCode.Alpha7)) SceneManager.LoadSceneAsync("AI");
    }
}