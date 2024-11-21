Shader "Custom/TrailDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionRadius ("Distortion Radius", Float) = 0.1
        _DistortionStrength ("Distortion Strength", Float) = 0.1
        _SpinSpeed ("Spin Speed", Float) = 1.0
        _NoiseFrequency ("Noise Frequency", Float) = 1.0
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.05
        _MaxRotationAngle ("Max Rotation Angle (radians)", Float) = 0.3
        _NumTrailPoints ("Number of Trail Points", Float) = 0
        _AlphaFactor ("Alpha Factor", Float) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
            float _DistortionRadius;
            float _DistortionStrength;
            float _SpinSpeed;
            float _NoiseFrequency;
            float _NoiseAmplitude;
            float _MaxRotationAngle;
            float4 _TrailPoints[320];
            float _NumTrailPoints;
            float _AlphaFactor;

            // Function for generating a random value
            float RandomValue(float2 pos)
            {
                return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453);
            }

            // Noise function
            float noise(float2 pos)
            {
                return sin(pos.x * _NoiseFrequency + _Time.y) * cos(pos.y * _NoiseFrequency + _Time.z);
            }

            // Rotate a point around a center
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

            // Vertex shader
            v2f vert (appdata v)
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
                float2 totalDistortion = float2(0.0, 0.0);
                float finalAlphaFactor = _AlphaFactor;

                for (int j = 0; j < _NumTrailPoints; j++)
                {
                    float2 trailPoint = _TrailPoints[j].xy;

                    // Gradually increase distortion radius for the first 5 points
                    float scaledRadius = _DistortionRadius;
                    if (j < 10)
                    {
                        scaledRadius = lerp(_DistortionRadius * 0.1, _DistortionRadius, j / 10.0);
                    }

                    // Randomized distortion radius based on the scaled radius
                    float randomRadius = lerp(scaledRadius * 0.5, scaledRadius, RandomValue(trailPoint));

                    float dist = distance(uv, trailPoint);

                    if (dist < randomRadius)
                    {
                        float distortionFactor = 1.0 - (dist / randomRadius);
                        finalAlphaFactor = max(finalAlphaFactor, distortionFactor);

                        // Stronger noise-based perturbation
                        float noiseValue = noise(uv) * _NoiseAmplitude;

                        // Randomly perturb trail point for irregular distortion shapes
                        float2 randomOffset = float2(
                            RandomValue(trailPoint + float2(0.1, 0.2)),
                            RandomValue(trailPoint + float2(0.3, 0.4))
                        ) * 0.1 * distortionFactor;

                        float2 perturbedTrailPoint = trailPoint + randomOffset;

                        // Add shape irregularity and rotation
                        float shapePerturbation = RandomValue(uv * 10.0) * 0.2;
                        float rotationAngle = (_SpinSpeed + noiseValue + shapePerturbation) * distortionFactor * _Time.y;

                        rotationAngle = clamp(rotationAngle, -_MaxRotationAngle, _MaxRotationAngle);

                        uv = RotatePoint(uv, perturbedTrailPoint, rotationAngle);

                        // Positional distortion amplified by shape irregularity
                        totalDistortion += (perturbedTrailPoint - uv) * (distortionFactor + noiseValue + shapePerturbation) * _DistortionStrength;
                    }
                }

                uv += totalDistortion;

                fixed4 color = tex2D(_MainTex, uv);
                color.a *= finalAlphaFactor;

                return color;
            }
            ENDCG
        }
    }
}
