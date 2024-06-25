/// @description 

draw_set_font(fNode);
draw_set_color(c_black);
draw_set_halign(fa_middle);
draw_set_valign(fa_center);

var _show_data = 1;
var _show_cost = 0;
var _show_potential = 0;
var _show_potential_grad = 0;
var _show_velocity = 0;

if(_show_data) {
	var _node = undefined;
	// show some node data
	for(var i=1; i<=GRID_WIDTH; i++){
	for(var j=1; j<=GRID_HEIGHT; j++){
		_node = game_grid[# i, j];
		draw_text(_node.x,_node.y,"ht: " + string(_node.height) 
							      //+ "\nvel: " + string(_node.average_velocity)
							      + "\ndens: " + string(_node.density)
								  + "\nG: " + string(_node.discomfort)
				 );
	}}
	// show cost of current node
	var _xx = mouse_x div GRID_SIZE;
	var _yy = mouse_y div GRID_SIZE
	if(point_in_rectangle(mouse_x,mouse_y,0,0,GRID_SIZE*ds_grid_width(game_grid)-1,GRID_SIZE*ds_grid_height(game_grid)-1))
	{
		_node = game_grid[# mouse_x div GRID_SIZE, mouse_y div GRID_SIZE];
		show_debug_message(_node)
		var _str = "Cost at Node [ "+string(mouse_x div GRID_SIZE)+" , "+string(mouse_y div GRID_HEIGHT)+" ]\n";
		for(var i=0;i<4;i++)
		{
			_str += string(i) + " | cost=" + string(_node.cost[i]) +"\n"
		}
		 
		draw_text(mouse_x+50,mouse_y+50,_str);
	}
} else if(_show_cost) {

	// show node costs
	for(var i=1; i<=GRID_WIDTH; i++){
	for(var j=1; j<=GRID_HEIGHT; j++){
		var _node = game_grid[# i, j];
		draw_text(_node.x,_node.y, "["+string(_node.cost[NORTH]) + "]\n[" + string(_node.cost[WEST]) + "]   [" +string(_node.cost[EAST]) + "]\n[" +string(_node.cost[SOUTH])+"]");
	}}

} else if(_show_potential) {

	// show node potential
	for(var i=0; i<=GRID_WIDTH+1; i++){
	for(var j=0; j<=GRID_HEIGHT+1; j++){
		var _node = game_grid[# i, j];
		//draw_text(_node.x, _node.y, "[ " + string(_node.potential) + " ]");
		
		var _str = _node.potential == INF ? "INF" : string(_node.potential);
		draw_text(_node.x,_node.y, _str);
	}}
	
} else if(_show_potential_grad) {

	// show node potential gradients
	for(var i=1; i<=GRID_WIDTH; i++){
	for(var j=1; j<=GRID_HEIGHT; j++){
		var _node = game_grid[# i, j];
		var _n = _node.potential_grad[NORTH] == infinity ? "INF" : string(_node.potential_grad[NORTH]);
		var _w = _node.potential_grad[WEST] == INF ? "INF" : string(_node.potential_grad[WEST]);
		var _e = _node.potential_grad[EAST] == INF ? "INF" : string(_node.potential_grad[EAST]);
		var _s = _node.potential_grad[SOUTH] == INF ? "INF" : string(_node.potential_grad[SOUTH]);
		//draw_text(_node.x,_node.y, "["+string(_node.potential_grad[NORTH]) + "]\n[" + string(_node.potential_grad[WEST]) + "]   [" +string(_node.potential_grad[EAST]) + "]\n[" +string(_node.potential_grad[SOUTH])+"]");
		draw_text(_node.x,_node.y, "["+ _n + "]\n[" + _w + "]   [" + _e + "]\n[" + _s +"]");
	}}

} else if(_show_velocity){
	// show node velocities
	var _node = undefined;
	var _arr = vect2(0,0);
	var _len = 40;
	var _dir = 0;
	var _xx = 0;
	var _yy = 0;
	for(var i=1; i<=GRID_WIDTH; i++){
	for(var j=1; j<=GRID_HEIGHT; j++){
		_node = game_grid[# i, j];
		if(!array_equals(_node.average_velocity, _arr)){
			_dir = vect_direction(_node.average_velocity);
			_xx = _node.x + lengthdir_x(_len, _dir);
			_yy = _node.y + lengthdir_y(_len, _dir);
			draw_arrow(_node.x,_node.y,_xx, _yy, 20)
		}
	}}
}


for(var i=0;i<array_length(groups);i++)
{
	var _group = groups[i];
	if(_group.active)
	{
		if(group_focused == i)
		{
			draw_set_color(c_black);
			draw_circle(_group.start_nodes[0].x, _group.start_nodes[0].y,10,false);
			draw_circle(_group.goal_nodes[0].x, _group.goal_nodes[0].y,10,false);
		}
		draw_set_color(_group.color1);
		draw_circle(_group.start_nodes[0].x, _group.start_nodes[0].y,6,false);
		draw_set_color(_group.color2);
		draw_circle(_group.goal_nodes[0].x, _group.goal_nodes[0].y,6,false);
	}
}
