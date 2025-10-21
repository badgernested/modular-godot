extends CharacterBody3D

signal hit

## How fast the player moves in meters per second.
@export var speed = 14
## Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse = 20
## Vertical impulse applied to the character upon bouncing over a mob in meters per second.
@export var bounce_impulse = 16
## The downward acceleration when in the air, in meters per second.
@export var fall_acceleration = 75

var moving_this_frame = false
var in_air = false

func pack_data():
	if !GameController.has_output("player"):
		var data = {}
		data["position"] = position
		data["rotation"] = rotation
		data["moving"] = moving_this_frame
		data["air"] = in_air
		GameController.set_output("player", data)

func _physics_process(delta):
	moving_this_frame = false
	
	var direction = GameController.get_input("move")

	if direction != Vector3.ZERO:
		# Setting the basis property will affect the rotation of the node.
		basis = Basis.looking_at(direction)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Jumping.
	if is_on_floor() and GameController.get_input("jump"):
		velocity.y += jump_impulse
		in_air = true

	# We apply gravity every frame so the character always collides with the ground when moving.
	# This is necessary for the is_on_floor() function to work as a body can always detect
	# the floor, walls, etc. when a collision happens the same frame.
	velocity.y -= fall_acceleration * delta
	move_and_slide()
	
	if velocity != Vector3.ZERO:
		moving_this_frame = true

	# Here, we check if we landed on top of a mob and if so, we kill it and bounce.
	# With move_and_slide(), Godot makes the body move sometimes multiple times in a row to
	# smooth out the character's motion. So we have to loop over all collisions that may have
	# happened.
	# If there are no "slides" this frame, the loop below won't run.
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				velocity.y = bounce_impulse
				# Prevent this block from running more than once,
				# which would award the player more than 1 point for squashing a single mob.
				break
				
		if collision.get_collider().is_in_group("floor"):
			in_air = false

	# This makes the character follow a nice arc when jumping
	rotation.x = PI / 6 * velocity.y / jump_impulse

func die():
	hit.emit()
	queue_free()

func _on_MobDetector_body_entered(_body):
	die()
