function PathRequest(_units, _startPoint, _endPoint){
	// sends a ticket to the controller to return a path to the goal
	var _ticket = new PathTicket(_units, _startPoint, _endPoint);
	with(global.controller) ds_queue_enqueue(pathQueue, _ticket);
}