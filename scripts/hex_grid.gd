extends Node3D

const Conversion = preload("res://scripts/utils/conversion.gd")
const PriorityQueue = preload("res://scripts/dtos/priority_queue.gd")
const Finder = preload("res://scripts/utils/finder.gd")

const TILE_SIZE := 2.0
const HEX_TILE = preload("res://scenes/hex_tile.tscn")

@export var grid_size := 30

var tile_map: Dictionary = {}

#Teste da função A*
func _ready() -> void:
	_generate_grid()
	var path = Finder.build_path(Vector2i(15, 20), Vector2i(5, 10), tile_map)
	for tile_pos in path:
		var tile = tile_map.get(tile_pos)
		if tile:
			tile.change_size()

func _generate_grid():
	for x in range(grid_size):
		var tile_coordinates := Vector2.ZERO
		tile_coordinates.x = x * TILE_SIZE * cos(deg_to_rad(30))
		tile_coordinates.y = 0 if x % 2 == 0 else TILE_SIZE / 2
		for y in range(grid_size):
			var tile = HEX_TILE.instantiate()
			add_child(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_map[Vector2i(x, y)] = tile
			tile_coordinates.y += TILE_SIZE
