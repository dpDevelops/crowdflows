/// @description 

if(keyboard_check_pressed(vk_escape))
{
	global.gamePaused = !global.gamePaused;
}

if(!global.gamePaused)
{
	UserInteract();
	
	// 1) each person is trying to reach a geographic goal (wandering/browsing is not suitable for simulation)
    // 2) people move at maximum possible speed (using a global speed field, based on position and direction of movement)
    // 3) there exists a discomfort field which describes preferable terrain for people
    // 4) people choose a path with minimum-cumulative cost relative to distance, time, and discomfort (this is a linear relationship)

    if(--step_timer < 0) step_timer = step_delay;
    if(step_timer == 0)
    {
//--// DENSITY CONVERSION
        // set up instance variables that are used repetatively
        var _node = undefined;
        var i=0, j=0, k=0, n=0, CDIR=0;
        // clear existing density
        for(i=0;i<ds_grid_width(game_grid);i++){
        for(j=0;j<ds_grid_height(game_grid);j++){
            _node = game_grid[# i, j];
            _node.discomfort = _node.is_edge ? 1000 : 0;
            _node.density = 0;
        }}
        // 'splat' the density values
        var _arr = array_create(9,0);
        var _density_contribution = 0;
        var half_grid = GRID_SIZE div 2;
        with(oPerson)
        {
            // find closest cell center whose coordinates are both less than that of the person (cell is refered to as 'A')
            var Ax = x div (half_grid); 
                if(Ax % 2 == 0) Ax -= 1;
                Ax *= half_grid;
            var Ay = y div (half_grid); 
                if(Ay % 2 == 0) Ay -= 1;
                Ay *= half_grid;
            var Axcell = Ax div GRID_SIZE;
            var Aycell = Ay div GRID_SIZE;

            // compute offset coordinates from this grid cell
            var dx = x - Ax;
            var dy = y - Ay;
            
            // (A) density base_location
            _node = other.game_grid[# Axcell, Aycell];
            if(is_undefined(_node)){instance_destroy(); continue}
            _density_contribution = 0.2*(100+min(1-dx, 1-dy)^other.density_falloff);
            _node.density += _density_contribution;
            ds_list_add(_node.density_velocity_list, vect_multr(velocity, _density_contribution));

            // (B) density right of A
            _node = other.game_grid[# Axcell+1, Aycell];
            if(is_undefined(_node)){instance_destroy(); continue}
            _density_contribution = -0.2*min(1-dx, dy)^other.density_falloff;
            _node.density += _density_contribution;
            ds_list_add(_node.density_velocity_list, vect_multr(velocity, _density_contribution));

            // (C) density below A
            _node = other.game_grid[# Axcell, Aycell+1];
            if(is_undefined(_node)){instance_destroy(); continue}
            _density_contribution = -0.2*min(dx, 1-dy)^other.density_falloff;
            _node.density += _density_contribution;
            ds_list_add(_node.density_velocity_list, vect_multr(velocity, _density_contribution));

            // (D) density down and right of A
            _node = other.game_grid[# Axcell+1, Aycell+1];
            if(is_undefined(_node)){instance_destroy(); continue}
            _density_contribution = 0.2*min(dx, dy)^other.density_falloff;
            _node.density += _density_contribution;
            ds_list_add(_node.density_velocity_list, vect_multr(velocity, _density_contribution));
        }
        // calculate average velocity (using the summed values of the _dsgrid)
        for(i=0;i<ds_grid_width(game_grid);i++){
        for(j=0;j<ds_grid_height(game_grid);j++){
            _node = game_grid[# i, j];
            var _list = _node.density_velocity_list;
            var _size = ds_list_size(_list);
            var _sum = vect2(0,0);
            if(_size > 0)
            {
                // sum the velocity*density values collected previously in each grid cell
                while(_size > 0)
                {
                    _sum = vect_add(_sum, _list[| 0]);
                    ds_list_delete(_list,0);
                    _size--;
                }
	            // insert average velocity into the game grid
	            _node.average_velocity = vect_divr(_sum, _node.density);
            } else {
				_node.average_velocity = vect2(0,0);
			}

        }}
        
//--// UNIT COST FUNCTIONS
        for(i=0;i<ds_grid_width(game_grid);i++){
        for(j=0;j<ds_grid_height(game_grid);j++){
            // for each node in the game grid, calculate speed and cost in the four cardinal directions 
            _node = game_grid[# i, j];
            for(CDIR=0;CDIR<4;CDIR++){
                var cdir_vect = speed_dir_to_vect2(1,CDIR*90);
                if(!point_in_rectangle(i+cdir_vect[1], j+cdir_vect[2],0,0,ds_grid_width(game_grid)-1,ds_grid_height(game_grid)-1)) continue;
                var _neighbor = game_grid[# i+cdir_vect[1], j+cdir_vect[2]];
                // 1) compute the speed field using equation (10)
                var flow_speed = vect_len(vect_proj(vect_norm(_neighbor.average_velocity), cdir_vect));
                var topo_speed = _node.topo_speed_field_mod[CDIR];
                var _speed = max(0, topo_speed + ((_neighbor.density-density_min) / (density_max-density_min))*(flow_speed-topo_speed));
                 
                _node.speed_field[CDIR] = _speed;
				
        /*
            !!!!!!!!!!
                    i'm doing the cost calculation in the same loop as the speed field calculation.
                    this means that the movement cost will lag behind the speed updates by one step.
            !!!!!!!!!!
        */

                // 2) compute the cost field using equation (4) 
                _node.cost[CDIR] = GRID_SIZE*(weight_distance*_neighbor.speed_field[CDIR] + weight_time + weight_discomfort*_neighbor.discomfort) / _neighbor.speed_field[CDIR]
            }
        }}
//--// DYNAMIC POTENTIAL FIELD CONSTRUCTION
		// for each group, calculate potential for goal
        for(n=0;n<array_length(groups);n++){
            var _gp = groups[n];
            if(_gp.active)
            {
				
                // get potentials
                CF_Calc_Potential(game_grid, game_grid_heap, _gp.goal_nodes, _gp);
				
				_gp.Normalize_Potential();
				
                // set velocity field
                for(i=1;i<ds_grid_width(game_grid)-1;i++){
                for(j=1;j<ds_grid_height(game_grid)-1;j++){
                    _node = game_grid[# i, j];
                    for(CDIR=0;CDIR<4;CDIR++){
						if(!point_in_rectangle(i+cdir_vect[1], j+cdir_vect[2],0,0,ds_grid_width(game_grid)-1,ds_grid_height(game_grid)-1)) continue;
                        _node.velocity[CDIR] = speed_dir_to_vect2(_node.potential_grad[CDIR]*_node.speed_field[CDIR],CDIR*90);
						//_node.velocity[CDIR] = speed_dir_to_vect2(_node.speed_field[CDIR],CDIR*90);
                    }
                }}
                _gp.Move();
            }
        }
    }
//--// MINIMUM DISTANCE ENFORCEMENT
    if(--distance_enforcement_timer < 0) distance_enforcement_timer = distance_enforcement_delay;
    if(distance_enforcement_timer == 0)
    {
        show_debug_message("min distance enforcement");
        /* 
            CREATE A SPRITE WITH CIRCULAR COLLISION MASK AND USE THIS FOR MINIMUM DISTANCE ENFORCEMENT
        */
        var _list = ds_list_create();
        var _dist = 0;
        var _vect = vect2(0,0);
        var _size = 0;
        var p1 = noone;
        var p2 = noone;
        
        with(oPerson)
        {        
            p1 = id;
            _size = instance_place_list(x, y, oPerson, _list, true);  
            if(_size > 0)
            {
                for(var i=0; i<_size; i++){
                    p2 = _list[| i];
                    _vect[1] = p2.x - p1.x;
                    _vect[2] = p2.y - p1.y;
                    _dist = ceil(0.5*(other.min_distance - point_distance(p1.x, p1.y, p2.x, p2.y)));
                    _vect = vect_truncate(_vect, _dist);

                    p1.position = vect_subtract(p1.position, _vect);
                    p2.position = vect_add(p2.position, _vect);
                }
            }
        }
        ds_list_destroy(_list);
    }
}

with(oPerson)
{
	x = clamp(mouse_x,GRID_SIZE,GRID_SIZE*(GRID_WIDTH+1)-1);
	y = clamp(mouse_y,GRID_SIZE,GRID_SIZE*(GRID_HEIGHT+1)-1);
	position[1] = x;
	position[2] = y;
	velocity[1] = 0;
	velocity[2] = 0;
	exit;
}
