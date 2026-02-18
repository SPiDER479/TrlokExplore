using UnityEngine;

[CreateAssetMenu(fileName = "DataSet", menuName = "Scriptable Objects/DataSet")]
public class DataSet : ScriptableObject
{
    [TextArea] public string english;
    [TextArea] public string hindi;
}