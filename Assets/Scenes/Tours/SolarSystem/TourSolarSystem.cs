using System.Collections;
using SpaceGraphicsToolkit.Prominence;
using UnityEngine;

public class TourSolarSystem : MonoBehaviour
{
    private AudioSource audioSource;
    private float elapsedTime, duration;
    private Camera camera;
    [SerializeField] private GameObject vortex;
    [SerializeField] private SgtProminence vortexProminence;
    [SerializeField] private Material skybox;
    private static readonly int StarsEmissionPower = Shader.PropertyToID("_StarsEmissionPower");

    [SerializeField] private GameObject sun;
    
    private void Awake()
    {
        audioSource = GetComponent<AudioSource>();
        camera = Camera.main;
    }

    private IEnumerator Start()
    {
        audioSource.clip = TourManager.Instance.GetAudio();
        camera.transform.position = Vector3.zero;
        ResetVortex();
        
        yield return new WaitForSeconds(1f);
        StartCoroutine(HyperJump());
        
        yield return new WaitForSeconds(2f);
        StartCoroutine(HyperJump());

        yield return null;
    }

    private void SetElapsedAndDuration(float duration)
    {
        elapsedTime = 0;
        this.duration = duration;
    }

    private void ResetVortex()
    {
        vortex.transform.position = new Vector3(0, 0, 20000);
        vortexProminence.Brightness = 0;
        vortex.SetActive(false);
        skybox.SetFloat(StarsEmissionPower, 1f);
    }

    private IEnumerator HyperJump()
    {
        vortex.SetActive(true);
        float jumpTime = 0f;

        while (jumpTime < 1f)
        {
            vortex.transform.position = Vector3.Lerp(new Vector3(0, 0, 20000), new Vector3(0, 0, 0), jumpTime / 1);
            vortexProminence.Brightness = Mathf.Lerp(0f, 1f, jumpTime / 1);
            skybox.SetFloat(StarsEmissionPower, Mathf.Lerp(1f, 100f,  Mathf.Sqrt(jumpTime / 1)));
            
            jumpTime += Time.deltaTime;
            yield return null;
        }
        
        ResetVortex();
    }
}