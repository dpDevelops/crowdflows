Node = function(_x_cell, _y_cell, _edge=false) constructor{
	is_edge = _edge;
	// scalar values (and average velocity)
	x_cell = _x_cell;
	y_cell = _y_cell;
	x = _x_cell * GRID_SIZE + (GRID_SIZE div 2);
	y = _y_cell * GRID_SIZE + (GRID_SIZE div 2);
    height = 0.0;
    density = 0.0;
    potential = 0.0;
    discomfort = 0.0;
    average_velocity = vect2(0, 0);
    density_velocity_list = ds_list_create();  // this is used in the calculation of average velocity
    // anisotropic variables
    cost = [0.0, 0.0, 0.0, 0.0];
    velocity = [vect2(0,0), vect2(0,0), vect2(0,0), vect2(0,0)];
    topo_speed_field_mod = [0.0, 0.0, 0.0, 0.0];
    speed_field = [0.0, 0.0, 0.0, 0.0];
    height_grad = [0.0, 0.0, 0.0, 0.0];
    potential_grad = [0.0, 0.0, 0.0, 0.0];
    // heap variables
    HeapIndex = 0;
	parent = undefined;
    static CompareTo = function(_otherNode)
    {
        // return 1 if current node has higher priority (lower potential)
        // return -1 if current node has lower priority
        var _compare = 0;
        if(potential != _otherNode.potential){ 
            // pick priority
            _compare = potential < _otherNode.potential ? 1 : -1;
        }else{
            // tie breaker
            _compare = discomfort < _otherNode.discomfort ? 1 : -1;
        }
        return _compare;
    }
}