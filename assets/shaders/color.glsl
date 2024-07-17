// https://gist.github.com/983/e170a24ae8eba2cd174f
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

uniform float hue;
uniform bool justHue;
uniform vec3 hsv;
uniform bool justColor;

vec4 effect(vec4 c, Image t, vec2 tc, vec2 sc) {
    if (justColor) {
        return vec4(hsv2rgb(hsv), 1);
    }
    if (justHue) {
        return vec4(hsv2rgb(vec3(1.0-tc.y,1.0,1.0)), 1);
    }
    return vec4(hsv2rgb(vec3(hue,tc.x,1.0-tc.y)), 1);
}