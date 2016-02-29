// Updated for Sunshine 1.4.3
Shader "Sunshine/Nature/Terrain/Diffuse" {
Properties {
	_Control ("Control (RGBA)", 2D) = "red" {}
	_Splat3 ("Layer 3 (A)", 2D) = "white" {}
	_Splat2 ("Layer 2 (B)", 2D) = "white" {}
	_Splat1 ("Layer 1 (G)", 2D) = "white" {}
	_Splat0 ("Layer 0 (R)", 2D) = "white" {}
	// used in fallback on old cards & base map
	_MainTex ("BaseMap (RGB)", 2D) = "white" {}
	_Color ("Main Color", Color) = (1,1,1,1)
}
	
SubShader {
	Tags {
		"SplatCount" = "4"
		"Queue" = "Geometry-100"
		"RenderType" = "Opaque"
	}
CGPROGRAM
 #include "Assets/Sunshine/Shaders/Sunshine.cginc"
#pragma multi_compile SUNSHINE_DISABLED SUNSHINE_FILTER_PCF_4x4 SUNSHINE_FILTER_PCF_3x3 SUNSHINE_FILTER_PCF_2x2 SUNSHINE_FILTER_HARD
#pragma target 3.0

#pragma surface surf Lambert vertex:sunshine_surf_vert exclude_path:prepass
struct Input {
	float2 uv_Control : TEXCOORD0;
	float2 uv_Splat0 : TEXCOORD1;
	float2 uv_Splat1 : TEXCOORD2;
	float2 uv_Splat2 : TEXCOORD3;
	float2 uv_Splat3 : TEXCOORD4;
	SUNSHINE_INPUT_PARAMS;
};

SUNSHINE_SURFACE_VERT(Input)

sampler2D _Control;
sampler2D _Splat0,_Splat1,_Splat2,_Splat3;

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 splat_control = tex2D (_Control, IN.uv_Control);
	fixed3 col = 0.0;
	col  = splat_control.r * tex2D (_Splat0, IN.uv_Splat0).rgb;
	col += splat_control.g * tex2D (_Splat1, IN.uv_Splat1).rgb;
	col += splat_control.b * tex2D (_Splat2, IN.uv_Splat2).rgb;
	col += splat_control.a * tex2D (_Splat3, IN.uv_Splat3).rgb;
	
	o.Albedo = col;
	o.Alpha = 0.0;
}
ENDCG  
}

Dependency "AddPassShader" = "Hidden/Sunshine/TerrainEngine/Splatmap/Lightmap-AddPass"
Dependency "BaseMapShader" = "Sunshine/Diffuse"

// Fallback to Built-In Terrain...
Fallback "Hidden/TerrainEngine/Splatmap/Lightmap-FirstPass"
}
