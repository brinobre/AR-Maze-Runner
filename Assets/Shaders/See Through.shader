Shader "MyShaders/See Through"
{
Properties
{
Color_79b7e270560a487f8ff062ee3f7377ce("Tint", Color) = (1, 1, 1, 1)
[NoScaleOffset]Texture2D_65cb25bd67b5407e9004e60484e1104e("Main Texture", 2D) = "white" {}
_Position("Player Position", Vector) = (0.5, 0.5, 0, 0)
_Size("Size", Float) = 1
Vector1_4dec99e223444e13bbf41955a9b696fd("Smoothness", Range(0, 1)) = 0.5
Vector1_3d2ae6f716e9473aae47329d41c20032("Opacity", Range(0, 1)) = 1
[NoScaleOffset]Texture2D_db2b308b884e42609e0d145f45085c37("Metallic Texture", 2D) = "white" {}
[NoScaleOffset]Texture2D_ac3b49561738490c8d29da1820bee850("Normal Texture", 2D) = "white" {}
[NoScaleOffset]Texture2D_97cc43a66ffa487dbd481451877675e1("Emission Texture", 2D) = "white" {}
Vector1_89f7a522db9f48c39459949739cd5a06("Smoothness 2", Float) = 0.5
[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
[HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
}
SubShader
{
Tags
{
"RenderPipeline" = "UniversalPipeline"
"RenderType" = "Transparent"
"UniversalMaterialType" = "Lit"
"Queue" = "Transparent"
}
Pass
{
Name "Universal Forward"
Tags
{
"LightMode" = "UniversalForward"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
#pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
#pragma multi_compile _ SHADOWS_SHADOWMASK
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_VIEWDIRECTION_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_FORWARD
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
float3 normalWS;
float4 tangentWS;
float4 texCoord0;
float3 viewDirectionWS;
#if defined(LIGHTMAP_ON)
float2 lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
float3 sh;
#endif
float4 fogFactorAndVertexLight;
float4 shadowCoord;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 TangentSpaceNormal;
float3 WorldSpacePosition;
float4 ScreenPosition;
float4 uv0;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
float3 interp1 : TEXCOORD1;
float4 interp2 : TEXCOORD2;
float4 interp3 : TEXCOORD3;
float3 interp4 : TEXCOORD4;
#if defined(LIGHTMAP_ON)
float2 interp5 : TEXCOORD5;
#endif
#if !defined(LIGHTMAP_ON)
float3 interp6 : TEXCOORD6;
#endif
float4 interp7 : TEXCOORD7;
float4 interp8 : TEXCOORD8;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
output.interp1.xyz = input.normalWS;
output.interp2.xyzw = input.tangentWS;
output.interp3.xyzw = input.texCoord0;
output.interp4.xyz = input.viewDirectionWS;
#if defined(LIGHTMAP_ON)
output.interp5.xy = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.interp6.xyz = input.sh;
#endif
output.interp7.xyzw = input.fogFactorAndVertexLight;
output.interp8.xyzw = input.shadowCoord;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
output.normalWS = input.interp1.xyz;
output.tangentWS = input.interp2.xyzw;
output.texCoord0 = input.interp3.xyzw;
output.viewDirectionWS = input.interp4.xyz;
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.interp5.xy;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.interp6.xyz;
#endif
output.fogFactorAndVertexLight = input.interp7.xyzw;
output.shadowCoord = input.interp8.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_bd3ee276f357480e8295e85686039966_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_Sampler_3_Linear_Repeat);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
float4 _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850, samplerTexture2D_ac3b49561738490c8d29da1820bee850, IN.uv0.xy);
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_R_4 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.r;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_G_5 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.g;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_B_6 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.b;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_A_7 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.a;
float4 _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37, samplerTexture2D_db2b308b884e42609e0d145f45085c37, IN.uv0.xy);
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_R_4 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.r;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_G_5 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.g;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_B_6 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.b;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_A_7 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.a;
float _Property_4617140cbeee48a8814fb890788b045d_Out_0 = Vector1_89f7a522db9f48c39459949739cd5a06;
float4 _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1, samplerTexture2D_97cc43a66ffa487dbd481451877675e1, IN.uv0.xy);
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_R_4 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.r;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_G_5 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.g;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_B_6 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.b;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_A_7 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.a;
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
surface.NormalTS = (_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.xyz);
surface.Emission = float3(0, 0, 0);
surface.Metallic = (_SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0).x;
surface.Smoothness = _Property_4617140cbeee48a8814fb890788b045d_Out_0;
surface.Occlusion = (_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0).x;
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

ENDHLSL
}
Pass
{
Name "GBuffer"
Tags
{
"LightMode" = "UniversalGBuffer"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile_fog
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
#pragma multi_compile _ LIGHTMAP_ON
#pragma multi_compile _ DIRLIGHTMAP_COMBINED
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS
#pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
#pragma multi_compile _ _SHADOWS_SOFT
#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
#pragma multi_compile _ _GBUFFER_NORMALS_OCT
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define VARYINGS_NEED_VIEWDIRECTION_WS
#define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_GBUFFER
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
float3 normalWS;
float4 tangentWS;
float4 texCoord0;
float3 viewDirectionWS;
#if defined(LIGHTMAP_ON)
float2 lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
float3 sh;
#endif
float4 fogFactorAndVertexLight;
float4 shadowCoord;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 TangentSpaceNormal;
float3 WorldSpacePosition;
float4 ScreenPosition;
float4 uv0;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
float3 interp1 : TEXCOORD1;
float4 interp2 : TEXCOORD2;
float4 interp3 : TEXCOORD3;
float3 interp4 : TEXCOORD4;
#if defined(LIGHTMAP_ON)
float2 interp5 : TEXCOORD5;
#endif
#if !defined(LIGHTMAP_ON)
float3 interp6 : TEXCOORD6;
#endif
float4 interp7 : TEXCOORD7;
float4 interp8 : TEXCOORD8;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
output.interp1.xyz = input.normalWS;
output.interp2.xyzw = input.tangentWS;
output.interp3.xyzw = input.texCoord0;
output.interp4.xyz = input.viewDirectionWS;
#if defined(LIGHTMAP_ON)
output.interp5.xy = input.lightmapUV;
#endif
#if !defined(LIGHTMAP_ON)
output.interp6.xyz = input.sh;
#endif
output.interp7.xyzw = input.fogFactorAndVertexLight;
output.interp8.xyzw = input.shadowCoord;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
output.normalWS = input.interp1.xyz;
output.tangentWS = input.interp2.xyzw;
output.texCoord0 = input.interp3.xyzw;
output.viewDirectionWS = input.interp4.xyz;
#if defined(LIGHTMAP_ON)
output.lightmapUV = input.interp5.xy;
#endif
#if !defined(LIGHTMAP_ON)
output.sh = input.interp6.xyz;
#endif
output.fogFactorAndVertexLight = input.interp7.xyzw;
output.shadowCoord = input.interp8.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_bd3ee276f357480e8295e85686039966_Sampler_3_Linear_Repeat);
SAMPLER(_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_Sampler_3_Linear_Repeat);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 NormalTS;
float3 Emission;
float Metallic;
float Smoothness;
float Occlusion;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
float4 _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850, samplerTexture2D_ac3b49561738490c8d29da1820bee850, IN.uv0.xy);
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_R_4 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.r;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_G_5 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.g;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_B_6 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.b;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_A_7 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.a;
float4 _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37, samplerTexture2D_db2b308b884e42609e0d145f45085c37, IN.uv0.xy);
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_R_4 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.r;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_G_5 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.g;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_B_6 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.b;
float _SampleTexture2D_bd3ee276f357480e8295e85686039966_A_7 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.a;
float _Property_4617140cbeee48a8814fb890788b045d_Out_0 = Vector1_89f7a522db9f48c39459949739cd5a06;
float4 _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1, samplerTexture2D_97cc43a66ffa487dbd481451877675e1, IN.uv0.xy);
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_R_4 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.r;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_G_5 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.g;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_B_6 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.b;
float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_A_7 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.a;
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
surface.NormalTS = (_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.xyz);
surface.Emission = float3(0, 0, 0);
surface.Metallic = (_SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0).x;
surface.Smoothness = _Property_4617140cbeee48a8814fb890788b045d_Out_0;
surface.Occlusion = (_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0).x;
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"

