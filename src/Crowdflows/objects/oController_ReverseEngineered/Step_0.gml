/// @description Update the Grid Space & Game Controls

//--// pathing queue
if(ds_queue_size(pathQueue) > 0)
{
	var _ticket = ds_queue_head(pathQueue);
	var _path = FindPath_Astar(_ticket.startPoint, _ticket.endPoint);
	for(var i=0; i< array_length(_ticket.units); i++)
	{
		var _unit = _ticket.units[i];
		if(instance_exists(_unit)) _unit.path = _path;
	}
	ds_queue_dequeue(pathQueue);
}

//--// Simulation Parameters

//For each timestep:
//•Convert the crowd to a density field.
//For each group:
//	•Construct the unit cost field C.
//	•Construct the potential φand it’s gradient ∇φ.
//	•Update the people’s locations.
//•Enforce the minimum distance between people.

// 1) Convert the crowd to a density field.
	// [ done in begin step ]
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
				// account for topographical speed & crowd density modifiers
				var _node = global.gridSpace[# i, j];
				_node.speedField = _node.topographSpeed;
			}
			}
					
/*
	There are two steps to computing the unit cost field C. We first
	compute the speed field f according to Equation (10), then calcu-
	late the cost field C using Equation (4).
	
	f(x,θ)=fT (x,θ) + ((ρ(x +rnθ)−ρmin)/(ρmax −ρmin)) (f ̄v(x,θ)−fT (x,θ)).
*/
	
//For each group:
// 2) Construct the unit cost field C.
// 3) Construct the potential φand it’s gradient ∇φ.
// 4) Update the people’s locations.
	//for(var i=0; i<ds_list_size(global.crowdList); i++)
	//{
	//	var _person = global.crowdList[| i];
	//	if(!_person.arrived)
	//	{
	//		var _gridX = _person.position[1] div CELL_SIZE;
	//		var _gridY = _person.position[2] div CELL_SIZE;
	//		var _node = global.gridSpace[# _gridX, _gridY]; 
	//		if(!is_undefined(_node))
	//		{
	//			var _dir = point_direction(_person.position[1],_person.position[2], _person.goal[1], _person.goal[2]);
	//			var _dist = point_distance(_person.position[1],_person.position[2], _person.goal[1], _person.goal[2]);
	//			var _unitVect = vect2(dcos(_dir), dsin(_dir));
	//			// interpolate velocity
	//			_person.velocity = vect2(
	//				lerp(_node.speedField[WEST], _node.speedField[EAST],(_person.position[1]-_gridX) / CELL_SIZE),
	//				lerp(_node.speedField[NORTH], _node.speedField[SOUTH],(_person.position[2]-_gridX) / CELL_SIZE)			
	//			);
	//			// stop at the goal position
	//			if(_dist <= vect_len(_person.velocity))
	//			{
	//				_person.position = _person.goal;
	//				_person.arrived = true;
	//			} else {
	//				// increment position
	//				_person.position = vect_add(_person.position, _person.velocity);
	//			}
	//		}
	//	}
	//}
// 5) Enforce the minimum distance between people.









//--// Input parameters

// pause the game
if(keyboard_check_pressed(vk_escape))
{
	global.gamePaused = !global.gamePaused;
	
	if(global.gamePaused)
	{
		// stop animating
		with(oPerson)
		{
			gamepausedimagespeed = image_speed;
			gamepausedspeed = speed;
			image_speed = 0;
			speed = 0;
		}
	} else {
		// start animating
		with(oPerson)
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


