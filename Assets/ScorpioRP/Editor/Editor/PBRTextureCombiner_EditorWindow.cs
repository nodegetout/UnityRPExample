using System.IO;
using System.Web.Razor.Parser;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;

namespace ScorpioRP.Editor.Editor
{
    public class PBRTextureCombiner : EditorWindow
    {
        [MenuItem("Scorpio/TextureToolset")]
        private static void ShowWindow()
        {
            var window = GetWindow<PBRTextureCombiner>();
            window.titleContent = new GUIContent("PBR Textures Combiner");
            window.Show();
        }

        private Texture2D m_RoughnessMap;
        private Texture2D m_MetallicMap;
        private Texture2D m_AOMap;
        private string m_DefaultPath;

        void OnGUI()
        {
            EditorGUI.BeginChangeCheck();
            // Sprite Texture Selection
            m_RoughnessMap = EditorGUILayout.ObjectField("Roughness Texture", m_RoughnessMap, typeof(Texture2D), false) as Texture2D;
            m_MetallicMap = EditorGUILayout.ObjectField("Metallic Texture", m_MetallicMap, typeof(Texture2D), false) as Texture2D;
            m_AOMap = EditorGUILayout.ObjectField("Ambient Occlusion Texture", m_AOMap, typeof(Texture2D), false) as Texture2D;
            if (EditorGUI.EndChangeCheck())
            {
                // m_CreationFeedback = string.Empty;
                m_DefaultPath = AssetDatabase.GetAssetPath(m_RoughnessMap);
            }

            GUILayout.Space(10);
            
            if (GUI.Button(new Rect(0f, 300, 260f, 50f), "Generate Combined PBR Texture"))
            {
                // Debug.Log(m_DefaultPath);
                string path = EditorUtility.SaveFilePanelInProject("Save Texture", "_rma", "tga", "OK", m_DefaultPath);
                Debug.Log(path);
                if (!string.IsNullOrEmpty(path))
                {
                    var combinedTexture = CreatePbpRmaTexture(m_RoughnessMap, m_MetallicMap, m_AOMap);
                    SaveTexture2DAsTGAImage(combinedTexture, path);
                }
            }
        }

        Texture2D CreatePbpRmaTexture(Texture2D roughness, Texture2D metallic, Texture2D ao)
        {
            if (roughness == null || metallic == null || ao == null)
            {
                return null;
            }

            bool hasSameWidth  = roughness.width != metallic.width && roughness.width != ao.width;
            bool hasSameHeight = roughness.height != metallic.height && roughness.height != ao.height;
            if (!hasSameWidth || !hasSameHeight)
            {
                return null;
            }

            int width  = roughness.width;
            int height = roughness.height;
            
            Debug.Log($"{width} - {height}");

            Texture2D result = new Texture2D(width, height, TextureFormat.RGB24, false);
            Color color;
            // result.set
            for (int i = 0; i < width; i++)
            {
                for (int j = 0; j < height; j++)
                {
                    color = new Color(roughness.GetPixel(i, j).r, metallic.GetPixel(i, j).r, ao.GetPixel(i, j).r);
                    result.SetPixel(i, j, color);
                }
            }
            result.Apply();

            return result;
        }

        void SaveTexture2DAsTGAImage(Texture2D tex, string path)
        {
            if (tex == null || string.IsNullOrEmpty(path))
            {
                return;
            }

            var bytes = tex.EncodeToPNG();
            Object.Destroy(tex);
        
            // string targetPath = Path.Combine(Application.dataPath, AssetDatabase.GetAssetPath(tex));
            // Write the returned byte array to a file in the project folder
            File.WriteAllBytes(Application.dataPath, bytes);
        }
    }
}