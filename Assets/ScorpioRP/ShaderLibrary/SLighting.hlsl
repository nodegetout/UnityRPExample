#ifndef _SCORPIO_LIGHTING_INCLUDED
#define _SCORPIO_LIGHTING_INCLUDED


half3 IncomingLight(Surface surface, Light light)
{
   return saturate(dot(surface.normal, light.direction)) * light.color;
}

half3 GetLighting(Surface surface, Light light)
{
   return IncomingLight(surface, light) * surface.color;
}

half3 GetLighting(Surface surface)
{
   half3 color = 0.0;
   int directionalLightCount = GetDirectionalLightCount();
   for (int i = 0; i < directionalLightCount; ++i)
   {
      color += GetLighting(surface, GetDirectionalLight(i));
   }
   return color;
}


#endif
