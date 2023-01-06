Shader "EditedToon/Lit" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_SecondColor ("Secondary Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_DispTex ("Displacement Texture", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {} 
		_Displacement("Displacement", Range(0,2)) = 0.1
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
CGPROGRAM
#pragma surface surf ToonRamp vertex:vert addshadow 

//You may have noticed that the shadows always stay at the original position. This is fixed by adding "addshadow" after "vertex:vert".
sampler2D _Ramp;

// custom lighting function that uses a texture ramp based
// on angle between light direction and normal
#pragma lighting ToonRamp exclude_path:prepass


//Sending values from the vertex to the surface function:
//In some cases you'll want to calculate something in the vertex function and then send it over to the surface function part.
//For this all you gotta do is declare a name(float4 dispTex) in the Input struct, then assign it in the vertex function (o.dispTex = d).
//Call it in the surface shader using IN. (IN.dispTex)

struct Input {
	float2 uv_MainTex : TEXCOORD0;
	float4 dispTex;
};

sampler2D _MainTex, _DispTex;
float4 _Color, _SecondColor;
float _Displacement;


//Where are the vertex and fragment parts ?
//This is a Surface shader, the "void surf" is basically the fragment shader here. When compiling it automatically gets converted to a (empty) vertex + fragment shader.
// inout appdata_full gives the mesh info through v. , out Input lets us send a value to the "void surf" via o


void vert(inout appdata_full v, out Input o)
{
	float3 worldpos = mul(unity_ObjectToWorld,v.vertex).xyz; // The mask texture can also be projected in world space. Instead of v.texcoord, use the world position:
	half4 disp = tex2Dlod(_DispTex,float4(worldpos.x,worldpos.y + _Time.y,0,0)); // Also can add (*) _Time.
	//half4 disp = tex2Dlod(_DispTex,v.texcoord); //Reading a texture is very similar to the way it's done in the surface shader.  Only instead of "tex2D" we need "tex2Dlod" and instead of "IN.uv_tex" it's "v.texcoord
	UNITY_INITIALIZE_OUTPUT(Input, o);
	//v.vertex.xyz += _Displacement; //As you can see the whole mesh moves up at an angle, local to the object.
	v.vertex.xyz += _Displacement * v.normal * disp; //It gets a bit more interesting if you multiply with the mesh's normals so the _Displacement value pushes outwards instead.
	o.dispTex = disp;
}


inline half4 LightingToonRamp (SurfaceOutput s, half3 lightDir, half atten)
{
	#ifndef USING_DIRECTIONAL_LIGHT
	lightDir = normalize(lightDir);
	#endif
	
	half d = dot (s.Normal, lightDir)*0.5 + 0.5;
	half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;
	
	half4 c;
	c.rgb = s.Albedo * _LightColor0.rgb * ramp * (atten * 2);
	c.a = 0;
	return c;
}


void surf (Input IN, inout SurfaceOutput o) {
	half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb + (IN.dispTex * _SecondColor);
	o.Alpha = c.a;
}
ENDCG

	} 

	Fallback "Diffuse"
}
