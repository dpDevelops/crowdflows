/// @description 

var _node = global.gridSpace[# mouse_x div CELL_SIZE, mouse_y div CELL_SIZE];

if(!is_undefined(_node))
{
	_node.movePenalty+=10;
}
