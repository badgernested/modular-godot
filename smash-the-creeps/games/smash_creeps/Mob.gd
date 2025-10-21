extends CharacterBody3D

# Emitted when the player jumped on the mob.
signal squashed

## Minimum speed of the mob in meters per second.
@export var min_speed = 10
## Maximum speed of the mob in meters per second.
@export var max_speed = 18

var id_number = 0

## ID counter
static var id_counter = 0

func _ready():
	id_number = id_counter
	id_counter += 1
	
	if id_counter > 9999999:
		id_counter = 0

func _exit_tree() -> void:
	
	var mobs = get_all_mobs_stored()
		
	mobs[id_number] = {}

	GameController.set_output("mobs", mobs)
	
func get_all_mobs_stored():
	var mobs:Dictionary = {}
	
	if GameController.has_output("mobs"):
		# You have to pull the variable out and set it there, since its stored
		# in a collection.
		mobs = GameController.get_output("mobs")
		
	return mobs
	
func update_mob_property(name, value):
		
	var mobs = get_all_mobs_stored()
		
	if !mobs.has(id_number):
		mobs[id_number] = {}
		
	mobs[id_number][name] = value

	GameController.set_output("mobs", mobs)

func pack_data() -> Dictionary:
	var data = {}
	
	if $VisibleOnScreenNotifier3D.is_on_screen() && is_instance_valid(self):
		data["position"] = position
		data["rotation"] = rotation
		
	return data
	
func _physics_process(_delta):
	move_and_slide()

func initialize(start_position, player_position):
	look_at_from_position(start_position, player_position, Vector3.UP)
	rotate_y(randf_range(-PI / 4, PI / 4))

	var random_speed = randf_range(min_speed, max_speed)
	# We calculate a forward velocity first, which represents the speed.
	velocity = Vector3.FORWARD * random_speed
	# We then rotate the vector based on the mob's Y rotation to move in the direction it's looking.
	velocity = velocity.rotated(Vector3.UP, rotation.y)

	var data  = {}

	data["position"] = position
	data["rotation"] = rotation

	data["speed"] =  random_speed / min_speed
	
	var mobs = get_all_mobs_stored()
	
	mobs[id_number] = data


func squash():
	squashed.emit()
	queue_free()


func _on_visible_on_screen_notifier_screen_exited():
	queue_free()
