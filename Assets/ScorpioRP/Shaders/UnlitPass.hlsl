#ifndef _SCORPIO_UNLIT_PASS_INCLUDED
#define _SCORPIO_UNLIT_PASS_INCLUDED

Varyings UnlitPassVertex (Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input)
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    // o.texcoord = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    // Instancing
    half4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(Props, _BaseMap_ST);
    output.texcoord = input.texcoord.xy * mainTexST.xy + mainTexST.zw;
    return output;
}

half4 UnlitPassFragment (Varyings input) : SV_Target
{
    // Instancing
    UNITY_SETUP_INSTANCE_ID(input);
    
    // sample the texture
    half4 baseColor = tex2D(_BaseMap, input.texcoord);

    half4 finalColor = baseColor * UNITY_ACCESS_INSTANCED_PROP(Props, _BaseColor);
    
    #if defined(_CLIPPING)
        clip(finalColor.a - UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff));
    #endif
    
    return finalColor;
}

#endif