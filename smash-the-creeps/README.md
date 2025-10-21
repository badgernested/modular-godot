# Smash the Creeps Demo

Note: *This demo is not intended as a demonstration of accessibility,* only a demonstration of swapping user interfaces.

Note: All files for this section are located in ``games/assets/smash_creeps``.

[Game Repository](https://github.com/badgernested/modular-godot/tree/main/smash-the-creeps)
[Game Extensions Repository](https://github.com/badgernested/modular-godot/tree/main/creeps-exp)

[Squash the Creeps](https://godotengine.org/asset-library/asset/2751) is a Demo game project provided by Godot to demonstrate the basic features of the engine. It features a small creature smashing on creeps by navigating the map and jumping on them. The player accumulates a score until they are hit by one of the creeps, which opens a retry screen. This proof of concept is intended to demonstrate the basic potential of using a modular deisgn with emphasis on separation of user I/O layer from the game's processing layer.

The original Smash the Creeps demo is designed with no separation between user I/O and game logic. In fact, this appears to be the assumption under which Godot was designed. For example, the player and mob objects both contain code for any relevant inputs, have the objects containing their meshes, and so on. This means that in order to convert the game, I had to split these components from the object and separate them. I detail the implementation process below.

## Initial Implemetation

I started by constructing the game object loader. For this game, there is no need for any advanced features, so it simply loads games and its input/output modules. This file is located at ``res://engine/core/game.gd`` and ``res://engine/core/GameComponent.tscn``. In the scene file, I have three nodes:

```
- Input
- Process
- Output
```

These are primarily used for organizational purposes. Input's processing is disabled, but Process and Output's processing must be enabled for game functionality to work. The scene is saved as a Global with the name GameComponent so that it can be accessed throughout the application.

The game is loaded with the method ``load_game()``. This method can take an optional io_module id so that it can load a different module than the default. This is not normally behavior that would be useful, since typically you only would want one external ID per user interface, but for this demo, it allows for the cycling of input models.

Every ``_process()`` frame, the input is polled, the game is procssed and the output state is set.

The object also has the ability to set input variables, and to get/set output variables. This way input/output scripts can access this global operator without passing a variable around. Plus, these values should just be available at all times anyways.

Note: The implementation of these getter/setter methods is not optimal. Godot also makes it difficult to restrict access to members, so all variables are effectively public.

For the game files, first I created the ``Input.tscn`` and ``Output.tscn`` files, which represent the default input and output modules. When the game is first loaded, if there is no overriding .PCK mod file, it will use the default input/output (thus still contained within the default project). Additionally, I modified ``Main.tscn`` to include variables for the default input and output modules, as well as the name of the mod file it looks for.

With this in place, I started with input, because input is relatively easy to consolidate. All the input script does is when ``do_process()`` is called by the ``GameController`` every process step, polls inputs and returns their results to the game. The input map has the following structure, with its default values:

```
movement: Vector3.ZERO
retry: false
jump: false
```

Notice that this is not simply just polling for the state of the inputs, but the interface represents an abstraction of what input should ultimately be interpreted as. In this case, ``movement`` consolidates the keypad buttons as a single movement variable, since they are all used for basic movement. This interface makes it easier to implement other input models, which will be demonstrated below.

Notably, the input module takes the last frame's output as an argument. This is because in some input models, such as the mouse, it requires information about the current position of objects to make an appropriate calculation.

After the input module polls the state of the inputs and outputs its state, the state is validated to ensure that the input stays within appropriate limits and acceleration. This helps prevent cheating behaviors. Currently, this only normalizes the Vector3 input to ensure that it stays within range.

Processing then occurs primarily within Main.tscn/Main.gd in the function ``do_process``, which is called by the controller at this time. This function sets various internal values relevant to the game state, similar to ``_process()`` in a normal Godot game. ``_process()`` is not used because more granular control is required for when exactly processing occurs.

One limitation discovered while implementing was recognizing how Godot's physics processing interferes with assumptions about the availability of variables, leading to difficulties in maintaining the assumptions of the communication machine between processor and output. This would lead to incorrect displays. Godot splits the physics and idle processing into two different processing flows which run at slightly different rates (physics is intended to run exactly 60 frames per second while idle is variable and occupies idle time between frames). This was resolved by isolating all output updates into the ``do_process`` routine, and using physics to only update the internal location states. In addition, to prevent conflicts from calling signals in the physics process cycle, flags are set that trigger the actions on the next ``do_process`` call instead to make sure all communication updates are contained within ``do_process``.

While processing, values can be set for output export by setting them with ``GameController.set_output()``. It turned out that while developing, I underestimated the amount of modifications needed to the output dictionary that my visible public interface was limited in expressing (while in Godot you can call private variables and functions that start with ``_`` but these are considered private functions and it is considered bad practice to do so). In future implementations I will make the interface more open for output generation.

The output dictionary model has the following structure:

```
player:
    position: Vector3.ZERO
    rotation: Vector3.ZERO 
    moving: false
    air: false

mobs:
    mob1:
        position: Vector3.ZERO
        rotation: Vector3.ZERO
        speed: 1
    [...]
```

Essentially, the output includes data about the player position and attributes, and a list of all active mobs. This data is processed by the output module. This module is what manipulates the meshes to actually make the output visible. It simply updates the player position, but mobs are more involved. For each mob, it will be assigned an identifier based on its ID in the dictionary model. If the mob does not exist, it will create one. If a mob is to be deleted, it will have an empty data struture instead, which signifies to the output module to delete the mob object.

With this system, the visual components of the game are all isolated from the internal processing, which exposes the game's processor component with input and output variables on its surface, allowing for direct manipulation of the game state on this interface, which we will explore in the following section.

Finally, Squash the Creeps has a scene reset functionality. Unfortunately, because of the use of the control node as the base root node, this leads to the game being unable to use the default reset scene functionality. Instead, it just frees the current scene quickly while replacing it with a new one. 

## Implementation of External Input Modules
