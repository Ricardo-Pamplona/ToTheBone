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
		var result = get_closest_enemy_hero_pair()
		var distance = result.distance
		if distance > 2:
			var limit = result.limit 
			
			if limit >= distance:
				limit = distance - 1
			
			move(result.enemy_pos.x, result.enemy_pos.y, result.hero_pos.x, result.hero_pos.y, limit)
		else:
			print(result)
			enemy_attacks_hero(tile_map.get(result.enemy_pos), tile_map.get(result.hero_pos))
	else:
		current_player = TEAM.Teams.Player

static func enemy_attacks_hero(enemy_tile, player_tile):
	enemy_tile.look_at_closest_enemy()
	var body = player_tile.body
	var has_died = body.take_damage(10000)
	if has_died:
		body.die()
		player_tile.remove_child(body)
		player_tile.body = null
		
		enemy_tile.check_victory_conditions()
	else:
		player_tile.body.hit()
		await player_tile.get_tree().create_timer(1).timeout

	change_player()
	erase()

static func move(x1: int, y1: int, x2: int, y2: int, limit: int) -> void:
	var path = FINDER.build_path(Vector2i(x1, y1), Vector2i(x2, y2), tile_map, limit)
	var index = path.get(0)
	
	if index == null:
		return	

	var origin_mob = tile_map.get(index)
	
	origin_mob.look_at_closest_enemy()
	
	var destination_mob = tile_map.get(path[path.size() - 1])

	var body = origin_mob.take()  
	destination_mob.give(body)
	
	change_player()

static func get_closest_enemy_hero_pair() -> Dictionary:
	var best_enemy_pos: Vector2i
	var best_hero_pos: Vector2i
	var shortest_path_length := INF
	var limit: int
	
	for enemy_tile_pos in tile_map:
		var enemy_tile = tile_map[enemy_tile_pos]

		if enemy_tile.body == null or enemy_tile.body.team != TEAM.Teams.Enemy:
			continue

		limit = enemy_tile.body.stats.speed

		for hero_tile_pos in tile_map:
			var hero_tile = tile_map[hero_tile_pos]

			if hero_tile.body == null or hero_tile.body.team != TEAM.Teams.Player:
				continue

			var path = FINDER.build_path(enemy_tile_pos, hero_tile_pos, tile_map, limit)
			if path.size() > 0 and path.size() < shortest_path_length:
				shortest_path_length = path.size()
				best_enemy_pos = enemy_tile_pos
				best_hero_pos = hero_tile_pos

	return {
		"enemy_pos": best_enemy_pos,
		"hero_pos": best_hero_pos,
		"distance": shortest_path_length,
		"limit": limit
	}

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
	current_player = TEAM.Teams.Player
	EVENT_HANDLER.player_count = 0
	EVENT_HANDLER.enemy_count = 0
	
	for tile in tile_map.values():
		tile.num_players = num_players
		tile.num_enemies = num_enemies
		if tile.body:
			tile.remove_child(tile.body)
			tile.body.queue_free()
			tile.body = null
	
	var players_to_spawn = num_players
	var enemies_to_spawn = num_enemies
	var spawned = 0
	for tile in tile_map.values():
		if players_to_spawn == 0 and enemies_to_spawn == 0:
			break
		elif tile.x % 10 == 0 and tile.y % 10 == 0:
			if players_to_spawn > 0:
				players_to_spawn -= spawn_groups(tile, TEAM.Teams.Player, players_to_spawn)
			elif enemies_to_spawn > 0:
				enemies_to_spawn -= spawn_groups(tile, TEAM.Teams.Enemy, enemies_to_spawn)
	
func spawn_groups(tile, team, amount) -> int:
	tile.fill(tile.x, tile.y, team)
	var spawned = 1
	if spawned == amount:
		return spawned
	
	var neighbors = get_neighbors(tile.x, tile.y)
	neighbors.shuffle()
	for neighbor in neighbors:
		if spawned == amount:
			return spawned
		var tile_neighbor = tile_map.get(neighbor)
		if tile_neighbor != null and tile_neighbor.body == null:
			tile_neighbor.fill(tile_neighbor.x, tile_neighbor.y, team)
			spawned += 1
	
	return spawned

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
			tile.fill(x, y, TEAM.Teams.Empty)
			add_child(tile)
			tile.translate(Vector3(tile_coordinates.x, 0, tile_coordinates.y))
			tile_map[Vector2i(x, y)] = tile
			tile_coordinates.y += TILE_SIZE

func get_neighbors(x: int, y: int) -> Array:
	var directions: Array

	if x % 2 == 0:
		directions = [
			Vector2i(+1,  0),   
			Vector2i( 0, -1),   
			Vector2i(-1, -1),   
			Vector2i(-1,  0),   
			Vector2i(-1, +1),   
			Vector2i( 0, +1),   
		]
	else:
		directions = [
			Vector2i(+1,  0),   
			Vector2i(+1, -1),   
			Vector2i( 0, -1),   
			Vector2i(-1,  0),   
			Vector2i(+1, +1),   
			Vector2i( 0, +1),   
		]

	var neighbors: Array = []
	for offset in directions:
		var nx = x + offset.x
		var ny = y + offset.y
		neighbors.append(Vector2i(nx, ny))
	return neighbors
