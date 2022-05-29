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

#endif