using System;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneHandler : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.P)) SceneManager.LoadSceneAsync("Solar System");
        if (Input.GetKeyDown(KeyCode.O)) SceneManager.LoadSceneAsync("Jupiter");
        if (Input.GetKeyDown(KeyCode.I)) SceneManager.LoadSceneAsync("Custom");
        if (Input.GetKeyDown(KeyCode.U)) SceneManager.LoadSceneAsync("AI");
    }
}