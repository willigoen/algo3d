extends Node3D

@export var orbit_sensitivity: float = 0.1
@export var pan_sensitivity: float = 0.01
@export var zoom_sensitivity: float = 1.0

@onready var gimbal: Node3D = $"."  # Assuming the script is attached to the gimbal itself.
@onready var inner_gimbal: Node3D = $InnerGimbal
@onready var camera: Camera3D = $InnerGimbal/MainCamera3D

var is_orbiting: bool = false
var is_panning: bool = false

func _unhandled_input(event):
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_MIDDLE:
            # Orbit with just the middle mouse button, Pan with Shift + middle mouse button
            if event.pressed:
                is_orbiting = !Input.is_key_pressed(KEY_SHIFT)
                is_panning = Input.is_key_pressed(KEY_SHIFT)
                Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
            else:
                is_orbiting = false
                is_panning = false
                Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

        elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            camera.translate(Vector3(0, 0, -zoom_sensitivity))
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            camera.translate(Vector3(0, 0, zoom_sensitivity))

    if event is InputEventMouseMotion:
        if is_orbiting:
            orbit_camera(event)
        elif is_panning:
            pan_camera(event)

func orbit_camera(event: InputEventMouseMotion):
    var orbit_rotation = gimbal.rotation_degrees
    orbit_rotation.y -= event.relative.x * orbit_sensitivity
    orbit_rotation.x = clamp(orbit_rotation.x - event.relative.y * orbit_sensitivity, -80, 80)
    gimbal.rotation_degrees = orbit_rotation

func pan_camera(event: InputEventMouseMotion):
    var pan_offset = Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity
    gimbal.translate(pan_offset)
