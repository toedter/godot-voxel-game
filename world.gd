@tool
extends MeshInstance3D

@export var generate := false :
	set(new_value):
		generate = false
		init_block_array()
		gen_chunk()

@export var chunk_size : int = 16
@export var seed : int = 1
@export 	var max_height : int = 30

enum BlockType {Air, Dirt}

var a_mesh = ArrayMesh.new()
var vertices = PackedVector3Array()
var indices = PackedInt32Array()
var uvs = PackedVector2Array()

var face_count
var tex_div = 0.25

var blocks = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_block_array()
	gen_chunk()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func init_block_array():
	var noise = FastNoiseLite.new()
	noise.seed = seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	
	blocks.resize(chunk_size)

	for x in range(chunk_size):
		blocks[x] = []
		for y in range(chunk_size):
			blocks[x].append([])
			for z in range(chunk_size):
				var noiseval = (int)(noise.get_noise_2d(x,z) * -max_height) % max_height
				if (y - 3) <= noiseval:
					blocks[x][y].append(BlockType.Dirt)
				else:
					blocks[x][y].append(BlockType.Air)
				
	
func add_uvs(x, y):
	uvs.append(Vector2(tex_div * x, tex_div * y))
	uvs.append(Vector2(tex_div * x + tex_div, tex_div * y))
	uvs.append(Vector2(tex_div * x + tex_div, tex_div * y + tex_div))
	uvs.append(Vector2(tex_div * x, tex_div * y + tex_div))
	
func add_tris():
	indices.append(face_count * 4 + 0)
	indices.append(face_count * 4 + 1)
	indices.append(face_count * 4 + 2)
	indices.append(face_count * 4 + 0)
	indices.append(face_count * 4 + 2)
	indices.append(face_count * 4 + 3)
	face_count += 1
	
func gen_cube_mesh(pos : Vector3):
	
	if block_is_air(pos + Vector3(0, 1, 0)):
		# TOP	
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))	
		vertices.append(pos + Vector3( 0.5, 0.5, -0.5))	
		vertices.append(pos + Vector3( 0.5, 0.5,  0.5))	
		vertices.append(pos + Vector3(-0.5, 0.5,  0.5))	
	
		add_tris()
		add_uvs(0,0)
	
	if block_is_air(pos + Vector3(1, 0, 0)):
		# EAST	
		vertices.append(pos + Vector3( 0.5, 0.5, 0.5))	
		vertices.append(pos + Vector3( 0.5, 0.5, -0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5,-0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5,  0.5))	
	
		add_tris()
		add_uvs(1,0)
	
	if block_is_air(pos + Vector3(0, 0, 1)):
		# SOUTH	
		vertices.append(pos + Vector3(-0.5, 0.5, 0.5))	
		vertices.append(pos + Vector3( 0.5, 0.5, 0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5,0.5))	
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))	
	
		add_tris()
		add_uvs(1,0)
	
	if block_is_air(pos + Vector3(-1, 0, 0)):
		# WEST	
		vertices.append(pos + Vector3(-0.5, 0.5, -0.5))	
		vertices.append(pos + Vector3(-0.5, 0.5,  0.5))	
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))	
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))	
	
		add_tris()
		add_uvs(1,0)
	
	if block_is_air(pos + Vector3(0, 0, -1)):
		# NORTH	
		vertices.append(pos + Vector3( 0.5,  0.5, -0.5))	
		vertices.append(pos + Vector3(-0.5,  0.5, -0.5))	
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5, -0.5))	
	
		add_tris()
		add_uvs(1,0)
	
	if block_is_air(pos + Vector3(0, -1, 0)):	
		# BOTTOM	
		vertices.append(pos + Vector3(-0.5, -0.5, 0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5, 0.5))	
		vertices.append(pos + Vector3( 0.5, -0.5, -0.5))	
		vertices.append(pos + Vector3(-0.5, -0.5, -0.5))	
	
		add_tris()
		add_uvs(2,0)
	
func gen_chunk():
	a_mesh = ArrayMesh.new()
	vertices = PackedVector3Array()
	indices = PackedInt32Array()
	uvs = PackedVector2Array()
	face_count = 0
	
	for x in range(chunk_size):
		for y in range(chunk_size):
			for z in range(chunk_size):
				if (blocks[x][y][z] == BlockType.Air):
					pass
				else:
					gen_cube_mesh(Vector3(x, y, z))
			
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	array[Mesh.ARRAY_TEX_UV] = uvs
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,array)
	mesh = a_mesh
	
func block_is_air(pos : Vector3):
	if pos.x < 0 or pos.y < 0 or pos.z < 0:
		return true
	elif pos.x >= chunk_size	or pos.y >= chunk_size or pos.z >= chunk_size	:
		return true
	elif blocks[pos.x][pos.y][pos.z] == BlockType.Air:
		return true
	else:
		return false
