extends "res://engine/core/scripts/input.gd"

func do_process():
	var input_result = {
		"move" : Vector3.ZERO,
		"retry" : false,
		"jump" : false
	}
	
	var x_move = 0
	var y_move = 0
	
	if Input.is_action_pressed("move_right"):
		x_move = 1
	if Input.is_action_pressed("move_left"):
		x_move = -1
	if Input.is_action_pressed("move_back"):
		y_move = 1
	if Input.is_action_pressed("move_forward"):
		y_move = -1
		
	var direction = Vector3.ZERO
	
	direction.x += x_move
	direction.z += y_move
		
	input_result["move"] = direction
		
	if Input.is_action_pressed("jump"):
		input_result["jump"] = true
		
	if Input.is_action_pressed("retry"):
		input_result["retry"] = true
		
	return input_result
