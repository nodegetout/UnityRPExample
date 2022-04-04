using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    [CreateAssetMenu(menuName = "Rendering/Scorpio Render Pipeline")]
    public class ScorpioRenderPipelineAsset : RenderPipelineAsset
    {
        [SerializeField]
        private bool useDynamicBatching;
        [SerializeField]
        private bool useGPUInstancing;
        [SerializeField]
        private bool useSRPBatcher;
        
        protected override RenderPipeline CreatePipeline()
        {
            return new ScorpioRenderPipeline(useDynamicBatching, useGPUInstancing, useSRPBatcher);
        }
    }
}
