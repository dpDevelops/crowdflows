/// @description Initialize the game
/*

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
function GenerateHeightMap(){
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
				var ii = i+dcos(theta);
				var jj = j-dsin(theta);
				var _neighbor = global.gridSpace[# ii, jj];
				var _direction = theta div 90;
				if(is_undefined(_neighbor))
				{
					// set height gradient to max
					_node.heightGradient[theta div 90] = 10000;
					// set max speed to 0
					_node.topographSpeed[_direction] = 0;
				} else {
					// height gradient
					_node.heightGradient[_direction] = lerp(_node.height,_neighbor.height,0.5*CELL_SIZE);
					// speed gradient
					_node.topographSpeed[_direction] = speedMax + ((_node.heightGradient[_direction]-_node.height)/(0.5*CELL_SIZE))*-speedMax
				}
			}
		}
	}
	// celculate the max speed
}
function FastMarchingPath(){
	var _path = ds_list_create();
	
	return _path	
}


randomize();
MACROS();
game_set_speed(FRAME_RATE, gamespeed_fps);
InitializeDisplay();

//--// managers
global.gamePaused = false;
global.seed = round(random_range(1000000,10000000));
global.controller = id;

//--// General variables
lambda = -4;
rhoMax = 20;
rhoMin = 2;
rhoBar = 0.5^lambda;
rhoRadius = 90;
rhoThreashold = 10;
posOffset = 40;
speedMax = 10;

{// Grid Discretization
	function GridNode(_xCell=0,_yCell=0) constructor
	{
	//--// scalar fields
		discomfort = 0; // g = discomfort
		potential = 0; // phi = potential
		density = 0; // rho = density
		height = 0; // h = height
		velocityAvg = vect2(0,0); // v = average velocity
		cell = vect2(_xCell,_yCell);
		position = vect2(_xCell*CELL_SIZE+0.5*CELL_SIZE, _yCell*CELL_SIZE+0.5*CELL_SIZE);
	
		rhoVel = vect2(0,0); // this variable is needed for calculating average velocity of the grid cell
		
	//--// anisotropic fields, stored as arrays corresponding to direction { 0, 90, 180, 270 }
		cost = [0,0,0,0]; // Cme = Cost from cell to neighbor
		topographSpeed = [0,0,0,0];
		speedField = [0,0,0,0]; // fme = Speed field from cell to neighbor
		heightGradient = [0,0,0,0]; // hme = Height gradient from cell to neighbor
		potentialGradient = [0,0,0,0]; // phiG = Gradient of the potential
		velocity = [0,0,0,0]; // nu = velocity
	}
	global.gridSpace = ds_grid_create(GRID_WIDTH,GRID_HEIGHT);
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
	function Person(_x=0,_y=0,_color=c_white) constructor
	{
		color = _color;
		x = _x;
		y = _y;
		velocity = vect2(0,0);
		goal = vect2(0,0);
		
		GetDirection = function(){
			return vect_direction(velocity);
		}
	}
	global.crowdList = ds_list_create();
	var _group1 = ds_list_create();
	repeat(10)
	{
		var _x = irandom(GRID_WIDTH-1)*CELL_SIZE + 0.5*CELL_SIZE;
		var _y = irandom(GRID_HEIGHT-1)*CELL_SIZE + 0.5* CELL_SIZE;
		var _person = new Person(_x,_y,c_aqua);
		ds_list_add(_group1,_person);
	}
	ds_list_add(global.crowdList, _group1);
	var _group2 = ds_list_create();
	repeat(10)
	{
		var _x = irandom(GRID_WIDTH-1)*CELL_SIZE + 0.5*CELL_SIZE;
		var _y = irandom(GRID_HEIGHT-1)*CELL_SIZE + 0.5* CELL_SIZE;
		var _person = new Person(_x,_y,c_lime);
		ds_list_add(_group2,_person);
	}
	ds_list_add(global.crowdList, _group2);
}
{ //--// Grid View Setup
	enum VIEW
	{
		NONE,
		HEIGHT,
		VELOCITY,
		DISCOMFORT,
		ALL
	}
	gridView = VIEW.ALL;
	gridViewStrings[VIEW.NONE] = "NONE";
	gridViewStrings[VIEW.HEIGHT] = "HEIGHT";
	gridViewStrings[VIEW.VELOCITY] = "VELOCITY";
	gridViewStrings[VIEW.DISCOMFORT] = "DISCOMFORT";
	gridViewStrings[VIEW.ALL] = "ALL";

	//--// Camera Setup
	x = 0.5*room_width;
	y = 0.5*room_height;
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