extends Node3D

const FINDER = preload("res://scripts/utils/finder.gd")
const TILE_SIZE := 2.0
const HEX_TILE = preload("res://scenes/hex_tile.tscn")
const ENEMY = preload("res://scenes/enemies.tscn")
const TEAM = preload("res://scripts/enums/teams.gd")
const EVENT_HANDLER = preload("res://scripts/tile/event_handler.gd")


@export var grid_size := 30
@export var num_players: int = 1
@export var num_enemies: int = 1
var round : int = 1


static var current_player: TEAM.Teams = TEAM.Teams.Player 
static var tile_map: Dictionary = {}
static var path: Array = []

func _ready() -> void:
	_generate_grid()
	start_round()
	randomize()

static func change_player():
	if current_player == TEAM.Teams.Player:
		current_player = TEAM.Teams.Enemy
		print("ENEMY's Turn")
	else:
		current_player = TEAM.Teams.Player
		print("PLAYER's Turn")

static func move(x1: int, y1: int, x2: int, y2: int, limit: int) -> void:
	var path = FINDER.build_path(Vector2i(x1, y1), Vector2i(x2, y2), tile_map, limit)

	var origin_mob = tile_map.get(path[0])
	var destination_mob = tile_map.get(path[path.size() - 1])

	var body = origin_mob.take()  
	destination_mob.give(body)
	
	change_player()

static func erase() -> void:
	for tile_pos in tile_map:
		var tile = tile_map.get(tile_pos)
		if tile:
			tile.bigger()


static func draw(x1: int, y1: int, x2: int, y2: int, limit: int) -> void:
	erase()
	path = FINDER.build_path(Vector2i(x1, y1), Vector2i(x2, y2), tile_map, limit)
	
	for tile_pos in path:
		var tile = tile_map.get(tile_pos)
		if tile:
			tile.smaller()

func start_round():
	EVENT_HANDLER.player_count = 0
	EVENT_HANDLER.enemy_count = 0
	
	for tile in tile_map.values():
		tile.num_players = num_players
		tile.num_enemies = num_enemies
		if tile.body:
			tile.remove_child(tile.body)
			tile.body.queue_free()
			tile.body = null
	
	var total_to_spawn = num_players + num_enemies
	var spawned = 0
	for tile in tile_map.values():
		if spawned >= total_to_spawn:
			break
		elif tile.x % 10 == 0 and tile.y % 10 == 0:
			tile.fill(tile.x, tile.y, true)
			spawned += 1

func next_round():
	round += 1
	num_players += 1            
	num_enemies = round 
	start_round()

func _generate_grid():
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg_to_rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			tile.fill(x, y, false)
			add_child(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_map[Vector2i(x, y)] = tile
			tile_coordinates.y += TILE_SIZE
