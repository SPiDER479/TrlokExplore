using System.Collections;
using UnityEngine;

public class Timer : MonoBehaviour
{
    private int count;
    
    private IEnumerator Start()
    {
        while (true)
        {
            yield return new WaitForSeconds(1);
            print(count++);
        }
    }
}