extends "res://engine/core/scripts/output.gd"

const MOB_SCENE = preload("res://games/smash_creeps/output/MobModel.tscn")

var mobs: Dictionary = {}

func _ready():
	for c in $Mobs.get_children():
		c.queue_free()
		
	$UserInterface/Retry.hide()

func do_process(result: Dictionary) -> void:
	
	if result.has("defeated"):
		$UserInterface/Retry.visible = result["defeated"]
		$PlayerModel.queue_free()

	else:
		# updates score
		if result.has("score"):
			$UserInterface/ScoreLabel.update_score(result["score"])
	
		# sets player position
		if result.has("player") && has_node("PlayerModel"):
			if result.is_empty():
				$PlayerModel.queue_free()
			else:
				var player = result["player"]
				$PlayerModel.position = player.position
				$PlayerModel.rotation = player.rotation
				if player.moving:
					$PlayerModel.set_animation_speed(4)
				else:
					$PlayerModel.set_animation_speed(1)
					
				if player.air:
					$PlayerModel/AnimationPlayer.stop()
				else:
					$PlayerModel/AnimationPlayer.play()
	
		if result.has("mobs"):
			var mobs_list = result["mobs"]
			
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

					mobs[c].position = mobs_list[c]["position"]
					mobs[c].rotation = mobs_list[c]["rotation"]
