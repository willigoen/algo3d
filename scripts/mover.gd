extends Node3D

signal object_selected(selected_obj: Node3D)

@export var temporary_material: Material
@onready var selected_label: Label = $"../CanvasLayer/Control/SelectedLabel"
@onready var camera_script = $"../CameraManager/CameraGimbal"
@export var handle_scene: PackedScene  # Asignar Handle3D.tscn en el editor

var selected_obj: Node3D = null
var material_node: MeshInstance3D = null
var original_material: Material = null
var camera: Camera3D = null
var handles: Node3D = null
var selected_axis: Vector3 = Vector3.ZERO
var is_object_selected: bool = false
var is_handle_selected: bool = false
var is_dragging: bool = false
var collider_disabled: bool = false

func _ready():
	selected_label.visible = false
	camera = get_viewport().get_camera_3d()
	if camera == null:
		printerr("No se encontró una cámara 3D en la escena.")
	else:
		print("Cámara detectada:", camera)
	
	if camera_script != null:
		self.connect("object_selected", Callable(camera_script, "_on_object_selected"))
	else:
		printerr("Camera script not found. Check the path to the camera gimbal.")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_handle_selected:
			_select_object(event)
		else:
			is_dragging = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		selected_axis = Vector3.ZERO
		is_dragging = false
		is_handle_selected = false
	elif event is InputEventMouseMotion and is_dragging and selected_axis != Vector3.ZERO:
		_move_along_selected_axis(event)

func _select_object(event):
	if camera == null:
		return

	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [camera]
	var result = space_state.intersect_ray(query)

	if result and result.collider is Node3D:
		if is_handle_selected:
			return

		if selected_obj != null and is_object_selected:
			_revert_material()
			_remove_handles()
			_enable_collider()

		selected_obj = result.collider
		is_object_selected = true
		print("Selected object:", selected_obj.name)

		_disable_collider(selected_obj)
		material_node = _find_material_node(selected_obj)
		if material_node != null:
			_apply_temporary_material(material_node)
			emit_signal("object_selected", selected_obj)
			_update_selected_label(selected_obj.get_name(), selected_obj.global_transform.origin)
			_spawn_handles(selected_obj)
	else:
		if is_object_selected:
			_revert_material()
			_remove_handles()
			_enable_collider()
			selected_obj = null
			is_object_selected = false
			_hide_selected_label()

func _spawn_handles(target: Node3D):
	if handle_scene != null:
		handles = handle_scene.instantiate()
		add_child(handles)
		handles.global_transform.origin = target.global_transform.origin
		print("Handles spawned at position:", handles.global_transform.origin)
		handles.connect("axis_selected", Callable(self, "_on_axis_selected"))
	else:
		printerr("handle_scene is not set. Please assign the Handle3D.tscn in the Inspector.")

func _remove_handles():
	if handles != null:
		handles.queue_free()
		handles = null
		print("Handles removed")

func _on_axis_selected(axis: Vector3):
	selected_axis = axis
	is_handle_selected = true
	print("Axis selected for movement:", selected_axis)

func _move_along_selected_axis(event: InputEventMouseMotion):
	if selected_obj != null and selected_axis != Vector3.ZERO:
		var movement_amount = event.relative.x * 0.05
		selected_obj.translate(selected_axis * movement_amount)
		print("Object moved along axis:", selected_axis, "by amount:", movement_amount)

func _disable_collider(target: Node3D):
	var collider = target.get_node_or_null("CollisionShape3D")
	if collider and collider is CollisionShape3D:
		collider.disabled = true
		collider_disabled = true
		print("Collider disabled for:", target.name)

func _enable_collider():
	if selected_obj and collider_disabled:
		var collider = selected_obj.get_node_or_null("CollisionShape3D")
		if collider and collider is CollisionShape3D:
			collider.disabled = false
			print("Collider re-enabled for:", selected_obj.name)
		collider_disabled = false

func _find_material_node(node: Node) -> MeshInstance3D:
	var current_node = node
	while current_node != null:
		if current_node is MeshInstance3D:
			return current_node as MeshInstance3D
		current_node = current_node.get_parent()
	return null

func _apply_temporary_material(obj: MeshInstance3D):
	original_material = obj.material_override
	if temporary_material != null:
		obj.material_override = temporary_material
		print("Temporary material applied to", obj.name)

func _revert_material():
	if material_node != null:
		material_node.material_override = original_material
		print("Reverted material for", material_node.name, "to", original_material)
		original_material = null
		material_node = null

func _update_selected_label(object_name: String, obj_position: Vector3):
	selected_label.text = "Seleccionado: " + object_name
	selected_label.visible = true
	var screen_pos = camera.unproject_position(obj_position)
	selected_label.position = screen_pos - selected_label.get_rect().size * 0.5

func _hide_selected_label():
	selected_label.visible = false
