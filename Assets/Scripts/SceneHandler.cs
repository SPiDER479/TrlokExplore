using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneHandler : MonoBehaviour
{
    public static SceneHandler Instance;
    
    private int currentSceneIndex;
    
    private void Awake()
    {
        if (!Instance) Instance = this;
        else Destroy(gameObject);
        
        DontDestroyOnLoad(gameObject);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            ++currentSceneIndex;
            if (currentSceneIndex >= SceneManager.sceneCountInBuildSettings) currentSceneIndex = 0;
            SceneManager.LoadSceneAsync(currentSceneIndex);
        }
    }
}