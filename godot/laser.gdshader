shader_type spatial;

uniform vec4 beam_color = vec4(1.0, 0.0, 0.0, 1.0); // Red color
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0; // Increase for more glow

void fragment() {
    float glow = glow_strength * abs(sin(TIME));
    ALBEDO = beam_color.rgb;
    EMISSION = beam_color.rgb * glow; // Increased emission for bloom
    ALPHA = beam_color.a;
}
