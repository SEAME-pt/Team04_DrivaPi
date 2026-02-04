#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(binding = 1) uniform sampler2D source;

layout(std140, binding = 0) uniform buf {
    float qt_Opacity;
    float topScale;
    float bottomScale;
    float centerBias;
} ubuf;

void main()
{
    vec2 uv = qt_TexCoord0;

    float scale = mix(ubuf.topScale, ubuf.bottomScale, uv.y);
    float center = 0.5 + ubuf.centerBias;

    float x = (uv.x - center) / scale + center;

    if (x < 0.0 || x > 1.0) {
        fragColor = vec4(0.0);
        return;
    }

    fragColor = texture(source, vec2(x, uv.y)) * ubuf.qt_Opacity;
}
