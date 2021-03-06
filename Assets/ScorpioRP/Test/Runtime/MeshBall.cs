using ScorpioEngine.Rendering.Runtime.Data;
using UnityEngine;

namespace ScorpioRP.Test.Runtime
{
    public class MeshBall : MonoBehaviour
    {
        [SerializeField] Mesh mesh = default;
        [SerializeField] Material material = default;

        Matrix4x4[] matrices = new Matrix4x4[1023];
        Vector4[] baseColors = new Vector4[1023];

        MaterialPropertyBlock m_MaterialPropertyBlock;

        MaterialPropertyBlock _materialPropertyBlock
        {
            get
            {
                m_MaterialPropertyBlock ??= new MaterialPropertyBlock();
                return m_MaterialPropertyBlock;
            }
        }

        void Awake()
        {
            for (int i = 0; i < matrices.Length; i++)
            {
                matrices[i] = Matrix4x4.TRS(
                    Random.insideUnitSphere * 10f, Quaternion.identity, Vector3.one
                );
                baseColors[i] =
                    new Vector4(Random.value, Random.value, Random.value, Random.value  );
            }
        }

        void Update()
        {
            _materialPropertyBlock.SetVectorArray(SShaderPropertyId.s_BaseColorPropertyId, baseColors);
            Graphics.DrawMeshInstanced(mesh, 0, material, matrices, 1023, m_MaterialPropertyBlock);
        }
    }
}
