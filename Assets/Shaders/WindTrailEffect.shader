Shader "Shaders/WindTrailEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _FlowMap ("Flow Map", 2D) = "black" {}
        _MaxRadius ("Max Radius", Float) = 0.2
        _FlowSpeed ("Flow Speed", Float) = 0.5
        _Center ("Effect Center", Vector) = (0.5, 0.5, 0.0, 0.0)  // Center of the distortion (normalized UV coordinates)
        _PointPosition ("Point Position", Vector) = (0.0, 0.0, 0.0, 0.0)  // Position of the spawned points
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Background" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            sampler2D _FlowMap;
            float _MaxRadius;
            float _FlowSpeed;
            float4 _Center;  // Center of the effect
            float4 _PointPosition;  // Position of the flow point

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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // Calculate distance from the point position
                float distanceFromCenter = length(uv - _PointPosition.xy); // Using UV space for the center

                // Apply the flow map effect only within the radius
                if (distanceFromCenter < _MaxRadius)
                {
                    // Get flow direction from flow map
                    float2 flow = tex2D(_FlowMap, uv).rg * 2.0 - 1.0;  // Map flow values from [0,1] to [-1,1]
                    float2 flowOffset = flow * _FlowSpeed * _Time.y;    // Apply flow map over time

                    // Offset UV coordinates by flow direction
                    uv += flowOffset;

                    // Apply a falloff based on the distance from the center of the flow
                    float falloff = saturate(1.0 - distanceFromCenter / _MaxRadius);  // Fade effect near the edges
                    uv += (flowOffset * falloff);  // Adjust UV with falloff
                }

                // Sample the texture with adjusted UVs
                fixed4 color = tex2D(_MainTex, uv);

                return color;
            }
            ENDCG
        }
    }
}
