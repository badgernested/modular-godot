extends Node

# Kills itself right after its made. This way the global object GameController can do everything.
func _ready() -> void:
	queue_free()
