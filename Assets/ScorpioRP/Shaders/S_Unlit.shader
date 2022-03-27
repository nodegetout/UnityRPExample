Shader "Scorpio/Unlit"
{
    Properties
    {
        _BaseColor("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex    UnlitPassVertex
            #pragma fragment  UnlitPassFragment


            struct Attributes
            {
                float4 positionOS : POSITION;
                half2 texcoord    : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                half2 texcoord    : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _BaseColor;

            #include "./UnlitPass.hlsl"
            
            ENDHLSL
        }
    }
}
