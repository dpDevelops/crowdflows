/// @description reset density & avg velocity
var i,j;
var _node = undefined;
var _valid = false;
var _dist = 0;
var _dir = 0;
var _x = 0;
var _y = 0;
var _xCell = 0;
var _yCell = 0;
var _max = 0;

for(i=0;i<GRID_WIDTH;i++)
{
for(j=0;j<GRID_HEIGHT;j++)
{
	_node = global.gridSpace[# i,j];
	// reset density value
	_node.density = 0;
	_node.velocityAvg[1] = 0;
	_node.velocityAvg[2] = 0;
	_node.population = 0;
}
}

for(var i=0; i<ds_list_size(global.crowdList); i++)
{
	var _person = global.crowdList[| i];
	if(instance_exists(_person))
	{
		_dist = vect_len(_person.velocity) == 0 ? 0 : CELL_SIZE;
		_dir = _person.direction;
		_x = clamp(_person.position[1] + lengthdir_x(_dist, _dir),0,room_width);
		_y = clamp(_person.position[2] + lengthdir_y(_dist, _dir),0,room_height);
		_xCell = (_x div CELL_SIZE);
		_yCell = (_y div CELL_SIZE);
		

		// density splatting
		for(var xx=-1;xx<=1;xx++)
		{
		for(var yy=-1;yy<=1;yy++)
		{
			_valid = (_xCell+xx >= 0)*(_xCell+xx < GRID_WIDTH)*(_yCell+yy >= 0)*(_yCell+yy < GRID_HEIGHT)
			if(_valid)
			{
				_node = global.gridSpace[# _xCell+xx, _yCell+yy];
				_dist = point_distance(_person.position[1],_person.position[2],_node.position[1],_node.position[2]);
				// set density
				_node.density += lerp(rhoMax, rhoMin, min(_dist / rhoRadius, 1));
			}
		}
		}
		
		// limit personal density, then increment average velocity
		_x = _person.position[1];
		_y = _person.position[2];
		_node = global.gridSpace[# _x div CELL_SIZE, _y div CELL_SIZE];
		_node.density = min(_node.density, rhoBar);
		_node.population++;
		_node.velocityAvg = vect_add(_node.velocityAvg, _person.velocity);
	}
}
// set average velocity
for(var i=0;i<GRID_WIDTH;i++)
{
for(var j=0;j<GRID_HEIGHT;j++)
{
	_node = global.gridSpace[# i,j];
	if(_node.population > 0) _node.velocityAvg = vect_divr(_node.velocityAvg, _node.population);
}
}
