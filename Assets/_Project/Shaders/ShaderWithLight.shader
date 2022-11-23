Shader "Unlit/ShaderWithLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct Interpolators
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXTCOORD1;
                float3 wPos : TEXTCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag (Interpolators i) : SV_Target
            {
                // Diffuse lighting
                //Light vector 
                float3 N = i.normal;
                float3 L = _WorldSpaceLightPos0.xyz; // a direction
                float diffuseLight = saturate(dot(N,L)); // Lambertian light equation
                //return float4(diffuseLight.xxx ,1);

                // Specular lighting
                float3 V = _WorldSpaceCameraPos - i.wPos;
                float3 R = reflect(-L,N); // Reflection
                float3 specularLight = saturate(dot(V,R));
                return float4(specularLight.xxx ,1); // Dot product between the view vector and reflected light vector


                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
