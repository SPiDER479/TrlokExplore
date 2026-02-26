using TMPro;
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
    public languages currentLanguage = languages.English;
    public TMP_FontAsset englishFont, hindiFont;

    private GameObject[] panels;
    
    private void Awake()
    {
        if (Instance)
        {
            currentLanguage = Instance.currentLanguage;
            GameObject.Find("Language").GetComponentInChildren<TMP_Text>().text = Instance.currentLanguage.ToString();
            Destroy(Instance.gameObject);
        }
        
        Instance = this;
        
        DontDestroyOnLoad(gameObject);
        
        panels = GameObject.FindGameObjectsWithTag("Respawn");
        OpenPanel(panels[0]);
    }

    public void ToggleLanguage(TMP_Text text)
    {
        if (currentLanguage == languages.English) currentLanguage = languages.Hindi;
        else if (currentLanguage == languages.Hindi) currentLanguage = languages.English;
        text.text = currentLanguage.ToString();
    }

    public void OpenPanel(GameObject panel)
    {
        foreach (GameObject p in panels) p.gameObject.SetActive(false);
        panel.SetActive(true);
    }
    
    public void LoadScene(string sceneName)
    {
        SceneManager.LoadSceneAsync(sceneName);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            SceneManager.LoadSceneAsync(0);
        }
    }
}