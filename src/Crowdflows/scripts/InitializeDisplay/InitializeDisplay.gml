function InitializeDisplay(_asp){
	//// dynamic resolution
		//idealWidth = 0;
		//idealHeight = RESOLUTION_H;
		//aspect_ratio_ = display_get_width() / display_get_height();
		//idealWidth = round(idealHeight*aspect_ratio_);
	// static resolution
	aspect_ratio_ = _asp;
	idealWidth = 1080;
	idealHeight = round(idealWidth / _asp);
	

	// perfect pixel scaling
		if(display_get_width() mod idealWidth != 0)
		{
			var d = round(display_get_width() / idealWidth);
			idealWidth = display_get_width() / d;
		}
		if(display_get_height() mod idealHeight != 0)
		{
			var d = round(display_get_height() / idealHeight);
			idealHeight = display_get_height() / d;
		}

	//check for odd numbers
	if(idealWidth & 1) idealWidth++;
	if(idealHeight & 1) idealHeight++;

	//do the zoom
	zoom = 1.5;
	zoomMax = floor(display_get_width() / idealWidth);
	zoom = min(zoom, zoomMax);
	
	// enable & set views of each room
	for(var i=0; i<=100; i++)
	{
		if(!room_exists(i)) break;
		show_debug_message(room_get_name(i)+" has been initialized")
		if(i == 30){show_message("update display initialize, there are too many rooms")}
		room_set_view_enabled(i, true);
		room_set_viewport(i,0,true,0,0,idealWidth, idealHeight);
	}	
	//surface_resize(application_surface, RESOLUTION_W, RESOLUTION_H);
	//display_set_gui_size(RESOLUTION_W, RESOLUTION_H);
	//window_set_size(RESOLUTION_W*zoom, RESOLUTION_H*zoom);
	surface_resize(application_surface, idealWidth, idealHeight);
	display_set_gui_size(idealWidth, idealHeight);
	window_set_size(idealWidth*zoom, idealHeight*zoom);
	alarm[0] = 1;
}