extends StaticBody3D

const SCALE_FACTOR := 0.5
var is_scaled_down := false

@onready var area := $"."
@onready var big := $big

static var first_clicked_tile: StaticBody3D = null
static var affected_tiles: Array = []

func _ready():
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if first_clicked_tile == null:
			first_clicked_tile = self
		else:
			for tile in affected_tiles:
				if is_instance_valid(tile):
					tile.change_size()
			affected_tiles.clear()
			first_clicked_tile = null
		change_size()
#
func change_size():
	big.visible = not big.visible
	
func _on_mouse_entered():
	if first_clicked_tile != null and self != first_clicked_tile:
		big.visible = false
		if not affected_tiles.has(self):
			affected_tiles.append(self)

func _on_mouse_exited():
	if first_clicked_tile != null and self != first_clicked_tile:
		big.visible = true
