#ifndef _SCORPIO_LIT_PASS_INCLUDED
#define _SCORPIO_LIT_PASS_INCLUDED

Varyings LitPassVertex (Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input)
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    output.positionCS = TransformObjectToHClip(input.positionOS);
    // o.texcoord = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    // Instancing
    half4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(Props, _BaseMap_ST);
    output.texcoord = input.texcoord.xy * mainTexST.xy + mainTexST.zw;
    output.normalWS = normalize(TransformObjectToWorld(input.normalOS));
    return output;
}

half4 LitPassFragment (Varyings input) : SV_Target
{
    // Instancing
    UNITY_SETUP_INSTANCE_ID(input);

    Surface surface;
    
    // sample the texture
    half4 baseColor = tex2D(_BaseMap, input.texcoord);
    baseColor = baseColor * UNITY_ACCESS_INSTANCED_PROP(Props, _BaseColor);
    surface.color  = baseColor.rgb;
    surface.alpha  = baseColor.a;
    surface.normal = input.normalWS;
    
    half3 color = GetLighting(surface);
    
    #if defined(_CLIPPING)
        clip(surface.alpha - UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff));
    #endif
    
    return half4(color, surface.alpha);
}

#endif