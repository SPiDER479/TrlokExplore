using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "QuestionsList", menuName = "Scriptable Objects/QuestionsList")]
public class QuestionsList : ScriptableObject
{
    public Question[] questions;
}
