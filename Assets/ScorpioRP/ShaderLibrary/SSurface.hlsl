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

Surface InitSurfaceData(half4 baseColor, float4 SpecularParams, float3 normalWS, float3 positionWS, float smoothness, float metallic)
{
    Surface surface = (Surface) 0;
    surface.albedo    = baseColor.rgb;
    surface.alpha     = baseColor.a;
    surface.normal    = normalize(normalWS);
    surface.viewDirectionWS = normalize(_WorldSpaceCameraPos.xyz - positionWS);
    surface.smoothness = SpecularParams.r * smoothness;
    surface.metallic  = SpecularParams.g * metallic;
    surface.ambientOcclusion  = SpecularParams.b ;
    return surface;
}

#endif