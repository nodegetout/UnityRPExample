#ifndef _SCORPIO_LIGHTING_INCLUDED
#define _SCORPIO_LIGHTING_INCLUDED

// half3 IncomingLight(Surface surface, Light light)
// {
//    return saturate(dot(surface.normal, light.direction)) * light.color;
// }
//
// float3 GetLighting(Surface surface, BRDF brdf, Light light)
// {
//    return IncomingLight(surface, light) * DirectBRDF(surface, brdf, light);
//    // return IncomingLight(surface, light) * GetDirectBRDF(surface, light.direction);
// }
//
// float3 GetLighting(Surface surface, BRDF brdf)
// {
//    float3 color = 0.0;
//    for (int i = 0; i < GetDirectionalLightCount(); ++i)
//    {
//       color += GetLighting(surface, brdf, GetDirectionalLight(i));
//    }
//    return color;
// }

#endif
