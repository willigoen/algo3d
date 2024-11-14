extends Node

@onready var handler_manager_script: Node = $".."

@onready var handlers: Array = [$"../X_Handle_mesh", $"../Y_Handle_mesh", $"../Z_Handle_mesh"]
@onready var handlers_area3D: Array = [$"../X_Handle_mesh/Area3D_X", $"../Y_Handle_mesh/Area3D_Y", $"../Z_Handle_mesh/Area3D_Z"]
@onready var handlers_materials: Array = []

# Colores para los manejadores de los ejes
var x_handler_color_deactivated : Color = Color.DARK_RED
var y_handler_color_deactivated : Color = Color.LIGHT_GREEN
var z_handler_color_deactivated : Color = Color.LIGHT_BLUE
var x_handler_color_activated : Color = Color.RED
var y_handler_color_activated : Color = Color.GREEN
var z_handler_color_activated : Color = Color.BLUE

func _ready() -> void:
	for handler in handlers:
		print(handler.name)
	for handler in handlers:
		print(handler.get_surface_override_material_count())
	for handler in handlers:
		var material = handler.get_active_material(0)
		handlers_materials.append(material)
		print(material)
	for mat in handlers_materials:
		mat.emission_energy_multiplier = 0.0
		print(mat)

func change_handler_state_enabled(_handler: int) -> void:
	for i in range(3):
		if i == _handler:
			handlers_materials[i].emission_energy_multiplier = 1.0
		else:
			handlers_materials[i].emission_energy_multiplier = 0.0

func change_handler_state_disabled() -> void:
	for mat in handlers_materials:
		mat.emission_energy_multiplier = 0.0

func _on_area_3d_x_mouse_entered() -> void:
	change_handler_state_enabled(0)
func _on_area_3d_y_mouse_entered() -> void:
	change_handler_state_enabled(1)
func _on_area_3d_z_mouse_entered() -> void:
	change_handler_state_enabled(2)

func _on_area_3d_x_mouse_exited() -> void:
	change_handler_state_disabled()
func _on_area_3d_z_mouse_exited() -> void:
	change_handler_state_disabled()
func _on_area_3d_y_mouse_exited() -> void:
	change_handler_state_disabled()
