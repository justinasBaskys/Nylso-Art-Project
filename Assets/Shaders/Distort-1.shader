Shader "Custom/MouseDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MousePos ("Mouse Position", Vector) = (0, 0, 0, 0)
        _DistortionRadius ("Distortion Radius", Float) = 0.1
        _DistortionStrength ("Distortion Strength", Float) = 0.05
        _SpinSpeed ("Spin Speed", Float) = 1.0
        _NoiseFrequency ("Noise Frequency", Float) = 1.0
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.02
        _MaxRotationAngle ("Max Rotation Angle (radians)", Float) = 0.2
    }
    SubShader
    {
        Pass
        {
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
            float4 _MousePos;
            float _DistortionRadius;
            float _DistortionStrength;
            float _SpinSpeed;
            float _NoiseFrequency;
            float _NoiseAmplitude;
            float _MaxRotationAngle;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Helper function to create simple noise based on sine and cosine functions
            float noise(float2 pos)
            {
                return sin(pos.x * _NoiseFrequency + _Time.y) * cos(pos.y * _NoiseFrequency + _Time.z);
            }

            // Helper function to rotate a point around a center
            float2 RotatePoint(float2 uv, float2 center, float angle)
            {
                float s = sin(angle);
                float c = cos(angle);

                float2 translatedUV = uv - center;
                float2 rotatedUV;
                rotatedUV.x = translatedUV.x * c - translatedUV.y * s;
                rotatedUV.y = translatedUV.x * s + translatedUV.y * c;

                rotatedUV += center;
                return rotatedUV;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 mouseUV = _MousePos.xy;

                float dist = distance(uv, mouseUV);

                if (dist < _DistortionRadius)
                {
                    float distortionFactor = 1.0 - (dist / _DistortionRadius);
                    float noiseValue = noise(uv) * _NoiseAmplitude;

                    // Modify the rotation angle with noise for randomness
                    float rotationAngle = (_SpinSpeed + noiseValue) * (1.0 - (dist / _DistortionRadius)) * _Time.y;

                    // Clamp the rotation angle to be within a limited range
                    rotationAngle = clamp(rotationAngle, -_MaxRotationAngle, _MaxRotationAngle);

                    // Apply rotation with added noise
                    uv = RotatePoint(uv, mouseUV, rotationAngle);

                    // Add extra distortion influenced by noise
                    uv += (mouseUV - uv) * (distortionFactor + noiseValue) * _DistortionStrength;
                }

                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}