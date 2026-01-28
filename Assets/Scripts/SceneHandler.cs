using System;
using UnityEngine;

public class SceneHandler : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        if (Input.GetMouseButtonDown(0)) print(2);
        if (Input.GetKeyDown(KeyCode.A)) print(1);
    }
}