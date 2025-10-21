extends Node

## This input example has movement based on the mouse instead of the keyboard.
## You use the left button to jump.
## Notice how validation will prevent rapid movements.

var data_packet = {}

var output_module = null

var button_pressed_last = false

func _ready():
	await get_tree().process_frame
	output_module = get_parent().get_parent().get_node("Output").get_child(0)

## Every frame, input is processed. The abstract result of input is stored in the InputMsg object.
## Note that for each different kind of module you should have a custom message type.
## You could also do this with JSON but its not as efficient.
func do_process(output:Dictionary) -> Dictionary:

	var viewport = get_viewport()
	
	var mouse_pos = Vector2.INF
	
	if output_module != null:
		mouse_pos = (output_module.get_global_mouse_position())
	
	var final_pos = Vector2.ZERO
	
	if output.has("player"):
		if mouse_pos != Vector2.INF:
			final_pos = mouse_pos - Vector2(output["player"].position.x,output["player"].position.z)

	if final_pos.length() < 1:
		final_pos = Vector2.ZERO

	var input_result = {
		"move" : Vector3.ZERO,
		"retry" : false,
		"jump" : false
	}
	
	var direction = Vector3.ZERO
	
	direction.x += final_pos.x * 10
	direction.z += final_pos.y * 10
		
	input_result["move"] = direction
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) && !button_pressed_last:
		input_result["jump"] = true
		input_result["retry"] = true
		
	button_pressed_last = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	
	return input_result
