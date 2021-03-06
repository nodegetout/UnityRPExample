using UnityEditor;
using UnityEngine;

namespace ScorpioRP.Test.Editor
{
    public static class GeometryMatrixHelper
    {
        [MenuItem("Scorpio/Geometry/SphereMatrix")]
        private static void GenerateCubeMatrix()
        {
            var parent = new GameObject();
            parent.name = "SphereMatrix";
            parent.transform.position = Vector3.zero;
            parent.transform.rotation = Quaternion.identity;
            parent.transform.localScale = Vector3.one;

            const int maxColumnCount = 21;
            const int maxRowCount = 21;

            for (int i = 0; i < maxColumnCount; i++)
            {
                for (int j = 0; j < maxRowCount; j++)
                {
                    var go = GameObject.CreatePrimitive(PrimitiveType.Sphere);
                    go.transform.parent = parent.transform;
                    go.transform.position = new Vector3((float) i, 0.0f, (float) j);
                    var perObjectMaterialProperty = go.AddComponent<SPerObjectMaterialProperty>();
                    perObjectMaterialProperty.m_Metallic =  i / (float) (maxColumnCount - 1);
                    perObjectMaterialProperty.m_Roughness =  j / (float) (maxRowCount - 1);
                }
            }
        }
    }
}