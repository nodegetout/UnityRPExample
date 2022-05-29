using UnityEditor;
using UnityEngine;

namespace ScorpioRP.Editor.Editor
{
    public class PBRTextureCombiner_EditorWindow : EditorWindow
    {
        [MenuItem("MENUITEM/MENUITEMCOMMAND")]
        private static void ShowWindow()
        {
            var window = GetWindow<PBRTextureCombiner_EditorWindow>();
            window.titleContent = new GUIContent("TITLE");
            window.Show();
        }

        private void OnGUI()
        {
            
        }
    }
}