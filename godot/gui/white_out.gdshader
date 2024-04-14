shader_type canvas_item;

uniform float strength = 0.0;

void fragment() {
	if (COLOR.a != 0.0) {
		COLOR = vec4(min(COLOR.r + strength, 1.0), min(COLOR.g + strength, 1.0), min(COLOR.b + strength, 1.0), 1.0);
	}
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
