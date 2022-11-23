Shader "Unlit/Healthbar"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Health ("Health" , Range(0,1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"  }

        Pass
        {
            ZWrite Off
            
            // src * srcAlpha + dst * (1-srcAlpha) 
            Blend SrcAlpha OneMinusSrcAlpha // Alpha Blending
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float _Health;

            float InverseLerp(float a, float b, float v )
            {
                return (v-a) / (b-a);
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                float healthbarMask = _Health > i.uv.x;
                
                // clip(healthbarMask - 0.5); // Discarding unwanted fragments 

                float tHealthColor = saturate(InverseLerp(0.2,0.8,_Health));
                
                float3 healtbarColor = lerp(float3(1,0,0),float3(0,1,0) ,tHealthColor);
                // float3 bgColor = float3(0,0,0);
                // float3 outColor = lerp(bgColor,healtbarColor,healthbarMask);    // used without alphablending
                // return float4(outColor,1);

                float flash = cos(_Time.y * 4) * 0.4 + 1; // +1 for color saturation
                if(_Health <= 0.2)
                {
                    healtbarColor *= flash;
                }
                
                return float4(healtbarColor,healthbarMask * 0.5); 
            }
            ENDCG
        }
    }
}
