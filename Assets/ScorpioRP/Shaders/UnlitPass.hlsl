#ifndef _SCORPIO_UNLIT_PASS_INCLUDED
#define _SCORPIO_UNLIT_PASS_INCLUDED

#include "../ShaderLibrary/SCommon.hlsl"

Varyings UnlitPassVertex (Attributes input)
{
    Varyings o;
    o.positionCS = TransformObjectToHClip(input.positionOS);
    o.texcoord = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    return o;
}

half4 UnlitPassFragment (Varyings input) : SV_Target
{
    // sample the texture
    // half4 col = tex2D(_MainTex, input.texcoord);
    // return col;
    return _BaseColor;
}

#endif