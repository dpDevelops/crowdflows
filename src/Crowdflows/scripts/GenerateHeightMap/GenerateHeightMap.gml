function GeneratePerlinHeightMap(_dsgrid, _tile_size, _peak_height){
	// _dsgrid is the DS Grid that the function will loop through
	// _grid_size is the width/height of the grid cell measured in pixels
	// _ speed is the amount that units can move on the terrain
	var _sMin = 0;
	var _sMax = 0;
	var _hMin = 0;
	var _hMax = 0;

	//--// Generate Static Height Map
	var i=0,j=0
	for(var i = 0; i < ds_grid_width(_dsgrid); i++){
	for(var j = 0; j < ds_grid_height(_dsgrid); j++){
		_dsgrid[# i,j].height = getPerlinNoise_2D(i,j,_peak_height);
		if(_dsgrid[# i,j].height < _sMin) _sMin = _dsgrid[# i,j].height;
		if(_dsgrid[# i,j].height > _sMax) _sMax = _dsgrid[# i,j].height;
	}}

	// calculate height gradients
	for(var i = 0; i < ds_grid_width(_dsgrid); i++){
	for(var j = 0; j < ds_grid_height(_dsgrid); j++){
		var _node = _dsgrid[# i,j];
		for(var theta=0;theta<360;theta+=90)
		{
			if(!point_in_rectangle(i+dcos(theta), j-dsin(theta),0,0,ds_grid_width(_dsgrid)-1,ds_grid_height(_dsgrid)-1)) continue;
			var _direction = theta div 90;
			var _neighbor = _dsgrid[# i+dcos(theta), j-dsin(theta)];
			
			// height gradient
			var _hgrad = (_neighbor.height-_node.height);
			_node.height_grad[_direction] = _hgrad;
			if(_hgrad < _sMin) _sMin = _hgrad;
			if(_hgrad > _sMax) _sMax = _hgrad;
		}
	}}

	// calculate topographical speed modifiers
	for(var i = 0; i < ds_grid_width(_dsgrid); i++){
	for(var j = 0; j < ds_grid_height(_dsgrid); j++){
		var _node = _dsgrid[# i,j];
		for(var CDIR=0;CDIR<4;CDIR++)
		{
			_node.topo_speed_field_mod[CDIR] = -2*((_node.height_grad[CDIR]+_sMin)/(_sMax-_sMin));
		}
	}}
	with(oSimulation)
	{
		slope_min = _sMin;
		slope_max = _sMax;
		height_min = _hMin;
		height_max = _hMax;
	}
return [_sMin, _sMax, _hMin, _hMax];
}