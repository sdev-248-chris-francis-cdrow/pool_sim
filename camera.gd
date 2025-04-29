extends Node3D

@export var camera: Camera3D
@export var target: Vector3 = Vector3.ZERO
@export var distance := 10.0
@export var min_zoom: float = 0
@export var max_zoom: float = 200.0

var rotation_x := 0.0
var rotation_y := -30.0  # Slight downward angle

func _ready():
	if not camera:
		camera = $OrbitCamera
	_update_camera_transform()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		rotation_x -= event.relative.x * 0.01
		rotation_y = clamp(rotation_y - event.relative.y * 0.01, deg_to_rad(-89), deg_to_rad(89))
		_update_camera_transform()

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(min_zoom, distance - 0.5)
			_update_camera_transform()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(max_zoom, distance + 0.5)
			_update_camera_transform()

func _update_camera_transform():
	var dir = Vector3(
		cos(rotation_y) * sin(rotation_x),
		sin(rotation_y),
		cos(rotation_y) * cos(rotation_x)
	)
	var camera_position = target + dir * distance
	camera.global_transform.origin = camera_position
	camera.look_at(target, Vector3.UP)
