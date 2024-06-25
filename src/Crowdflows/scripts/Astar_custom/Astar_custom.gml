function FindPath_Astar(_start=[2,0,0], _end=[2,0,0]){
    //convert world position into node positions 
    var _startNode = global.gridSpace[# _start[1] div CELL_SIZE, _start[2] div CELL_SIZE];
    var _endNode = global.gridSpace[# _end[1] div CELL_SIZE, _end[2] div CELL_SIZE];

    var openSet = global.controller.pathHeap; openSet.Initialize();
    var closedSet = ds_list_create();

    // add starting node to OPEN before looping
	_startNode.gCost = 0;
	_startNode.hCost = 0;
	openSet.Add(_startNode);

    // loop through currently open nodes
    while(openSet.Count() > 0)
    {
		var _currentNode = openSet.RemoveFirst();	
        // set currentNode as next in path
        ds_list_add(closedSet, _currentNode);

        if(_currentNode != _endNode)
        {
            // get neighboring cells for evaluation
            for(var xx=-1; xx<=1; xx++)
            {
            for(var yy=-1; yy<=1; yy++)
            {
                if(_currentNode.cell[1]+xx > -1) && (_currentNode.cell[1]+xx < GRID_WIDTH) && (_currentNode.cell[2]+yy > -1) && (_currentNode.cell[2]+yy < GRID_HEIGHT)
				{
					var _neighbor = global.gridSpace[# _currentNode.cell[1]+xx, _currentNode.cell[2]+yy];
	                if(!is_undefined(_neighbor)) && (_neighbor != _currentNode) && (_neighbor.walkable) && (ds_list_find_index(closedSet,_neighbor) == -1) && (!openSet.Contains(_neighbor)) 
	                {
	                    var _costToNeighbor = _currentNode.gCost + point_distance(_currentNode.position[1],_currentNode.position[2],_neighbor.position[1],_neighbor.position[2]) + _neighbor.movePenalty;
						if(_costToNeighbor < _neighbor.gCost) || (!openSet.Contains(_neighbor))
						{
		                    _neighbor.gCost = _costToNeighbor
		                    _neighbor.hCost = point_distance(_endNode.position[1],_endNode.position[2],_neighbor.position[1],_neighbor.position[2]);
		                    _neighbor.parent = _currentNode;
							
		                    // add/update neighbor
							openSet.Add(_neighbor);
						}
	                }
				}
            }
            }
        }
    }

    // retrace path
    var _path = ds_list_create();
    var _node = _endNode;
    while(_node != _startNode) 
    {
        ds_list_insert(_path, 0, _node); 
        _node = _node.parent;
    }
    return _path;
}
