using ScorpioEngine.Rendering.Runtime.Data;
using UnityEngine;

[DisallowMultipleComponent]
[RequireComponent(typeof(Renderer))]
public class SPerObjectMaterialProperty : MonoBehaviour
{
    private MaterialPropertyBlock m_MaterialPropertyBlock;

    [SerializeField] private Color m_BaseColor;
    [SerializeField]
    [Range(0f, 1f)]
    private float m_Cutoff;

    MaterialPropertyBlock materialPropertyBlock
    {
        get
        {
            m_MaterialPropertyBlock ??= new MaterialPropertyBlock();
            return m_MaterialPropertyBlock;
        }
    }

    private void Start()
    {
        m_BaseColor = Random.ColorHSV().gamma;
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
        materialPropertyBlock.SetColor(SShaderPropertyId.s_BaseColorPropertyId, m_BaseColor);
        materialPropertyBlock.SetFloat(SShaderPropertyId.s_CutoffPropertyId, m_Cutoff);
        GetComponent<Renderer>().SetPropertyBlock(materialPropertyBlock);
    }
}
