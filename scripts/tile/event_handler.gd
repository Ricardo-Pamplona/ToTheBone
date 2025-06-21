extends StaticBody3D

const HEX_GRID = preload("res://scripts/hex_grid.gd")
const FINDER = preload("res://scripts/utils/finder.gd")
const UNIT = preload("res://scenes/unit.tscn")
const ENEMY = preload("res://scenes/enemies.tscn")

@onready var area := $"."
@export var possible_tiles : Array[tile_data]

static var first_clicked_tile: StaticBody3D = null

var x: int
var y: int
var body: CharacterBody3D = null
var _data: tile_data = null

static var last_x: int = -1
static var last_y: int = -1

func fill(x: int, y: int, body: bool) -> void:
	self.x = x
	self.y = y
	if body:
		_spawn_unit()

func _spawn_unit():
	body = UNIT.instantiate()
	add_child(body)
	

func _ready():
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if first_clicked_tile == null and body != null:
			start()
		elif first_clicked_tile != null and first_clicked_tile.body != null and self.body == null:
			finish()
	
	elif first_clicked_tile != null and (last_y != y or last_x != x):
		draw()

func start():
	first_clicked_tile = self
	self.smaller()
	
func finish():
	self.body = first_clicked_tile.body
	first_clicked_tile.remove_unit_from_tile()
	first_clicked_tile.body = null
	add_child(body)
	first_clicked_tile = null
	self.bigger()
	HEX_GRID.erase()
	last_x = -1
	last_y = -1

func draw():
	HEX_GRID.draw(first_clicked_tile.x, first_clicked_tile.y, last_x, last_y)
	last_x = x 
	last_y = y
	self.smaller()
	
func smaller():
	scale = Vector3.ONE * 0.5
	
func bigger():
	scale = Vector3.ONE * 1

func remove_unit_from_tile():
	if body:
		remove_child(body)
