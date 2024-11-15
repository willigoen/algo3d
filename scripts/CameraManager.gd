extends Node

@export_category("Camera Settings")
@export var orbit_sensitivity: float = 0.1
@export var pan_sensitivity: float = 0.01

@export var zoom_sensitivity: float = 1.0
@export var zoom_lerp_speed: float = 0.4
var zoom_target_z: float = 0.0  # Target Z position for zoom

@export var min_pan_y: float = 0.0  # Minimum Y value for panning
@export var max_orbit_elevation: float = 10.0  # Minimum angle above ground (10 degrees)
@export var min_orbit_elevation: float = -90.0  # Maximum angle for looking down (90 degrees downwards)
@export var focus_speed: float = 0.1  # Speed for lerping focus to the selected object
@export var zoom_range: Array = [float(-4),float(8)]  # Zoom range in Z (from, to)

@export_category("Pan Settings")
@export var pan_y: bool = false  # Enable panning in the Y axis

@export_group("Camera Nodes")
@onready var gimbal: Node3D = $CameraGimbal
@onready var inner_gimbal: Node3D = $CameraGimbal/InnerGimbal
@onready var camera: Camera3D = $CameraGimbal/InnerGimbal/MainCamera3D

var focus_speed_value: float = 0.05  # Multiplier for focus speed

var is_orbiting: bool = false
var is_panning: bool = false
var selected_obj: Node3D = null  # Store the currently selected object
var is_focusing: bool = false  # Track when we're focusing

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				is_orbiting = !Input.is_key_pressed(KEY_SHIFT)
				is_panning = Input.is_key_pressed(KEY_SHIFT)
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_orbiting = false
				is_panning = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(-zoom_sensitivity)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(zoom_sensitivity)

	if event is InputEventMouseMotion:
		if is_orbiting:
			orbit_camera(event)
		elif is_panning:
			pan_camera(event)

	# Check for "F" key press to initiate focus
	if event is InputEventKey and event.pressed and event.keycode == KEY_F:
		if selected_obj != null:
			is_focusing = true

func _process(delta):
	if is_focusing and selected_obj != null:
		focus_on_object(delta)

func orbit_camera(event: InputEventMouseMotion):
	var orbit_rotation = gimbal.rotation_degrees
	orbit_rotation.y -= event.relative.x * orbit_sensitivity

	# Inverted clamping: allowing view from above but preventing below ground level
	orbit_rotation.x = clamp(orbit_rotation.x - event.relative.y * orbit_sensitivity, min_orbit_elevation, max_orbit_elevation)
	gimbal.rotation_degrees = orbit_rotation

func pan_camera(event: InputEventMouseMotion):
	if pan_y:
		var pan_offset = Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity
		gimbal.translate(pan_offset)
		# Clamp the gimbal’s Y position to stay above min_pan_y
		var current_position = gimbal.global_transform.origin
		if current_position.y < min_pan_y:
			current_position.y = min_pan_y
			gimbal.global_transform.origin = current_position
	else:
		# Calculate the pan offset in the x and z directions
		var pan_offset = Vector3(-event.relative.x, 0, -event.relative.y) * pan_sensitivity
		# Translate the gimbal in the x and z axes only
		gimbal.translate(pan_offset)
		# Constrain the gimbal's y position to remain constant (ground level)
		var current_position = gimbal.global_transform.origin
		current_position.y = min_pan_y  # Ensure it remains at ground level
		gimbal.global_transform.origin = current_position

func _zoom(delta: float):
	# Calculate the target Z position
	var target_z = clamp(camera.transform.origin.z + delta, zoom_range[0], zoom_range[1])
	
	# Smoothly interpolate the current Z position towards the target Z position
	camera.transform.origin.z = lerp(camera.transform.origin.z, target_z, zoom_lerp_speed)
	
	print("Zoom adjusted. New Z:", camera.transform.origin.z)

func focus_on_object(delta):
	var target_position = selected_obj.global_transform.origin  # Position to move towards
	var current_position = gimbal.global_transform.origin
	var distance_to_target = current_position.distance_to(target_position)

	# Calculate the speed dynamically to reach the target in approximately 0.6 seconds
	var dynamic_focus_speed = distance_to_target / focus_speed_value

	# Use lerp with dynamic speed to move the gimbal towards the target
	gimbal.global_transform.origin = current_position.lerp(target_position, dynamic_focus_speed * delta)

	# Stop focusing once close enough to the target
	if current_position.distance_to(target_position) < 0.1:
		is_focusing = false  # Stop the focusing movement

# Called by Selection.gd when an object is selected
func _on_object_selected(selected: Node3D):
	selected_obj = selected
	is_focusing = false  # Reset focusing to prevent automatic focus
