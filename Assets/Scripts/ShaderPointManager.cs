using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class ShaderPointManager : MonoBehaviour
{
    public Material targetMaterial;

    [Range(1, 128)] public int numPoints = 1;
    public List<Vector2> points = new List<Vector2>();

    [Header("Shader Parameters")]
    [Range(0.01f, 1.0f)] public float distortionRadius = 0.025f;
    [Range(0.0f, 1.0f)] public float distortionStrength = 0.01f;
    [Range(0.0f, 5.0f)] public float spinSpeed = 0.15f;
    [Range(100.0f, 500.0f)] public float noiseFrequency = 242.6f;
    [Range(0.0f, 2.0f)] public float noiseAmplitude = 0.7f;
    [Range(0.0f, 0.1f)] public float maxRotationAngle = 0.01f;

    void OnValidate()
    {
        // Adjust points list size
        if (points.Count > 128)
            points.RemoveRange(128, points.Count - 128);

        if (points.Count < numPoints)
        {
            for (int i = points.Count; i < numPoints; i++)
                points.Add(Vector2.zero);
        }
        else if (points.Count > numPoints)
        {
            points.RemoveRange(numPoints, points.Count - numPoints);
        }

        UpdateMaterialProperties();
    }

    void Update()
    {
        // For runtime updates
        UpdateMaterialProperties();
    }

    void UpdateMaterialProperties()
    {
        if (targetMaterial != null)
        {
            // Update points array
            targetMaterial.SetFloat("_NumPoints", numPoints);
            Vector4[] shaderPoints = new Vector4[128];
            for (int i = 0; i < points.Count; i++)
            {
                shaderPoints[i] = new Vector4(points[i].x, points[i].y, 0, 0);
            }
            targetMaterial.SetVectorArray("_Points", shaderPoints);

            // Update shader parameters
            targetMaterial.SetFloat("_DistortionRadius", distortionRadius);
            targetMaterial.SetFloat("_DistortionStrength", distortionStrength);
            targetMaterial.SetFloat("_SpinSpeed", spinSpeed);
            targetMaterial.SetFloat("_NoiseFrequency", noiseFrequency);
            targetMaterial.SetFloat("_NoiseAmplitude", noiseAmplitude);
            targetMaterial.SetFloat("_MaxRotationAngle", maxRotationAngle);
        }
    }
}
