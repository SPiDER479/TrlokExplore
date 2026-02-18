using UnityEngine;
using UnityEngine.SceneManagement;

public enum languages
{
    English,
    Hindi
}

public class SceneHandler : MonoBehaviour
{
    public static SceneHandler Instance;
    public static languages currentLanguage = languages.English;
    
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

        if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            if (currentLanguage == languages.English) currentLanguage = languages.Hindi;
            else if (currentLanguage == languages.Hindi) currentLanguage = languages.English;
        }
    }
}