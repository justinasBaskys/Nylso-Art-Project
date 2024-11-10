using UnityEngine;

public class OnMouseClick : MonoBehaviour
{
    [SerializeField] private MousePosition2D mousePosition2D;
    [SerializeField] private GameObject objectToSpawn;

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {

            Vector3 spawnPosition = mousePosition2D.mouseWorldPosition;

            // Instantiate the object at the mouse world position
            GameObject spawnedObject = Instantiate(objectToSpawn, spawnPosition, Quaternion.identity);


            Destroy(spawnedObject, 2.5f);
        }
    }
}
