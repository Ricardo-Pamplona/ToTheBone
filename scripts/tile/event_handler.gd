extends StaticBody3D

const HEX_GRID = preload("res://scripts/hex_grid.gd")
const FINDER = preload("res://scripts/utils/finder.gd")
#const UNIT = preload("res://scripts/unit.gd")
const UNIT = preload("res://scripts/entity/entity.gd")
const ENEMY = preload("res://scenes/enemies.tscn")
const TEAM = preload("res://scripts/enums/teams.gd")

@onready var area := $"."

static var first_clicked_tile: StaticBody3D = null

var x: int
var y: int
var body: CharacterBody3D = null

static var last_x: int = -1
static var last_y: int = -1

static var i: int = 1 

func can_be_used_in_path() -> bool:
	if body == null:
		return true
	
	if body.team == first_clicked_tile.body.team:
		return true
	
	return false

func fill(x: int, y: int, body: bool) -> void:
	self.x = x
	self.y = y
	if body:
		if i % 2 == 0:
			_spawn_unit(TEAM.Teams.Player)
		else:
			_spawn_unit(TEAM.Teams.Enemy)
		i += 1

func _spawn_unit(team: TEAM.Teams):
	body = UNIT.default(team)
	add_child(body)

func _ready():
	area.connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	area.connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if first_clicked_tile == null and body != null and body.team == HEX_GRID.current_player:
			start()
		elif first_clicked_tile != null and first_clicked_tile.body != null:
			finish()
	
	elif first_clicked_tile != null and (last_y != y or last_x != x):
		draw()

func start():
	first_clicked_tile = self
	self.smaller()
	
func finish():
	if body == null:
		move() 
	elif body.team != HEX_GRID.current_player and FINDER.are_neighbors(first_clicked_tile.x, first_clicked_tile.y, last_x, last_y):
		attack()

func attack():
	var has_died = body.take_damage(body.stats.strength)
	if has_died:
		body.die()
		await get_tree().create_timer(1).timeout
		remove_child(body)
		body = null
	else:
		body.hit()
		await get_tree().create_timer(0.5).timeout

	HEX_GRID.change_player()
	first_clicked_tile = null
	self.bigger()
	HEX_GRID.erase()
	last_x = -1
	last_y = -1

func move():
	HEX_GRID.move(
		first_clicked_tile.x, 
		first_clicked_tile.y, 
		last_x, 
		last_y, 
		first_clicked_tile.body.stats.speed
	)
	first_clicked_tile = null
	self.bigger()
	HEX_GRID.erase()
	last_x = -1
	last_y = -1

func draw():
	last_x = x 
	last_y = y
	
	HEX_GRID.draw(
		first_clicked_tile.x, 
		first_clicked_tile.y, 
		last_x, 
		last_y, 
		first_clicked_tile.body.stats.speed
	)
	
func smaller():
	scale = Vector3.ONE * 0.5
	
func bigger():
	scale = Vector3.ONE * 1

func give(body: CharacterBody3D) -> void:
	self.body = body
	add_child(body)
	
func take() -> CharacterBody3D:
	var b := body
	remove_child(b)
	body = null
	return b
