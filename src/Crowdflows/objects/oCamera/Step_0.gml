/// @description update camera

if(!global.gamePaused)
{
	// update destination
	if(instance_exists(follow))
	{
		xTo = follow.x;
		yTo = follow.y;
	}

	h_pan = keyboard_check(ord("D")) - keyboard_check(ord("A"));
	v_pan = keyboard_check(ord("S")) - keyboard_check(ord("W"));

	if(h_pan != 0) or (v_pan != 0)
	{
		dir = point_direction(0,0,h_pan,v_pan);
		xTo += lengthdir_x(spd, dir);
		yTo += lengthdir_y(spd, dir);
	}

	// update object position
	x += 0.15*(xTo - x);
	y += 0.15*(yTo - y);

	//// keep camera inside the room
	//x = clamp(x, viewWidthHalf, room_width - viewWidthHalf);
	//y = clamp(y, viewHeightHalf, room_height - viewHeightHalf);

	//camera_set_view_size(cam_, _display_manager.ideal_width_*view_zoom_,_display_manager.ideal_height_*view_zoom_);
	camera_set_view_pos(cam, x-viewWidthHalf, y-viewHeightHalf);
}
