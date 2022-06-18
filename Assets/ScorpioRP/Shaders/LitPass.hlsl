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

    Light mainLight = GetDirectionalLight(0);
    PBSDirections directions = CreatePBSDirections(normalWS, mainLight.direction, positionWS.xyz);

    float smoothness = UNITY_ACCESS_INSTANCED_PROP(Props, _Smoothness);
    float metallic   = UNITY_ACCESS_INSTANCED_PROP(Props, _Metallic);
    Surface surface = InitSurfaceData(baseColor, SpecularParams, directions, smoothness, metallic);

    // float3 F0 = float3(0.04); 
    // F0 = mix(F0, albedo, metallic);
    // return half4(F0, surface.alpha);

    // calculate per-light radiance
    // float3 L = normalize(mainLight.direction - positionWS);
    // float3 H = normalize(V + L);
    // float distance = length(mainLight.direction - positionWS);
    // float attenuation = 1.0 / (distance * distance);
    // float3 radiance = mainLight.color * attenuation;
    // return half4(radiance, 1);

    float3 directRadiance = LightingPhysicallyBased(surface, directions, mainLight);

    // return half4(directRadiance, 1);
    // ambient lighting (note that the next IBL tutorial will replace 
    // this ambient lighting with environment lighting).
    float3 ambient = 0.03 * surface.albedo * surface.ambientOcclusion;
    float3 color = ambient + directRadiance;

    // HDR tonemapping
    // color = color / (color + 1.0);
    // gamma correct
    // color = pow(color, 0.4545); 
    
    #if defined(_CLIPPING)
        clip(surface.alpha - UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff));
    #endif
    
    return half4(color, surface.alpha);
}

#endif