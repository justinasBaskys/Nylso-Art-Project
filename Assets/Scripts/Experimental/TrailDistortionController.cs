using UnityEngine;

[ExecuteInEditMode]
public class TrailDistortionController : MonoBehaviour
{
    public Material material;
    public Vector4[] trailPoints;
    [Range(0, 320)] public int numTrailPoints;
    [Range(0.0f, 1.0f)] public float alphaFactor = 0.5f;

    void Update()
    {
        if (material == null || trailPoints == null) return;

        // Pass trail points and count to the shader
        material.SetInt("_NumTrailPoints", numTrailPoints);
        material.SetFloat("_AlphaFactor", alphaFactor);

        // Update the trail points in the shader
        for (int i = 0; i < Mathf.Min(numTrailPoints, trailPoints.Length); i++)
        {
            material.SetVector("_TrailPoints[" + i + "]", trailPoints[i]);
        }
    }
}