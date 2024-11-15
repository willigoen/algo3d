extends Node3D

@onready var handlers_color_manager = get_node("ColorChanger")

# Variables para el control de los manejadores de los ejes
@onready var handlers: Array = [$X_Handle_mesh, $Y_Handle_mesh, $Z_Handle_mesh]
@onready var handlers_area3D: Array = [$X_Handle_mesh/Area3D_X, $Y_Handle_mesh/Area3D_Y, $Z_Handle_mesh/Area3D_Z]

var is_x_handler : bool = false
var is_y_handler : bool = false
var is_z_handler : bool = false

# Variables para el control del arrastre
var is_dragging = false
var initial_mouse_pos : Vector3
var initial_obj_pos : Vector3

func calculate_mouse_screen_position():
	is_dragging = true
	initial_mouse_pos = calculate_mouse_position()
	initial_obj_pos = global_transform.origin
	#print("Dragging started")
	#print("Initial mouse position: ", initial_mouse_pos)
	#print("Initial object position: ", initial_obj_pos)

# Detecta el clic inicial sobre el objeto
func _on_area_3d_x_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_x_handler = true
			calculate_mouse_screen_position()

func _on_area_3d_y_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_y_handler = true
			calculate_mouse_screen_position()

func _on_area_3d_z_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_z_handler = true
			calculate_mouse_screen_position()

# Detecta el movimiento mientras se arrastra el objeto
func _unhandled_input(event):
	if is_dragging and event is InputEventMouseMotion:
		var delta_pos_x = 0
		var delta_pos_y = 0
		var delta_pos_z = 0
		
		var current_mouse_pos = calculate_mouse_position()
		if is_x_handler:
			delta_pos_x = current_mouse_pos.x - initial_mouse_pos.x
			global_transform.origin.x = initial_obj_pos.x + delta_pos_x
		elif is_y_handler:
			delta_pos_y = current_mouse_pos.y - initial_mouse_pos.y
			global_transform.origin.y = initial_obj_pos.y + delta_pos_y
		elif is_z_handler:
			delta_pos_z = current_mouse_pos.z - initial_mouse_pos.z
			global_transform.origin.z = initial_obj_pos.z + delta_pos_z
		
		#print("Current mouse position: ", current_mouse_pos)
		#print("Delta position X: ", delta_pos_x, ", Y: ", delta_pos_y, ", Z: ", delta_pos_z)
		#print("New object position: ", global_transform.origin)

	# Finaliza el arrastre al soltar el botón
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			is_x_handler = false
			is_y_handler = false
			is_z_handler = false
			handlers_color_manager.emit_signal("set_handler_state_disabled")
			#print("Dragging stopped")


# Calcula la posición del ratón en el plano del objeto según el eje seleccionado
func calculate_mouse_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position())
	
	var plane_normal = Vector3.ZERO
	var plane_point = global_transform.origin

	# Definir el plano en función del eje seleccionado
	if is_x_handler:
		plane_normal = Vector3(0, 1, 0)  # Plano horizontal XZ
	elif is_y_handler:
		plane_normal = Vector3(1, 0, 0)  # Plano vertical YZ
	elif is_z_handler:
		plane_normal = Vector3(0, 1, 0)  # Plano horizontal XZ
	
	# Cálculo de la intersección del rayo con el plano
	var denom = plane_normal.dot(ray_direction)
	if abs(denom) > 0.0001:
		var difference = plane_point - ray_origin
		var t = difference.dot(plane_normal) / denom
		if t > 0:
			var intersection = ray_origin + ray_direction * t
			return intersection
	
	return global_transform.origin
