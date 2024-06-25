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
	if(!_node.walkable) 
	{
		draw_set_color(c_dkgrey);
		draw_set_alpha(0.8);
	}
	draw_rectangle(_x,_y,_x+CELL_SIZE,_y+CELL_SIZE,false);
	//draw_set_halign(fa_center);
	//draw_set_valign(fa_middle);
	//draw_set_color(c_white);
	//draw_text(_x+0.5*CELL_SIZE,_y+0.5*CELL_SIZE,"Rho: "+string(_node.density)+"\nVel: "+string(_node.velocityAvg))
	draw_set_alpha(1);
	draw_set_color(c_white);
	draw_set_halign(fa_center);
	draw_set_valign(fa_top);
	//// draw speed field at edges
	//draw_text(_x+0.5*CELL_SIZE,_y,string(_node.speedField[NORTH]));
	//draw_set_halign(fa_center);
	//draw_set_valign(fa_bottom);
	//draw_text(_x+0.5*CELL_SIZE,_y+CELL_SIZE,string(_node.speedField[SOUTH]));
	//draw_set_halign(fa_left);
	//draw_set_valign(fa_middle);
	//draw_text(_x,_y+0.5*CELL_SIZE,string(_node.speedField[WEST]));
	//draw_set_halign(fa_right);
	//draw_set_valign(fa_middle);
	//draw_text(_x+CELL_SIZE,_y+0.5*CELL_SIZE,string(_node.speedField[EAST]));
	// draw density & average velocity & movePenalty
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	draw_text(_x+0.5*CELL_SIZE,_y+0.5*CELL_SIZE,"Rho: "+string(_node.density) 
	                                           +"\nVel: ["+ string(_node.velocityAvg[1])+","+string(_node.velocityAvg[2])+"]"
											   +"\nPen: " + string(_node.movePenalty)
											   );
	// draw h & f Costs
	//draw_set_halign(fa_center);
	//draw_set_valign(fa_middle);
	//draw_text(_x+0.5*CELL_SIZE,_y+0.5*CELL_SIZE,"G: "+string(_node.gCost)+"\nH: "+string(_node.hCost));
}
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);