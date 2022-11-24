Shader "Unlit/ShaderWithLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Gloss("Gloss",Range(0,1)) = 1
        _Color("Color", Color) = (1,1,1,1)
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
            float _Gloss;
            float4 _Color;

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
                float3 N = normalize(i.normal) ;
                float3 L = _WorldSpaceLightPos0.xyz; // a direction
                float3 lambert = saturate(dot( N,L ));
                //float diffuseLight = saturate(dot(N,L)); // Lambertian light equation
                float diffuseLight = lambert * _LightColor0.xyz;  
                //return float4(diffuseLight.xxx ,1);

                // Specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                //float3s R = reflect(-L,N); // Reflection
                float3 H = normalize(L+V);
                float3 specularLight = saturate(dot(H,N)) * (lambert >0);

                float specularExponent = exp2(_Gloss * 11 ) + 2;
                
                specularLight = pow(specularLight, specularExponent) * _Gloss;
                specularLight *= _LightColor0.xyz;

                //Fresnel effect 
                //float fresnel = 1 - dot(V,N); // Glowing effect
                float fresnel = (1 - dot(V,N)) * (cos(_Time.y * 4)); 
                
                //return float4(specularLight , specularExponent); // Dot product between the view vector and reflected light vector
                return float4(diffuseLight * _Color + specularLight + fresnel , 1); // Compositing


                // sample the texture
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
