#include <metal_stdlib>
using namespace metal;

[[stitchable]] half4 sunRays(float2 position, half4 color, float time, float2 size) {
    // Normalize coordinates
    float2 uv = position / size;
    
    // Origin at top center
    float2 center = float2(0.5, -0.1);
    float2 dir = uv - center;
    
    // Distance from origin
    float dist = length(dir);
    
    // Angle for rays
    float angle = atan2(dir.y, dir.x);
    
    // Create moving rays using sin waves
    float rays = sin(angle * 8.0 + time * 0.4) * 0.5 + 0.5;
    rays += sin(angle * 15.0 - time * 0.2) * 0.3;
    
    // Mask by distance (fade out as we go down)
    float mask = pow(max(0.0, 1.0 - dist * 0.8), 3.0);
    
    // Base purple color
    half3 purple = half3(0.68, 0.55, 0.95); // A nice lavender/purple
    
    // Final intensity
    float intensity = rays * mask * 0.4;
    
    return half4(purple, intensity * color.a);
}
