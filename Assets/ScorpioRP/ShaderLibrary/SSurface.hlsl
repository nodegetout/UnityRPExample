#ifndef _SCORPIO_SURFACE_INCLUDED
#define _SCORPIO_SURFACE_INCLUDED

struct Surface
{
    half3 albedo;
    half3 normal;
    half3 viewDirectionWS;
    half smoothness;
    half metallic;
    half ambientOcclusion;
    half alpha;
};

Surface InitSurfaceData(half4 baseColor, float4 SpecularParams, PBSDirections directions, float smoothness, float metallic)
{
    Surface surface = (Surface) 0;
    surface.albedo    = baseColor.rgb;
    surface.alpha     = baseColor.a;
    surface.normal    = normalize(directions.normalWS);
    surface.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - directions.positionWS);
    surface.smoothness = SpecularParams.r * smoothness;
    surface.metallic  = SpecularParams.g * metallic;
    surface.ambientOcclusion  = SpecularParams.b ;
    return surface;
}

#endif