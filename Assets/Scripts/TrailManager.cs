using UnityEngine;

public class TrailManager : MonoBehaviour
{
    [SerializeField] private GameObject pointPrefab;  // Prefab to represent each point
    [SerializeField] private Material distortionMaterial; // Material with the shader

    private Camera mainCamera;
    private float spawnRate = 0.1f;  // How frequently points are spawned
    private float pointLifetime = 2f; // Time before points are destroyed
    private float maxRadius = 0.2f; // Max radius for the flow effect

    void Start()
    {
        mainCamera = Camera.main;
    }

    void Update()
    {
        if (Input.GetMouseButton(0)) // Spawn points while holding the mouse button
        {
            SpawnPoints();
        }
    }

    void SpawnPoints()
    {
        Vector3 mousePosition = Input.mousePosition;
        Vector3 worldPos = mainCamera.ScreenToWorldPoint(new Vector3(mousePosition.x, mousePosition.y, mainCamera.nearClipPlane));
        worldPos.z = 0f;

        // Create a new point at the mouse position
        GameObject point = Instantiate(pointPrefab, worldPos, Quaternion.identity);
        point.transform.localScale = new Vector3(maxRadius, maxRadius, 1f); // Scale based on the radius

        // Apply the point to the shader
        AddPointToShader(point.transform.position);

        // Destroy point after a certain time
        Destroy(point, pointLifetime);
    }

    void AddPointToShader(Vector3 pointPosition)
    {
        // We need to pass the position to the shader for the flow effect
        Vector4 pointData = new Vector4(pointPosition.x, pointPosition.y, 0f, 0f);
        
        // Set the point data to the shader
        distortionMaterial.SetVector("_PointPosition", pointData);
    }
}
