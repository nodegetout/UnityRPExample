using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public partial class ScorpioRenderer
    {
        private static ShaderTagId s_UnlitShaderTagId = new ShaderTagId("SRPDefaultUnlit");
        private static ShaderTagId s_ForwardLitShaderTagId = new ShaderTagId("ScorpioForward");
        private const string k_BufferName = "Scorpio Renderer";
        
        private ScriptableRenderContext m_Context;
        private Camera m_Camera;
        private CullingResults m_CullingResults;

        private Lighting m_Lighting = new Lighting();

        private CommandBuffer m_CommandBuffer = new CommandBuffer()
        {
            name = k_BufferName
        };

        public void Render (ScriptableRenderContext context, Camera camera,
            bool useDynamicBatching, bool useGPUInstancing)
        {
            m_Context = context;
            m_Camera = camera;

            PrepareBuffer();
            PrepareForSceneWindow();
            
            if (!Cull())
            {
                return;
            }

            Setup();
            m_Lighting.Setup(context, m_CullingResults);
            DrawVisibleGeometry(useDynamicBatching, useGPUInstancing);
            
            DrawUnsupportedShaders();
            DrawGizmos();
            
            Submit();
        }

        private void Setup()
        {
            m_Context.SetupCameraProperties(m_Camera);
            var flags = m_Camera.clearFlags;
            m_CommandBuffer.ClearRenderTarget(flags <= CameraClearFlags.Depth,
                flags == CameraClearFlags.Color,
                flags == CameraClearFlags.Color ?  m_Camera.backgroundColor.linear : Color.clear
                );
            m_CommandBuffer.BeginSample(SampleName);
            ExecuteBuffer();
        }

        bool Cull()
        {
            if (m_Camera.TryGetCullingParameters(out ScriptableCullingParameters parameters))
            {
                m_CullingResults = m_Context.Cull(ref parameters);
                return true;
            }

            return false;
        }

        private void DrawVisibleGeometry(bool useDynamicBatching, bool useInstancing)
        {
            var sortingSettings = new SortingSettings(m_Camera)
            {
                criteria = SortingCriteria.CommonOpaque
            };
            var drawingSettings = new DrawingSettings(s_UnlitShaderTagId,sortingSettings)
            {
                enableInstancing = useInstancing,
                enableDynamicBatching = useDynamicBatching
            };
            drawingSettings.SetShaderPassName(1, s_ForwardLitShaderTagId);
            var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);
            m_Context.DrawRenderers(m_CullingResults, ref drawingSettings, ref filteringSettings);
            
            m_Context.DrawSkybox(m_Camera);

            sortingSettings.criteria = SortingCriteria.CommonTransparent;
            drawingSettings.sortingSettings = sortingSettings;
            filteringSettings.renderQueueRange = RenderQueueRange.transparent;
            m_Context.DrawRenderers(
                m_CullingResults, ref drawingSettings, ref filteringSettings
                );
        }

        private void Submit()
        {
            m_CommandBuffer.EndSample(SampleName);
            ExecuteBuffer();
            m_Context.Submit();
        }

        private void ExecuteBuffer()
        {
            m_Context.ExecuteCommandBuffer(m_CommandBuffer);
            m_CommandBuffer.Clear();
        }
    }
}