#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2  uSize;
uniform float uLevel;
uniform float uPhase;
uniform vec4  uAmp0;
uniform vec4  uAmp1;
uniform vec4  uAmp2;
uniform float uS;
uniform vec4  uM0;
uniform vec4  uM1;
uniform vec4  uM2;
uniform vec4  uN0;
uniform vec4  uN1;
uniform vec4  uN2;
uniform float uNormInv;
uniform vec3  uBg;
uniform vec3  uGold;
uniform vec3  uTurq;
uniform vec3  uIndigo;
uniform sampler2D uLut;

out vec4 fragColor;

const float PI = 3.14159265;

float J(float row, float r) {
  vec4 t = texture(
    uLut,
    vec2(r * (511.0 / 512.0) + 0.5 / 512.0, (row + 0.5) / 12.0)
  );
  return (t.r * 255.0 * 256.0 + t.g * 255.0) / 65535.0 * 2.0 - 1.0;
}

float hash(vec2 p) {
  return fract(sin(dot(floor(p * 0.7), vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
  vec2 fc = FlutterFragCoord().xy;
  vec2 p = (fc - 0.5 * uSize) / (0.5 * min(uSize.x, uSize.y) * 0.94);

  float r = length(p);
  // Outside the plate stays transparent so the starry night shows through.
  if (r > 1.04) {
    fragColor = vec4(0.0);
    return;
  }

  // Fold the plate into one mirrored sector. No animated angular phase is
  // applied, so every frame keeps exact S-fold symmetry.
  float a = PI / uS;
  float th = mod(atan(p.y, p.x), 2.0 * a);
  th = th > a ? 2.0 * a - th : th;

  float rc = min(r, 1.0);
  float M[12] = float[12](
    uM0.x, uM0.y, uM0.z, uM0.w,
    uM1.x, uM1.y, uM1.z, uM1.w,
    uM2.x, uM2.y, uM2.z, uM2.w
  );
  float N[12] = float[12](
    uN0.x, uN0.y, uN0.z, uN0.w,
    uN1.x, uN1.y, uN1.z, uN1.w,
    uN2.x, uN2.y, uN2.z, uN2.w
  );
  float A[12] = float[12](
    uAmp0.x, uAmp0.y, uAmp0.z, uAmp0.w,
    uAmp1.x, uAmp1.y, uAmp1.z, uAmp1.w,
    uAmp2.x, uAmp2.y, uAmp2.z, uAmp2.w
  );

  float u = 0.0;
  for (int j = 0; j < 12; j++) {
    u += J(float(j), rc) * cos(M[j] * th) * N[j] * pow(A[j], 1.5);
  }

  // Two restrained, self-similar radial scales add organic depth without
  // replacing the twelve physical plate modes. Bass opens a broad copy;
  // mids/highs reveal a finer folded copy. The radial drift is slow and no
  // angular phase is introduced, so exact S-fold symmetry is preserved.
  float lowBand = 0.25 * (A[0] + A[3] + A[6] + A[9]);
  float detailBand = 0.25 * (A[2] + A[5] + A[8] + A[11]);
  float lowDrive = smoothstep(0.08, 0.78, lowBand) * uLevel;
  float detailDrive = smoothstep(0.10, 0.80, detailBand) * uLevel;
  float radialBreath = sin(uPhase * 2.0 * PI);
  float broadR = clamp(rc * (0.66 + 0.018 * radialBreath), 0.0, 1.0);
  float folded = fract(rc * 1.62 - uPhase * 0.018);
  float fineR = 1.0 - abs(2.0 * folded - 1.0);
  float broad = J(2.0, broadR) * cos(M[2] * th) * N[2]
      * pow(A[2], 1.35);
  float fine = J(9.0, fineR) * cos(M[9] * th) * N[9]
      * pow(A[9], 1.55);
  u += broad * 0.22 * lowDrive + fine * 0.12 * detailDrive;
  u *= uNormInv / (1.0 + 0.07 * lowDrive + 0.04 * detailDrive);

  float wd = 0.085 * (1.0 + 0.4 * uLevel);
  float sand = exp(-(u * u) / (wd * wd)) * (0.7 + 0.6 * hash(fc + uS));
  float halo = exp(-abs(u) / (wd * 3.0));
  float pp = max(u, 0.0);
  float nn = max(-u, 0.0);

  vec3 light =
      uTurq * (1.0 - exp(-pp * pp * 0.6)) * (0.22 + 0.25 * uLevel)
    + uIndigo * (1.0 - exp(-nn * nn * 0.6)) * (0.20 + 0.22 * uLevel)
    + uGold * (sand * (0.85 + 0.5 * uLevel) + halo * 0.22);

  // The plate is a translucent dark disc: the night stays faintly visible
  // behind the pattern. Output is premultiplied alpha.
  float inside = clamp((1.0 - r) / 0.03, 0.0, 1.0);
  float plate = 0.55 * inside;
  vec3 rim = uGold * exp(-pow((r - 1.0) / 0.008, 2.0)) * 0.6;
  vec3 rgb = uBg * plate + light * inside + rim;
  float alpha = clamp(
    plate + max(max(rgb.r, rgb.g), rgb.b),
    0.0,
    1.0
  );
  fragColor = vec4(min(rgb, vec3(alpha)), alpha);
}
