/// @description Update the Grid Space & Game Controls

//--// Simulation Parameters

//For each timestep:
//•Convert the crowd to a density field.
//For each group:
//	•Construct the unit cost field C.
//	•Construct the potential φand it’s gradient ∇φ.
//	•Update the people’s locations.
//•Enforce the minimum distance between people.

// 1) Convert the crowd to a density field.
	for(var i=0; i<ds_list_size(global.crowdList); i++)
	{
		var _group = global.crowdList[| i];
		for(var j=0; j<ds_list_size(_group); j++)
		{
			var _person = _group[| j];
			// if velocity is not 0, then calculate density based on an offset position from the person
			if(_person.velocity[1] != 0) || (_person.velocity[2] != 0)
			{
				var _dir = _person.GetDirection;
				var _x = _person.x + lengthdir_x(_person.rhoRadius,_dir);
				var _y = _person.y + lengthdir_y(_person.rhoRadius,_dir);
			} else {
				var _x = _person.x;
				var _y = _person.y;
			}
/*
	For each person, we find the closest cell center whose coordinates are both less than that of the
	person. We then compute the relative coordinates [∆x,∆y]of that person with respect to the cell center, 
	as shown in Figure 4(b). The person’s density is then added to the grid as:
*/
// density field must be continuous
// each person shoudl contribute no less than rhoBar to their own cell but no more than rhoBar to neighboring cells
			var _node = undefined;
			var _rho = 0;
			var _cellx = (_x div CELL_SIZE)-1;
			var _celly = (_y div CELL_SIZE)-1;
			var _xDelta = _person.x - (_cellx*CELL_SIZE);
			var _yDelta = _person.y - (_celly*CELL_SIZE);
			var _valid = false;
			// density splatting
			for(var xx=-1;xx<=1;xx++)
			{
			for(var yy=-1;yy<=1;yy++)
			{
				_valid = (_cellx+xx >= 0)*(_cellx+xx < GRID_WIDTH)*(_celly+yy >= 0)*(_celly+yy < GRID_HEIGHT)
				if(_valid)
				{
					_node = global.gridSpace[# _cellx+xx, _celly+yy];
					var _dist = point_distance(_person.x,_person.y,_node.position[1],_node.position[2]);
					if(_dist <= rhoRadius)
					{
						_node.density += lerp(rhoBar*10, 0, _dist / rhoRadius);
					}
				}
			}
			}
			// density falloff
			for(var xx=0;xx<=1;xx++)
			{
			for(var yy=0;yy<=1;yy++)
			{
				_valid = (_cellx+xx >= 0)*(_cellx+xx < GRID_WIDTH)*(_celly+yy >= 0)*(_celly+yy < GRID_HEIGHT)
				if(_valid)
				{
					_node = global.gridSpace[# _cellx+xx, _celly+yy];
					if(xx=0) && (yy=0) _rho = min(1-_xDelta, 1-_yDelta)^lambda; // rhoA
					if(xx=1) && (yy=0) _rho = min(_xDelta,1-_yDelta)^lambda; // rhoB
					if(xx=1) && (yy=1) _rho = min(_xDelta,_yDelta)^lambda; // rhoC
					if(xx=0) && (yy=1) _rho = min(1-_xDelta, _yDelta)^lambda; // rhoD
					_node.density += _rho;
					vect_add(_node.rhoVel, vect_multr(_person.velocity, _rho));
				}
			}
			}			
		}
	}
/*
	this density conversion method is continuous with respect
	to the location of each person, and is defined so that each person
	contributes at least  ̄ρ to their grid cell, but no more than  ̄ρ to neigh-
	boring cells, with  ̄ρ=1/2λ. Thus, our requirements are satisfied.
	As we compute the density field ρ, we simultaneously compute the
	average velocity  ̄v according to Equation (7).
*/
	// loop through all cells to calculate average velocity
	for(var i=0;i<GRID_WIDTH;i++)
	{
	for(var j=0;j<GRID_HEIGHT;j++)
	{
		var _node = global.gridSpace[# i, j];
		_node.velocityAvg = vect_divr(_node.rhoVel, _node.density);
	}
	}
/*
	There are two steps to computing the unit cost field C. We first
	compute the speed field f according to Equation (10), then calcu-
	late the cost field C using Equation (4).
	
	f(x,θ)=fT (x,θ) + ((ρ(x +rnθ)−ρmin)/(ρmax −ρmin)) (f ̄v(x,θ)−fT (x,θ)).
*/
//--// loop through each person
	for(var i=0; i<ds_list_size(global.crowdList); i++)
	{
		var _group = global.crowdList[| i];
		for(var j=0; j<ds_list_size(_group); j++)
		{
			var _person = _group[| j];
			// calculate the speed field using equation (10)
			for(var theta=0;theta<360;theta+=90)
			{
				var _speed = vect_len(_person.velocity)
				var _unitVect = _speed == 0 ? vect2(0,0) : vect_divr(_person.velocity, vect_len(_person.velocity));
				var _x = _person.x + posOffset*_unitVect[1];
				var _y = _person.y + posOffset*_unitVect[2];
				_x = _x div CELL_SIZE;
				_y = _y div CELL_SIZE;
				_valid = (_x >= 0)*(_x < GRID_WIDTH)*(_y >= 0)*(_y < GRID_HEIGHT)
				if(_valid)
				{
					var _node = global.gridSpace[# _x div CELL_SIZE, _y div CELL_SIZE];
					// flow speed	
					var _flowSpeed = _speed == 0 ? 0 : vect_len(vect_mult(_unitVect, _node.velocityAvg));
					_node.speedField[theta div 90] = _flowSpeed;
					//show_message(string(_unitVect)+"\nFlowspeed: "+string(_flowSpeed)+"\nTopographical: "+string(_node.topographSpeed));
				}
			}
		}	
	}
	// loop through all cells to calculate cost, per equation (4)
	for(var i=0;i<GRID_WIDTH;i++)
	{
	for(var j=0;j<GRID_HEIGHT;j++)
	{
		var _alpha = 1;
		var _beta = 1;
		var _gamma = 1;
		var _node = global.gridSpace[# i, j];
		// value is anisotropic, so calculate for each cardinal direction
		for(var theta=0;theta<360;theta+=90)
		{
			var _ind = theta div 90;
			_node.cost[_ind] = (_alpha*_node.speedField[_ind]+_beta+_gamma*_node.discomfort) / _node.speedField[_ind];
		}
	}
	}
	
//For each group:
// 2) Construct the unit cost field C.
// 3) Construct the potential φand it’s gradient ∇φ.
	/*
	We begin by assigning the potential
	field φthe value of 0 inside the goal, and including these grid cells
	in the list of KNOWN cells; all other cells are UNKNOWN and set to ∞.
	*/
	for(var i=0;i<GRID_WIDTH;i++)
	{
	for(var j=0;j<GRID_HEIGHT;j++)
	{
		global.gridSpace[# i, j].potentialGradient = [0,0,0,0];
	}
	}
	for(var i=0; i<ds_list_size(global.crowdList); i++)
	{
		var _group = global.crowdList[| i];
		for(var j=0; j<ds_list_size(_group); j++)
		{
			var _person = _group[| j];
		}
	}
// 4) Update the people’s locations.
	for(var i=0; i<ds_list_size(global.crowdList); i++)
	{
		var _group = global.crowdList[| i];
		for(var j=0; j<ds_list_size(_group); j++)
		{
			var _person = _group[| j];
			
			// interpolate velocity
//			_person.velocity = 
			// increment position
			_person.x += _person.velocity[1];
			_person.y += _person.velocity[2];
		}
	}
// 5) Enforce the minimum distance between people.









//--// Input parameters

// pause the game
if(keyboard_check_pressed(vk_escape))
{
	global.gamePaused = !global.gamePaused;
	
	if(global.gamePaused)
	{
		// stop animating
		with(pUnit)
		{
			gamepausedimagespeed = image_speed;
			gamepausedspeed = speed;
			image_speed = 0;
			speed = 0;
		}
	} else {
		// start animating
		with(pUnit)
		{
			image_speed = gamepausedimagespeed;
			speed = gamepausedspeed;
		}
	}
}

////--// Grid View Controls
//var _viewCycleUp = keyboard_check_pressed(ord("E"));
//var _viewCycleDown = keyboard_check_pressed(ord("Q"));
//if(_viewCycleUp) if(++gridView > VIEW.ALL) gridView = VIEW.NONE;
//if(_viewCycleDown) if(--gridView < VIEW.NONE) gridView = VIEW.ALL;

//--// Camera controls
if(!global.gamePaused)
{
	// camera controls
	var _up, _left, _down, _right, _fastPan
	_up = keyboard_check(ord("W"));
	_left = keyboard_check(ord("A"));
	_down = keyboard_check(ord("S"));
	_right = keyboard_check(ord("D"));
	_fastPan = keyboard_check(vk_shift);
	// camera pan
	direction = point_direction(0, 0, _right - _left, _down - _up);
	if(abs(_right - _left) || abs(_down - _up)) 
	{
		follow = noone;
		xTo += lengthdir_x(spd+_fastPan*spd, direction);
		yTo += lengthdir_y(spd+_fastPan*spd, direction);
		x = xTo; 
		y = yTo;
	} 

	// update destination
	if(instance_exists(follow))
	{
		xTo = follow.x;
		yTo = follow.y;
	}

	// update object position
	x += 0.15*(xTo - x);
	y += 0.15*(yTo - y);

	//// keep camera inside the room
	//x = clamp(x, viewWidthHalf, room_width - viewWidthHalf);
	//y = clamp(y, viewHeightHalf, room_height - viewHeightHalf);

	//screen shake
	x += irandom_range(-shakeRemain, shakeRemain);
	y += irandom_range(-shakeRemain, shakeRemain);

	shakeRemain = max(0, shakeRemain - ((1/shakeLength)*shakeMagnitude));

	//camera_set_view_size(cam_, _display_manager.ideal_width_*view_zoom_,_display_manager.ideal_height_*view_zoom_);
	camera_set_view_pos(cam, x-viewWidthHalf, y-viewHeightHalf);

}


