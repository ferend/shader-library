   #include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define USE_LIGHT

struct MeshData
{
    float4 vertex : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
    float4 tangent : TANGENT; // xyz = tangent dir, w = tangent sign
};

struct Interpolators
{
    float4 vertex : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : TEXTCOORD1;
    float3 tangent : TEXTCOORD2;
    float3 biTangent : TEXTCOORD3;
    float3 wPos : TEXTCOORD4;

    LIGHTING_COORDS(5,6) // Unity Macro for light interp
};

sampler2D _RockAlbedo;
sampler2D _RockNormals;
sampler2D _RockHeight;
sampler2D _DiffuseIBl;
float4 _RockAlbedo_ST;
float _Gloss;
float4 _Color;
float _NormalIntensity;
float _HeightStrenght;
float4 _AmbientLight;

Interpolators vert (MeshData v)
{
    Interpolators o;
    o.uv = TRANSFORM_TEX(v.uv, _RockAlbedo);

    // Adding the height (or .x is the same thing).
    // Text2dlod is for picking mip level yourself instead of having it get picked auto.
    // This will sample a specific MIP level.
    float height = tex2Dlod(_RockHeight, float4(o.uv, 0, 0)).x * 2 - 1;

    v.vertex.xyz  += v.normal * (height * _HeightStrenght) ;
    
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.normal = UnityObjectToWorldNormal(v.normal);
    o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.biTangent = cross(o.normal,o.tangent);//  cross product
    o.biTangent *= (v.tangent.w * unity_WorldTransformParams.w);
    o.wPos = mul(unity_ObjectToWorld, v.vertex);
    TRANSFER_VERTEX_TO_FRAGMENT(o); // 
    return o;
}

float4 frag (Interpolators i) : SV_Target
{
    float3 rock = tex2D(_RockAlbedo, i.uv );
    float3 surfaceColor = rock * _Color.rgb; // replace this with wherever you write color before, to sample it with texture
    float3 tangentSpaceNormal = UnpackNormal(tex2D(_RockNormals,i.uv));
    tangentSpaceNormal = lerp(float3(0,0,1),tangentSpaceNormal,_NormalIntensity);

    float3x3 mtxTangentToWorld = {
    i.tangent.x, i.biTangent.x,i.normal.x,
    i.tangent.y, i.biTangent.y,i.normal.y,
    i.tangent.z, i.biTangent.z,i.normal.z
    };

    float3 N = mul(mtxTangentToWorld, tangentSpaceNormal); // this gives us the world space normal
    
    // return tex2D(_RockNormals, i.uv);
    
    #ifdef USE_LIGHT
    
    // Diffuse lighting
    //Light vector
    
    // float3 N = normalize(i.normal) ;
    float3 L = normalize(UnityWorldSpaceLightDir(i.wPos));
    float attenuation = LIGHT_ATTENUATION(i); // Will read from the interpolator light coord
    
    float3 lambert = saturate(dot( N,L ));
    float3 diffuseLight = (lambert * attenuation) * _LightColor0.xyz;

    #ifdef IS_IN_BASE_PASS
            diffuseLight += _AmbientLight;
    #endif

    // Specular lighting
    float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
    float3 H = normalize(L+V);
    float3 specularLight = saturate(dot(H,N)) * (lambert >0);

    float specularExponent = exp2(_Gloss * 11 ) + 2;
                
    specularLight = pow(specularLight, specularExponent) * _Gloss * attenuation;
    specularLight *= _LightColor0.xyz;
                
    return float4(diffuseLight * surfaceColor  + specularLight, 1); // Dot product between the view vector and reflected light vector

    #endif


} 
