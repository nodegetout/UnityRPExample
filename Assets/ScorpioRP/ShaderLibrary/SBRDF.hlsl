#ifndef _SCORPIO_BRDF_INCLUDED
#define _SCORPIO_BRDF_INCLUDED

#define MIN_REFLECTIVITY 0.04
half4 kDielectricSpec =  half4(0.04, 0.04, 0.04, 1 - 0.04);

// ----------------------------------------------------------------------------
float DistributionGGX(float3 N, float3 H, float roughness)
{
    float a = roughness*roughness;
    float a2 = a*a;
    float NdotH = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;

    float nom   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float nom   = NdotV;
    float denom = NdotV * (1.0 - k) + k;

    return nom / denom;
}
// ----------------------------------------------------------------------------
float GeometrySmith(float3 N, float3 V, float3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2 = GeometrySchlickGGX(NdotV, roughness);
    float ggx1 = GeometrySchlickGGX(NdotL, roughness);

    return ggx1 * ggx2;
}
// ----------------------------------------------------------------------------
float3 fresnelSchlick(float cosTheta, float3 F0)
{
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

float3 LightingPhysicallyBased(Surface surface, PBSDirections directions, Light light)
{
    float3 F0 = lerp(surface.albedo, surface.metallic, kDielectricSpec.rgb);
    // Cook-Torrance BRDF
    float  NDF = DistributionGGX(directions.normalWS, directions.halfVectorWS, surface.smoothness);   
    float  G   = GeometrySmith(directions.normalWS, directions.viewDirWS, directions.lightDirWS, surface.smoothness);      
    float3 F   = fresnelSchlick(clamp(directions.hDotV, 0.0, 1.0), F0);
           
    float3 numerator  = NDF * G * F;
    // + 0.0001 to prevent divide by zero
    float denominator = 4.0 * directions.nDotV * directions.nDotL + 0.0001;
    float3 specular   = numerator / denominator;
        
    // kS is equal to Fresnel
    float3 kS = F;
    // for energy conservation, the diffuse and specular light can't
    // be above 1.0 (unless the surface emits light); to preserve this
    // relationship the diffuse component (kD) should equal 1.0 - kS.
    float3 kD = 1.0 - kS;
    // multiply kD by the inverse metalness such that only non-metals 
    // have diffuse lighting, or a linear blend if partly metal (pure metals
    // have no diffuse light).
    kD *= 1.0 - surface.metallic;
    
    // add to outgoing radiance Lo
    // note that we already multiplied the BRDF by the Fresnel (kS) so we won't multiply by kS again
    float3 directRadiance = (kD * surface.albedo / PI + specular ) * light.color * directions.hDotL;
    return directRadiance;
}

#endif