extends Node3D

# Variables para el control del arrastre
var is_dragging = false
var initial_mouse_pos : Vector3
var initial_obj_pos : Vector3

# Detecta el clic inicial sobre el objeto
func _on_area_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = true
			initial_mouse_pos = calculate_mouse_position()
			initial_obj_pos = global_transform.origin
			print("Dragging started")
			print("Initial mouse position: ", initial_mouse_pos)
			print("Initial object position: ", initial_obj_pos)

# Detecta el movimiento mientras se arrastra el objeto
func _unhandled_input(event):
	if is_dragging and event is InputEventMouseMotion:
		var current_mouse_pos = calculate_mouse_position()
		var delta_pos_x = current_mouse_pos.x - initial_mouse_pos.x
		var delta_pos_z = current_mouse_pos.z - initial_mouse_pos.z
		global_transform.origin.x = initial_obj_pos.x + delta_pos_x
		global_transform.origin.z = initial_obj_pos.z + delta_pos_z
		print("Current mouse position: ", current_mouse_pos)
		print("Delta position X: ", delta_pos_x, ", Z: ", delta_pos_z)
		print("New object position: ", global_transform.origin)

	# Finaliza el arrastre al soltar el botón
	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = false
			print("Dragging stopped")

# Calcula la posición del ratón en el plano del objeto
func calculate_mouse_position() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var ray_origin = camera.project_ray_origin(get_viewport().get_mouse_position())
	var ray_direction = camera.project_ray_normal(get_viewport().get_mouse_position())
	
	# Definir un plano horizontal en Y = 0 para calcular la intersección
	var plane_normal = Vector3.UP
	var plane_point = global_transform.origin
	
	# Cálculo de la intersección del rayo con el plano
	var denom = plane_normal.dot(ray_direction)
	if abs(denom) > 0.0001:
		var difference = plane_point - ray_origin
		var t = difference.dot(plane_normal) / denom
		if t > 0:
			var intersection = ray_origin + ray_direction * t
			return intersection
	
	# Si no hay intersección, devolver la posición actual del objeto
	return global_transform.origin
