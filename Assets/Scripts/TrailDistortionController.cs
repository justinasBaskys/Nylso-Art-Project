using UnityEngine;
using System.Collections.Generic;

public class TrailDistortionController : MonoBehaviour
{
    [SerializeField] private Material trailMaterial;
    [SerializeField] private TrailRenderer trailRenderer; // Assign the TrailRenderer component in the Inspector

    private const int maxTrailPoints = 128; // Adjust this to match or exceed the trail's capacity
    private Vector3[] positions = new Vector3[maxTrailPoints];
    private Vector4[] trailPositions = new Vector4[maxTrailPoints];

    void Update()
    {
        // Get the number of positions from the trail renderer
        int numPositions = trailRenderer.GetPositions(positions);

        // Ensure numPositions does not exceed maxTrailPoints
        if (numPositions > maxTrailPoints)
        {
            numPositions = maxTrailPoints;
        }

        // Convert Vector3 positions to Vector4 for shader usage
        for (int i = 0; i < numPositions; i++)
        {
            Vector3 pos = positions[i];
            trailPositions[i] = new Vector4(pos.x, pos.y, pos.z, 1.0f); // Using w = 1.0 for consistency
        }

        // Pass the array of trail positions to the shader
        trailMaterial.SetVectorArray("_TrailPositions", trailPositions);
        trailMaterial.SetFloat("_NumTrailPoints", numPositions);
    }
}