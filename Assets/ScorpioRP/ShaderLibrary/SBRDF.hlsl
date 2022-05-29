#ifndef _SCORPIO_BRDF_INCLUDED
#define _SCORPIO_BRDF_INCLUDED

#define MIN_REFLECTIVITY 0.04
half4 kDielectricSpec =  half4(0.04, 0.04, 0.04, 1 - 0.04);

float OneMinusReflectivity (float metallic)
{
    float range = 1.0 - MIN_REFLECTIVITY;
    return range - metallic * range;
}

half OneMinusReflectivityMetallic(half metallic)
{
    // We'll need oneMinusReflectivity, so
    //   1-reflectivity = 1-lerp(dielectricSpec, 1, metallic) = lerp(1-dielectricSpec, 0, metallic)
    // store (1-dielectricSpec) in kDieletricSpec.a, then
    //   1-reflectivity = lerp(alpha, 0, metallic) = alpha + metallic*(0 - alpha) =
    //                  = alpha - metallic * alpha
    half oneMinusDielectricSpec = kDielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

struct BRDF
{
    float3 diffuse;
    float3 specular;

    float perceptualRoughness;
    float roughness;
    float roughness2;
};

// --- D - Trowbridge-Reitz GGX;
// NDF = alpha / (PI * coefficient);
// alpha =  roughness * roughness;
// coefficient = ((NDotH)* (NDotH) * (alpha - 1) + 1) * ((NDotH)* (NDotH) * (alpha - 1) + 1);
half D_GGX_TR(half nDotH, float roughness)
{
    float squareRoughness = roughness * roughness;
    nDotH = max(nDotH, 0.0);
    float a = nDotH * (squareRoughness - 1) + 1;
    float denominator = PI * a * a;
    return squareRoughness / max(denominator, 0.00001);
}

// --- F - Fresnel-Schlick Approximation;
// FSchlick = F0 + (1 - F0) * pow(1- NDotV, 5);
half3 FresnelSchlick(half3 surfaceColor, float nDotV, half metallic)
{
    half3 F0 = half3(0.04, 0.04, 0.04);
    F0       = lerp(F0, surfaceColor, metallic);
    // return F0 + (1.0 - F0) * pow(max(1.0 - nDotV, 0.0), 5.0);
    return F0 + (1.0 - F0) * exp2(max(1.0 - nDotV, 0.0));
}

// G - Geometry Function = Geometry Obstruction(From View) * Geometry Shadowing(From Light)
// G - Smith’s Schlick-GGX
// GSmithSchlickGGX = NDotV / ((NDotV) * (1 - K) + K)
// KDirect = (alpha + 1) * (alpha + 1) / 8
// KIBL    = alpha * alpha / 2
// Schlick-Beckmann
half GeometrySchlickGGX(float cosine, float k)
{
    float nom   = cosine;
    float denom = cosine * (1 - k) + k;
    return nom / max(denom, 0.00001);
}
half GeometrySmith(half nDotV, half nDotH, float coefficient)
{
    // coefficient associate with roughness
    float ggxGeometryObstruction = GeometrySchlickGGX(nDotV, coefficient);
    float ggxGeometryShadowing   = GeometrySchlickGGX(nDotH, coefficient);

    return ggxGeometryObstruction * ggxGeometryShadowing;
}

BRDF GetMyBRDF(Surface surface)
{
    BRDF outBRDFData;
    half oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    half reflectivity = 1.0 - oneMinusReflectivity;

    outBRDFData.diffuse = surface.albedo * oneMinusReflectivity / PI;
    outBRDFData.specular = lerp(kDielectricSpec.rgb, surface.albedo, surface.metallic);
    half perceptualRoughness =PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
    outBRDFData.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);

    return outBRDFData;
}

float GetSpecularStrength(Surface surface, BRDF brdf, Light light)
{
    half nDotL = dot(surface.normal, light.direction);
    half3 halfVector = SafeNormalize(surface.viewDirectionWS + light.direction);
    half nDotH = dot(surface.normal, halfVector);
    half nDotV = dot(surface.normal, surface.viewDirectionWS);
    
    float NDF      =  D_GGX_TR(nDotH, brdf.roughness);
    half3 Fresnel  = FresnelSchlick(surface.albedo, nDotV, surface.metallic);
    half  k        = (brdf.roughness * brdf.roughness + 1) * (brdf.roughness * brdf.roughness + 1) * 0.125;
    half  Geometry = GeometrySmith(nDotV, nDotL, k);
    brdf.specular  = 0.25 * NDF * Fresnel * Geometry / (nDotV * nDotL);
    return brdf.specular;
}

float SpecularStrength (Surface surface, BRDF brdf, Light light)
{
    float3 h = SafeNormalize(light.direction + surface.viewDirectionWS);
    float nh2 = Square(saturate(dot(surface.normal, h)));
    float lh2 = Square(saturate(dot(light.direction, h)));
    float r2 = Square(brdf.roughness);
    float d2 = Square(nh2 * (r2 - 1.0) + 1.00001);
    float normalization = brdf.roughness * 4.0 + 2.0;
    return r2 / (d2 * max(0.1, lh2) * normalization);
}

float3 DirectBRDF(Surface surface, BRDF brdf, Light light)
{
    return SpecularStrength(surface, brdf, light) * brdf.specular + brdf.diffuse;
}

BRDF GetBRDFData(Surface surface)
{
    BRDF brdf;
    float oneMinusReflectivity = OneMinusReflectivity(surface.metallic);
    brdf.diffuse = surface.albedo * oneMinusReflectivity;
    brdf.specular = lerp(MIN_REFLECTIVITY, surface.albedo, surface.metallic);
    float perceptualRoughness =PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
    brdf.roughness = PerceptualRoughnessToRoughness(perceptualRoughness);
    return brdf;
}

BRDF GetBRDF(Surface surface)
{
    BRDF outBRDFData;
    half oneMinusReflectivity = OneMinusReflectivityMetallic(surface.metallic);
    half reflectivity = 1.0 - oneMinusReflectivity;

    outBRDFData.diffuse = surface.albedo * oneMinusReflectivity;
    outBRDFData.specular = lerp(kDielectricSpec.rgb, surface.albedo, surface.metallic);

    // outBRDFData.grazingTerm = saturate(smoothness + reflectivity);
    outBRDFData.perceptualRoughness = PerceptualSmoothnessToPerceptualRoughness(surface.smoothness);
    outBRDFData.roughness = max(PerceptualRoughnessToRoughness(outBRDFData.perceptualRoughness), HALF_MIN);
    outBRDFData.roughness2 = outBRDFData.roughness * outBRDFData.roughness;
    return outBRDFData;
}

#endif