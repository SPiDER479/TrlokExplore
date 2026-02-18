using UnityEngine;

public class TourManager : MonoBehaviour
{
    public static TourManager Instance;
    public languages language;
    public AudioClip englishClip;
    public AudioClip hindiClip;

    private void Awake()
    {
        Instance = this;
    }

    public AudioClip GetAudio()
    {
        if (language == languages.English) return englishClip;
        else if (language == languages.Hindi) return hindiClip;
        else return null;
    }
}