#ifndef _SCORPIO_LIT_INPUT_INCLUDED
#define _SCORPIO_LIT_INPUT_INCLUDED

#include "../ShaderLibrary/SCommon.hlsl"
#include "../ShaderLibrary/SSurface.hlsl"
#include "../ShaderLibrary/SLight.hlsl"
#include "../ShaderLibrary/SBRDF.hlsl"
#include "../ShaderLibrary/SLighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    float2 texcoord   : TEXCOORD0;
    float3 normalOS   : NORMAL;
    float4 tangentOS  : TANGENT;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half2 texcoord    : TEXCOORD0;
    // half3 positionWS  : TEXCOORD1;
    // half3 normalWS    : TEXCOORD2;
    float4 tToW0 :  TEXCOORD1;
    float4 tToW1 :  TEXCOORD2;
    float4 tToW2 :  TEXCOORD3;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

sampler2D _BaseMap;
sampler2D _NormalMap;
sampler2D _PBRMap;

// CBUFFER_START(UnityPerMaterial)
// half4 _MainTex_ST;
// half4 _BaseColor;
// CBUFFER_END

UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    UNITY_DEFINE_INSTANCED_PROP(half, _Smoothness)
    UNITY_DEFINE_INSTANCED_PROP(half, _Metallic)
    #if defined(_CLIPPING)
        UNITY_DEFINE_INSTANCED_PROP(half, _Cutoff)
    #endif
UNITY_INSTANCING_BUFFER_END(Props)

#endif