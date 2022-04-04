#ifndef _SCORPIO_UNLIT_INPUT_INCLUDED
#define _SCORPIO_UNLIT_INPUT_INCLUDED

#include "../ShaderLibrary/SCommon.hlsl"

struct Attributes
{
    float4 positionOS : POSITION;
    half2 texcoord    : TEXCOORD0;
    
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS : SV_POSITION;
    half2 texcoord    : TEXCOORD0;
    
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