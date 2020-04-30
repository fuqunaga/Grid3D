Shader "Custom/Grid3D"
{
    Properties
    {
        _Color("Color", color) = (1,1,1,1)
        _GridCount("GridCount", Vector) = (100,100,100,0)
        _GridInterval("GridInterval", Float) = 10
        _LineWidth("LineWidth", Float) = 0.01
        _LineLength("LineLength", Float) = 0.2
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
            ZTest Always

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _GridCount;
            float _GridInterval;
            float _LineWidth;
            float _LineLength;

            float3 calcQuadVertex(uint vtx_idx) // face 0:x 1:y 2:z
            {
                float3 offset;
                if      ( vtx_idx == 0) offset = float3(-0.5, -0.5, 0);
                else if ( vtx_idx == 1) offset = float3( 0.5, -0.5, 0);
                else if ( vtx_idx == 2) offset = float3(-0.5,  0.5, 0);
                else if ( vtx_idx == 3) offset = float3( 0.5,  0.5, 0);
                else if ( vtx_idx == 4) offset = float3(-0.5,  0.5, 0);
                else if ( vtx_idx == 5) offset = float3( 0.5, -0.5, 0);

                offset.x *= _LineWidth;
                offset.y *= _LineLength;

                return offset;
            }

            float4 vert (uint id : SV_VERTEXID) : SV_POSITION
            {
                uint vtx_per_quad = 6;
                uint vtx_per_line = vtx_per_quad * 2;
                uint vtx_per_star = vtx_per_line * 3;

                uint quad_vtx_idx = id % vtx_per_quad;
                float3 quad = calcQuadVertex(quad_vtx_idx);

                uint line_vtx_idx = id % vtx_per_line;
                bool rot90 = line_vtx_idx >= vtx_per_quad;

                quad.xyz = rot90 ? quad.zyx : quad.xyz;

                // up_axix: 0:x 1:y 2:z
                uint line_idx_per_star = (id % vtx_per_star) / vtx_per_line;
                switch(line_idx_per_star)
                {
                    case 0: quad.xyz = quad.yxz; break;
                    case 2: quad.xyz = quad.xzy; break;
                }

                uint star_idx = id / vtx_per_star;
                int3 gridCount = (int3)_GridCount;

                float3 xyz_idx = float3(
                    (star_idx / gridCount.z) % gridCount.x,
                    star_idx / (gridCount.x * gridCount.z),
                    star_idx % gridCount.z
                );

                float3 origin = _GridCount * -0.5;

                float3 pos = (xyz_idx + origin) * _GridInterval + quad;

                return mul(UNITY_MATRIX_VP, float4(pos,1));
            }

            fixed4 _Color;

            fixed4 frag () : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
