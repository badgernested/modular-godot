extends Node2D

@onready var player = $Player

const MOB_SCENE = preload("res://ext/creeps1/Mob.tscn")

var mobs: Dictionary = {}

func do_process(data: Dictionary) -> void:
	if data.has("defeated"):
		$UI/Retry.visible =data["defeated"]
		player.queue_free()
	
	if data.has("score"):
		$UI/Label.text = "SCORE: %s" % data["score"]
	
	if is_instance_valid(player):	
		if data.has("player"):
			
			player.rotation = data["player"].rotation.y
			player.position.x = data["player"].position.x
			player.position.y = data["player"].position.z
			
			if data["player"].has("speed"):
				player.set_animation_speed(data["player"].speed)
			
			var scale_fac = (data["player"].position.y * 0.33 + 0.93) * player.DEFAULT_SIZE
			
			player.scale.x = scale_fac
			player.scale.y = scale_fac
			
	if data.has("mobs"):
		var mobs_list = data["mobs"]
		for c in mobs_list:
			
			if mobs_list[c].is_empty():
				if mobs.has(c):
					mobs[c].queue_free()
					mobs.erase(c)
			else:
				if !mobs.has(c):
					mobs[c] = MOB_SCENE.instantiate()
					$Mobs.add_child(mobs[c])
					
				if mobs_list[c].has("speed"):
					mobs[c].set_animation_speed(mobs_list[c]["speed"])

				mobs[c].position.x = mobs_list[c]["position"].x
				mobs[c].position.y = mobs_list[c]["position"].z
				mobs[c].rotation = mobs_list[c]["rotation"].y
