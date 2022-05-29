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

float D_GGX(float roughness, float nDotH)
{
    float squareRoughness = roughness * roughness;
    nDotH = max(nDotH, 0.0);
    float a = nDotH * (squareRoughness - 1) + 1;
    float denominator = PI * a * a;
    return squareRoughness / max(denominator, 0.00001);
}


float BlinnPhongNormalDistribution(float NdotH, float specularpower, float speculargloss)
{
    float Distribution = pow(NdotH,speculargloss) * specularpower;
    Distribution *= (2+specularpower) / (2*3.1415926535);
    return Distribution;
}

float GGXNormalDistribution(float NdotH, float roughness)
{
    float roughnessSqr = roughness*roughness;
    float NdotHSqr = NdotH*NdotH;
    float TanNdotHSqr = (1-NdotHSqr)/NdotHSqr;
    return (1.0/3.1415926535) * sqrt(roughness/(NdotHSqr * (roughnessSqr + TanNdotHSqr)));
}

float TrowbridgeReitzNormalDistribution(float NdotH, float roughness)
{
    float roughnessSqr = roughness*roughness;
    float Distribution = NdotH*NdotH * (roughnessSqr-1.0) + 1.0;
    return roughnessSqr / (3.1415926535 * Distribution*Distribution);
}

float CookTorrenceGeometricShadowingFunction(float NdotL, float NdotV, float VdotH, float NdotH)
{
    float Gs = min(1.0, min(2 * NdotH * NdotV / VdotH, 2 * NdotH * NdotL / VdotH));
    return (Gs);
}

float SchlickGGXGeometricShadowingFunction(float NdotL, float NdotV, float roughness)
{
    float k = roughness / 2;
    float SmithL = (NdotL) / (NdotL * (1 - k) + k);
    float SmithV = (NdotV) / (NdotV * (1 - k) + k);
    float Gs = (SmithL * SmithV);
    return Gs;
}

float SchlickFresnel(float i)
{
    float x = clamp(1.0 - i, 0.0, 1.0);
    float x2 = x * x;
    return x2 * x2 * x;
}

float3 SchlickFresnelFunction(float3 SpecularColor, float LdotH)
{
    return SpecularColor + (1 - SpecularColor) * SchlickFresnel(LdotH);
}

half4 LitPassFragment (Varyings input) : SV_Target
{
    // Instancing
    UNITY_SETUP_INSTANCE_ID(input);
    
    // sample the texture
    half4 baseColor = tex2D(_BaseMap, input.texcoord);
    half4 SpecularParams = tex2D(_PBRMap, input.texcoord);
    float4 normalTS = tex2D(_NormalMap, input.texcoord);
    normalTS.xyz = UnpackNormal(normalTS);
    float3x3 TBN = transpose(float3x3(input.tToW0.xyz, input.tToW1.xyz, input.tToW2.xyz));
    float3 normalWS = mul(TBN, normalTS);
    float3 positionWS = float3(input.tToW0.w, input.tToW1.w, input.tToW2.w);
    Light mainLight = GetDirectionalLight(0);

    Surface surface = (Surface) 0;
    baseColor = baseColor * UNITY_ACCESS_INSTANCED_PROP(Props, _BaseColor);
    surface.albedo    = baseColor.rgb;
    surface.alpha     = baseColor.a;
    surface.normal    = normalize(normalWS);
    surface.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
    surface.smoothness = /*SpecularParams.a **/ UNITY_ACCESS_INSTANCED_PROP(Props, _Smoothness);
    surface.metallic  = SpecularParams.r * UNITY_ACCESS_INSTANCED_PROP(Props, _Metallic);

    half3  normal = normalize(normalWS);
    float3 lightDir = normalize(mainLight.direction);
    float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - positionWS.xyz);
    float3 lightColor = mainLight.color;
    float3 halfVector = normalize(lightDir + viewDir);\
    
    float perceptualRoughness = 1 - surface.smoothness * surface.smoothness;
    float roughness = perceptualRoughness * perceptualRoughness;
    roughness = lerp(0.02, 1, roughness);
    float squareRoughness = roughness * roughness;
    
    float nDotL = max(dot(normal, lightDir), 0.000001);
    float nDotV = max(dot(normal, viewDir), 0.000001);
    float nDotH = max(dot(normal, halfVector), 0.000001);

    float D = D_GGX_TR(nDotH, roughness);
    float G = GeometrySmith(nDotV, nDotH, (roughness + 1) * (roughness + 1) * 0.125);
    float3 F = FresnelSchlick(surface.albedo, nDotV, surface.metallic);
    float Ks = F;
    float Kd = (1 - Ks) * (1 - surface.metallic);
    float3 diffuse  = surface.albedo * INV_PI;
    float3 specular =  D * F * G * 0.25 / (max(nDotV, 0.00001) * max(nDotL, 0.00001));
    float3 DirectLightResult = (/*Kd **/ diffuse + specular) * mainLight.color * max(0.0, nDotL);

    return half4(DirectLightResult, 1);
    
    float3 iblDiffuseResult = 0.0;
    float3 iblSpecularResult = 0.0;
    float3 IndirectResult = iblDiffuseResult + iblSpecularResult;
    float3  color = DirectLightResult + IndirectResult;    
    
    #if defined(_CLIPPING)
        clip(surface.alpha - UNITY_ACCESS_INSTANCED_PROP(Props, _Cutoff));
    #endif
    
    return half4(color, surface.alpha);
}

#endif