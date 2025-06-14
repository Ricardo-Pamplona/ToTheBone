extends CollisionShape3D

@onready var area := $"../../CollisionShape3D"
@onready var visual := $"../../hex_grass"

const SCALE_FACTOR := 0.5

func _ready():
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _on_mouse_entered():
	print("ENTERED")
	visual.scale = Vector3.ONE * SCALE_FACTOR

func _on_mouse_exited():
	print("EXITED")
	visual.scale = Vector3.ONE
