/// @description this object runs the simulation

MACROS()
NODE()
POPULATION()
PotentialFunctions()

randomize();
game_set_speed(FRAME_RATE, gamespeed_fps);

InitializeDisplay(ASPECT_RATIO);

global.gamePaused = false;
global.seed = 0;
global.iCamera = instance_create_layer(0,0,"Instances",oCamera);
global.iSim = id;
global.goalBound = [0,0,0,0];

// create the game space
min_distance = 15;
distance_enforcement_delay = FRAME_RATE div 2;
distance_enforcement_timer = 2;
step_delay = FRAME_RATE div 4;
step_timer = 1;
move_speed_min = 0;
move_speed_max = 5;
game_grid = ds_grid_create(GRID_WIDTH+2, GRID_HEIGHT+2);
game_grid_heap = new CF_Heap();
game_grid_heap.Initialize(game_grid);
bgtiles = layer_tilemap_create(layer_create(100), 0, 0, tsTiles, ds_grid_width(game_grid), ds_grid_height(game_grid));

for(var i=0;i<ds_grid_width(game_grid);i++){
for(var j=0;j<ds_grid_height(game_grid);j++){
	// populate the grid
	if(i==0) or (i==ds_grid_width(game_grid)-1) or (j==0) or (j==ds_grid_height(game_grid)-1){
		game_grid[# i, j] = new Node(i, j, true);
		tilemap_set(bgtiles, 2, i, j);
	} else {
		game_grid[# i, j] = new Node(i, j, false);
		tilemap_set(bgtiles, 1, i, j);
	}
}}

//--// new seed
global.seed = round(random_range(1000000,10000000));
// height map data
GeneratePerlinHeightMap(game_grid, GRID_SIZE, 20);



// group control
// get start and end positions for the four predetermined groups
var separation = GRID_SIZE*4;
var xcenter = (ds_grid_width(game_grid) div 2) * GRID_SIZE;
var ycenter = (ds_grid_height(game_grid) div 2) * GRID_SIZE;
var positions = [[0,0],[0,0],[0,0],[0,0]];
var colors = array_create(0);
var dir = 0;
var inc = 360 div 8;
for(var i=0; i<4; i++)
{
	dir = i * inc;
	positions[i][0] = vect2(xcenter + lengthdir_x(separation,dir), ycenter + lengthdir_y(separation,dir))
	positions[i][1] = vect2(xcenter + lengthdir_x(separation,dir+180), ycenter + lengthdir_y(separation,dir+180))
}
array_push(colors, [make_color_rgb(163,206,39),  make_color_rgb(68,137,26) ]);
array_push(colors, [make_color_rgb(224,11,139),  make_color_rgb(190,38,51) ]);
array_push(colors, [make_color_rgb(235,137,49),  make_color_rgb(164,100,34)]);
array_push(colors, [make_color_rgb(178,220,239), make_color_rgb(49,162,242)]);

// create the groups
group_focused = 0;
groups = [];
for(var i=0; i<4; i++)
{
	var _start = positions[i][0];
	var _end =   positions[i][1];
	var _c1 =    colors[i][0];
	var _c2 =    colors[i][1];
	var _start_nodes = array_create(1, game_grid[# _start[1] div GRID_SIZE, _start[2] div GRID_SIZE]);
	var _goal_nodes = array_create(1, game_grid[# _end[1] div GRID_SIZE, _end[2] div GRID_SIZE]);
	array_push(groups, new Group(_start_nodes, _goal_nodes, _c1, _c2, i, 0, false, game_grid));
}

global.iCamera.x = xcenter;
global.iCamera.y = ycenter;
global.iCamera.xTo = global.iCamera.x;
global.iCamera.yTo = global.iCamera.y;
global.goalBound = [GRID_SIZE,GRID_SIZE,ds_grid_width(game_grid)*GRID_SIZE-1,ds_grid_height(game_grid)*GRID_SIZE-1];

// IMPLEMENTATION
density_falloff = 0.9;
density_min = 300;
density_max = 500;
weight_distance = 0.7;
weight_time = 0.2;
weight_discomfort = 1;
path_queue = ds_queue_create();



// Set the collision mask to be used for min distance enforcement
var _xcenter = sprite_get_width(sMinDistance) div 2;
var _ycenter = sprite_get_height(sMinDistance) div 2;
sprite_set_offset(
	sMinDistance,
	_xcenter,
	_ycenter
);
sprite_collision_mask(
	sMinDistance,
	false,
	2,
	xcenter-min_distance,
	ycenter-min_distance,
	xcenter+min_distance,
	ycenter+min_distance,
	bboxkind_ellipse,
	0
);
object_set_mask(
	oPerson,
	sMinDistance
);