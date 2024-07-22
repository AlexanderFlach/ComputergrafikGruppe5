@tool
extends MeshInstance3D

@export var size = Vector2i(2, 2)
@export var resolution = Vector2i(32, 32)
@export var noise_frequency = 0.5
@export var noise_amplitude = 0.1
@export var noise_octaves = 6
@export var height = 0.3

@export var regenerate_mesh: bool:
	set(value):
		create_planemesh()

var noise = FastNoiseLite.new()


func create_planemesh():
	init_noise()


	var planemesh = PlaneMesh.new()
	planemesh.subdivide_width = resolution.x
	planemesh.subdivide_depth = resolution.y
	planemesh.size = size

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(planemesh, 0)

	var mesh_arrays = surface_tool.commit_to_arrays()
	var vertices = mesh_arrays[ArrayMesh.ARRAY_VERTEX]

	for i in vertices.size():
		vertices[i].y = height_map(vertices[i].x, vertices[i].z)

	mesh_arrays[ArrayMesh.ARRAY_VERTEX] = vertices

	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)

	surface_tool.create_from(array_mesh, 0)
	surface_tool.generate_normals()

	mesh = surface_tool.commit()

func init_noise():
	noise.seed = randi()
	noise.fractal_octaves = noise_octaves
	noise.frequency = noise_frequency
	
func height_map(x: float, z: float) -> float:
	var falloff = terrain_falloff(x, z)
	return noise.get_noise_2d(x, z) * noise_amplitude * falloff + falloff * height

func terrain_falloff(x: float, z: float) -> float:
	return cos(x * PI / size.x) * cos(z * PI / size.y)


func _on_btn_generate_terrain_pressed():
	create_planemesh()


func _on_spin_box_hight_value_changed(value):
	height = value


func _on_spin_box_size_x_value_changed(value):
	size.x = value


func _on_spin_box_size_y_value_changed(value):
	size.y = value
