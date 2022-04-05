#ifndef _SCORPIO_LIT_INPUT_INCLUDED
#define _SCORPIO_LIT_INPUT_INCLUDED

#include "../ShaderLibrary/SCommon.hlsl"
#include "../ShaderLibrary/SSurface.hlsl"
#include "../ShaderLibrary/SLight.hlsl"
#include "../ShaderLibrary/SLighting.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    half2 texcoord    : TEXCOORD0;
    half3 normalOS    : NORMAL;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half2 texcoord    : TEXCOORD0;
    half3 normalWS    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

sampler2D _BaseMap;

// CBUFFER_START(UnityPerMaterial)
// half4 _MainTex_ST;
// half4 _BaseColor;
// CBUFFER_END

UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseMap_ST)
    UNITY_DEFINE_INSTANCED_PROP(half4, _BaseColor)
    #if defined(_CLIPPING)
        UNITY_DEFINE_INSTANCED_PROP(half, _Cutoff)
    #endif
UNITY_INSTANCING_BUFFER_END(Props)

#endif