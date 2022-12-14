//
// Surface shader for Ribbon
//
// Texture format:
//
// _PositionTex.xyz = position
// _PositionTex.w   = random number
//
Shader "Custom/Ribbon"
{
    Properties
    {
        _PositionTex ("-", 2D) = ""{}
        _Color ("-", Color) = (1, 1, 1, 1)
        _Color2 ("-", Color) = (1, 1, 1, 1)
    }

    CGINCLUDE

    #pragma multi_compile COLOR_RANDOM COLOR_SMOOTH

    sampler2D _PositionTex;
    float4 _PositionTex_TexelSize;

    float _RibbonWidth;
    half4 _Color;
    half4 _Color2;
    half _Metallic;
    half _Smoothness;

    float2 _BufferOffset;

    struct Input {
        half color;
    };

    // pseudo random number generator
    float nrand(float2 uv, float salt)
    {
        uv += float2(salt, 0);
        return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
    }

    void vert(inout appdata_full v, out Input data, float flip)
    {
        UNITY_INITIALIZE_OUTPUT(Input, data);

        float4 uv = float4(v.texcoord + _BufferOffset, 0, 0);
        float4 duv = float4(_PositionTex_TexelSize.x, 0, 0, 0);

        // line number
        float ln = uv.y;

        // adjacent vertices
        float3 p1 = tex2Dlod(_PositionTex, uv - duv * 2).xyz;
        float3 p2 = tex2Dlod(_PositionTex, uv          ).xyz;
        float3 p3 = tex2Dlod(_PositionTex, uv + duv * 2).xyz;

        // binormal vector
        float3 bn = normalize(cross(p3 - p2, p2 - p1)) * flip;

        v.vertex.xyz = p2 + bn * _RibbonWidth * nrand(ln, 10) * v.vertex.x;
        v.normal = normalize(cross(bn, p2 - p1));

#if COLOR_RANDOM
        data.color = nrand(ln, 11);
#else
        data.color = ln;
#endif
    }

    ENDCG

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM

        #pragma surface surf Standard vertex:vert_front nolightmap addshadow
        #pragma target 3.0

        void vert_front(inout appdata_full v, out Input data)
        {
            vert(v, data, 1);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = lerp(_Color, _Color2, IN.color);
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG

        CGPROGRAM

        #pragma surface surf Standard vertex:vert_back nolightmap addshadow
        #pragma target 3.0

        void vert_back(inout appdata_full v, out Input data)
        {
            vert(v, data, -1);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = lerp(_Color, _Color2, IN.color);
            o.Metallic = _Metallic;
            o.Smoothness = _Smoothness;
        }

        ENDCG
    }
}
