extends Node

const Conversion = preload("res://scripts/utils/conversion.gd")
const PriorityQueue = preload("res://scripts/dtos/priority_queue.gd")

static func build_path(start: Vector2i, goal: Vector2i, tile_map: Dictionary) -> Array:
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

			var new_cost = cost_so_far[current] + 1  
			if not cost_so_far.has(next_cube) or new_cost < cost_so_far[next_cube]:
				cost_so_far[next_cube] = new_cost
				var priority = new_cost + Conversion.heuristic(goal_cube, next_cube)
				frontier.push(next_cube, priority)
				came_from[next_cube] = current

	var path := []
	var current = goal_cube
	while current != null:
		path.append(Conversion.cube_to_offset(current))
		current = came_from.get(current)
	path.reverse()
	return path
