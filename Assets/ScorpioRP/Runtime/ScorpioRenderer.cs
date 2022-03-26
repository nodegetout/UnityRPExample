using UnityEngine;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public class ScorpioRenderer
    {
        ScriptableRenderContext m_Context;

        Camera m_Camera;

        public void Render (ScriptableRenderContext context, Camera camera) 
        {
            this.m_Context = context;
            this.m_Camera = camera;

            Setup();
            DrawVisibleGeometry();
            Submit();
        }

        private void Setup()
        {
            m_Context.SetupCameraProperties(m_Camera);
        }

        private void DrawVisibleGeometry()
        {
            m_Context.DrawSkybox(m_Camera);
        }

        private void Submit()
        {
            m_Context.Submit();
        }
    }
}