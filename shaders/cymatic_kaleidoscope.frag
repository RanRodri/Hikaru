#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
// Seconds of motion. Advances only while the cymatic is alive.
uniform float uTime;
// 0 at rest, 1 while the rhythm is fully present.
uniform float uMotion;
// 1.0 at rest, about 1.15 on a peak.
uniform float uPulse;
// 0 draws diamonds, 1 draws round petals.
uniform float uMorph;
uniform float uGlow;
// 0-1 attack energy that brightens the core.
uniform float uSpark;
// Low, mid and high band shares.
uniform vec3 uBands;
uniform vec3 uTint;
uniform vec3 uHighlight;
uniform vec3 uBackgroundCenter;
uniform vec3 uBackgroundEdge;
uniform float uFolds;

out vec4 fragColor;

const float PI = 3.14159265;
const float TAU = 6.28318531;
// Mandala radius as a share of the shortest side, so the pulse stays on screen.
const float MANDALA_SHARE = 0.4;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
}

float noise(vec2 p) {
  vec2 cell = floor(p);
  vec2 local = fract(p);
  vec2 blend = local * local * (3.0 - 2.0 * local);
  float a = hash(cell);
  float b = hash(cell + vec2(1.0, 0.0));
  float c = hash(cell + vec2(0.0, 1.0));
  float d = hash(cell + vec2(1.0, 1.0));
  return mix(mix(a, b, blend.x), mix(c, d, blend.x), blend.y);
}

float fbm(vec2 p) {
  float value = 0.0;
  float amplitude = 0.5;
  for (int octave = 0; octave < 5; octave++) {
    value += amplitude * noise(p);
    p = p * 2.02 + vec2(3.1, 1.7);
    amplitude *= 0.5;
  }
  return value;
}

mat2 rotation(float angle) {
  float c = cos(angle);
  float s = sin(angle);
  return mat2(c, -s, s, c);
}

// Folds the plane into one mirrored sector: x runs along the sector axis.
vec2 foldSector(vec2 p, float folds) {
  float sector = TAU / folds;
  float angle = mod(atan(p.y, p.x) + sector * 0.5, sector) - sector * 0.5;
  return vec2(cos(angle), abs(sin(angle))) * length(p);
}

// Thin bright veins where the noise crosses its midline.
float ridges(vec2 p) {
  float value = 0.0;
  float amplitude = 0.55;
  for (int octave = 0; octave < 4; octave++) {
    value += amplitude * (1.0 - abs(noise(p) * 2.0 - 1.0));
    p = p * 2.1 + vec2(1.3, 7.1);
    amplitude *= 0.5;
  }
  return value;
}

vec3 saturate(vec3 color, float amount) {
  float luma = dot(color, vec3(0.299, 0.587, 0.114));
  return clamp(mix(vec3(luma), color, amount), 0.0, 1.0);
}

float stars(vec2 frag, float time) {
  vec2 grid = frag / 22.0;
  vec2 id = floor(grid);
  vec2 local = fract(grid) - 0.5;
  vec2 offset = vec2(hash(id + 3.1), hash(id + 5.7)) - 0.5;
  float distance = length(local - offset * 0.7);
  float present = step(0.92, hash(id));
  float twinkle = 0.55 + 0.45 * sin(time * 1.6 + hash(id + 9.2) * TAU);
  return smoothstep(0.07, 0.0, distance) * present * twinkle;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  float unit = MANDALA_SHARE * min(uSize.x, uSize.y);
  vec2 uv = (frag - 0.5 * uSize) / unit;
  float screenRadius = length(uv);
  float time = uTime;

  vec3 rich = saturate(uTint, 1.4);
  vec3 deep = mix(rich * rich, rich * 0.6, 0.5);
  vec3 hot = mix(rich, uHighlight, 0.55);

  vec3 color = mix(
    uBackgroundCenter * 0.5,
    uBackgroundEdge * 0.7,
    smoothstep(0.3, 3.0, screenRadius)
  );
  float nebula = fbm(uv * 0.7 + vec2(time * 0.03, -time * 0.02));
  color += deep * 0.35 * nebula * exp(-screenRadius * 0.55);
  color += uHighlight * stars(frag, time) * 0.3;

  vec2 p = rotation(time * 0.04) * (uv / uPulse);
  float radius = length(p);
  vec2 sector = foldSector(p, uFolds);

  // A mirrored smoke field: clusters, bright skins, and fine filaments.
  vec2 flow = sector * (4.2 + 1.6 * uBands.y);
  flow += vec2(time * 0.14, -time * 0.06);
  float warp = fbm(flow * 0.7);
  flow += vec2(warp - 0.5, fbm(flow.yx * 0.85 + 3.7) - 0.5) *
    (0.85 + 0.5 * uMorph);

  float smoke = fbm(flow);
  float grain = ridges(flow * 1.8 + vec2(time * 0.05, 1.4));
  float clouds = pow(smoothstep(0.36, 0.74, smoke), 1.25);
  float skin = pow(smoothstep(0.1, 0.0, abs(smoke - 0.56)), 1.5);
  float filaments = pow(grain, 3.4);
  filaments *= 0.65 + 0.9 * uBands.z + 0.45 * uSpark;

  float ripples = 0.0;
  for (int wave = 0; wave < 3; wave++) {
    float travel = fract(time * 0.11 + float(wave) / 3.0);
    ripples += exp(-abs(radius - travel * 1.15) * 36.0) *
      (0.35 + 0.65 * sin(travel * PI));
  }
  ripples *= 0.18 + 0.5 * uBands.x;

  float core = exp(-radius * 9.0) * (0.45 + 0.7 * uSpark);
  float plate = smoothstep(1.28, 0.18, radius);
  float presence = 0.62 + 0.38 * uMotion;
  vec3 mandala = deep * clouds * 0.9 +
    rich * (filaments * 1.35 + ripples) +
    hot * (skin * 1.55 + filaments * 0.35);
  mandala *= plate;
  mandala += hot * core * 0.65;
  color += mandala * presence * uGlow;

  color = vec3(1.0) - exp(-color * 1.7);
  color = pow(color, vec3(1.05));
  fragColor = vec4(color, 1.0);
}
