extends Node

var component_name: String = "default"

# These variables store the currently loaded modules in memory.
var _input_modules = []
var _output_modules = []
var game:Node = null
var game_scene: PackedScene = null

# Result of the input cycle
var _input_result = {}

# Result of the output cycle
var _output_result = {}

# Whitelist for loading scenes, to prevent malicious behavior
const SCENE_WHITELIST = [
	"Main"
]
	
## Loads the requested game object
func load_game(main_scene):
	
	if ResourceLoader.exists("res://games/%s.tscn" % main_scene):
		game_scene = load("res://games/%s.tscn" % main_scene)

		open_game()
	else:
		
		push_error("Could not load resource res://games/%s.tscn." % main_scene)
		
func open_game():
	if game_scene != null:
		if game_scene.can_instantiate():
			
			_input_result = {}
			_output_result = {}
			
			if game != null && is_instance_valid(game):
				game.queue_free()
				await game.tree_exited            
			
			# clears active input and output modules
			for c in _input_modules:
				c.queue_free()
				
			for c in _output_modules:
				c.queue_free()
				
			for c in $Input.get_children():
				c.queue_free()
				
			for c in $Output.get_children():
				c.queue_free()
				
			_input_modules.clear()
			_output_modules.clear()
			
			# Loads scene from packed scene
			game = game_scene.instantiate()
			$Process.add_child(game)

			# Try to load the IO module if it exists
			var io_module:String = game.mod_id.strip_edges().strip_escapes()
				
			if io_module.length() > 0:
				_load_modules(io_module)
			else:
				push_error("Invalid name for external module to be loaded. Must be set properly to load modules.")
		
		else:			
			push_error("Game scene cannot be instantiated.")

	else:
		push_error("Game scene has not been initialized.")

func reload_game():
	open_game()

## Reloads the current loaded modules based on module set name

func _load_modules(module) -> void:
	var base_addr = "/home/felix/code/game/moddability-prototype/export-pkgs/"
	
	var input = []
	var output = []
	
	# This could fail if, for example, mod.pck cannot be found.
	var path = base_addr + "output/%s.pck" % module

	var success = ProjectSettings.load_resource_pack(path)

	if success:
		# Now one can use the assets as if they had them in the project from the start.

		if ResourceLoader.exists("res://ext/%s/config.gd" % component_name):
			var config =  load("res://ext/default/config.gd").new()
			_input_modules = config.input.duplicate()
			_output_modules = config.output.duplicate()

	else:
		# If the input/output modules are defined, instantiate them
		if game.default_input_module != null && game.default_input_module != null:
			$Input.add_child(game.default_input_module.instantiate())
			$Output.add_child(game.default_output_module.instantiate())
			
			# processes input module once to prevent nonsense
			_input_result = get_input_result()

	for item in _input_modules:
		if ResourceLoader.exists("res://ext/%s.tscn" % item):
			var mod = load("res://ext/%s.tscn" % item).instantiate()
			_input_modules.append(mod)
			$Input.add_child(mod)
		else:
			push_error("Module not located: res://ext/%s" % item )
			
	for item in _output_modules:
		if ResourceLoader.exists("res://ext/%s.tscn" % item):
			var mod = load("res://ext/%s.tscn" % item).instantiate()
			_output_modules.append(mod)
			$Output.add_child(mod)
		else:
			push_error("Module not located: res://ext/%s" % item )

# This returns the net result of the input modules
func get_input_result() -> Dictionary:
	_input_result = {}
	var _input_r = {}
	
	for input in $Input.get_children():
		if is_instance_valid(input):
			
			_input_r = input.do_process()
			
	return _input_r

# Generates the output from the output modules
func generate_output(output: Dictionary) -> void:
	for module in $Output.get_children():
		module.do_process(output)
		
# Interface to interact with input/output

func get_input(name):
	if _input_result.has(name):
		return _input_result[name]
		
	push_error("Tried to get input variable %s which does not exist." % name)
	return null
	
func set_output(name, value):
	_output_result[name] = value

# returns the output result if it exists
func get_output(name):
	if _output_result.has(name):
		return _output_result[name]
		
	push_error("Unable to find output variable %s" % name)
	return null
	
func has_output(name):
	return _output_result.has(name)

## Normal node control functions

func _ready() -> void:
	load_game("smash_creeps/Main")

func _process(delta: float) -> void:
	
	# Gets the input result
	_input_result = game.validate_input(get_input_result())
	
	# Processes game logic
	game.do_process(delta)
	# Generates the output	
	generate_output(_output_result)
	# Clears output immediately after updating
	_output_result = {}
