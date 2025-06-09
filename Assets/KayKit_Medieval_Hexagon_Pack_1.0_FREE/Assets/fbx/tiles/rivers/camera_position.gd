extends Node3D

@onready var roation_x = $CameraRotation
@onready var zoom = $CameraRotation/CameraZoom
@onready var camera = $CameraRotation/CameraZoom/Camera3D

var move_speed : float = 0.6
var move_target : Vector3
var rotate_speed : float = 1.5
var rotate_target: float
var zoom_speed : float = 3.0
var zoom_target : float
var min_zoom : float = -20.0
var max_zoom : float = 20.0
var mouse_sens : float = 0.2


func _ready() -> void:
	move_target = position
	rotate_target = rotation_degrees.y
	zoom_target = camera.position.z
	
	camera.look_at(position)
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.is_action_just_pressed("rotate_mouse"):
		rotate_target -= event.relative.x * mouse_sens
		roation_x.rotation_degrees.x -= event.relative.x * mouse_sens
		roation_x.rotation_degrees.x = clamp(roation_x.rota.x, -10, 30)
		
func _process(delta: float) -> void:
	var input_dir = Input.get_vector("left","right","up","down")
	var movement_direction  = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var rotate_keys = Input.get_axis("rotate_left","rotate_right")
	var zoom_dir = (int(Input.is_action_just_released("zoom_out")) - int(Input.is_action_just_released("zoom_in")))
	
	move_target += move_speed * movement_direction
	rotate_target += rotate_keys * rotate_speed
	zoom_target += zoom_speed * zoom_dir
	
	position = lerp(position, move_target, 0.1)
	rotation_degrees.y = lerp(rotation_degrees.y, rotate_target, 0.1)
	camera.position.z = lerp(camera.position.z, zoom_target, 0.1)
