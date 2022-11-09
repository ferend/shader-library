  Shader "Unlit/Shader1"
{
    Properties
    {
        // Input data
        //_MainTex ("Texture", 2D) = "white" {}
        _ColorA("Color A", Color) = (1,1,1,1)
        _ColorB("Color B", Color) = (1,1,1,1)
        _Scale("UV Scale",Float) = 1
        _Offset ("UV Offset",Float) = 0
        _ColorStart("Color Start",Range(0,1)) = 1
        _ColorEnd("Color End",Range(0,1)) = 0
        _WaveAmp("Wave Amplitude", Range(0,0.2)) = 0.1 
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" // Tag to inform what type of shader this is 
            }  
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.283185

            float4 _ColorA;
            float4 _ColorB;
            float _Scale;
            float _Offset;
            float _ColorStart;
            float _ColorEnd;
            float _WaveAmp;
            
            struct MeshData // per vertex mesh data
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
                // float3 tangent : TANGENT;
                float4 uv0 : TEXCOORD0;
                
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD1;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };


            float GetWave(float2 uv)
            {
                float2 uvCentered = uv * 2 - 1;
                float radialDistance = length(uvCentered);
                float t = sin((radialDistance  - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5; // Cosine wave
                t *= 1- radialDistance;
                 return  t;
            }


            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.y = GetWave(v.uv0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal( v.normals); // Just pass normals, convert it to world pos
                o.uv =  v.uv0; //(v.uv0 + _Offset) * _Scale; passtroguh
                return o;
            }
            

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }


            float CosWave(float2 uv)
            {

                float xOff = cos(uv.x * TAU * 8 ) * 0.01;
                float t = cos((uv.y + xOff - _Time.y * 0.1) * TAU * 5) * 0.5 + 0.5; // Cosine wave
                return  t;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // return  float4(i.uv,0,1); // converting float3 value to float 4
                
                // blend between two colors base on the x uv coord.
                // float4 outColor = lerp(_ColorA,_ColorB, i.uv.x);
                // return outColor;
                  
                // float t = saturate(InverseLerp(_ColorStart,_ColorEnd,i.uv.x));
                // float4 outColor = lerp(_ColorA,_ColorB,t );
                // return outColor;
                

                return GetWave(i.uv);


                // float topBottomRemover = (abs(i.normal.y) < 0.5);
                // float waves = t * topBottomRemover;
                //
                // float4 gradient = lerp(_ColorA,_ColorB, i.uv.y);
                //
                // return waves * gradient;
                
            }
            ENDCG
        }
    }
}
