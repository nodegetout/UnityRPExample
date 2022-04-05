using Unity.Collections;
using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public class Lighting
    {
        const string k_BufferName = "Lighting";
        private const int k_MaxDirectionalLightCount = 4;

        static readonly int k_DirectionalLightCountId = Shader.PropertyToID("_DirectionalLightCount");
        static readonly int k_DirectionalLightColorId = Shader.PropertyToID("_DirectionalLightColors");
        static readonly int k_DirectionalLightDirectionId = Shader.PropertyToID("_DirectionalLightDirections");

        private static Vector4[] s_DirectionalLightColors = new Vector4[k_MaxDirectionalLightCount];
        private static Vector4[] s_DirectionalLightDirections = new Vector4[k_MaxDirectionalLightCount];

        CommandBuffer m_Buffer = new CommandBuffer
        {
            name = k_BufferName
        };

        CullingResults m_CullingResults;

        public void Setup(ScriptableRenderContext context, CullingResults cullingResults)
        {
            this.m_CullingResults = cullingResults;
            m_Buffer.BeginSample(k_BufferName);
            SetupLights();
            m_Buffer.EndSample(k_BufferName);
            context.ExecuteCommandBuffer(m_Buffer);
            m_Buffer.Clear();
        }
        
        void SetupLights()
        {
            NativeArray<VisibleLight> visibleLights = m_CullingResults.visibleLights;
            int lightCount = visibleLights.Length;

            int directionalLightCount = 0;
            for (int i = 0; i < lightCount; i++)
            {
                var visibleLight = visibleLights[i];
                if (visibleLights[i].lightType is LightType.Directional)
                {
                    SetupDirectionalLight(directionalLightCount++, ref visibleLight);
                    if (directionalLightCount >= k_MaxDirectionalLightCount)
                    {
                        break;
                    }
                }
            }
            
            m_Buffer.SetGlobalInt(k_DirectionalLightCountId, visibleLights.Length);
            m_Buffer.SetGlobalVectorArray(k_DirectionalLightColorId, s_DirectionalLightColors);
            m_Buffer.SetGlobalVectorArray(k_DirectionalLightDirectionId, s_DirectionalLightDirections);
        }

        void SetupDirectionalLight (int index, ref VisibleLight light) 
        {
            s_DirectionalLightColors[index] = light.finalColor.linear;
            s_DirectionalLightDirections[index] = -light.localToWorldMatrix.GetColumn(2);
        }
    }
}