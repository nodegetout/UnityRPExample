#ifndef _SCORPIO_BRDF_INCLUDED
#define _SCORPIO_BRDF_INCLUDED

#define MIN_REFLECTIVITY 0.04
half4 kDielectricSpec =  half4(0.04, 0.04, 0.04, 1 - 0.04);

struct PBSDirections
{
    float3 normalWS;
    float3 lightDirWS;
    float3 viewDirWS;
    float3 halfVectorWS;

    // dots
    float nDotL;
    float nDotH;
    float nDotV;

    float hDotL;
    float hDotV;
};

PBSDirections CreatePBSDirections(float3 normalWS, float3 lightDirWS, float3 positionWS)
{
    PBSDirections directions = (PBSDirections) 0;
    directions.normalWS = normalize(normalWS);
    directions.lightDirWS = normalize(lightDirWS);
    directions.viewDirWS = normalize(_WorldSpaceCameraPos.xyz - positionWS.xyz);
    directions.halfVectorWS = normalize(directions.lightDirWS + directions.viewDirWS);

    directions.nDotL = max(dot(directions.normalWS, directions.lightDirWS), 0.0001);
    directions.nDotH = max(dot(directions.normalWS, directions.halfVectorWS), 0.0001);
    directions.nDotV = max(dot(directions.normalWS, directions.viewDirWS), 0.0001);
    
    directions.hDotL = max(dot(directions.halfVectorWS, directions.lightDirWS), 0.0001);
    directions.hDotV = max(dot(directions.halfVectorWS, directions.viewDirWS), 0.0001);

    return directions;
}

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

#endif