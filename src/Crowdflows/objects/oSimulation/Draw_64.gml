/// @description 

draw_set_font(fNode);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);

draw_text(10,5,"[shift+left-click] to adjust start point\n[shift+right-click] to adjust end point")
for(var i=0;i<array_length(groups);i++)
{
	var _x = 20;
	var _y = 40 + i*15;
	var _group = groups[i];
	var _color = _group.active ? _group.color1 : c_black;
	var _str = group_focused == i ? "Group " + string(i) + " (selected)" : "Group " + string(i)
	draw_set_color(_color)
	draw_text(_x, _y, _str);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(fTitle);
draw_set_color(c_black);
draw_text(20,100,"camera pos: [" + string(global.iCamera.x) + ", " + string(global.iCamera.y)+ "]");