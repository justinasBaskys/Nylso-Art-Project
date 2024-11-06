using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class MousePosition2D : MonoBehaviour
{
    [SerializeField] private Camera mainCamera;
    
    void Update()
    {
        
        Vector3 mouseScreenPosition = Input.mousePosition;
        mouseScreenPosition.z = -mainCamera.transform.position.z; // Set z to the distance to the 2D plane

        Vector3 mouseWorldPosition = mainCamera.ScreenToWorldPoint(mouseScreenPosition);
        mouseWorldPosition.z = 0f; // Ensure z is zero for 2D

        transform.position = mouseWorldPosition;

        Debug.Log(mouseWorldPosition);
    }
}
