extends Node3D

@export var pan_sensitivity: float = 0.01
@onready var CameraGimbal: Node3D = self  # Referencia a la cámara principal


func _process(_delta):
	print(CameraGimbal.position)
	pass

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pan_camera(event)


# Ejecuta el paneo de la cámara
func pan_camera(event):
	if CameraGimbal == null:
		return
	# Verifica si el botón izquierdo del ratón está presionado
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			# Obtiene el movimiento del ratón
			var pan_offset = Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity

			# Actualiza la posición del gimbal de la cámara
			CameraGimbal.translate(pan_offset)
