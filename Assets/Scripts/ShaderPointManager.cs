using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class ShaderPointManager : MonoBehaviour
{
    public Material targetMaterial;

    [Range(1, 128)] public int numPoints = 1;
    public List<Vector2> points = new List<Vector2>();

    void OnValidate()
    {
        // Adjust points list size
        while (points.Count < numPoints) points.Add(Vector2.zero);
        if (points.Count > numPoints) points.RemoveRange(numPoints, points.Count - numPoints);

        UpdateMaterialProperties();
    }

    void UpdateMaterialProperties()
    {
        if (targetMaterial != null)
        {
            targetMaterial.SetFloat("_NumPoints", numPoints);
            Vector4[] shaderPoints = new Vector4[128];
            for (int i = 0; i < points.Count; i++)
            {
                shaderPoints[i] = new Vector4(points[i].x, points[i].y, 0, 0);
            }
            targetMaterial.SetVectorArray("_Points", shaderPoints);
        }
    }
}
