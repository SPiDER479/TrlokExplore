using UnityEngine;

[CreateAssetMenu(fileName = "TourDataSet", menuName = "Scriptable Objects/TourDataSet")]
public class TourDataSet : ScriptableObject
{
    [TextArea] public string english;
    [TextArea] public string hindi;
    public AudioClip englishClip;
    public AudioClip hindiClip;
}