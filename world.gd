@tool
extends MeshInstance3D

@export var generate := false :
	set(new_value):
		generate = false
		generate_world()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_world()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func generate_world() -> void:
	print("hello voxel world")
