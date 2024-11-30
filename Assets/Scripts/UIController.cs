using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour
{
    public ShaderPointManager shaderPointManager;
    public Slider distortionRadiusSlider;

    void Start()
    {
        distortionRadiusSlider.onValueChanged.AddListener(UpdateDistortionRadius);
    }

    void UpdateDistortionRadius(float value)
    {
        if (shaderPointManager != null)
        {
            shaderPointManager.distortionRadius = value;
        }
    }
}
