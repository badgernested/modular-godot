extends Node

var data_packet = {}

## Every frame, input is processed. The abstract result of input is stored in the InputMsg object.
## Note that for each different kind of module you should have a custom message type.
## You could also do this with JSON but its not as efficient.
func do_process(delta) -> Dictionary:

	# clear the data packet this frame
	data_packet = {}
	
	data_packet["jump"] = Input.is_action_just_pressed("ui_accept")
	data_packet["left"] = Input.is_action_just_pressed("move_left")
	data_packet["right"] = Input.is_action_just_pressed("move_right")
	data_packet["up"] = Input.is_action_just_pressed("move_up")
	data_packet["down"] = Input.is_action_just_pressed("move_down")

	return data_packet
