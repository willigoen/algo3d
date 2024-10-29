extends Camera3D

@export var orbit_sensitivity: float = 0.005
@export var zoom_sensitivity: float = 15.0

#@onready var camera_target: Node3D = $"../CameraTarget"

var camera_rotation: Vector2
var head_rotation: Vector2
var distance: float = 10.0
var is_panning: bool = false
var is_orbiting: bool = false
var is_head_orbiting: bool = false
var focus_point: Vector3 = Vector3.ZERO
var last_camera_position: Vector3 = Vector3()
var last_focus_point: Vector3 = Vector3()
var pan_handler: Node = null  # Referencia al PanHandler

func _ready():
	# Configura la posición inicial de la cámara y apunta al punto de enfoque
	update_camera_position()
	last_camera_position = transform.origin
	last_focus_point = focus_point

	# Asignamos el PanHandler y configuramos la referencia de la cámara
	pan_handler = $PanHandler
	pan_handler.set_camera(self)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Activar órbita "girar la cabeza" y guardar la posición actual
			is_head_orbiting = event.pressed
			if event.pressed:
				head_rotation = Vector2(rotation_degrees.y, -rotation_degrees.x) * PI / 180
				last_camera_position = transform.origin
		elif event.button_index == MOUSE_BUTTON_MIDDLE and Input.is_key_pressed(KEY_SHIFT):
			# Activar paneo (Shift + botón central)
			is_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			# Activar órbita alrededor del punto de enfoque y guardar la posición
			is_orbiting = event.pressed
			if event.pressed:
				camera_rotation = Vector2(rotation_degrees.y, -rotation_degrees.x) * PI / 180
				last_focus_point = focus_point

	if event is InputEventMouseMotion:
		if is_panning:
			# Llama al PanHandler para ejecutar el paneo
			pan_handler.pan_camera(event.relative)
		elif is_orbiting:
			# Órbita alrededor del punto de enfoque
			var mouse_mov = event.relative * orbit_sensitivity
			camera_rotation.x -= mouse_mov.x
			camera_rotation.y -= mouse_mov.y
			camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.5)
			update_camera_position()
		elif is_head_orbiting:
			# Girar la "cabeza" desde el centro de la cámara
			var mouse_mov = event.relative * orbit_sensitivity
			head_rotation.x -= mouse_mov.x
			head_rotation.y += mouse_mov.y
			head_rotation.y = clamp(head_rotation.y, -1.5, 1.5)
			update_head_rotation()

func _process(delta):
	# Zoom con la rueda del ratón
	if Input.is_action_just_pressed("ui_scroll_up"):
		distance -= zoom_sensitivity * delta
		update_camera_position()
	elif Input.is_action_just_pressed("ui_scroll_down"):
		distance += zoom_sensitivity * delta
		update_camera_position()

func update_camera_position():
	# Calcula la posición de la cámara en función del punto de enfoque y la rotación
	var offset = Vector3(0, 0, distance).rotated(Vector3.RIGHT, camera_rotation.y).rotated(Vector3.UP, camera_rotation.x)
	transform.origin = focus_point + offset
	look_at(focus_point)

func update_head_rotation():
	# Ajusta la rotación para girar la "cabeza" desde el centro de la cámara
	rotation_degrees.x = -head_rotation.y * 180 / PI
	rotation_degrees.y = head_rotation.x * 180 / PI
	transform.origin = last_camera_position
