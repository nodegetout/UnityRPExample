using ScorpioEngine.Rendering.Runtime.Data;
using UnityEngine;

[DisallowMultipleComponent]
[RequireComponent(typeof(Renderer))]
public class SPerObjectMaterialProperty : MonoBehaviour
{
    private MaterialPropertyBlock m_MaterialPropertyBlock;
    private MeshRenderer m_MeshRenderer;

    [SerializeField]
    private Color m_BaseColor = Color.white;
    
    [Range(0f, 1f)]
    public float m_Roughness = 0.0f;

    [Range(0f, 1f)]
    public float m_Metallic = 0.5f;

    [Range(0f, 1f)]
    public float m_Cutoff;

    MaterialPropertyBlock materialPropertyBlock
    {
        get
        {
            m_MaterialPropertyBlock ??= new MaterialPropertyBlock();
            return m_MaterialPropertyBlock;
        }
    }

    MeshRenderer meshRenderer
    {
        get
        {
            if (m_MeshRenderer == null)
            {
                m_MeshRenderer = GetComponent<MeshRenderer>();
            }

            return m_MeshRenderer;
        }
    }

    private void Start()
    {
        
        // m_BaseColor = Random.ColorHSV().linear;
        UpdateMaterialPropertyBlock();
    }

#if UNITY_EDITOR
    void OnValidate()
    {
        UpdateMaterialPropertyBlock();
    }
#endif

    void UpdateMaterialPropertyBlock()
    {
        meshRenderer.GetPropertyBlock(materialPropertyBlock);
        materialPropertyBlock.SetColor(SShaderPropertyId.s_BaseColorPropertyId, m_BaseColor);
        materialPropertyBlock.SetFloat(SShaderPropertyId.s_SmoothnessPropertyId, m_Roughness);
        materialPropertyBlock.SetFloat(SShaderPropertyId.s_MetallicPropertyId,  m_Metallic);
        materialPropertyBlock.SetFloat(SShaderPropertyId.s_CutoffPropertyId, m_Cutoff);
        meshRenderer.SetPropertyBlock(materialPropertyBlock);
    }
}
