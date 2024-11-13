extends Node3D

signal object_selected(selected_obj: Node3D)  # Define the signal

@onready var selected_label: Label = $"../CanvasLayer/Control/SelectedLabel"
@onready var camera_script = $"../CameraManager/CameraGimbal"  # Adjust this path to your camera orbit script location
var selected_obj: Node3D = null
var camera: Camera3D = null

func _ready():
	selected_label.visible = false
	camera = get_viewport().get_camera_3d()
	if camera == null:
		printerr("No se encontró una cámara 3D en la escena.")
	else:
		print("Cámara detectada:", camera)
	
	# Connect signal to camera orbit script
	if camera_script != null:
		self.connect("object_selected", Callable(camera_script, "_on_object_selected"))
	else:
		printerr("Camera script not found. Check the path to the camera gimbal.")

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_object()

func _select_object():
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
		selected_obj = result.collider
		emit_signal("object_selected", selected_obj)  # Emit the signal when an object is selected
		_update_selected_label(selected_obj.get_name(), selected_obj.global_transform.origin)
	else:
		selected_obj = null
		_hide_selected_label()

func _update_selected_label(object_name: String, obj_position: Vector3):
	selected_label.text = "Seleccionado: " + object_name
	selected_label.visible = true
	var screen_pos = camera.unproject_position(obj_position)
	selected_label.position = screen_pos - selected_label.get_rect().size * 0.5

func _hide_selected_label():
	selected_label.visible = false
