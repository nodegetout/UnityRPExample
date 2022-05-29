#ifndef _SCORPIO_LIGHT_INCLUDED
#define _SCORPIO_LIGHT_INCLUDED

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

CBUFFER_START(_CustomLight)
    uint _DirectionalLightCount;
    half3 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    half3 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

struct Light
{
    half3   direction;
    half3   color;
    half    distanceAttenuation;
    half    shadowAttenuation;
};

int GetDirectionalLightCount()
{
    return _DirectionalLightCount;
}

Light GetDirectionalLight(int index)
{
    Light light = (Light) 0;
    light.color = _DirectionalLightColors[index].rgb;
    light.direction = normalize(_DirectionalLightDirections[index].xyz);
    light.distanceAttenuation = 1.0;
    return light;
}

#endif
