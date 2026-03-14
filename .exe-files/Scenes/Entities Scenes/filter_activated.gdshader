shader_type canvas_item;

uniform float reveal : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    if (UV.y > reveal) {
        tex.a = 0.0;
    }

    COLOR = tex;
}