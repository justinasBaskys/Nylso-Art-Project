Shader "Shaders/More-Grass-Experiment-Background"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionRadius ("Distortion Radius", Float) = 0.025
        _DistortionStrength ("Distortion Strength", Float) = 0.01
        _SpinSpeed ("Spin Speed", Float) = 0.15
        _NoiseFrequency ("Noise Frequency", Float) = 242.6
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.7
        _MaxRotationAngle ("Max Rotation Angle (radians)", Float) = 0.01
        _NumPoints ("Number of Points", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha // Enable transparency
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;

            float _DistortionRadius;
            float _DistortionStrength;
            float _SpinSpeed;
            float _NoiseFrequency;
            float _NoiseAmplitude;
            float _MaxRotationAngle;
            float4 _Points[128]; // Preset points for distortion
            float _NumPoints;

            // Noise function
            float noise(float2 pos)
            {
                return sin(pos.x * _NoiseFrequency + _Time.y) * cos(pos.y * _NoiseFrequency + _Time.z);
            }

            // Rotation function
            float2 RotatePoint(float2 uv, float2 center, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);
                float2 translatedUV = uv - center;
                float2 rotatedUV;
                rotatedUV.x = translatedUV.x * c - translatedUV.y * s;
                rotatedUV.y = translatedUV.x * s + translatedUV.y * c;
                return rotatedUV + center;
            }

            // Custom falloff function
            float CustomFalloff(float distance, float radius)
            {
                return pow(1.0 - saturate(distance / radius), 3.0);
            }

            // Vertex shader
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Fragment shader
            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                fixed4 color = tex2D(_MainTex, uv);

                float2 totalDistortion = float2(0.0, 0.0);

                // Iterate through preset points
                for (int j = 0; j < _NumPoints; j++)
                {
                    float2 currPoint = _Points[j].xy; // Use only the xy of the float4
                    float dist = distance(uv, currPoint);

                    if (dist < _DistortionRadius)
                    {
                        float distortionFactor = CustomFalloff(dist, _DistortionRadius);

                        // Noise-based perturbation
                        float noiseValue = noise(uv) * _NoiseAmplitude;

                        // Apply rotation
                        uv = RotatePoint(uv, currPoint, (_SpinSpeed + noiseValue) * distortionFactor * _Time.y);

                        // Combine effects
                        totalDistortion += (currPoint - uv) * distortionFactor * _DistortionStrength;
                    }
                }

                uv += totalDistortion;

                // Final texture sampling
                color = tex2D(_MainTex, uv);

                return color;
            }
            ENDCG
        }
    }
}
