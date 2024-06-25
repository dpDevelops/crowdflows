function UserInteract(){
	if(keyboard_check_pressed(vk_f1))
	{
		GenerateHeightMap(game_grid, GRID_SIZE, move_speed_max);
	}
	
	// toggle groups, check for num_key inputs
	for(var i=1; i<=4; i++)
	{
		// check normal number keys (on keyboard or numpad respectively)
		if(keyboard_check_pressed(48+i) || keyboard_check_pressed(96+i))
		{
			var _group = groups[i-1];
			if(_group.active)
			{
				if(group_focused == i-1)
				{
					// deactivate group
					_group.active = !_group.active;
				} else {
					// change focus
					group_focused = i-1;
				}
			} else {
				// activate and set focus
				_group.active = !_group.active;
				group_focused = i-1;
			}
		}
	}
	// control start / end points for active group
	if(keyboard_check(vk_shift))
	{
		//if(mouse_check_button(mb_left)) and (point_in_rectangle(mouse_x,mouse_y, global.iCamera.x-global.iCamera.viewWidthHalf, global.iCamera.y-global.iCamera.viewHeightHalf, global.iCamera.x+global.iCamera.viewWidthHalf, global.iCamera.y+global.iCamera.viewHeightHalf)){
		if(mouse_check_button(mb_left)) and (point_in_rectangle(mouse_x,mouse_y, global.goalBound[0],global.goalBound[1],global.goalBound[2],global.goalBound[3])){
			// set start point
			var _group = groups[group_focused];
			_group.start_nodes = array_create(1, game_grid[# mouse_x div GRID_SIZE, mouse_y div GRID_SIZE]);
		} else if(mouse_check_button(mb_right)) and (point_in_rectangle(mouse_x,mouse_y, global.goalBound[0],global.goalBound[1],global.goalBound[2],global.goalBound[3])){//(point_in_rectangle(mouse_x,mouse_y,global.iCamera.x-global.iCamera.viewWidthHalf,global.iCamera.y-global.iCamera.viewHeightHalf,global.iCamera.x+global.iCamera.viewWidthHalf,global.iCamera.y+global.iCamera.viewHeightHalf)){
			// set end point
			var _group = groups[group_focused];
			_group.goal_nodes = array_create(1, game_grid[# mouse_x div GRID_SIZE, mouse_y div GRID_SIZE]);
		}
	}
	
	// add / remove people from group
	if(mouse_wheel_up()) || (keyboard_check_pressed(ord("E"))){
		var _group = groups[group_focused];
		var _node = undefined;
		if(_group.active)
		{
			_group.AddPop(1, 1.2);
		}
	}
	if(mouse_wheel_down()) || (keyboard_check_pressed(ord("Q"))){
		var _group = groups[group_focused];
		if(_group.active) && (_group.size > 0)
		{
			_group.size--;
			var _inst = _group.people[| 0];
			ds_list_delete(_group.people, 0);
			if(instance_exists(_inst)) instance_destroy(_inst);
		}
	}
	
}