using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    [CreateAssetMenu(menuName = "Rendering/Scorpio Render Pipeline")]
    public class ScorpioRenderPipelineAsset : RenderPipelineAsset
    {
        protected override RenderPipeline CreatePipeline()
        {
            return new ScorpioRenderPipeline();
        }
    }
}
