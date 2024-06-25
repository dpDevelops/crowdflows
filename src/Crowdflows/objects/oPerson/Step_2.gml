/// @description 

image_angle = vect_direction(velocity);

position = vect_add(position, velocity);
x = position[1];
y = position[2];

/*

var _grid = global.iSim.game_grid;
if(point_in_rectangle(mouse_x,mouse_y,GRID_SIZE,GRID_SIZE,ds_grid_width(_grid)*GRID_SIZE-GRID_SIZE,ds_grid_height(_grid)*GRID_SIZE-GRID_SIZE))
{
	x = mouse_x;
	y = mouse_y;
}