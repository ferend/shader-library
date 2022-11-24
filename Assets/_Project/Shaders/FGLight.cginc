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
    LIGHTING_COORDS(3,4) // Unity Macro for light interp
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
    TRANSFER_VERTEX_TO_FRAGMENT(o); // 
    return o;
}

float4 frag (Interpolators i) : SV_Target
{
    // Diffuse lighting
    //Light vector 
    float3 N = normalize(i.normal) ;
    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i); // Will read from the interpolator light coord
    
    float3 lambert = saturate(dot( N,L ));
    float3 diffuseLight = (lambert * attenuation) * _LightColor0.xyz;  

    // Specular lighting
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize(L+V);
    float3 specularLight = saturate(dot(H,N)) * (lambert >0);

    float specularExponent = exp2(_Gloss * 11 ) + 2;
                
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation;
    specularLight *= _LightColor0.xyz;
                
    return float4(diffuseLight * _Color  + specularLight, 1); // Dot product between the view vector and reflected light vector

} 
