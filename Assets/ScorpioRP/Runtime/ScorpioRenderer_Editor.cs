using UnityEditor;
using UnityEngine;
using UnityEngine.Profiling;
using UnityEngine.Rendering;

namespace ScorpioEngine.Rendering.Runtime
{
    public partial class ScorpioRenderer
    {
        partial void DrawGizmos();
        partial void DrawUnsupportedShaders();
        partial void PrepareForSceneWindow();
        partial void PrepareBuffer();

#if UNITY_EDITOR
        private static ShaderTagId[] s_LegacyShaderTagIds = {
            new ShaderTagId("Always"),
            new ShaderTagId("ForwardBase"),
            new ShaderTagId("PrepassBase"),
            new ShaderTagId("Vertex"),
            new ShaderTagId("VertexLMRGBM"),
            new ShaderTagId("VertexLM")
        };
        private static Material s_ErrorMaterial;

        private string SampleName { get; set; }

        partial void DrawGizmos()
        {
            if (Handles.ShouldRenderGizmos())
            {
                m_Context.DrawGizmos(m_Camera, GizmoSubset.PreImageEffects);
                m_Context.DrawGizmos(m_Camera, GizmoSubset.PostImageEffects);
            }
        }
        partial void DrawUnsupportedShaders()
        {
            if (s_ErrorMaterial == null)
            {
                s_ErrorMaterial = new Material(Shader.Find("Hidden/InternalErrorShader"));
            }
            var drawingSettings = new DrawingSettings(s_LegacyShaderTagIds[0],new SortingSettings(m_Camera))
            {
                overrideMaterial = s_ErrorMaterial
            };
            for (int i = 1; i < s_LegacyShaderTagIds.Length; i++)
            {
                drawingSettings.SetShaderPassName(i, s_LegacyShaderTagIds[i]);
            }
            var filteringSettings = FilteringSettings.defaultValue;
            m_Context.DrawRenderers(
                m_CullingResults, ref drawingSettings, ref filteringSettings
            );
        }

        partial void PrepareForSceneWindow()
        {
            if (m_Camera.cameraType == CameraType.SceneView)
            {
                ScriptableRenderContext.EmitWorldGeometryForSceneView(m_Camera);
            }
        }

        partial void PrepareBuffer()
        {
            Profiler.BeginSample("Editor Only");
            m_CommandBuffer.name = SampleName = m_Camera.name;
            Profiler.EndSample();
        }
#else
    string SampleName => k_BufferName;
#endif
    }
}