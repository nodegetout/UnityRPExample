Shader "Scorpio/Unlit"
{
    Properties
    {
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("Src Blend", Float) = 0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("Dst Blend", Float) = 0
        [Enum(Off, 0, On, 1)]_ZWrite("Z Write", Float) = 1
        _BaseMap ("Texture", 2D) = "white" {}
        _BaseColor("Tint Color", Color) = (1,1,1,1)
        [Toggle(_CLIPPING)] _Clipping("Clipping", Float) = 0
        _Cutoff("Cut Off", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            
            HLSLPROGRAM
            
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma shader_feature _CLIPPING
            
            #pragma vertex    UnlitPassVertex
            #pragma fragment  UnlitPassFragment

            #include "./UnlitInput.hlsl"
            #include "./UnlitPass.hlsl"
            
            ENDHLSL
        }
    }
}
