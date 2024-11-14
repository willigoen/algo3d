extends Node3D

signal object_selected(selected_obj: Node3D)

@export var temporary_material: Material  # Material temporal para resaltar el objeto seleccionado
@export var handle_scene: PackedScene  # Escena del handler que permitirá mover el objeto seleccionado

var selected_obj: Node3D = null
var material_node: MeshInstance3D = null
var original_material: Material = null
var handles: Node3D = null
var camera: Camera3D = null
var selected_axis: Vector3 = Vector3.ZERO
var is_dragging: bool = false
var is_handle_selected: bool = false

func _ready():
	camera = get_viewport().get_camera_3d()
	if camera == null:
		printerr("No se encontró una cámara 3D en la escena.")
	else:
		print("Cámara detectada:", camera)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_handle_selected:
			is_dragging = true
		else:
			_select_or_deselect_object(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		is_dragging = false
		is_handle_selected = false
	elif event is InputEventMouseMotion and is_dragging and selected_axis != Vector3.ZERO:
		_move_along_selected_axis(event)

func _select_or_deselect_object(event):
	if camera == null:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [camera]
	var result = space_state.intersect_ray(query)

	if result:
		if result.collider == selected_obj:
			return
		elif result.collider == handles:
			is_handle_selected = true
			return
		elif result.collider is Node3D:
			if selected_obj != null:
				_deselect_object()
			_select_object(result.collider)
	else:
		_deselect_object()

func _select_object(obj: Node3D):
	selected_obj = obj
	material_node = _find_material_node(selected_obj)
	if material_node != null:
		if original_material == null:
			original_material = material_node.material_override
			print("Original material stored for", material_node.name, ":", original_material)
		_apply_temporary_material(material_node)
		emit_signal("object_selected", selected_obj)
	_spawn_handler(selected_obj)
	print("Selected object:", selected_obj.name)

func _spawn_handler(target: Node3D):
	if handle_scene != null:
		handles = handle_scene.instantiate()
		add_child(handles)
		handles.global_transform.origin = target.global_transform.origin
		handles.connect("axis_selected", Callable(self, "_on_axis_selected"))
	else:
		printerr("Handle scene is not set. Assign the Handle3D.tscn.")

func _on_axis_selected(axis: Vector3):
	selected_axis = axis
	is_handle_selected = true
	print("Axis selected for movement:", selected_axis)

func _move_along_selected_axis(event: InputEventMouseMotion):
	if selected_obj == null:
		return
	var movement_amount = event.relative.x * 0.05
	selected_obj.translate(selected_axis * movement_amount)
	print("Object moved along axis:", selected_axis, "by amount:", movement_amount)

func _deselect_object():
	if selected_obj != null:
		_revert_material()
		_remove_handler()
		selected_obj = null
		selected_axis = Vector3.ZERO
		print("Deselected object")

func _apply_temporary_material(obj: MeshInstance3D):
	if temporary_material != null:
		obj.material_override = temporary_material
		print("Temporary material applied to", obj.name)

func _revert_material():
	if material_node != null and original_material != null:
		material_node.material_override = original_material
		print("Reverted material for", material_node.name, "to original material:", original_material)
		original_material = null
		material_node = null

# Ajuste en el método para buscar el MeshInstance3D
func _find_material_node(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	
	for child in node.get_children():
		if child is MeshInstance3D:
			return child as MeshInstance3D
	
	return null

func _remove_handler():
	if handles != null:
		handles.queue_free()
		handles = null
		print("Handler removed")
