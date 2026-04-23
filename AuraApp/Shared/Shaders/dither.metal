//
//  Shaders.metal
//  AuraApp
//
//  Created by Wahyu Kurniawan on 22/04/26.
//

#include<metal_stdlib>
using namespace metal;

constant float bayer4x4[16] = {
  0, 8, 2, 10,
    12, 4, 14, 6,
    3, 11, 1, 9,
    15, 7, 13, 5
};

[[stitchable]] half4 dither(float2 position, half4 color) {
  int x = int(position.x) % 4;
  int y = int(position.y) % 4;
  float threshold = bayer4x4[y * 4 + x] / 16.0;

  float gray = dot(float3(color.rgb), float3(0.299, 0.587, 0.114));
  float dithered = gray > threshold ? 1.0 : 0.0;

  return half4(half3(dithered), color.a);
};
