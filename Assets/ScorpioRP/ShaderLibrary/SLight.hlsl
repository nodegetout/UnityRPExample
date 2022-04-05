#ifndef _SCORPIO_LIGHT_INCLUDED
#define _SCORPIO_LIGHT_INCLUDED

#define MAX_DIRECTIONAL_LIGHT_COUNT 4

CBUFFER_START(_CustomLight)
    int   _DirectionalLightCount;
    half3 _DirectionalLightColors[MAX_DIRECTIONAL_LIGHT_COUNT];
    half3 _DirectionalLightDirections[MAX_DIRECTIONAL_LIGHT_COUNT];
CBUFFER_END

struct Light
{
    half3 color;
    half3 direction;
    float attenuation;
};

int GetDirectionalLightCount()
{
    return _DirectionalLightCount;
}

Light GetDirectionalLight(int index)
{
    Light light;
    light.color = _DirectionalLightColors[index].rgb;
    light.direction = _DirectionalLightDirections[index].xyz;
    light.attenuation = 1.0;
    return light;
}

#endif
