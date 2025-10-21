extends Node2D

func _ready():
	$AnimationTree.play("float")
	scale.x = 0.05
	scale.y = 0.05

func set_animation_speed(value):
	$AnimationTree.speed_scale = value
