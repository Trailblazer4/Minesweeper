shader_type canvas_item;

uniform vec3 bg_color: source_color = vec3(0.58823529411, 0.67843137254, 0.66666666666);
uniform vec3 border_color: source_color = vec3(0.0);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if ((0.125 < UV.x && UV.x < 0.875) && (0.0625 < UV.y && UV.y < 0.4375)) {
		COLOR.rgb = bg_color;
	}
	else {
		COLOR.rgb = mix(COLOR.rgb, border_color, 0.3);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
