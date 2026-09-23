#version 440
// Inverts colour, keeps alpha (premultiplied): used for single-colour tray
// icons that would vanish on the bar. Compile: qsb --qt6 -o invert.frag.qsb invert.frag
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
};
layout(binding = 1) uniform sampler2D source;
void main() {
    vec4 c = texture(source, qt_TexCoord0);
    fragColor = vec4(c.a - c.rgb, c.a) * qt_Opacity;
}
