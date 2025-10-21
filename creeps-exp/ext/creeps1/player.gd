extends Node2D

const DEFAULT_SIZE = 0.05

func _ready():
	$AnimationTree.play("float")
	scale.x = DEFAULT_SIZE
	scale.y = DEFAULT_SIZE

func set_animation_speed(value):
	$AnimationTree.speed_scale = value
