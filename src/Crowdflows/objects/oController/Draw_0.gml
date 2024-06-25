/// @description 

var _textColor = c_lime;
var _sep = 8;
var _wid = 40;
draw_set_color(c_white);
draw_set_font(fDefault);
for(var i=0;i<GRID_WIDTH;i++)
{
for(var j=0;j<GRID_HEIGHT;j++)
{
	var _node = global.gridSpace[# i, j];
	var _x = i*CELL_SIZE  //+0.5*CELL_SIZE;
	var _y = j*CELL_SIZE  //+0.5*CELL_SIZE;
	draw_set_color(c_black);
	draw_set_alpha(_node.height*0.01);
	draw_rectangle(_x,_y,_x+CELL_SIZE,_y+CELL_SIZE,false);
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_set_color(c_white);
	draw_text(_x+0.5*CELL_SIZE,_y+0.5*CELL_SIZE,"Rho: "+string(_node.density)+"\nVel: "+string(_node.velocityAvg))
}
}
for(var i=0; i<ds_list_size(global.crowdList); i++)
{
	var _group = global.crowdList[| i];
	for(var j=0; j<ds_list_size(_group); j++)
	{
		var _person = _group[| j];
		var _rad = 3;
		draw_set_alpha(1);
		draw_set_color(c_black);
		draw_circle(_person.x,_person.y, _rad,true);
		draw_set_color(_person.color);
		draw_circle(_person.x, _person.y, _rad, false);
	}
}
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);