ENDHLSL
}
Pass
{
Name "ShadowCaster"
Tags
{
"LightMode" = "ShadowCaster"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_SHADOWCASTER
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 WorldSpacePosition;
float4 ScreenPosition;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

ENDHLSL
}
Pass
{
Name "DepthOnly"
Tags
{
"LightMode" = "DepthOnly"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite On
ColorMask 0

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define VARYINGS_NEED_POSITION_WS
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHONLY
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 WorldSpacePosition;
float4 ScreenPosition;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

ENDHLSL
}
Pass
{
Name "DepthNormals"
Tags
{
"LightMode" = "DepthNormals"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite On

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma multi_compile_instancing
#pragma multi_compile _ DOTS_INSTANCING_ON
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_NORMAL_WS
#define VARYINGS_NEED_TANGENT_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
float3 normalWS;
float4 tangentWS;
float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 TangentSpaceNormal;
float3 WorldSpacePosition;
float4 ScreenPosition;
float4 uv0;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
float3 interp1 : TEXCOORD1;
float4 interp2 : TEXCOORD2;
float4 interp3 : TEXCOORD3;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
output.interp1.xyz = input.normalWS;
output.interp2.xyzw = input.tangentWS;
output.interp3.xyzw = input.texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
output.normalWS = input.interp1.xyz;
output.tangentWS = input.interp2.xyzw;
output.texCoord0 = input.interp3.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_Sampler_3_Linear_Repeat);

// Graph Functions

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float3 NormalTS;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850, samplerTexture2D_ac3b49561738490c8d29da1820bee850, IN.uv0.xy);
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_R_4 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.r;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_G_5 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.g;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_B_6 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.b;
float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_A_7 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.a;
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.NormalTS = (_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.xyz);
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

ENDHLSL
}
Pass
{
Name "Meta"
Tags
{
"LightMode" = "Meta"
}

// Render State
Cull Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
#pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define ATTRIBUTES_NEED_TEXCOORD1
#define ATTRIBUTES_NEED_TEXCOORD2
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_META
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
float4 uv1 : TEXCOORD1;
float4 uv2 : TEXCOORD2;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 WorldSpacePosition;
float4 ScreenPosition;
float4 uv0;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
float4 interp1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
output.interp1.xyzw = input.texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
output.texCoord0 = input.interp1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
float3 Position;
float3 Normal;
float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
VertexDescription description = (VertexDescription)0;
description.Position = IN.ObjectSpacePosition;
description.Normal = IN.ObjectSpaceNormal;
description.Tangent = IN.ObjectSpaceTangent;
return description;
}

// Graph Pixel
struct SurfaceDescription
{
float3 BaseColor;
float3 Emission;
float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
SurfaceDescription surface = (SurfaceDescription)0;
float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
surface.Emission = float3(0, 0, 0);
surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
VertexDescriptionInputs output;
ZERO_INITIALIZE(VertexDescriptionInputs, output);

output.ObjectSpaceNormal = input.normalOS;
output.ObjectSpaceTangent = input.tangentOS;
output.ObjectSpacePosition = input.positionOS;

return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
SurfaceDescriptionInputs output;
ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





output.WorldSpacePosition = input.positionWS;
output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

ENDHLSL
}
Pass
{
// Name: <None>
Tags
{
"LightMode" = "Universal2D"
}

// Render State
Cull Back
Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
ZTest LEqual
ZWrite Off

// Debug
// <None>

// --------------------------------------------------
// Pass

HLSLPROGRAM

// Pragmas
#pragma target 4.5
#pragma exclude_renderers gles gles3 glcore
#pragma vertex vert
#pragma fragment frag

// DotsInstancingOptions: <None>
// HybridV1InjectedBuiltinProperties: <None>

// Keywords
// PassKeywords: <None>
// GraphKeywords: <None>

// Defines
#define _SURFACE_TYPE_TRANSPARENT 1
#define _NORMALMAP 1
#define _NORMAL_DROPOFF_TS 1
#define ATTRIBUTES_NEED_NORMAL
#define ATTRIBUTES_NEED_TANGENT
#define ATTRIBUTES_NEED_TEXCOORD0
#define VARYINGS_NEED_POSITION_WS
#define VARYINGS_NEED_TEXCOORD0
#define FEATURES_GRAPH_VERTEX
/* WARNING: $splice Could not find named fragment 'PassInstancing' */
#define SHADERPASS SHADERPASS_2D
/* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

// Includes
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

// --------------------------------------------------
// Structs and Packing

struct Attributes
{
float3 positionOS : POSITION;
float3 normalOS : NORMAL;
float4 tangentOS : TANGENT;
float4 uv0 : TEXCOORD0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : INSTANCEID_SEMANTIC;
#endif
};
struct Varyings
{
float4 positionCS : SV_POSITION;
float3 positionWS;
float4 texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};
struct SurfaceDescriptionInputs
{
float3 WorldSpacePosition;
float4 ScreenPosition;
float4 uv0;
};
struct VertexDescriptionInputs
{
float3 ObjectSpaceNormal;
float3 ObjectSpaceTangent;
float3 ObjectSpacePosition;
};
struct PackedVaryings
{
float4 positionCS : SV_POSITION;
float3 interp0 : TEXCOORD0;
float4 interp1 : TEXCOORD1;
#if UNITY_ANY_INSTANCING_ENABLED
uint instanceID : CUSTOM_INSTANCE_ID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
#endif
};

PackedVaryings PackVaryings(Varyings input)
{
PackedVaryings output;
output.positionCS = input.positionCS;
output.interp0.xyz = input.positionWS;
output.interp1.xyzw = input.texCoord0;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}
Varyings UnpackVaryings(PackedVaryings input)
{
Varyings output;
output.positionCS = input.positionCS;
output.positionWS = input.interp0.xyz;
output.texCoord0 = input.interp1.xyzw;
#if UNITY_ANY_INSTANCING_ENABLED
output.instanceID = input.instanceID;
#endif
#if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
#endif
#if (defined(UNITY_STEREO_INSTANCING_ENABLED))
output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
#endif
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
output.cullFace = input.cullFace;
#endif
return output;
}

// --------------------------------------------------
// Graph

// Graph Properties
CBUFFER_START(UnityPerMaterial)
float4 Color_79b7e270560a487f8ff062ee3f7377ce;
float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
float2 _Position;
float _Size;
float Vector1_4dec99e223444e13bbf41955a9b696fd;
float Vector1_3d2ae6f716e9473aae47329d41c20032;
float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
float Vector1_89f7a522db9f48c39459949739cd5a06;
CBUFFER_END

// Object and Global properties
TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);

// Graph Functions

void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
{
    Out = A * B;
}

void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
{
    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void Unity_Add_float2(float2 A, float2 B, out float2 Out)
{
    Out = A + B;
}

void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
{
    Out = UV * Tiling + Offset;
}

void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
{
    Out = A * B;
}

void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
{
    Out = A - B;
}

void Unity_Divide_float(float A, float B, out float Out)
{
    Out = A / B;
}

void Unity_Multiply_float(float A, float B, out float Out)
{
    Out = A * B;
}

void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
{
    Out = A / B;
}

void Unity_Length_float2(float2 In, out float Out)
{
    Out = length(In);
}

void Unity_OneMinus_float(float In, out float Out)
{
    Out = 1 - In;
}

void Unity_Saturate_float(float In, out float Out)
{
    Out = saturate(In);
}

void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
{
    Out = smoothstep(Edge1, Edge2, In);
}

// Graph Vertex
struct VertexDescription
{
    float3 Position;
    float3 Normal;
    float3 Tangent;
};

VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
{
    VertexDescription description = (VertexDescription)0;
    description.Position = IN.ObjectSpacePosition;
    description.Normal = IN.ObjectSpaceNormal;
    description.Tangent = IN.ObjectSpaceTangent;
    return description;
}

// Graph Pixel
struct SurfaceDescription
{
    float3 BaseColor;
    float Alpha;
};

SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
{
    SurfaceDescription surface = (SurfaceDescription)0;
    float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
    float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
    float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
    Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
    float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
    float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
    float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
    float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
    Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
    float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
    Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
    float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
    Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
    float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
    Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
    float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
    Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
    float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
    float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
    float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
    Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
    float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
    float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
    Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
    float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
    Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
    float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
    Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
    float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
    Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
    float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
    Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
    float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
    float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
    Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
    float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
    Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
    surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
    surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
    return surface;
}

// --------------------------------------------------
// Build Graph Inputs

VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
{
    VertexDescriptionInputs output;
    ZERO_INITIALIZE(VertexDescriptionInputs, output);

    output.ObjectSpaceNormal = input.normalOS;
    output.ObjectSpaceTangent = input.tangentOS;
    output.ObjectSpacePosition = input.positionOS;

    return output;
}

SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
{
    SurfaceDescriptionInputs output;
    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





    output.WorldSpacePosition = input.positionWS;
    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
    output.uv0 = input.texCoord0;
#if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
#else
#define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
#endif
#undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

    return output;
}


// --------------------------------------------------
// Main

#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

ENDHLSL
}
}
SubShader
{
    Tags
    {
        "RenderPipeline" = "UniversalPipeline"
        "RenderType" = "Transparent"
        "UniversalMaterialType" = "Lit"
        "Queue" = "Transparent"
    }
    Pass
    {
        Name "Universal Forward"
        Tags
        {
            "LightMode" = "UniversalForward"
        }

    // Render State
    Cull Back
    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
    ZTest LEqual
    ZWrite Off

    // Debug
    // <None>

    // --------------------------------------------------
    // Pass

    HLSLPROGRAM

    // Pragmas
    #pragma target 2.0
    #pragma only_renderers gles gles3 glcore
    #pragma multi_compile_instancing
    #pragma multi_compile_fog
    #pragma vertex vert
    #pragma fragment frag

    // DotsInstancingOptions: <None>
    // HybridV1InjectedBuiltinProperties: <None>

    // Keywords
    #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
    #pragma multi_compile _ LIGHTMAP_ON
    #pragma multi_compile _ DIRLIGHTMAP_COMBINED
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
    #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
    #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
    #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
    #pragma multi_compile _ _SHADOWS_SOFT
    #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    #pragma multi_compile _ SHADOWS_SHADOWMASK
    // GraphKeywords: <None>

    // Defines
    #define _SURFACE_TYPE_TRANSPARENT 1
    #define _NORMALMAP 1
    #define _NORMAL_DROPOFF_TS 1
    #define ATTRIBUTES_NEED_NORMAL
    #define ATTRIBUTES_NEED_TANGENT
    #define ATTRIBUTES_NEED_TEXCOORD0
    #define ATTRIBUTES_NEED_TEXCOORD1
    #define VARYINGS_NEED_POSITION_WS
    #define VARYINGS_NEED_NORMAL_WS
    #define VARYINGS_NEED_TANGENT_WS
    #define VARYINGS_NEED_TEXCOORD0
    #define VARYINGS_NEED_VIEWDIRECTION_WS
    #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
    #define FEATURES_GRAPH_VERTEX
    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
    #define SHADERPASS SHADERPASS_FORWARD
    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

    // Includes
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

    // --------------------------------------------------
    // Structs and Packing

    struct Attributes
    {
        float3 positionOS : POSITION;
        float3 normalOS : NORMAL;
        float4 tangentOS : TANGENT;
        float4 uv0 : TEXCOORD0;
        float4 uv1 : TEXCOORD1;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : INSTANCEID_SEMANTIC;
        #endif
    };
    struct Varyings
    {
        float4 positionCS : SV_POSITION;
        float3 positionWS;
        float3 normalWS;
        float4 tangentWS;
        float4 texCoord0;
        float3 viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        float2 lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 sh;
        #endif
        float4 fogFactorAndVertexLight;
        float4 shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };
    struct SurfaceDescriptionInputs
    {
        float3 TangentSpaceNormal;
        float3 WorldSpacePosition;
        float4 ScreenPosition;
        float4 uv0;
    };
    struct VertexDescriptionInputs
    {
        float3 ObjectSpaceNormal;
        float3 ObjectSpaceTangent;
        float3 ObjectSpacePosition;
    };
    struct PackedVaryings
    {
        float4 positionCS : SV_POSITION;
        float3 interp0 : TEXCOORD0;
        float3 interp1 : TEXCOORD1;
        float4 interp2 : TEXCOORD2;
        float4 interp3 : TEXCOORD3;
        float3 interp4 : TEXCOORD4;
        #if defined(LIGHTMAP_ON)
        float2 interp5 : TEXCOORD5;
        #endif
        #if !defined(LIGHTMAP_ON)
        float3 interp6 : TEXCOORD6;
        #endif
        float4 interp7 : TEXCOORD7;
        float4 interp8 : TEXCOORD8;
        #if UNITY_ANY_INSTANCING_ENABLED
        uint instanceID : CUSTOM_INSTANCE_ID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
        #endif
    };

    PackedVaryings PackVaryings(Varyings input)
    {
        PackedVaryings output;
        output.positionCS = input.positionCS;
        output.interp0.xyz = input.positionWS;
        output.interp1.xyz = input.normalWS;
        output.interp2.xyzw = input.tangentWS;
        output.interp3.xyzw = input.texCoord0;
        output.interp4.xyz = input.viewDirectionWS;
        #if defined(LIGHTMAP_ON)
        output.interp5.xy = input.lightmapUV;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.interp6.xyz = input.sh;
        #endif
        output.interp7.xyzw = input.fogFactorAndVertexLight;
        output.interp8.xyzw = input.shadowCoord;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }
    Varyings UnpackVaryings(PackedVaryings input)
    {
        Varyings output;
        output.positionCS = input.positionCS;
        output.positionWS = input.interp0.xyz;
        output.normalWS = input.interp1.xyz;
        output.tangentWS = input.interp2.xyzw;
        output.texCoord0 = input.interp3.xyzw;
        output.viewDirectionWS = input.interp4.xyz;
        #if defined(LIGHTMAP_ON)
        output.lightmapUV = input.interp5.xy;
        #endif
        #if !defined(LIGHTMAP_ON)
        output.sh = input.interp6.xyz;
        #endif
        output.fogFactorAndVertexLight = input.interp7.xyzw;
        output.shadowCoord = input.interp8.xyzw;
        #if UNITY_ANY_INSTANCING_ENABLED
        output.instanceID = input.instanceID;
        #endif
        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
        #endif
        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
        #endif
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        output.cullFace = input.cullFace;
        #endif
        return output;
    }

    // --------------------------------------------------
    // Graph

    // Graph Properties
    CBUFFER_START(UnityPerMaterial)
    float4 Color_79b7e270560a487f8ff062ee3f7377ce;
    float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
    float2 _Position;
    float _Size;
    float Vector1_4dec99e223444e13bbf41955a9b696fd;
    float Vector1_3d2ae6f716e9473aae47329d41c20032;
    float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
    float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
    float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
    float Vector1_89f7a522db9f48c39459949739cd5a06;
    CBUFFER_END

        // Object and Global properties
        TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
        SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
        TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
        SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
        TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
        SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
        TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
        SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
        SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);
        SAMPLER(_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_Sampler_3_Linear_Repeat);
        SAMPLER(_SampleTexture2D_bd3ee276f357480e8295e85686039966_Sampler_3_Linear_Repeat);
        SAMPLER(_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_Sampler_3_Linear_Repeat);

        // Graph Functions

        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
        {
            Out = A * B;
        }

        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
        {
            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
        }

        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A + B;
        }

        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
        {
            Out = UV * Tiling + Offset;
        }

        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
        {
            Out = A * B;
        }

        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A - B;
        }

        void Unity_Divide_float(float A, float B, out float Out)
        {
            Out = A / B;
        }

        void Unity_Multiply_float(float A, float B, out float Out)
        {
            Out = A * B;
        }

        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
        {
            Out = A / B;
        }

        void Unity_Length_float2(float2 In, out float Out)
        {
            Out = length(In);
        }

        void Unity_OneMinus_float(float In, out float Out)
        {
            Out = 1 - In;
        }

        void Unity_Saturate_float(float In, out float Out)
        {
            Out = saturate(In);
        }

        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
        {
            Out = smoothstep(Edge1, Edge2, In);
        }

        // Graph Vertex
        struct VertexDescription
        {
            float3 Position;
            float3 Normal;
            float3 Tangent;
        };

        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
        {
            VertexDescription description = (VertexDescription)0;
            description.Position = IN.ObjectSpacePosition;
            description.Normal = IN.ObjectSpaceNormal;
            description.Tangent = IN.ObjectSpaceTangent;
            return description;
        }

        // Graph Pixel
        struct SurfaceDescription
        {
            float3 BaseColor;
            float3 NormalTS;
            float3 Emission;
            float Metallic;
            float Smoothness;
            float Occlusion;
            float Alpha;
        };

        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
        {
            SurfaceDescription surface = (SurfaceDescription)0;
            float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
            float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
            float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
            Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
            float4 _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850, samplerTexture2D_ac3b49561738490c8d29da1820bee850, IN.uv0.xy);
            float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_R_4 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.r;
            float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_G_5 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.g;
            float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_B_6 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.b;
            float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_A_7 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.a;
            float4 _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37, samplerTexture2D_db2b308b884e42609e0d145f45085c37, IN.uv0.xy);
            float _SampleTexture2D_bd3ee276f357480e8295e85686039966_R_4 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.r;
            float _SampleTexture2D_bd3ee276f357480e8295e85686039966_G_5 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.g;
            float _SampleTexture2D_bd3ee276f357480e8295e85686039966_B_6 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.b;
            float _SampleTexture2D_bd3ee276f357480e8295e85686039966_A_7 = _SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0.a;
            float _Property_4617140cbeee48a8814fb890788b045d_Out_0 = Vector1_89f7a522db9f48c39459949739cd5a06;
            float4 _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1, samplerTexture2D_97cc43a66ffa487dbd481451877675e1, IN.uv0.xy);
            float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_R_4 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.r;
            float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_G_5 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.g;
            float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_B_6 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.b;
            float _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_A_7 = _SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0.a;
            float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
            float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
            float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
            float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
            Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
            float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
            Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
            float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
            Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
            float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
            Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
            float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
            Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
            float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
            float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
            float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
            Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
            float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
            float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
            Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
            float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
            Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
            float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
            Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
            float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
            Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
            float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
            Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
            float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
            float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
            Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
            float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
            Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
            surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
            surface.NormalTS = (_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.xyz);
            surface.Emission = float3(0, 0, 0);
            surface.Metallic = (_SampleTexture2D_bd3ee276f357480e8295e85686039966_RGBA_0).x;
            surface.Smoothness = _Property_4617140cbeee48a8814fb890788b045d_Out_0;
            surface.Occlusion = (_SampleTexture2D_79af8db5233c4b53a3dd2a48e805f092_RGBA_0).x;
            surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
            return surface;
        }

        // --------------------------------------------------
        // Build Graph Inputs

        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
        {
            VertexDescriptionInputs output;
            ZERO_INITIALIZE(VertexDescriptionInputs, output);

            output.ObjectSpaceNormal = input.normalOS;
            output.ObjectSpaceTangent = input.tangentOS;
            output.ObjectSpacePosition = input.positionOS;

            return output;
        }

        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
        {
            SurfaceDescriptionInputs output;
            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



            output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


            output.WorldSpacePosition = input.positionWS;
            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
            output.uv0 = input.texCoord0;
        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
        #else
        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
        #endif
        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

            return output;
        }


        // --------------------------------------------------
        // Main

        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"

        ENDHLSL
    }
    Pass
    {
        Name "ShadowCaster"
        Tags
        {
            "LightMode" = "ShadowCaster"
        }

            // Render State
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
            ZTest LEqual
            ZWrite On
            ColorMask 0

            // Debug
            // <None>

            // --------------------------------------------------
            // Pass

            HLSLPROGRAM

            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>

            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>

            // Defines
            #define _SURFACE_TYPE_TRANSPARENT 1
            #define _NORMALMAP 1
            #define _NORMAL_DROPOFF_TS 1
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define VARYINGS_NEED_POSITION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

            // --------------------------------------------------
            // Structs and Packing

            struct Attributes
            {
                float3 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                float3 WorldSpacePosition;
                float4 ScreenPosition;
            };
            struct VertexDescriptionInputs
            {
                float3 ObjectSpaceNormal;
                float3 ObjectSpaceTangent;
                float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                float4 positionCS : SV_POSITION;
                float3 interp0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };

            PackedVaryings PackVaryings(Varyings input)
            {
                PackedVaryings output;
                output.positionCS = input.positionCS;
                output.interp0.xyz = input.positionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            Varyings UnpackVaryings(PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }

            // --------------------------------------------------
            // Graph

            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 Color_79b7e270560a487f8ff062ee3f7377ce;
            float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
            float2 _Position;
            float _Size;
            float Vector1_4dec99e223444e13bbf41955a9b696fd;
            float Vector1_3d2ae6f716e9473aae47329d41c20032;
            float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
            float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
            float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
            float Vector1_89f7a522db9f48c39459949739cd5a06;
            CBUFFER_END

                // Object and Global properties
                TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
                SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
                TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
                SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
                TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
                SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
                TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
                SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);

                // Graph Functions

                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                {
                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                }

                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A + B;
                }

                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }

                void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                {
                    Out = A * B;
                }

                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A - B;
                }

                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }

                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }

                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                {
                    Out = A / B;
                }

                void Unity_Length_float2(float2 In, out float Out)
                {
                    Out = length(In);
                }

                void Unity_OneMinus_float(float In, out float Out)
                {
                    Out = 1 - In;
                }

                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }

                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                {
                    Out = smoothstep(Edge1, Edge2, In);
                }

                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };

                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    description.Position = IN.ObjectSpacePosition;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }

                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };

                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
                    float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                    float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
                    float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
                    Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
                    float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
                    Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
                    float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
                    Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
                    float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
                    Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
                    float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
                    Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
                    float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
                    float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
                    float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
                    Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
                    float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
                    float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
                    Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
                    float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
                    Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
                    float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
                    Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
                    float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
                    Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
                    float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
                    Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
                    float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
                    float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
                    Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
                    float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                    Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
                    surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                    return surface;
                }

                // --------------------------------------------------
                // Build Graph Inputs

                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                    output.ObjectSpaceNormal = input.normalOS;
                    output.ObjectSpaceTangent = input.tangentOS;
                    output.ObjectSpacePosition = input.positionOS;

                    return output;
                }

                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                    output.WorldSpacePosition = input.positionWS;
                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                    return output;
                }


                // --------------------------------------------------
                // Main

                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"

                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }

                    // Render State
                    Cull Back
                    Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                    ZTest LEqual
                    ZWrite On
                    ColorMask 0

                    // Debug
                    // <None>

                    // --------------------------------------------------
                    // Pass

                    HLSLPROGRAM

                    // Pragmas
                    #pragma target 2.0
                    #pragma only_renderers gles gles3 glcore
                    #pragma multi_compile_instancing
                    #pragma vertex vert
                    #pragma fragment frag

                    // DotsInstancingOptions: <None>
                    // HybridV1InjectedBuiltinProperties: <None>

                    // Keywords
                    // PassKeywords: <None>
                    // GraphKeywords: <None>

                    // Defines
                    #define _SURFACE_TYPE_TRANSPARENT 1
                    #define _NORMALMAP 1
                    #define _NORMAL_DROPOFF_TS 1
                    #define ATTRIBUTES_NEED_NORMAL
                    #define ATTRIBUTES_NEED_TANGENT
                    #define VARYINGS_NEED_POSITION_WS
                    #define FEATURES_GRAPH_VERTEX
                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                    #define SHADERPASS SHADERPASS_DEPTHONLY
                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                    // Includes
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                    // --------------------------------------------------
                    // Structs and Packing

                    struct Attributes
                    {
                        float3 positionOS : POSITION;
                        float3 normalOS : NORMAL;
                        float4 tangentOS : TANGENT;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : INSTANCEID_SEMANTIC;
                        #endif
                    };
                    struct Varyings
                    {
                        float4 positionCS : SV_POSITION;
                        float3 positionWS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };
                    struct SurfaceDescriptionInputs
                    {
                        float3 WorldSpacePosition;
                        float4 ScreenPosition;
                    };
                    struct VertexDescriptionInputs
                    {
                        float3 ObjectSpaceNormal;
                        float3 ObjectSpaceTangent;
                        float3 ObjectSpacePosition;
                    };
                    struct PackedVaryings
                    {
                        float4 positionCS : SV_POSITION;
                        float3 interp0 : TEXCOORD0;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        uint instanceID : CUSTOM_INSTANCE_ID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                        #endif
                    };

                    PackedVaryings PackVaryings(Varyings input)
                    {
                        PackedVaryings output;
                        output.positionCS = input.positionCS;
                        output.interp0.xyz = input.positionWS;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }
                    Varyings UnpackVaryings(PackedVaryings input)
                    {
                        Varyings output;
                        output.positionCS = input.positionCS;
                        output.positionWS = input.interp0.xyz;
                        #if UNITY_ANY_INSTANCING_ENABLED
                        output.instanceID = input.instanceID;
                        #endif
                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                        #endif
                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                        #endif
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        output.cullFace = input.cullFace;
                        #endif
                        return output;
                    }

                    // --------------------------------------------------
                    // Graph

                    // Graph Properties
                    CBUFFER_START(UnityPerMaterial)
                    float4 Color_79b7e270560a487f8ff062ee3f7377ce;
                    float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
                    float2 _Position;
                    float _Size;
                    float Vector1_4dec99e223444e13bbf41955a9b696fd;
                    float Vector1_3d2ae6f716e9473aae47329d41c20032;
                    float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
                    float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
                    float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
                    float Vector1_89f7a522db9f48c39459949739cd5a06;
                    CBUFFER_END

                        // Object and Global properties
                        TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
                        SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
                        TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
                        SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
                        TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
                        SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
                        TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
                        SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);

                        // Graph Functions

                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                        {
                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                        }

                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A + B;
                        }

                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                        {
                            Out = UV * Tiling + Offset;
                        }

                        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A - B;
                        }

                        void Unity_Divide_float(float A, float B, out float Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Multiply_float(float A, float B, out float Out)
                        {
                            Out = A * B;
                        }

                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                        {
                            Out = A / B;
                        }

                        void Unity_Length_float2(float2 In, out float Out)
                        {
                            Out = length(In);
                        }

                        void Unity_OneMinus_float(float In, out float Out)
                        {
                            Out = 1 - In;
                        }

                        void Unity_Saturate_float(float In, out float Out)
                        {
                            Out = saturate(In);
                        }

                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                        {
                            Out = smoothstep(Edge1, Edge2, In);
                        }

                        // Graph Vertex
                        struct VertexDescription
                        {
                            float3 Position;
                            float3 Normal;
                            float3 Tangent;
                        };

                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                        {
                            VertexDescription description = (VertexDescription)0;
                            description.Position = IN.ObjectSpacePosition;
                            description.Normal = IN.ObjectSpaceNormal;
                            description.Tangent = IN.ObjectSpaceTangent;
                            return description;
                        }

                        // Graph Pixel
                        struct SurfaceDescription
                        {
                            float Alpha;
                        };

                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                        {
                            SurfaceDescription surface = (SurfaceDescription)0;
                            float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
                            float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                            float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
                            float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
                            Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
                            float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
                            Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
                            float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
                            Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
                            float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
                            Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
                            float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
                            Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
                            float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
                            float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
                            float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
                            Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
                            float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
                            float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
                            Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
                            float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
                            Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
                            float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
                            Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
                            float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
                            Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
                            float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
                            Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
                            float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
                            float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
                            Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
                            float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                            Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
                            surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                            return surface;
                        }

                        // --------------------------------------------------
                        // Build Graph Inputs

                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                        {
                            VertexDescriptionInputs output;
                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                            output.ObjectSpaceNormal = input.normalOS;
                            output.ObjectSpaceTangent = input.tangentOS;
                            output.ObjectSpacePosition = input.positionOS;

                            return output;
                        }

                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                        {
                            SurfaceDescriptionInputs output;
                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                            output.WorldSpacePosition = input.positionWS;
                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                        #else
                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                        #endif
                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                            return output;
                        }


                        // --------------------------------------------------
                        // Main

                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"

                        ENDHLSL
                    }
                    Pass
                    {
                        Name "DepthNormals"
                        Tags
                        {
                            "LightMode" = "DepthNormals"
                        }

                            // Render State
                            Cull Back
                            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                            ZTest LEqual
                            ZWrite On

                            // Debug
                            // <None>

                            // --------------------------------------------------
                            // Pass

                            HLSLPROGRAM

                            // Pragmas
                            #pragma target 2.0
                            #pragma only_renderers gles gles3 glcore
                            #pragma multi_compile_instancing
                            #pragma vertex vert
                            #pragma fragment frag

                            // DotsInstancingOptions: <None>
                            // HybridV1InjectedBuiltinProperties: <None>

                            // Keywords
                            // PassKeywords: <None>
                            // GraphKeywords: <None>

                            // Defines
                            #define _SURFACE_TYPE_TRANSPARENT 1
                            #define _NORMALMAP 1
                            #define _NORMAL_DROPOFF_TS 1
                            #define ATTRIBUTES_NEED_NORMAL
                            #define ATTRIBUTES_NEED_TANGENT
                            #define ATTRIBUTES_NEED_TEXCOORD0
                            #define ATTRIBUTES_NEED_TEXCOORD1
                            #define VARYINGS_NEED_POSITION_WS
                            #define VARYINGS_NEED_NORMAL_WS
                            #define VARYINGS_NEED_TANGENT_WS
                            #define VARYINGS_NEED_TEXCOORD0
                            #define FEATURES_GRAPH_VERTEX
                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                            // Includes
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                            // --------------------------------------------------
                            // Structs and Packing

                            struct Attributes
                            {
                                float3 positionOS : POSITION;
                                float3 normalOS : NORMAL;
                                float4 tangentOS : TANGENT;
                                float4 uv0 : TEXCOORD0;
                                float4 uv1 : TEXCOORD1;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : INSTANCEID_SEMANTIC;
                                #endif
                            };
                            struct Varyings
                            {
                                float4 positionCS : SV_POSITION;
                                float3 positionWS;
                                float3 normalWS;
                                float4 tangentWS;
                                float4 texCoord0;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };
                            struct SurfaceDescriptionInputs
                            {
                                float3 TangentSpaceNormal;
                                float3 WorldSpacePosition;
                                float4 ScreenPosition;
                                float4 uv0;
                            };
                            struct VertexDescriptionInputs
                            {
                                float3 ObjectSpaceNormal;
                                float3 ObjectSpaceTangent;
                                float3 ObjectSpacePosition;
                            };
                            struct PackedVaryings
                            {
                                float4 positionCS : SV_POSITION;
                                float3 interp0 : TEXCOORD0;
                                float3 interp1 : TEXCOORD1;
                                float4 interp2 : TEXCOORD2;
                                float4 interp3 : TEXCOORD3;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                uint instanceID : CUSTOM_INSTANCE_ID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                #endif
                            };

                            PackedVaryings PackVaryings(Varyings input)
                            {
                                PackedVaryings output;
                                output.positionCS = input.positionCS;
                                output.interp0.xyz = input.positionWS;
                                output.interp1.xyz = input.normalWS;
                                output.interp2.xyzw = input.tangentWS;
                                output.interp3.xyzw = input.texCoord0;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }
                            Varyings UnpackVaryings(PackedVaryings input)
                            {
                                Varyings output;
                                output.positionCS = input.positionCS;
                                output.positionWS = input.interp0.xyz;
                                output.normalWS = input.interp1.xyz;
                                output.tangentWS = input.interp2.xyzw;
                                output.texCoord0 = input.interp3.xyzw;
                                #if UNITY_ANY_INSTANCING_ENABLED
                                output.instanceID = input.instanceID;
                                #endif
                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                #endif
                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                #endif
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                output.cullFace = input.cullFace;
                                #endif
                                return output;
                            }

                            // --------------------------------------------------
                            // Graph

                            // Graph Properties
                            CBUFFER_START(UnityPerMaterial)
                            float4 Color_79b7e270560a487f8ff062ee3f7377ce;
                            float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
                            float2 _Position;
                            float _Size;
                            float Vector1_4dec99e223444e13bbf41955a9b696fd;
                            float Vector1_3d2ae6f716e9473aae47329d41c20032;
                            float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
                            float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
                            float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
                            float Vector1_89f7a522db9f48c39459949739cd5a06;
                            CBUFFER_END

                                // Object and Global properties
                                TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
                                SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
                                TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
                                SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
                                TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
                                SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
                                TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
                                SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
                                SAMPLER(_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_Sampler_3_Linear_Repeat);

                                // Graph Functions

                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                {
                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                }

                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A + B;
                                }

                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                {
                                    Out = UV * Tiling + Offset;
                                }

                                void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A - B;
                                }

                                void Unity_Divide_float(float A, float B, out float Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Multiply_float(float A, float B, out float Out)
                                {
                                    Out = A * B;
                                }

                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                {
                                    Out = A / B;
                                }

                                void Unity_Length_float2(float2 In, out float Out)
                                {
                                    Out = length(In);
                                }

                                void Unity_OneMinus_float(float In, out float Out)
                                {
                                    Out = 1 - In;
                                }

                                void Unity_Saturate_float(float In, out float Out)
                                {
                                    Out = saturate(In);
                                }

                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                {
                                    Out = smoothstep(Edge1, Edge2, In);
                                }

                                // Graph Vertex
                                struct VertexDescription
                                {
                                    float3 Position;
                                    float3 Normal;
                                    float3 Tangent;
                                };

                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                {
                                    VertexDescription description = (VertexDescription)0;
                                    description.Position = IN.ObjectSpacePosition;
                                    description.Normal = IN.ObjectSpaceNormal;
                                    description.Tangent = IN.ObjectSpaceTangent;
                                    return description;
                                }

                                // Graph Pixel
                                struct SurfaceDescription
                                {
                                    float3 NormalTS;
                                    float Alpha;
                                };

                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                {
                                    SurfaceDescription surface = (SurfaceDescription)0;
                                    float4 _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850, samplerTexture2D_ac3b49561738490c8d29da1820bee850, IN.uv0.xy);
                                    float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_R_4 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.r;
                                    float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_G_5 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.g;
                                    float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_B_6 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.b;
                                    float _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_A_7 = _SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.a;
                                    float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
                                    float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                    float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
                                    float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
                                    Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
                                    float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
                                    Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
                                    float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
                                    Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
                                    float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
                                    Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
                                    float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
                                    Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
                                    float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
                                    float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
                                    float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
                                    Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
                                    float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
                                    float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
                                    Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
                                    float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
                                    Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
                                    float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
                                    Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
                                    float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
                                    Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
                                    float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
                                    Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
                                    float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
                                    float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
                                    Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
                                    float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                    Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
                                    surface.NormalTS = (_SampleTexture2D_f8e01f7d276a4d568c06ab2739888f46_RGBA_0.xyz);
                                    surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                    return surface;
                                }

                                // --------------------------------------------------
                                // Build Graph Inputs

                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                {
                                    VertexDescriptionInputs output;
                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                    output.ObjectSpaceNormal = input.normalOS;
                                    output.ObjectSpaceTangent = input.tangentOS;
                                    output.ObjectSpacePosition = input.positionOS;

                                    return output;
                                }

                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                {
                                    SurfaceDescriptionInputs output;
                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);



                                    output.TangentSpaceNormal = float3(0.0f, 0.0f, 1.0f);


                                    output.WorldSpacePosition = input.positionWS;
                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                    output.uv0 = input.texCoord0;
                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                #else
                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                #endif
                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                    return output;
                                }


                                // --------------------------------------------------
                                // Main

                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"

                                ENDHLSL
                            }
                            Pass
                            {
                                Name "Meta"
                                Tags
                                {
                                    "LightMode" = "Meta"
                                }

                                    // Render State
                                    Cull Off

                                    // Debug
                                    // <None>

                                    // --------------------------------------------------
                                    // Pass

                                    HLSLPROGRAM

                                    // Pragmas
                                    #pragma target 2.0
                                    #pragma only_renderers gles gles3 glcore
                                    #pragma vertex vert
                                    #pragma fragment frag

                                    // DotsInstancingOptions: <None>
                                    // HybridV1InjectedBuiltinProperties: <None>

                                    // Keywords
                                    #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                                    // GraphKeywords: <None>

                                    // Defines
                                    #define _SURFACE_TYPE_TRANSPARENT 1
                                    #define _NORMALMAP 1
                                    #define _NORMAL_DROPOFF_TS 1
                                    #define ATTRIBUTES_NEED_NORMAL
                                    #define ATTRIBUTES_NEED_TANGENT
                                    #define ATTRIBUTES_NEED_TEXCOORD0
                                    #define ATTRIBUTES_NEED_TEXCOORD1
                                    #define ATTRIBUTES_NEED_TEXCOORD2
                                    #define VARYINGS_NEED_POSITION_WS
                                    #define VARYINGS_NEED_TEXCOORD0
                                    #define FEATURES_GRAPH_VERTEX
                                    /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                    #define SHADERPASS SHADERPASS_META
                                    /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                    // Includes
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                                    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"

                                    // --------------------------------------------------
                                    // Structs and Packing

                                    struct Attributes
                                    {
                                        float3 positionOS : POSITION;
                                        float3 normalOS : NORMAL;
                                        float4 tangentOS : TANGENT;
                                        float4 uv0 : TEXCOORD0;
                                        float4 uv1 : TEXCOORD1;
                                        float4 uv2 : TEXCOORD2;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        uint instanceID : INSTANCEID_SEMANTIC;
                                        #endif
                                    };
                                    struct Varyings
                                    {
                                        float4 positionCS : SV_POSITION;
                                        float3 positionWS;
                                        float4 texCoord0;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };
                                    struct SurfaceDescriptionInputs
                                    {
                                        float3 WorldSpacePosition;
                                        float4 ScreenPosition;
                                        float4 uv0;
                                    };
                                    struct VertexDescriptionInputs
                                    {
                                        float3 ObjectSpaceNormal;
                                        float3 ObjectSpaceTangent;
                                        float3 ObjectSpacePosition;
                                    };
                                    struct PackedVaryings
                                    {
                                        float4 positionCS : SV_POSITION;
                                        float3 interp0 : TEXCOORD0;
                                        float4 interp1 : TEXCOORD1;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        uint instanceID : CUSTOM_INSTANCE_ID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                        #endif
                                    };

                                    PackedVaryings PackVaryings(Varyings input)
                                    {
                                        PackedVaryings output;
                                        output.positionCS = input.positionCS;
                                        output.interp0.xyz = input.positionWS;
                                        output.interp1.xyzw = input.texCoord0;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }
                                    Varyings UnpackVaryings(PackedVaryings input)
                                    {
                                        Varyings output;
                                        output.positionCS = input.positionCS;
                                        output.positionWS = input.interp0.xyz;
                                        output.texCoord0 = input.interp1.xyzw;
                                        #if UNITY_ANY_INSTANCING_ENABLED
                                        output.instanceID = input.instanceID;
                                        #endif
                                        #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                        output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                        #endif
                                        #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                        output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                        #endif
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        output.cullFace = input.cullFace;
                                        #endif
                                        return output;
                                    }

                                    // --------------------------------------------------
                                    // Graph

                                    // Graph Properties
                                    CBUFFER_START(UnityPerMaterial)
                                    float4 Color_79b7e270560a487f8ff062ee3f7377ce;
                                    float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
                                    float2 _Position;
                                    float _Size;
                                    float Vector1_4dec99e223444e13bbf41955a9b696fd;
                                    float Vector1_3d2ae6f716e9473aae47329d41c20032;
                                    float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
                                    float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
                                    float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
                                    float Vector1_89f7a522db9f48c39459949739cd5a06;
                                    CBUFFER_END

                                        // Object and Global properties
                                        TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
                                        SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
                                        TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
                                        SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
                                        TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
                                        SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
                                        TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
                                        SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
                                        SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);

                                        // Graph Functions

                                        void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                        {
                                            Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                        }

                                        void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A + B;
                                        }

                                        void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                        {
                                            Out = UV * Tiling + Offset;
                                        }

                                        void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A - B;
                                        }

                                        void Unity_Divide_float(float A, float B, out float Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Multiply_float(float A, float B, out float Out)
                                        {
                                            Out = A * B;
                                        }

                                        void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                        {
                                            Out = A / B;
                                        }

                                        void Unity_Length_float2(float2 In, out float Out)
                                        {
                                            Out = length(In);
                                        }

                                        void Unity_OneMinus_float(float In, out float Out)
                                        {
                                            Out = 1 - In;
                                        }

                                        void Unity_Saturate_float(float In, out float Out)
                                        {
                                            Out = saturate(In);
                                        }

                                        void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                        {
                                            Out = smoothstep(Edge1, Edge2, In);
                                        }

                                        // Graph Vertex
                                        struct VertexDescription
                                        {
                                            float3 Position;
                                            float3 Normal;
                                            float3 Tangent;
                                        };

                                        VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                        {
                                            VertexDescription description = (VertexDescription)0;
                                            description.Position = IN.ObjectSpacePosition;
                                            description.Normal = IN.ObjectSpaceNormal;
                                            description.Tangent = IN.ObjectSpaceTangent;
                                            return description;
                                        }

                                        // Graph Pixel
                                        struct SurfaceDescription
                                        {
                                            float3 BaseColor;
                                            float3 Emission;
                                            float Alpha;
                                        };

                                        SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                        {
                                            SurfaceDescription surface = (SurfaceDescription)0;
                                            float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
                                            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
                                            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
                                            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
                                            float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
                                            float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
                                            float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
                                            Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
                                            float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
                                            float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                            float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
                                            float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
                                            Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
                                            float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
                                            Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
                                            float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
                                            Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
                                            float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
                                            Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
                                            float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
                                            Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
                                            float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
                                            Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
                                            float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
                                            float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
                                            Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
                                            float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
                                            float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
                                            Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
                                            float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
                                            Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
                                            float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
                                            Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
                                            float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
                                            Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
                                            float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
                                            Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
                                            float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
                                            float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
                                            Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
                                            float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                            Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
                                            surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
                                            surface.Emission = float3(0, 0, 0);
                                            surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                            return surface;
                                        }

                                        // --------------------------------------------------
                                        // Build Graph Inputs

                                        VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                        {
                                            VertexDescriptionInputs output;
                                            ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                            output.ObjectSpaceNormal = input.normalOS;
                                            output.ObjectSpaceTangent = input.tangentOS;
                                            output.ObjectSpacePosition = input.positionOS;

                                            return output;
                                        }

                                        SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                        {
                                            SurfaceDescriptionInputs output;
                                            ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                            output.WorldSpacePosition = input.positionWS;
                                            output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                            output.uv0 = input.texCoord0;
                                        #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                        #else
                                        #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                        #endif
                                        #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                            return output;
                                        }


                                        // --------------------------------------------------
                                        // Main

                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                        #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"

                                        ENDHLSL
                                    }
                                    Pass
                                    {
                                            // Name: <None>
                                            Tags
                                            {
                                                "LightMode" = "Universal2D"
                                            }

                                            // Render State
                                            Cull Back
                                            Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                                            ZTest LEqual
                                            ZWrite Off

                                            // Debug
                                            // <None>

                                            // --------------------------------------------------
                                            // Pass

                                            HLSLPROGRAM

                                            // Pragmas
                                            #pragma target 2.0
                                            #pragma only_renderers gles gles3 glcore
                                            #pragma multi_compile_instancing
                                            #pragma vertex vert
                                            #pragma fragment frag

                                            // DotsInstancingOptions: <None>
                                            // HybridV1InjectedBuiltinProperties: <None>

                                            // Keywords
                                            // PassKeywords: <None>
                                            // GraphKeywords: <None>

                                            // Defines
                                            #define _SURFACE_TYPE_TRANSPARENT 1
                                            #define _NORMALMAP 1
                                            #define _NORMAL_DROPOFF_TS 1
                                            #define ATTRIBUTES_NEED_NORMAL
                                            #define ATTRIBUTES_NEED_TANGENT
                                            #define ATTRIBUTES_NEED_TEXCOORD0
                                            #define VARYINGS_NEED_POSITION_WS
                                            #define VARYINGS_NEED_TEXCOORD0
                                            #define FEATURES_GRAPH_VERTEX
                                            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                                            #define SHADERPASS SHADERPASS_2D
                                            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */

                                            // Includes
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                                            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                                            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

                                            // --------------------------------------------------
                                            // Structs and Packing

                                            struct Attributes
                                            {
                                                float3 positionOS : POSITION;
                                                float3 normalOS : NORMAL;
                                                float4 tangentOS : TANGENT;
                                                float4 uv0 : TEXCOORD0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                uint instanceID : INSTANCEID_SEMANTIC;
                                                #endif
                                            };
                                            struct Varyings
                                            {
                                                float4 positionCS : SV_POSITION;
                                                float3 positionWS;
                                                float4 texCoord0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };
                                            struct SurfaceDescriptionInputs
                                            {
                                                float3 WorldSpacePosition;
                                                float4 ScreenPosition;
                                                float4 uv0;
                                            };
                                            struct VertexDescriptionInputs
                                            {
                                                float3 ObjectSpaceNormal;
                                                float3 ObjectSpaceTangent;
                                                float3 ObjectSpacePosition;
                                            };
                                            struct PackedVaryings
                                            {
                                                float4 positionCS : SV_POSITION;
                                                float3 interp0 : TEXCOORD0;
                                                float4 interp1 : TEXCOORD1;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                uint instanceID : CUSTOM_INSTANCE_ID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                                                #endif
                                            };

                                            PackedVaryings PackVaryings(Varyings input)
                                            {
                                                PackedVaryings output;
                                                output.positionCS = input.positionCS;
                                                output.interp0.xyz = input.positionWS;
                                                output.interp1.xyzw = input.texCoord0;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }
                                            Varyings UnpackVaryings(PackedVaryings input)
                                            {
                                                Varyings output;
                                                output.positionCS = input.positionCS;
                                                output.positionWS = input.interp0.xyz;
                                                output.texCoord0 = input.interp1.xyzw;
                                                #if UNITY_ANY_INSTANCING_ENABLED
                                                output.instanceID = input.instanceID;
                                                #endif
                                                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                                                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                                                #endif
                                                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                                                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                                                #endif
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                output.cullFace = input.cullFace;
                                                #endif
                                                return output;
                                            }

                                            // --------------------------------------------------
                                            // Graph

                                            // Graph Properties
                                            CBUFFER_START(UnityPerMaterial)
                                            float4 Color_79b7e270560a487f8ff062ee3f7377ce;
                                            float4 Texture2D_65cb25bd67b5407e9004e60484e1104e_TexelSize;
                                            float2 _Position;
                                            float _Size;
                                            float Vector1_4dec99e223444e13bbf41955a9b696fd;
                                            float Vector1_3d2ae6f716e9473aae47329d41c20032;
                                            float4 Texture2D_db2b308b884e42609e0d145f45085c37_TexelSize;
                                            float4 Texture2D_ac3b49561738490c8d29da1820bee850_TexelSize;
                                            float4 Texture2D_97cc43a66ffa487dbd481451877675e1_TexelSize;
                                            float Vector1_89f7a522db9f48c39459949739cd5a06;
                                            CBUFFER_END

                                                // Object and Global properties
                                                TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e);
                                                SAMPLER(samplerTexture2D_65cb25bd67b5407e9004e60484e1104e);
                                                TEXTURE2D(Texture2D_db2b308b884e42609e0d145f45085c37);
                                                SAMPLER(samplerTexture2D_db2b308b884e42609e0d145f45085c37);
                                                TEXTURE2D(Texture2D_ac3b49561738490c8d29da1820bee850);
                                                SAMPLER(samplerTexture2D_ac3b49561738490c8d29da1820bee850);
                                                TEXTURE2D(Texture2D_97cc43a66ffa487dbd481451877675e1);
                                                SAMPLER(samplerTexture2D_97cc43a66ffa487dbd481451877675e1);
                                                SAMPLER(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_Sampler_3_Linear_Repeat);

                                                // Graph Functions

                                                void Unity_Multiply_float(float4 A, float4 B, out float4 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Remap_float2(float2 In, float2 InMinMax, float2 OutMinMax, out float2 Out)
                                                {
                                                    Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
                                                }

                                                void Unity_Add_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A + B;
                                                }

                                                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                                                {
                                                    Out = UV * Tiling + Offset;
                                                }

                                                void Unity_Multiply_float(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Subtract_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A - B;
                                                }

                                                void Unity_Divide_float(float A, float B, out float Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Multiply_float(float A, float B, out float Out)
                                                {
                                                    Out = A * B;
                                                }

                                                void Unity_Divide_float2(float2 A, float2 B, out float2 Out)
                                                {
                                                    Out = A / B;
                                                }

                                                void Unity_Length_float2(float2 In, out float Out)
                                                {
                                                    Out = length(In);
                                                }

                                                void Unity_OneMinus_float(float In, out float Out)
                                                {
                                                    Out = 1 - In;
                                                }

                                                void Unity_Saturate_float(float In, out float Out)
                                                {
                                                    Out = saturate(In);
                                                }

                                                void Unity_Smoothstep_float(float Edge1, float Edge2, float In, out float Out)
                                                {
                                                    Out = smoothstep(Edge1, Edge2, In);
                                                }

                                                // Graph Vertex
                                                struct VertexDescription
                                                {
                                                    float3 Position;
                                                    float3 Normal;
                                                    float3 Tangent;
                                                };

                                                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                                                {
                                                    VertexDescription description = (VertexDescription)0;
                                                    description.Position = IN.ObjectSpacePosition;
                                                    description.Normal = IN.ObjectSpaceNormal;
                                                    description.Tangent = IN.ObjectSpaceTangent;
                                                    return description;
                                                }

                                                // Graph Pixel
                                                struct SurfaceDescription
                                                {
                                                    float3 BaseColor;
                                                    float Alpha;
                                                };

                                                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                                                {
                                                    SurfaceDescription surface = (SurfaceDescription)0;
                                                    float4 _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0 = SAMPLE_TEXTURE2D(Texture2D_65cb25bd67b5407e9004e60484e1104e, samplerTexture2D_65cb25bd67b5407e9004e60484e1104e, IN.uv0.xy);
                                                    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_R_4 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.r;
                                                    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_G_5 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.g;
                                                    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_B_6 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.b;
                                                    float _SampleTexture2D_6ed3b44942c9476591a6356022e27114_A_7 = _SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0.a;
                                                    float4 _Property_542e228f13024157a4de705267712c5b_Out_0 = Color_79b7e270560a487f8ff062ee3f7377ce;
                                                    float4 _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2;
                                                    Unity_Multiply_float(_SampleTexture2D_6ed3b44942c9476591a6356022e27114_RGBA_0, _Property_542e228f13024157a4de705267712c5b_Out_0, _Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2);
                                                    float _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0 = Vector1_4dec99e223444e13bbf41955a9b696fd;
                                                    float4 _ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0 = float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0);
                                                    float2 _Property_aa584016e2fd4f8cb526856f372755da_Out_0 = _Position;
                                                    float2 _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3;
                                                    Unity_Remap_float2(_Property_aa584016e2fd4f8cb526856f372755da_Out_0, float2 (0, 1), float2 (0.5, -1.5), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3);
                                                    float2 _Add_224e5ced308a48e4b920da14f0e3294b_Out_2;
                                                    Unity_Add_float2((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), _Remap_b14050576f3d42168c2af61c4e1fd1cc_Out_3, _Add_224e5ced308a48e4b920da14f0e3294b_Out_2);
                                                    float2 _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3;
                                                    Unity_TilingAndOffset_float((_ScreenPosition_5c01c384a0864a52ab8dc4d766cfdb49_Out_0.xy), float2 (1, 1), _Add_224e5ced308a48e4b920da14f0e3294b_Out_2, _TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3);
                                                    float2 _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2;
                                                    Unity_Multiply_float(_TilingAndOffset_331dd27dffbb42d78a0c83a08c9fb29e_Out_3, float2(2, 2), _Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2);
                                                    float2 _Subtract_174975539c544f35989f43e32fb513be_Out_2;
                                                    Unity_Subtract_float2(_Multiply_30c369d4d4b144fba9306695286ecfd1_Out_2, float2(1, 1), _Subtract_174975539c544f35989f43e32fb513be_Out_2);
                                                    float _Divide_18876c5999034898a2ab85e84d8351e6_Out_2;
                                                    Unity_Divide_float(unity_OrthoParams.y, unity_OrthoParams.x, _Divide_18876c5999034898a2ab85e84d8351e6_Out_2);
                                                    float _Property_3cfe1111614b4659a5eb33391d155c38_Out_0 = _Size;
                                                    float _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2;
                                                    Unity_Multiply_float(_Divide_18876c5999034898a2ab85e84d8351e6_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0, _Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2);
                                                    float2 _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0 = float2(_Multiply_cbfa6090d35649e0b8c440b5f39d9540_Out_2, _Property_3cfe1111614b4659a5eb33391d155c38_Out_0);
                                                    float2 _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2;
                                                    Unity_Divide_float2(_Subtract_174975539c544f35989f43e32fb513be_Out_2, _Vector2_83c25e2759d043c5bcfb49d20209afa4_Out_0, _Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2);
                                                    float _Length_31469e9880b244be96422d18d79ab7df_Out_1;
                                                    Unity_Length_float2(_Divide_a1f3cc5d9e1d4ae59b551fe0bb552196_Out_2, _Length_31469e9880b244be96422d18d79ab7df_Out_1);
                                                    float _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1;
                                                    Unity_OneMinus_float(_Length_31469e9880b244be96422d18d79ab7df_Out_1, _OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1);
                                                    float _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1;
                                                    Unity_Saturate_float(_OneMinus_740e559472f849d89d2fc67be9fffffc_Out_1, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1);
                                                    float _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3;
                                                    Unity_Smoothstep_float(0, _Property_9eb4696664cf4347a1ecf35c5887e36d_Out_0, _Saturate_833ca0f0294b4133b04015537ae3de26_Out_1, _Smoothstep_180392aad058406bb505e0847538dbf2_Out_3);
                                                    float _Property_896cc429c8fd4111b6bc940430d17a32_Out_0 = Vector1_3d2ae6f716e9473aae47329d41c20032;
                                                    float _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2;
                                                    Unity_Multiply_float(_Smoothstep_180392aad058406bb505e0847538dbf2_Out_3, _Property_896cc429c8fd4111b6bc940430d17a32_Out_0, _Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2);
                                                    float _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                                    Unity_OneMinus_float(_Multiply_35e0764be5e443ae802a03bb9a732d33_Out_2, _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1);
                                                    surface.BaseColor = (_Multiply_304577a4c40948cfbb41eb0e712fc445_Out_2.xyz);
                                                    surface.Alpha = _OneMinus_deaa405aa42f4f69b3155e121ef1c3e4_Out_1;
                                                    return surface;
                                                }

                                                // --------------------------------------------------
                                                // Build Graph Inputs

                                                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                                                {
                                                    VertexDescriptionInputs output;
                                                    ZERO_INITIALIZE(VertexDescriptionInputs, output);

                                                    output.ObjectSpaceNormal = input.normalOS;
                                                    output.ObjectSpaceTangent = input.tangentOS;
                                                    output.ObjectSpacePosition = input.positionOS;

                                                    return output;
                                                }

                                                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                                                {
                                                    SurfaceDescriptionInputs output;
                                                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);





                                                    output.WorldSpacePosition = input.positionWS;
                                                    output.ScreenPosition = ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                                                    output.uv0 = input.texCoord0;
                                                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                                                #else
                                                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                                                #endif
                                                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN

                                                    return output;
                                                }


                                                // --------------------------------------------------
                                                // Main

                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                                                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"

                                                ENDHLSL
                                            }
}
    CustomEditor "ShaderGraph.PBRMasterGUI"
                                                    FallBack "Hidden/Shader Graph/FallbackError"
}
