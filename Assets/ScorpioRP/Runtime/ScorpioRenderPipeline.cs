using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public class ScorpioRenderPipeline : RenderPipeline
    {
        private ScorpioRenderer m_Renderer = new ScorpioRenderer();

        private bool b_UseDynamicBatching;
        private bool b_UseGPUInstancing;

        public ScorpioRenderPipeline(
            bool useDynamicBatching, bool useGPUInstancing, bool useSRPBatcher)
        {
            GraphicsSettings.useScriptableRenderPipelineBatching = useSRPBatcher;
            b_UseDynamicBatching = useDynamicBatching;
            b_UseGPUInstancing = useGPUInstancing;
        }
        
        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            foreach (var camera in cameras)
            {
                m_Renderer.Render(context, camera, b_UseDynamicBatching, b_UseGPUInstancing);
            }
        }
    }
}