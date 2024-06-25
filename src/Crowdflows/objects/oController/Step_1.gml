/// @description clear continuous values in the grid

for(var i=0;i<GRID_WIDTH;i++)
{
for(var j=0;j<GRID_HEIGHT;j++)
{
	var _node = global.gridSpace[# i,j];
	// reset density value
	_node.density = 0;
	_node.rhoVel = vect2(0,0);
}
}
