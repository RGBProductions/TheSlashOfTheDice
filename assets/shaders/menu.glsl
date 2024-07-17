uniform Image tex;
uniform vec2 texSize;
uniform highp float time;

vec4 effect(vec4 c, Image t, vec2 tc, vec2 sc) {
    highp vec2 uv = (sc+vec2(time,time))/texSize;
    return Texel(tex, uv)*c;
}