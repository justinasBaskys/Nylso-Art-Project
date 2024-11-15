using UnityEngine;

public class TrailDistortion : MonoBehaviour
{
    [SerializeField] private Material distortionMaterial;
    private TrailRenderer trailRenderer;
    private Vector4[] trailPoints;

    // Maximum number of points to pass to the shader
    private const int MaxTrailPoints = 64;

    void Start()
    {
        trailRenderer = GetComponent<TrailRenderer>();
        trailPoints = new Vector4[MaxTrailPoints];
    }

    void Update()
    {
        int numPositions = trailRenderer.positionCount;
        for (int i = 0; i < numPositions && i < MaxTrailPoints; i++)
        {
            Vector3 worldPos = trailRenderer.GetPosition(i);
            Vector3 screenPos = Camera.main.WorldToViewportPoint(worldPos);
            trailPoints[i] = new Vector4(screenPos.x, screenPos.y, 0, 1);
        }

        // Pass positions to the shader
        distortionMaterial.SetVectorArray("_TrailPoints", trailPoints);
        distortionMaterial.SetInt("_NumTrailPoints", numPositions);
    }
}