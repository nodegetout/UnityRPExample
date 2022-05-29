using UnityEngine;

namespace ScorpioEngine.Rendering.Runtime.Data
{
    public static class SShaderPropertyId
    {
        public static int s_BaseColorPropertyId = Shader.PropertyToID("_BaseColor");
        public static int s_SmoothnessPropertyId = Shader.PropertyToID("_Smoothness");
        public static int s_MetallicPropertyId = Shader.PropertyToID("_Metallic");
        public static int s_CutoffPropertyId = Shader.PropertyToID("_Cutoff");
    }
}