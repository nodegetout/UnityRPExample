#ifndef _SCORPIO_UTILS_INCLUDED
#define _SCORPIO_UTILS_INCLUDED

struct PBSDirections
{
    float3 normalWS;
    float3 lightDirWS;
    float3 viewDirWS;
    float3 halfVectorWS;

    float3 positionWS;

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
    directions.positionWS = positionWS;

    directions.nDotL = max(dot(directions.normalWS, directions.lightDirWS), 0.0001);
    directions.nDotH = max(dot(directions.normalWS, directions.halfVectorWS), 0.0001);
    directions.nDotV = max(dot(directions.normalWS, directions.viewDirWS), 0.0001);
    
    directions.hDotL = max(dot(directions.halfVectorWS, directions.lightDirWS), 0.0001);
    directions.hDotV = max(dot(directions.halfVectorWS, directions.viewDirWS), 0.0001);

    return directions;
}

#endif