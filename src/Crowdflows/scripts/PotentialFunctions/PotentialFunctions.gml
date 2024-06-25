function CF_Calc_Potential(_grid, _heap, _goal_nodes, _group){
	var _xlimit = ds_grid_width(_grid);
	var _ylimit = ds_grid_height(_grid);
	var i=0,j=0,n=0,_rtn=undefined,_loop=0;
    var candidate_set = _heap; 
	candidate_set.Initialize();
    var known_set = ds_list_create();

	var _neighbors = array_create(4, undefined);
	var _neighbor = undefined;
	var _parent_node = undefined;
	var _current_node = undefined;
	var x_upwind_node = undefined;
	var y_upwind_node = undefined;
	var x_upwind_dir = undefined;
	var y_upwind_dir = undefined;
	var max_potential = 0;

	// reset potential for the game grid nodes
	for(i=0; i<ds_grid_width(_grid); i++){
	for(j=0; j<ds_grid_height(_grid); j++){
		_grid[# i, j].potential = infinity;
	}}
	// set 0 potential for goal/known nodes, only add node if it is not an edge node
	for(i=0;i<array_length(_goal_nodes);i++)
	{
		_current_node = _goal_nodes[i];
		if(_current_node.is_edge) continue;
		_goal_nodes[i].potential = 0;
		ds_list_add(known_set, _goal_nodes[i]);
	}
	
    // process goal nodes, to identify initial candidates
	show_debug_message("\nprocessing goal nodes first");
	for(n=0;n<array_length(_goal_nodes);n++) 
	{
		// initialize goal cells
		_current_node = _goal_nodes[n];
		_current_node.potential = 0;

		// add valid neighbors to the candidate set
		_neighbors[EAST] = _current_node.x_cell+1 >= _xlimit ? undefined : _grid[# _current_node.x_cell+1, _current_node.y_cell]; 
		_neighbors[NORTH] = _current_node.y_cell-1 < 0 ? undefined : _grid[# _current_node.x_cell, _current_node.y_cell-1]; 
		_neighbors[WEST] = _current_node.x_cell-1 < 0 ? undefined : _grid[# _current_node.x_cell-1, _current_node.y_cell];
		_neighbors[SOUTH] = _current_node.y_cell+1 >= _ylimit ? undefined : _grid[# _current_node.x_cell, _current_node.y_cell+1];
		
		_parent_node = _current_node;
		for(var i=0; i<4;i++)
		{
			_neighbor = _neighbors[i];
			// _node, _parent, _group, _grid
			SetNodePotential(_neighbor, _current_node, _group, _grid, known_set, candidate_set, i);
		}
	}
	
    // get current candidate with lowest potential, switch it to the known set, and add its neighbors as candidates
    while(candidate_set.Count() > 0)
    {
		_current_node = candidate_set.RemoveFirst();	
        // set currentNode as next in path
        ds_list_add(known_set, _current_node);
		if(_current_node.is_edge) continue;
		// get neighboring cells for evaluation
		// add valid neighbors to the candidate set
		_neighbors[EAST] = _current_node.x_cell+1 >= _xlimit ? undefined : _grid[# _current_node.x_cell+1, _current_node.y_cell]; 
		_neighbors[NORTH] = _current_node.y_cell-1 < 0 ? undefined : _grid[# _current_node.x_cell, _current_node.y_cell-1]; 
		_neighbors[WEST] = _current_node.x_cell-1 < 0 ? undefined : _grid[# _current_node.x_cell-1, _current_node.y_cell];
		_neighbors[SOUTH] = _current_node.y_cell+1 >= _ylimit ? undefined : _grid[# _current_node.x_cell, _current_node.y_cell+1];
		
		for(var i=0;i<4;i++){
			var _neighbor = _neighbors[i];
			// _node, _parent, _group, _grid
			SetNodePotential(_neighbor, _current_node, _group, _grid, known_set, candidate_set, i);
		}
    }
}

function GetUpwindHorizontal(_node, _grid){
	var _rtn = [undefined, EAST];

	if(_node.x_cell+1 >= ds_grid_width(_grid))
	{
		// check if west neighbor is valid
		if(_node.x_cell-1 >= 0) 
		{	
			// set West as the upwind direction
			_rtn[0] = _grid[# _node.x_cell-1, _node.y_cell];
			_rtn[1] = WEST;
		}
	} else {
		// get the East node before checking to compare
		var _eNode = _grid[# _node.x_cell+1, _node.y_cell]
		_rtn[0] = _eNode;

		if(_node.x_cell-1 < 0)
		{
			// do nothing
		} else {
			// compare, set to node with least cost-potential sum
			var _wNode = _grid[# _node.x_cell-1, _node.y_cell];
			if(_node.cost[EAST]+_eNode.potential > _node.cost[WEST]+_wNode.potential)
			{
				_rtn[0] = _wNode; 
				_rtn[1] = WEST;
			}
		}
	}
	if(_rtn[0].potential == infinity) || (_rtn[0].potential == NaN) _rtn[0] = undefined;
	return _rtn;
}
function GetUpwindVertical(_node, _grid){
	var _rtn = [undefined, SOUTH];

	if(_node.y_cell+1 >= ds_grid_height(_grid))
	{
		// check if north neighbor is valid
		if(_node.y_cell-1 >= 0) 
		{	
			_rtn[0] = _grid[# _node.x_cell, _node.y_cell-1];
			_rtn[1] = NORTH;
		}
	} else {
		// get the South node before checking to compare
		var _sNode = _grid[# _node.x_cell, _node.y_cell+1];
		_rtn[0] = _sNode;

		if(_node.y_cell-1 < 0)
		{
			// do nothing
		} else {
			// compare, set to node with least potential-cost sum
			var _nNode = _grid[# _node.x_cell, _node.y_cell-1];
			if(_node.cost[SOUTH]+_sNode.potential > _node.cost[NORTH]+_nNode.potential)
			{
				_rtn[0] = _nNode; 
				_rtn[1] = NORTH;
			}
		}
	}
	if(_rtn[0].potential == infinity) || (_rtn[0].potential == NaN) _rtn[0] = undefined;
	return _rtn;
}
function SetNodePotential(_node, _parent, _group, _grid, known_set, candidate_set, _dir){
	var x_upwind_node = undefined;
	var y_upwind_node = undefined;
	var x_upwind_dir = undefined;
	var y_upwind_dir = undefined;
	if(!is_undefined(_node)) && (ds_list_find_index(known_set, _node) == -1) && (!candidate_set.Contains(_node))
	{
		var _rtn = GetUpwindHorizontal(_node, _grid);
		x_upwind_node = _rtn[0];
		x_upwind_dir = _rtn[1];
		_rtn = GetUpwindVertical(_node, _grid);
		y_upwind_node = _rtn[0];
		y_upwind_dir = _rtn[1];

		// calculate potential if there is a valid neighbor
		_node.potential = _node.is_edge ? infinity : Equation11(_node, x_upwind_node, y_upwind_node, x_upwind_dir, y_upwind_dir);
		// calculate potential gradient to the node & its parent
		_parent.potential_grad[_dir] = _node.potential - _parent.potential;
		_node.potential_grad[_dir+2 > 3 ? _dir-2 : _dir+2] = -_parent.potential_grad[_dir];

		// store value of smallest and largest potential gradient
		if(_group.pot_max < abs(_parent.potential_grad[_dir])) _group.pot_max = _parent.potential_grad[_dir];
		if(_group.pot_min > -abs(_parent.potential_grad[_dir])) _group.pot_min = _parent.potential_grad[_dir];

		// add to the heap, sorted by lowest potential, as long aas the node is not on the edge of the grid
		if(!_node.is_edge) candidate_set.Add(_node);
	}
}
function Equation11(node, x_upwind_node, y_upwind_node, x_upwind_dir, y_upwind_dir){
	var _case = !is_undefined(x_upwind_node) + 2*!is_undefined(y_upwind_node);
	var _directions = ["east","north","west","south"];
	var _a = 0;
	var _b = 0;
	show_debug_message("case = {0} | node cell = [{1}, {2}] | dirs = [{3}, {4}]", _case, node.x_cell, node.y_cell, _directions[x_upwind_dir], _directions[y_upwind_dir]);
	switch(_case){
		case 0: // no upwind node
			// do nothing
			break;
		case 1: // only given x upwind
			x_upwind_dir = x_upwind_node.x_cell - node.x_cell == -1 ? WEST : EAST;
			/*
			var _Px = x_upwind_node.potential;
			var _Cmx = node.cost[x_upwind_dir];
			var _Cmy = node.cost[y_upwind_dir];
			var _binomial = -sqr(_Px) + sqr(_Cmx) + sqr(_Cmy);
			show_debug_message("px = {0} | cmx = {1} | cmy = {2} | binom = {3} | xcell = [{4}, {5}]", _Px, _Cmx, _Cmy, _binomial, x_upwind_node.x_cell, x_upwind_node.y_cell);
			_a = (-sqrt(_binomial)/(_Cmx*_Cmy) - _Px/sqr(_Cmx)) / (1/sqr(_Cmx) + 1/sqr(_Cmy));
			_b = (sqrt(_binomial)/(_Cmx*_Cmy) - _Px/sqr(_Cmx)) / (1/sqr(_Cmx) + 1/sqr(_Cmy));
			*/
			_a = x_upwind_node.potential - node.cost[x_upwind_dir];
			_b = x_upwind_node.potential + node.cost[x_upwind_dir];
			break;
		case 2: // only given y upwind
			y_upwind_dir = y_upwind_node.y_cell - node.y_cell == -1 ? NORTH : SOUTH;
			/*
			var _Py = y_upwind_node.potential;
			var _Cmx = node.cost[x_upwind_dir];
			var _Cmy = node.cost[y_upwind_dir];
			var _binomial = -sqr(_Py) + sqr(_Cmx) + sqr(_Cmy);
			show_debug_message("py = {0} | cmx = {1} | cmy = {2} | binom = {3} | ycell = [{4}, {5}]", _Py, _Cmx, _Cmy, _binomial, y_upwind_node.x_cell, y_upwind_node.y_cell);
			_a = (-sqrt(_binomial)/(_Cmx*_Cmy) - _Py/sqr(_Cmy)) / (1/sqr(_Cmx) + 1/sqr(_Cmy));
			_b = (sqrt(_binomial)/(_Cmx*_Cmy) - _Py/sqr(_Cmy)) / (1/sqr(_Cmx) + 1/sqr(_Cmy));
			*/
			_a = y_upwind_node.potential - node.cost[y_upwind_dir];
			_b = y_upwind_node.potential + node.cost[y_upwind_dir];
			break;
		case 3: // given both x & y upwind
			x_upwind_dir = x_upwind_node.x_cell - node.x_cell == -1 ? WEST : EAST;
			y_upwind_dir = y_upwind_node.y_cell - node.y_cell == -1 ? NORTH : SOUTH;
			var _Px = x_upwind_node.potential;
			var _Py = y_upwind_node.potential;
			var _Cmx = node.cost[x_upwind_dir];
			var _Cmy = node.cost[y_upwind_dir];
			/*
			var _binomial = -sqr(_Px) + (2*_Px*_Py) - sqr(_Py) + sqr(_Cmx) + sqr(_Cmy);
			show_debug_message("px = {0} | py = {1} | cmx = {2} | cmy = {3} | binom = {4} | xcell = [{5}, {6}] | ycell = [{7}, {8}]", _Px, _Py, _Cmx, _Cmy, _binomial, x_upwind_node.x_cell, x_upwind_node.y_cell, y_upwind_node.x_cell, y_upwind_node.y_cell);
			// first attempt at solution
			_a = (-sqrt(_binomial)/(_Cmx*_Cmy) + _Px/sqr(_Cmx) + _Py/sqr(_Cmy))  /  (1/sqr(_Cmx) + 1/sqr(_Cmy));
			_b = (sqrt(_binomial)/(_Cmx*_Cmy) + _Px/sqr(_Cmx) + _Py/sqr(_Cmy))  /  (1/sqr(_Cmx) + 1/sqr(_Cmy));
			*/
			// second attempt at solution, costs cannot equal zero
			var _binomial = sqr(_Cmy)*sqr(_Cmx)*(-sqr(_Px)+2*_Px*_Py-sqr(_Py)+sqr(_Cmy)+sqr(_Cmx));
			show_debug_message("px = {0} | py = {1} | cmx = {2} | cmy = {3} | binom = {4} | xcell = [{5}, {6}] | ycell = [{7}, {8}]", _Px, _Py, _Cmx, _Cmy, _binomial, x_upwind_node.x_cell, x_upwind_node.y_cell, y_upwind_node.x_cell, y_upwind_node.y_cell);
			_a = (-sqrt(_binomial) + _Px*sqr(_Cmy) + _Py*sqr(_Cmx)) / (sqr(_Cmx)+sqr(_Cmy));
			_b = (sqrt(_binomial) + _Px*sqr(_Cmy) + _Py*sqr(_Cmx)) / (sqr(_Cmx)+sqr(_Cmy));
			break;
	}
	return max(_a, _b);
}

CF_Heap = function() constructor
{
	currentItemCount = 0;
	maxHeapSize = GRID_WIDTH*GRID_HEIGHT;
	items = array_create(maxHeapSize, -1);

	static Initialize = function(_grid=undefined){
        if(!is_undefined(_grid)) && (ds_exists(_grid,ds_type_grid))
        {
            maxHeapSize = ds_grid_width(_grid)*ds_grid_height(_grid);
        }
        items = array_create(maxHeapSize, undefined);
		currentItemCount = 0;
	}
	static Add = function(_item){
		_item.HeapIndex = currentItemCount;
		items[currentItemCount] = _item;
		SortUp(_item);
		currentItemCount++;
	}
	static RemoveFirst = function(){
		var _firstItem = items[0];
		currentItemCount--;
		items[0] = items[currentItemCount];
		items[0].HeapIndex = 0;
		SortDown(items[0]);
		return _firstItem;
	}
	static UpdateItem = function(_item){
		SortUp(_item);
	}
	static Count = function(){
		return currentItemCount;
	}
	static Contains = function(_item){
		var _checkItem = items[_item.HeapIndex];

		return _checkItem == undefined ? false : (_checkItem.x_cell == _item.x_cell) and (_checkItem.y_cell == _item.y_cell);
		
		//return array_equals(items[_item.HeapIndex].cell, _item.cell);
	}
	static SortUp = function(_item){
		var _parentIndex = (_item.HeapIndex-1)/2;
		while(true)
		{
			var _parentItem = items[_parentIndex];
			if(_item.CompareTo(_parentItem) > 0)
			{
				Swap(_item,_parentItem);
			} else {
				break;
			}
			_parentIndex = (_item.HeapIndex-1)/2;
			return _parentIndex;
		}
	}
	static SortDown = function(_item){
		while(true)
		{
			var _childIndexLeft = _item.HeapIndex*2 + 1; 
			var _childIndexRight = _item.HeapIndex*2 + 2;
			var _swapIndex = 0;
			
			if(_childIndexLeft < currentItemCount)
			{
				_swapIndex = _childIndexLeft;
				
				if(_childIndexRight < currentItemCount)
				{
					if(items[_childIndexLeft].CompareTo(items[_childIndexRight]) < 0)
					{
						_swapIndex = _childIndexRight;
					}
				}
				if(_item.CompareTo(items[_swapIndex]) < 0)
				{
					Swap(_item, items[_swapIndex]);
				} else {
					return;
				}
			} else {
				return;
			}
		}
	}
	static Swap = function(itemA,itemB){
		items[itemA.HeapIndex] = itemB;
		items[itemB.HeapIndex] = itemA;
		var _itemAIndex = itemA.HeapIndex;
		itemA.HeapIndex = itemB.HeapIndex;
		itemB.HeapIndex = _itemAIndex;
	}
}
