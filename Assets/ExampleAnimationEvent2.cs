using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Kvant; 

public class ExampleAnimationEvent2 : MonoBehaviour
{

    public GameObject spray;
    Spray sprayParticle;
    // Start is called before the first frame update
    private void Start()
    {
        sprayParticle = spray.GetComponent<Spray>();  
    }

    // Update is called once per frame
    public void Spray3(float duration)
    {
        Debug.Log("Spray Particle");
        StartCoroutine(SprayForDuration(duration));
    }



    IEnumerator SprayForDuration(float duration)
    {
        sprayParticle.throttle = 0.5f;
        Debug.Log("SprayForDuration " + duration);
        yield return new WaitForSeconds(duration);
        sprayParticle.throttle = 0.0f;
    }
    public void  PrintEvent(string s)
    {
        Debug.Log("PrintEvent: " + s + " called at: " + Time.time);
    }


}
