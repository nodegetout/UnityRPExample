Shader "Scorpio/Lit"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Cull Mode", Float) = 2
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor("Tint Color", Color) = (1,1,1,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _Smoothness("Smoothness", Range(0, 1)) = 0
        _Metallic("Metallic", Range(0, 1)) = 0.0
        [Header(R roughness G metallic B AO)]
        _PBRMap("PBR Texture", 2D) = "white" {} 
        [Toggle(_CLIPPING)] _Clipping("Clipping", Float) = 0
        _Cutoff("Cut Off", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags
            {
                "LightMode" = "ScorpioForward"
            }
            Cull [_CullMode]
            
            HLSLPROGRAM
            // OpenGL 3.5 - es 3.0
            #pragma target 3.0
            
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _CLIPPING
            
            #pragma vertex    LitPassVertex
            #pragma fragment  LitPassFragment

            #include "./LitInput.hlsl"
            #include "./LitPass.hlsl"
            
            ENDHLSL
        }
    }
}
