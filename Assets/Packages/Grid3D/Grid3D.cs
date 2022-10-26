using UnityEngine;


public class Grid3D : MonoBehaviour
{
    public static class ShaderParam
    {
        public static readonly int CenterPosition = Shader.PropertyToID("_CenterPosition");
        public static readonly int GridCount = Shader.PropertyToID("_GridCount");
        public static readonly int GridInterval = Shader.PropertyToID("_GridInterval");
        public static readonly int LineWidth = Shader.PropertyToID("_LineWidth");
        public static readonly int LineLength = Shader.PropertyToID("_LineLength");
    }

    public Material material;
    public Vector3Int gridCount = Vector3Int.one * 100;
    public float gridInterval = 1f;
    public float gridSize = 0.2f;
    public float gridWidth = 0.01f;


    private void OnRenderObject()
    {
        if ((Camera.current.cullingMask & (1 << gameObject.layer)) != 0)
        {
            var lineVertexCount = 6 * 2;
            var starVertexCount = lineVertexCount * 3;

            var vertexCount = gridCount.x * gridCount.y * gridCount.z * starVertexCount;

            material.SetVector(ShaderParam.CenterPosition, transform.position);
            material.SetVector(ShaderParam.GridCount, (Vector3)gridCount);
            material.SetFloat(ShaderParam.GridInterval, gridInterval);
            material.SetFloat(ShaderParam.LineWidth, gridWidth);
            material.SetFloat(ShaderParam.LineLength, gridSize);

            material.SetPass(0);
            Graphics.DrawProceduralNow(MeshTopology.Triangles, vertexCount);
        }
    }
}
