#version 120

uniform float time;
uniform vec2 center;
uniform vec4 u_color;

varying vec4 worldPos;
varying vec4 vColor;

// =======================================================================
// [CONFIGURATION]
// =======================================================================

// 1. SIZE: Lower = Bigger clouds
const float NOISE_SCALE = 0.006;

// 2. SPEED: How fast does it scroll?
const vec2 SCROLL_SPEED = vec2(0.3, 0.5);

// 3. CONTRAST: 1.0 = Blurry/Flat. 0.0 = Sharp edges.
const float SHARPNESS = 0.5;

// 4. VISIBILITY:
const float OPACITY_MIN = 0.6; // The most transparent part of the smoke
const float OPACITY_MAX = 0.8; // The most opaque part of the smoke

// 5. DETAIL: 0.0 to 1.0
const float DETAIL_STRENGTH = 0.3;

// 6. ACCENT COLOR (The 2nd color - "hot" parts).
const vec3 ACCENT_COLOR = vec3(1.0, 0.91, 0.29);

// 7. COLOR MIX STRENGTH
// 0.0 = Only use base color. 1.0 = Fully switch to accent in dense spots.
const float COLOR_MIX_AMOUNT = 0.2;

// =======================================================================

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void main() {
    // 1. Setup Base Coordinates
    vec2 uv = (worldPos.xz - center) * NOISE_SCALE;
    vec2 flow = time * SCROLL_SPEED;

    // 2. Generate 3 Layers of Noise (Fractal Brownian Motion)

    // Layer 1: Base Shape (Big, Slow)
    float n1 = noise(uv - flow);

    // Layer 2: Medium Detail (2x smaller, 1.5x faster)
    float n2 = noise(uv * 2.0 + flow * 1.5);

    // Layer 3: Fine Grit/Shimmer (4x smaller, 3.0x faster)
    float n3 = noise(uv * 4.0 + flow * 3.0);

    // 3. Mix Layers
    // Weights: 50% Base, 30% Medium, 20% Small (roughly)
    // We use DETAIL_STRENGTH to control the 3rd layer's impact
    float weightedNoise = (n1 * 0.5) + (n2 * 0.3) + (n3 * DETAIL_STRENGTH);

    // Normalize slightly because adding layers can push values > 1.0
    weightedNoise = weightedNoise / (0.8 + DETAIL_STRENGTH);

    // 4. Apply Sharpness
    float density = smoothstep(0.5 - (0.5 * SHARPNESS), 0.5 + (0.5 * SHARPNESS), weightedNoise);

    // 5. Final Output
    float finalAlpha = mix(OPACITY_MIN, OPACITY_MAX, density);

    // NEW: Mix the base color (Orange) with the Accent Color (Yellow)
    // The denser the smoke, the more yellow it gets.
    vec3 mixedColor = mix(vColor.rgb, ACCENT_COLOR, density * COLOR_MIX_AMOUNT);

    gl_FragColor = vec4(mixedColor, vColor.a * finalAlpha);
}
