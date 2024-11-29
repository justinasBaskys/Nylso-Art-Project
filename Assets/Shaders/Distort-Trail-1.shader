Shader "Shaders/TrailDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _AoEMask ("AoE Mask", 2D) = "white" {} // New AoE mask texture
        _DistortionRadius ("Distortion Radius", Float) = 0.025
        _DistortionStrength ("Distortion Strength", Float) = 0.01
        _SpinSpeed ("Spin Speed", Float) = 0.15
        _NoiseFrequency ("Noise Frequency", Float) = 242.6
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.7
        _MaxRotationAngle ("Max Rotation Angle (radians)", Float) = 0.01
        _NumTrailPoints ("Number of Trail Points", Float) = 0
        _MagneticPullStrength ("Magnetic Pull Strength", Float) = 0.002
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
            sampler2D _AoEMask; // New AoE mask sampler

            float _DistortionRadius;
            float _DistortionStrength;
            float _SpinSpeed;
            float _NoiseFrequency;
            float _NoiseAmplitude;
            float _MaxRotationAngle;
            float4 _TrailPoints[128];
            float _NumTrailPoints;
            float _MagneticPullStrength;

            // Noise Function
            float noise(float2 pos)
            {
                return sin(pos.x * _NoiseFrequency + _Time.y) * cos(pos.y * _NoiseFrequency + _Time.z);
            }

            // Rotating around the center
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

            // Radius of effect
            float CalculateScaledRadius(int index, float baseRadius)
            {
                if (index < 10)
                {
                    return baseRadius * (float(index + 1) / 10.0); // Increasing radius gradually in the first 10 points
                }
                return baseRadius;
            }

            // Magnetic pull
            float2 ApplyMagneticPull(float2 currentPoint, float2 previousPoint, float distortionFactor)
            {
                if (distortionFactor <= 0.0 || length(previousPoint) == 0.0) return float2(0.0, 0.0);

                float2 direction = normalize(currentPoint - previousPoint);
                return direction * _MagneticPullStrength * distortionFactor;
            }

            // Noise-Based Perturbation
            float2 ApplyNoisePerturbation(float2 uv, float2 trailPoint, float distortionFactor)
            {
                float2 randomOffset = float2(
                    noise(trailPoint + float2(0.1, 0.2)),
                    noise(trailPoint + float2(0.3, 0.4))
                );
                return randomOffset * 0.1 * distortionFactor;
            }

            // Rotation Effect
            float2 ApplyRotation(float2 uv, float2 center, float distortionFactor, float noiseValue)
            {
                float rotationAngle = (_SpinSpeed + noiseValue) * distortionFactor * _Time.y;
                rotationAngle = clamp(rotationAngle, -_MaxRotationAngle, _MaxRotationAngle);
                return RotatePoint(uv, center, rotationAngle);
            }

            float CustomFalloff(float distance, float radius)
            {
                return pow(1.0 - saturate(distance / radius), 3.0); // Power-based falloff
            }

            // Vertex Shader
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Fragment Shader
            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 totalDistortion = float2(0.0, 0.0);
                fixed4 color = tex2D(_MainTex, uv);

                // Sample the AoE mask
                float aoeMaskValue = tex2D(_AoEMask, uv).r; // Use the red channel of the mask
                if (aoeMaskValue <= 0.0) // Skip distortion if mask value is 0
                {
                    return color;
                }

                // Iterate through trail points
                for (int j = 0; j < _NumTrailPoints; j++)
                {
                    float2 trailPoint = _TrailPoints[j].xy;

                    // Calculate scaled distortion radius
                    float scaledRadius = CalculateScaledRadius(j, _DistortionRadius);

                    // Taking distance and checking if within influence
                    float dist = distance(uv, trailPoint);
                    if (dist < scaledRadius)
                    {
                        float distortionFactor = CustomFalloff(dist, scaledRadius) * aoeMaskValue; // Scale by AoE mask

                        // Magnetic pull
                        float2 magneticPull = float2(0.0, 0.0);
                        if (j > 0)
                        {
                            float2 prevTrailPoint = _TrailPoints[j - 1].xy;
                            magneticPull = ApplyMagneticPull(trailPoint, prevTrailPoint, distortionFactor);
                        }

                        // Noise perturbation
                        float noiseValue = noise(uv) * _NoiseAmplitude;
                        float2 noisePerturbation = ApplyNoisePerturbation(uv, trailPoint, distortionFactor);

                        // Applying rotation
                        uv = ApplyRotation(uv, trailPoint + noisePerturbation, distortionFactor, noiseValue);

                        // Combining effects
                        totalDistortion += magneticPull + (trailPoint - uv) * distortionFactor * _DistortionStrength;
                    }
                }

                uv += totalDistortion;

                // Finally applying distortion to the texture
                color = tex2D(_MainTex, uv);

                return color;
            }
            ENDCG
        }
    }
}
