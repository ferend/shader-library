using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetPosition : MonoBehaviour
{
    [SerializeField] private GameObject obj;
    private Material _mat;
    private void Start()
    {
        _mat = obj.GetComponent<Renderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
       _mat.SetFloat("_Radius",Mathf.Lerp(_mat.GetFloat("_Radius"),10,0.2F * Time.deltaTime));  
        Shader.SetGlobalVector("_Position", transform.position);
        
    }
}
