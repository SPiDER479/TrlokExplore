using UnityEngine;

[CreateAssetMenu(fileName = "Question", menuName = "Scriptable Objects/Question")]
public class Question : ScriptableObject
{
    [TextArea] public string question;
    [TextArea] public string optionA;
    [TextArea] public string optionB;
    [TextArea] public string optionC;
    [TextArea] public string optionD;
    [Range(0, 3)] public int correctOption;
}
