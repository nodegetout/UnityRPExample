#ifndef _SCORPIO_LIT_PASS_INCLUDED
#define _SCORPIO_LIT_PASS_INCLUDED

Varyings LitPassVertex (Attributes input)
{
    Varyings output;
    UNITY_SETUP_INSTANCE_ID(input)
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    
    float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
    output.positionCS = TransformWorldToHClip(positionWS);
    
    // o.texcoord = input.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
    // Instancing
    half4 mainTexST = UNITY_ACCESS_INSTANCED_PROP(Props, _BaseMap_ST);
    output.texcoord = input.texcoord.xy * mainTexST.xy + mainTexST.zw;
    
    // output.normalWS = (TransformObjectToWorld(input.normalOS));
    float3 tangentWS  = normalize(TransformObjectToWorld(input.tangentOS.xyz));
    float3 normalWS   = TransformObjectToWorldNormal(input.normalOS, true);
    float3 biNormalWS = normalize(cross(tangentWS, normalWS) * input.tangentOS.w);
    output.tToW0 = float4(tangentWS,  positionWS.x);
    output.tToW1 = float4(biNormalWS, positionWS.y);
    output.tToW2 = float4(normalWS,   positionWS.z);
    
    return output;
}

half4 LitPassFragment (Varyings input) : SV_Target
{
    // Instancing
    UNITY_SETUP_INSTANCE_ID(input);
    
    // sample the texture
    half4 baseColor = tex2D(_BaseMap, input.texcoord);
    baseColor = baseColor * UNITY_ACCESS_INSTANCED_PROP(Props, _BaseColor);
    half4 SpecularParams = tex2D(_PBRMap, input.texcoord);
    float4 normalTS = tex2D(_NormalMap, input.texcoord);

    normalTS.xyz = UnpackNormal(normalTS);
    float3x3 TBN = transpose(float3x3(input.tToW0.xyz, input.tToW1.xyz, input.tToW2.xyz));
    float3 normalWS = mul(TBN, normalTS);
    float3 positionWS = float3(input.tToW0.w, input.tToW1.w, input.tToW2.w);

    float smoothness = UNITY_ACCESS_INSTANCED_PROP(Props, _Smoothness);
    float metallic   = UNITY_ACCESS_INSTANCED_PROP(Props, _Metallic);

    Surface surface = InitSurfaceData(baseColor, SpecularParams, normalWS, positionWS, smoothness, metallic);

    // direct 
    int realtimeLightCount = GetDirectionalLightCount();
    float3 color = 0;
    UNITY_LOOP
    for (int i = 0; i < realtimeLightCount; ++i)
    {
        Light dirLight = GetDirectionalLight(i);
        PBSDirections directions = CreatePBSDirections(normalWS, dirLight.direction, positionWS.xyz);
        float3 directRadiance = LightingPhysicallyBased(surface, directions, dirLight);
        color += directRadiance;
    }
    
    // ambient lighting (note that the next IBL tutorial will replace 
    // this ambient lighting with environment lighting).
    float3 ambient = 0.03 * surface.albedo * surface.ambientOcclusion;
    

    // HDR tonemapping
    // color = color / (color + 1.0);
    // gamma correct
    // color = pow(color, 0.4545); 
    
    // #if defined(_CLIPPING)
    //     clip(baseColor.a - UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff));
    // #endif
    
    return half4(color, baseColor.a);
}

#endif