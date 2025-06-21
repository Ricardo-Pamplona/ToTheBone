extends Node3D

const FINDER = preload("res://scripts/utils/finder.gd")
const TILE_SIZE := 2.0
const HEX_TILE = preload("res://scenes/hex_tile.tscn")
const ENEMY = preload("res://scenes/enemies.tscn")
const TEAM = preload("res://scripts/enums/teams.gd")

@export var grid_size := 30

static var current_player: TEAM.Teams = TEAM.Teams.Player 
static var tile_map: Dictionary = {}
static var path: Array = []

func _ready() -> void:
	_generate_grid()

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

func _generate_grid():
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg_to_rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			tile.fill(x, y, x % 10 == 0 and y % 10 == 0)
			add_child(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_map[Vector2i(x, y)] = tile
			tile_coordinates.y += TILE_SIZE
