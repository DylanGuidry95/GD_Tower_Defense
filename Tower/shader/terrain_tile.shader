shader_type canvas_item;
uniform float height;

void fragment()
{
	vec4 grass = vec4(0,1,0,1);
	vec4 water = vec4(0, 0, 1, 1);
	vec4 mountain = vec4(1, .98, .98, 1);
	
	vec4 c = texture(TEXTURE, UV);
	
	if(height >= 1.5)
		COLOR = mountain * c;
	else if(height <= -1.0)
		COLOR = water * c;
	else	
		COLOR = grass * c;	
}