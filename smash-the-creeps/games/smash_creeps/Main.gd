extends Node

@export var mob_scene: PackedScene
@export var mod_id: String
@export var default_input_module: PackedScene
@export var default_output_module: PackedScene

@onready var player = $Player

var score = 0
var defeated = false

func validate_input(input:Dictionary) -> Dictionary:
	
	var direction = input["move"]	
	
	if direction != Vector3.ZERO:
		# In the lines below, we turn the character when moving and make the animation play faster.
		input["move"] = direction.normalized()
	
	return input

func do_process(delta) -> void:
	# Only run retry code if retry is visible
	if defeated:
		if GameController.get_input("retry"):
			reset_scene()

	var mobs = {}
	
	if GameController.has_output("mobs"):
		# You have to pull the variable out and set it there, since its stored
		# in a collection.
		mobs = GameController.get_output("mobs")
	
	if is_instance_valid(player):
		player.pack_data()
	
	for c in $Mobs.get_children():
		var data_pack = c.pack_data()
		if !mobs.has("mob%s" % c.id_number):
			mobs["mob%s" % c.id_number] = data_pack
		
	GameController.set_output("mobs", mobs)
		
func reset_scene():
	GameController.reload_game()

func increment_score():
	score +=1
	GameController.set_output("score", score)

func _on_mob_timer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instantiate()

	# Choose a random location on the SpawnPath.
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()

	# Communicate the spawn location and the player's location to the mob.
	var player_position = player.position
	mob.initialize(mob_spawn_location.position, player_position)

	# Spawn the mob by adding it to the Main scene.
	$Mobs.add_child(mob)
	# We connect the mob to the score label to update the score upon squashing a mob.
	mob.squashed.connect(increment_score)


func _on_player_hit():
	$MobTimer.stop()
	defeated = true
	GameController.set_output("defeated", true)
