using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public class ScorpioRenderPipeline : RenderPipeline
    {
        private ScorpioRenderer m_Renderer = new ScorpioRenderer();
        
        protected override void Render(ScriptableRenderContext context, Camera[] cameras)
        {
            foreach (var camera in cameras)
            {
                m_Renderer.Render(context, camera);
            }
        }
    }
}