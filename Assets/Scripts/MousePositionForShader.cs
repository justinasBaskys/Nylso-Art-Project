using UnityEngine;

public class MousePositionForShader : MonoBehaviour
{
    public Material material;  // Assign the material using the shader

    void Update()
    {
        // Convert mouse position to normalized screen space
        Vector2 mousePos = Input.mousePosition;
        mousePos.x /= Screen.width;
        mousePos.y /= Screen.height;

        // Pass mouse position to the shader
        material.SetVector("_MousePos", new Vector4(mousePos.x, mousePos.y, 0, 0));
    }
}