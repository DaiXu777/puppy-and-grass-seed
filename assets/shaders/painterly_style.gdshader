shader_type canvas_item;

// 三渲二厚涂风着色器
// Painterly Thick-Paint Cel-Shading Post-Processing
// 温馨插画风格

uniform float paint_strength : hint_range(0.0, 1.0) = 0.35;
uniform float paper_texture_strength : hint_range(0.0, 1.0) = 0.2;
uniform vec3 warm_tint = vec3(1.05, 1.02, 0.95);
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.3;
uniform float brush_detail : hint_range(1.0, 4.0) = 2.0;

// 伪随机噪声函数（用于模拟画笔质感）
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// 更柔和的噪声（模拟厚涂笔触）
float brush_noise(vec2 uv, float time) {
    float n = 0.0;
    vec2 offset = vec2(time * 0.02, time * 0.01);
    
    n += hash(floor((uv + offset) * 80.0 * brush_detail)) * 0.5;
    n += hash(floor((uv + offset) * 160.0 * brush_detail)) * 0.3;
    n += hash(floor((uv + offset) * 320.0 * brush_detail)) * 0.2;
    
    return n;
}

// 边缘柔化（模拟厚涂的边缘晕染效果）
float soft_edge(vec2 uv) {
    float edge_x = smoothstep(0.0, 0.08, uv.x) * smoothstep(0.0, 0.08, 1.0 - uv.x);
    float edge_y = smoothstep(0.0, 0.08, uv.y) * smoothstep(0.0, 0.08, 1.0 - uv.y);
    return edge_x * edge_y;
}

// 暗角效果（聚焦中心，增加温馨感）
float vignette(vec2 uv) {
    uv = uv * 2.0 - 1.0;
    float dist = length(uv) * 0.7;
    return 1.0 - dist * vignette_strength;
}

void fragment() {
    vec4 original = texture(TEXTURE, UV);
    
    // 1. 厚涂笔触纹理
    float noise_val = brush_noise(UV, TIME);
    float paint_texture = mix(1.0, 0.9 + noise_val * 0.15, paint_strength);
    
    // 2. 纸张纹理叠加
    float paper = 1.0 - (noise_val * 0.08 * paper_texture_strength);
    
    // 3. 暖色调调整
    vec3 warm_color = original.rgb * warm_tint;
    
    // 4. 三渲二：色彩量化（减少色阶，模拟赛璐珞）
    float levels = 8.0 + brush_detail * 2.0;
    vec3 cel_color = floor(warm_color * levels) / levels;
    vec3 final_color = mix(warm_color, cel_color, paint_strength * 0.4);
    
    // 5. 边缘柔化
    float edge = soft_edge(UV);
    final_color *= mix(1.0, edge, paint_strength * 0.3);
    
    // 6. 暗角
    float vig = vignette(UV);
    final_color *= vig;
    
    // 7. 纸张质感叠加
    final_color *= paper;
    
    // 8. 轻微的饱和度提升（插画风格）
    float gray = dot(final_color, vec3(0.299, 0.587, 0.114));
    final_color = mix(vec3(gray), final_color, 1.15);
    
    COLOR = vec4(final_color, original.a);
}
