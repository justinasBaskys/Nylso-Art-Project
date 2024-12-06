Shader "Shaders/Consistent-Grass-Background"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DistortionRadius ("Distortion Radius", Float) = 0.084
        _DistortionStrength ("Distortion Strength", Float) = 0.0291
        _SpinSpeed ("Spin Speed", Float) = 0.5
        _NoiseFrequency ("Noise Frequency", Float) = 145
        _NoiseAmplitude ("Noise Amplitude", Float) = 0.003
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
            float4 _Points[128];
            float _NumPoints;

            // Smoothed noise for random offset generation
            float SmoothNoise(float2 pos)
            {
                float n = sin(dot(pos.xy, float2(12.9898, 78.233)) * _NoiseFrequency);
                return 0.5 + 0.5 * sin(n + _Time.y); // Smoothed oscillation between 0 and 1
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
                return pow(1.0 - saturate(distance / radius), 2.0);
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
                float time = _Time.y * 0.5; // Moderate time multiplier

                for (int j = 0; j < _NumPoints; j++)
                {
                    float2 currPoint = _Points[j].xy;
                    float dist = distance(uv, currPoint);

                    if (dist < _DistortionRadius)
                    {
                        float distortionFactor = CustomFalloff(dist, _DistortionRadius);

                        // Generate smooth random offsets
                        float randomOffsetX = (SmoothNoise(currPoint + float2(1.0, 0.0)) - 0.5) * _NoiseAmplitude;
                        float randomOffsetY = (SmoothNoise(currPoint + float2(0.0, 1.0)) - 0.5) * _NoiseAmplitude;

                        // Combine random offsets into a displacement vector
                        float2 randomOffset = float2(randomOffsetX, randomOffsetY);

                        // Apply dynamic rotation
                        float rotationAngle = _SpinSpeed * distortionFactor * sin(time);

                        // Rotate UV with additional random offset
                        uv = RotatePoint(uv + randomOffset, currPoint, rotationAngle);

                        // Accumulate distortion effects
                        totalDistortion += (currPoint - uv) * distortionFactor * _DistortionStrength;
                    }
                }

                uv += totalDistortion;
                color = tex2D(_MainTex, uv);
                return color;
            }
            ENDCG
        }
    }
}
