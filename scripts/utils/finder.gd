extends Node

const Conversion = preload("res://scripts/utils/conversion.gd")
const PriorityQueue = preload("res://scripts/dtos/priority_queue.gd")

static func are_neighbors(x1: int, y1: int, x2: int, y2: int) -> bool:
	var cube1 = Conversion.offset_to_cube(x1, y1)
	var cube2 = Conversion.offset_to_cube(x2, y2)
	
	var dx = abs(cube1.x - cube2.x)
	var dy = abs(cube1.y - cube2.y)
	var dz = abs(cube1.z - cube2.z)

	return dx + dy + dz == 2

static func build_path(start: Vector2i, goal: Vector2i, tile_map: Dictionary, limit: int) -> Array:
	var start_cube = Conversion.offset_to_cube(start.x, start.y)
	var goal_cube = Conversion.offset_to_cube(goal.x, goal.y)

	var frontier := PriorityQueue.PriorityQueue.new()
	frontier.push(start_cube, 0)

	var came_from = {}
	var cost_so_far = {}
	came_from[start_cube] = null
	cost_so_far[start_cube] = 0

	while not frontier.is_empty():
		var current = frontier.pop()

		if current == goal_cube:
			break

		for next_cube in Conversion.hex_neighbors(current):
			var next_offset = Conversion.cube_to_offset(next_cube)

			if not tile_map.has(next_offset):
				continue

			var tile = tile_map[next_offset]
			if not tile.can_be_used_in_path():
				continue

			var new_cost = cost_so_far[current] + 1
			if not cost_so_far.has(next_cube) or new_cost < cost_so_far[next_cube]:
				cost_so_far[next_cube] = new_cost
				var priority = new_cost + Conversion.heuristic(goal_cube, next_cube)
				frontier.push(next_cube, priority)
				came_from[next_cube] = current

	var path := []
	var current = goal_cube
	while current != null and came_from.has(current):
		path.append(Conversion.cube_to_offset(current))
		current = came_from.get(current)

	path.reverse()
	return path.slice(0, limit)
