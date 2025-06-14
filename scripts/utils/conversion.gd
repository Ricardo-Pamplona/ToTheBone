extends Node

const CUBE_DIRECTIONS = [
	Vector3(1, -1, 0), Vector3(1, 0, -1), Vector3(0, 1, -1),
	Vector3(-1, 1, 0), Vector3(-1, 0, 1), Vector3(0, -1, 1)
]

static func offset_to_cube(x: int, y: int) -> Vector3:
	var col = x
	var row = y - (x - (x & 1)) / 2
	var z = -col - row
	return Vector3(col, row, z)

static func cube_to_offset(cube: Vector3) -> Vector2i:
	var x = int(cube.x)
	var y = int(cube.y + (cube.x - (int(cube.x) & 1)) / 2)
	return Vector2i(x, y)

static func hex_neighbors(cube: Vector3) -> Array:
	var neighbors := []
	for dir in CUBE_DIRECTIONS:
		neighbors.append(cube + dir)
	return neighbors

static func heuristic(a: Vector3, b: Vector3) -> float:
	return max(abs(a.x - b.x), abs(a.y - b.y), abs(a.z - b.z))
