extends StaticBody3D

const HEX_GRID = preload("res://scripts/hex_grid.gd")
const FINDER = preload("res://scripts/utils/finder.gd")
const UNIT = preload("res://scripts/entity/entity.gd")
const ENEMY = preload("res://scenes/enemies.tscn")
const TEAM = preload("res://scripts/enums/teams.gd")

@onready var area := $"."
var num_players: int
var num_enemies: int

static var first_clicked_tile: StaticBody3D = null

var x: int
var y: int
var body: CharacterBody3D = null

static var last_x: int = -1
static var last_y: int = -1

static var player_count := 0
static var enemy_count := 0

func can_be_used_in_path() -> bool:
	if body == null:
		return true
	
	if first_clicked_tile == null:
		return true
		
	if first_clicked_tile.body == null:
		return true
	
	if body.team == first_clicked_tile.body.team:
		return true
	
	return false

func fill(x: int, y: int, team: TEAM.Teams) -> void:
	self.x = x
	self.y = y
	if team != TEAM.Teams.Empty:
		_spawn_unit(team)

func _spawn_unit(team: TEAM.Teams):
	body = UNIT.default(team)
	add_child(body)
	await body.ready
	look_at_closest_enemy()

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
	first_clicked_tile.look_at_closest_enemy()
	first_clicked_tile.body.attack() 
	await get_tree().create_timer(0.5).timeout
	var has_died = body.take_damage(body.stats.strength)
	if has_died:
		body.die()
		await get_tree().create_timer(1).timeout
		remove_child(body)
		body = null
		
		check_victory_conditions()
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

func look_at_closest_enemy():
	if body == null:
		return
	
	var closest_tile: StaticBody3D = null
	var closest_dist := INF
	
	for tile in HEX_GRID.tile_map.values():
		if tile == self or tile.body == null:
			continue
		
		if tile.body.team != body.team:
			var dist := Vector2(x, y).distance_to(Vector2(tile.x, tile.y))
			if dist < closest_dist:
				closest_dist = dist
				closest_tile = tile
	
	if closest_tile != null:
		var target_pos = closest_tile.global_transform.origin
		body.look_at_target(target_pos)

func reset_counts():
	player_count = 0
	enemy_count = 0

func check_victory_conditions():
	var has_player := false
	var has_enemy := false
	
	for tile in HEX_GRID.tile_map.values():
		if tile.body == null:
			continue
		if tile.body.team == TEAM.Teams.Player:
			has_player = true
		elif tile.body.team == TEAM.Teams.Enemy:
			has_enemy = true
	
	if not has_enemy:
		show_victory_screen()
	elif not has_player:
		show_defeat_screen()

func show_victory_screen():
	var hex_grid = get_tree().root.get_node("Board/HexGrid")
	var ui = get_tree().root.get_node("Board/VictoryDefeatUI")
	ui.call("show_victory", func(): hex_grid.next_round())

func show_defeat_screen():
	var ui = get_tree().root.get_node("Board/VictoryDefeatUI")
	ui.call("show_defeat")
