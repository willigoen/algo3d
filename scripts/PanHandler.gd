extends Node

@export var pan_sensitivity: float = 0.05
var camera: Camera3D = null  # Referencia a la cámara principal

# Configura la referencia a la cámara desde el script de la cámara
func set_camera(cam):
	camera = cam

# Ejecuta el paneo de la cámara
func pan_camera(mouse_movement: Vector2):
	if camera == null:
		return
	# Calcula el movimiento de paneo en el espacio de la cámara
	var pan_offset = -camera.transform.basis.x * mouse_movement.x * pan_sensitivity + camera.transform.basis.y * mouse_movement.y * pan_sensitivity
	camera.focus_point += pan_offset
	camera.update_camera_position()  # Asegura que se actualice la posición
