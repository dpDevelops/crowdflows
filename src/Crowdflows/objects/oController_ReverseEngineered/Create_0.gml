/// @description Initialize the game

/*

Heap();
function randomSeed(){
	var _range = argument[0] == undefined ? 0 : argument[0];
	var _num = 0;
	switch(argument_count)
	{
	    case 2:
	        _num = argument[1];
	        break;
	    case 3:
	        _num = argument[1] + argument[2] * 65536;
	        break;
	}

	var _seed = global.seed + _num;

	random_set_seed(_seed);
	var _rand = irandom_range(0,_range);

	return round(_rand);
}
function getPerlinNoise_2D(xx, yy, range)
{

	var chunkSize = 16;

	var noise = 0;

	range = range div 2;

	while(chunkSize > 0){
	    var index_x = xx div chunkSize;
	    var index_y = yy div chunkSize;
    
	    var t_x = (xx % chunkSize) / chunkSize;
	    var t_y = (yy % chunkSize) / chunkSize;
    
	    var r_00 = randomSeed(range,index_x,   index_y);
	    var r_01 = randomSeed(range,index_x,   index_y+1);
	    var r_10 = randomSeed(range,index_x+1, index_y);
	    var r_11 = randomSeed(range,index_x+1, index_y+1);
    
	    var r_0 = lerp(r_00,r_01,t_y);
	    var r_1 = lerp(r_10,r_11,t_y);
    
	    noise += lerp(r_0,r_1,t_x);
    
	    chunkSize = chunkSize div 2;
	    range = range div 2;
	    range = max(1,range);
	}

	return round(noise);
}



function InitializeDisplay(){
	//// dynamic resolution
		//ideal_width_ = 0;
		//ideal_height_ = RESOLUTION_H;
		//aspect_ratio_ = display_get_width() / display_get_height();
		//ideal_width_ = round(ideal_height_*aspect_ratio_);
	// static resolution
	ideal_width_ = CELL_SIZE*GRID_WIDTH;
	ideal_height_ = CELL_SIZE*GRID_HEIGHT;
	aspect_ratio_ = ideal_width_ / ideal_height_;

	//// perfect pixel scaling
		//if(display_get_width() mod ideal_width_ != 0)
		//{
		//	var d = round(display_get_width() / ideal_width_);
		//	ideal_width_ = display_get_width() / d;
		//}
		//if(display_get_height() mod ideal_height_ != 0)
		//{
		//	var d = round(display_get_height() / ideal_height_);
		//	ideal_height_ = display_get_height() / d;
		//}

	//check for odd numbers
	if(ideal_width_ & 1) ideal_width_++;
	if(ideal_height_ & 1) ideal_height_++;

	//do the zoom
	zoom = 1;
	zoom_max_ = floor(display_get_width() / ideal_width_);
	zoom = min(zoom, zoom_max_)
	
	// enable & set views of each room
	room_set_view_enabled(rEnvironment, true);
	room_set_viewport(rEnvironment,0,true,0,0,ideal_width_, ideal_height_);
	room_set_width(rEnvironment, ideal_width_);
	room_set_height(rEnvironment, ideal_height_);
	//window_set_size(ideal_width_,ideal_height_);
	//display_set_gui_size(ideal_width_,ideal_height_);
}
function GenerateHeightMap(_dsgrid){
	//--// new seed
	global.seed = round(random_range(1000000,10000000));
	//--// Generate Static Height Map
	var i=0,j=0
	for(var i = 0; i < GRID_WIDTH; i++){
		for(var j = 0; j < GRID_HEIGHT; j++){
		    var zz = getPerlinNoise_2D(i,j,100);
		    global.gridSpace[# i,j].height = zz;
		}
	}
	// calculate height gradients & speed fields
	for(var i = 0; i < GRID_WIDTH; i++){
		for(var j = 0; j < GRID_HEIGHT; j++){
		    var _node = global.gridSpace[# i,j];
			for(var theta=0;theta<360;theta+=90)
			{
				var _direction = theta div 90;
				var ii = i+dcos(theta);
				var jj = j-dsin(theta);
				var _valid = (ii >= 0)*(ii < GRID_WIDTH)*(jj >= 0)*(jj < GRID_HEIGHT)
				if(_valid)
				{
					var _neighbor = global.gridSpace[# ii, jj];
					// height gradient
					_node.heightGradient[_direction] = lerp(_node.height,_neighbor.height,0.5);
					// speed gradient
					_node.topographSpeed[_direction] = speedMax + ((_node.heightGradient[_direction]-_node.height)/(0.5*CELL_SIZE))*-speedMax
					//// debug
					//show_message("node height: " + string(_node.height) 
					//		   + "\nneighbor height ("+string(_direction)+"): "+string(_neighbor.height)
					//		   + "\nlerp: " + string(lerp(_node.height,_neighbor.height,0.5))
					//		   + "\nspeed: " + string(speedMax + ((_node.heightGradient[_direction]-_node.height)/(0.5*CELL_SIZE))*-speedMax)
					//);
				} else {
					// set height gradient to max
					_node.heightGradient[theta div 90] = 10000;
					// set max speed to 0
					_node.topographSpeed[_direction] = 0;
				}
			}
		}
	}
	// celculate the max speed
}

randomize();
MACROS();
game_set_speed(FRAME_RATE, gamespeed_fps);
InitializeDisplay();

//--// managers
global.gamePaused = false;
global.controller = id;
global.seed = round(random_range(1000000,10000000));
global.gridSpace = ds_grid_create(GRID_WIDTH,GRID_HEIGHT);
global.crowdList = ds_list_create();

//--// General variables
lambda = -8;
global.rhoLimit = 50;
rhoRadius = 3*CELL_SIZE;
rhoBar = 10;
rhoMax = 20;
rhoMin = 0;


posOffset = 2*CELL_SIZE;
speedMax = 1;
pathHeap = new NodeHeap();
pathQueue = ds_queue_create();

{// Grid Discretization
	function GridNode(_xCell=0,_yCell=0) constructor
	{
	//--// scalar fields
	    walkable = true; // whether the cell is part of the playspace
	    blocked = false; // whether the cell has something built on it
		discomfort = 0; // g = discomfort
		potential = 0; // phi = potential
		density = 0; // rho = density
		height = 0; // h = height
		velocityAvg = vect2(0,0); // v = average velocity
		cell = vect2(_xCell,_yCell);
		position = vect2(_xCell*CELL_SIZE+0.5*CELL_SIZE, _yCell*CELL_SIZE+0.5*CELL_SIZE);
		population = 0;
		movePenalty = 0;
	    gCost = 0;
	    hCost = 0;
		parent = undefined;
		HeapIndex = 0;
	    static fCost = function(){
	        return gCost + hCost;
	    }	
		static CompareTo = function(_otherNode){
			// return 1 if current node has higher priority (lower fCost/hCost)
			// return -1 if current node has lower priority
			var _compare = 0;
			if(gCost != _otherNode.gCost)
			{
				// pick priority
				_compare = gCost < _otherNode.gCost ? 1 : -1;
			}else{
				// tie breaker
				_compare = hCost < _otherNode.hCost ? 1 : -1;
			}
			return _compare;
		}
	//--// anisotropic fields, stored as arrays corresponding to direction { 0, 90, 180, 270 }
		cost = [0,0,0,0]; // Cme = Cost from cell to neighbor
		topographSpeed = [0,0,0,0];
		speedField = [0,0,0,0]; // fme = Speed field from cell to neighbor
		heightGradient = [0,0,0,0]; // hme = Height gradient from cell to neighbor
		potentialGradient = [0,0,0,0]; // phiG = Gradient of the potential
		velocity = [0,0,0,0]; // nu = velocity
	}
	for(var i=0;i<GRID_WIDTH;i++)
	{
	for(var j=0;j<GRID_HEIGHT;j++)
	{
		var _node = new GridNode(i, j);
		global.gridSpace[# i, j] = _node;
	}
	}
	GenerateHeightMap();
}

{// Crowd Setup
	repeat(20)
	{
		var _x = 1*CELL_SIZE + 0.5*CELL_SIZE;
		var _y = irandom(GRID_HEIGHT-1)*CELL_SIZE + 0.5* CELL_SIZE;
		with(instance_create_layer(_x,_y,"Instances",oPerson))
		{
			xSpawn = _x;
			ySpawn = _y;
			colorFaction = c_aqua;
			goal = vect2(GRID_WIDTH*CELL_SIZE-2.5*CELL_SIZE, (round(0.5*GRID_HEIGHT)*CELL_SIZE)+0.5*CELL_SIZE);
		}
	}
	repeat(20)
	{
		var _x = (GRID_WIDTH*CELL_SIZE) - 1.5*CELL_SIZE;
		var _y = irandom(GRID_HEIGHT-1)*CELL_SIZE + 0.5* CELL_SIZE;
		with(instance_create_layer(_x,_y,"Instances",oPerson))
		{
			xSpawn = _x;
			ySpawn = _y;
			colorFaction = c_lime;
			goal = vect2(2.5*CELL_SIZE, (round(0.5*GRID_HEIGHT)*CELL_SIZE)+0.5*CELL_SIZE);
		}
	}
}

{ //--// Grid View Setup

	//--// Camera Setup
	x = 0.5*GRID_WIDTH*CELL_SIZE;
	y = 0.5*GRID_WIDTH*CELL_SIZE;
	cam = view_camera[0];
	follow = noone;
	viewWidthHalf = 0.5*camera_get_view_width(cam);
	viewHeightHalf = 0.5*camera_get_view_height(cam);

	spd = 10;
	spdMult = 2;

	xTo = x;
	yTo = y;

	shakeLength = 0;
	shakeMagnitude = 0;
	shakeRemain = 0;
}