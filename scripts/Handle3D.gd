# Handle3D.gd
extends Node3D

signal axis_selected(axis: Vector3)

@onready var x_handle = $X_Handle
@onready var y_handle = $Y_Handle
@onready var z_handle = $Z_Handle

func _ready():
	# Check that each handle is loaded correctly
	print("X_Handle:", x_handle)
	print("Y_Handle:", y_handle)
	print("Z_Handle:", z_handle)

	# If any handle is null, print an error message and return early
	if x_handle == null or y_handle == null or z_handle == null:
		printerr("One or more handles are not loaded. Check the paths in Handle3D.tscn.")
		return

	# Connect each handle's input event with the correct axis argument
	x_handle.connect("input_event", Callable(self, "_on_handle_input").bind(Vector3(1, 0, 0)))
	y_handle.connect("input_event", Callable(self, "_on_handle_input").bind(Vector3(0, 1, 0)))
	z_handle.connect("input_event", Callable(self, "_on_handle_input").bind(Vector3(0, 0, 1)))

func _on_handle_input(_camera, event, axis: Vector3, _extra_args):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("axis_selected", axis)
		print("Handle selected for axis:", axis)
