extends Node3D

@onready var selected_label: Label = $"../CanvasLayer/Control/SelectedLabel"
var selected_obj: Node3D = null
var camera: Camera3D = null  # Variable para almacenar la cámara

func _ready():
	# Inicialmente ocultar el `Label`
	selected_label.visible = false
	# Detectar la cámara en la escena
	camera = get_viewport().get_camera_3d()
	if camera == null:
		printerr("No se encontró una cámara 3D en la escena.")
	else:
		print("Cámara detectada:", camera)

func _unhandled_input(event):
	# Detectar clic izquierdo del mouse
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_object()

func _select_object():
	if camera == null:
		return  # Salir si no se ha encontrado una cámara

	# Obtener la posición del mouse en la pantalla
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000

	# Realizar la intersección del rayo en el mundo 3D ignorando la cámara
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [camera]  # Excluir la cámara del raycast
	var result = space_state.intersect_ray(query)

	# Validar si se ha hecho clic en algún objeto
	if result and result.collider is Node3D:
		selected_obj = result.collider
		print("Seleccionado:", selected_obj.get_name())
		_update_selected_label(selected_obj.get_name(), selected_obj.global_transform.origin)
	else:
		selected_obj = null
		_hide_selected_label()
		
func _update_selected_label(object_name: String, obj_position: Vector3):
	selected_label.text = "Seleccionado: " + object_name
	selected_label.visible = true

	# Convertir la posición 3D a coordenadas de pantalla y ajustar la etiqueta
	var screen_pos = camera.unproject_position(obj_position)
	selected_label.position = screen_pos - selected_label.get_rect().size * 0.5  # Centra el label

func _hide_selected_label():
	selected_label.visible = false
