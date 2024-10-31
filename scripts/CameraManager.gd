extends Node

@onready var world_center: Vector3 = Vector3.ZERO
@onready var gimbal_obj: Node3D
@onready var inner_gimbal_obj: Node3D
@onready var camera_obj: Camera3D
@onready var cam_pos: Vector3
var is_rotating: bool = false
var is_orbiting: bool = false

# camera settings:
@export var orbit_sensitivity: float = 0.1 
@export var rotation_sensitivity: float = 0.1

func _ready():
	gimbal_obj = get_node("CameraGimbal")
	inner_gimbal_obj = get_node("CameraGimbal/InnerGimbal")
	camera_obj = get_node("CameraGimbal/InnerGimbal/MainCamera3D")

func _process(_delta):
	#print(camera_obj.rotation_degrees)  # Imprime la posición de la cámara en cada frame
	pass

func _unhandled_input(event):
	orbit_camera(event)
	rotate_camera(event)

func orbit_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			print("Middle button pressed    ", event.pressed)
			if event.pressed:
				is_orbiting = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_orbiting = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and is_orbiting:
		if event is InputEventMouseMotion:
			var orbit_cam = gimbal_obj.rotation_degrees
			
			# Ajuste horizontal en `y` para girar alrededor del objeto sin inclinación excesiva
			orbit_cam.y -= event.relative.x * orbit_sensitivity
			
			# Limitar la rotación en `x` entre -80 y 80 grados para evitar tilt
			orbit_cam.x = clamp(orbit_cam.x - event.relative.y * orbit_sensitivity, -80, 80)
			
			# Aplicar la rotación limitada al `gimbal_obj`
			gimbal_obj.rotation_degrees = orbit_cam


func rotate_camera(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			print("Right button pressed    ", event.pressed)
			if event.pressed:
				is_rotating = true
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				is_rotating = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and is_rotating:
		if event is InputEventMouseMotion:
			# Tomar la rotación actual de la cámara
			var rotate_cam = camera_obj.rotation_degrees
			
			# Ajustar rotación vertical (eje X) con límite de inclinación
			rotate_cam.x = clamp(rotate_cam.x - event.relative.y * rotation_sensitivity, -80, 80)
			
			# Ajustar rotación horizontal (eje Y) sin límite
			rotate_cam.y -= event.relative.x * rotation_sensitivity
			
			# Aplicar la rotación calculada a la cámara
			camera_obj.rotation_degrees = rotate_cam

