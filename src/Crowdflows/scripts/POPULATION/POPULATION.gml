Group = function(_start_nodes, _goal_nodes, _start_color, _goal_color, _group_index, _size=0, _active=false, _grid=undefined) constructor{
		group_index = _group_index;
		pop_count = _size;
		start_nodes = _start_nodes;
		goal_nodes = _goal_nodes;
		color1 = _start_color;
		color2 = _goal_color;
		active = _active;
		grid = _grid;
        people = ds_list_create();
		pot_min = 0;
		pot_max = 0;
		static Normalize_Potential = function(){
			for(var i=1;i<ds_grid_width(grid)-1;i++){
			for(var j=1;j<ds_grid_width(grid)-1;j++){
				var _node = grid[# i,j];
				for(var CDIR=0;CDIR<4;CDIR++)
				{
					if(!is_nan(_node.potential_grad[CDIR]))
					{
						_node.potential_grad[CDIR] = (_node.potential_grad[CDIR]-pot_min)/(pot_max-pot_min);
					}
				}
			}}
		}
		static Move = function(){
			if(pop_count > 0)
			{
				for(var i=0;i<pop_count;i++)
				{
					var _person = people[| i];
					
					if(is_undefined(_person)) continue;
					
					var xx = _person.x div GRID_SIZE;
					var yy = _person.y div GRID_SIZE;
					var _node = grid[# xx, yy];
					var _prop = (_person.image_angle % 90) / 90;
					var _ind1 = _person.image_angle div 90;
					var _ind2 = _ind1 == 3 ? 0 : _ind1 + 1;
					var _vel1 = _node.velocity[_ind1];
					var _vel2 = _node.velocity[_ind2];
					show_debug_message("MOVING PERSON:\nprop = {0}\nind1 = {1}\nind2 = {2}\nvel1 = {3}\nvel2 = {4}",_prop,_ind1,_ind2, _vel1, _vel2);
					_person.velocity[1] = _person.move_speed * lerp(_vel1[1], _vel2[1], _prop);
					_person.velocity[2] = _person.move_speed * lerp(_vel1[2], _vel2[2], _prop);
				}
			}
		}
		static AddPop = function(_count, _move_speed){
			repeat(_count)
			{
				pop_count++;
				// pick at random from group starting nodes
				var _node = start_nodes[irandom(array_length(start_nodes)-1)];
				// create struct for person
				var _dir = point_direction(_node.x, _node.y, goal_nodes[0].x, goal_nodes[0].y);
				var _struct = {
					move_speed : _move_speed,
			        goal_x : 0,
			        goal_y : 0,
			        group : oSimulation.groups[group_index],
					position : vect2(_node.x + random(GRID_SIZE)-0.5*GRID_SIZE, _node.y + random(GRID_SIZE)-0.5*GRID_SIZE),
					velocity : vect2(lengthdir_x(1, _dir), lengthdir_y(1, _dir))
				}
				ds_list_add(people, instance_create_layer(_struct.position[1], _struct.position[2], "Instances", oPerson, _struct));
			}
		}
}
