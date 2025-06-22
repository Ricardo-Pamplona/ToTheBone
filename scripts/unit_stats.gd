extends Resource
class_name UnitStats

static func default() -> UnitStats:
	var stats := UnitStats.new()
	
	stats.health = 10
	stats.strength = 5 
	stats.speed = 5

	return stats

#stats
@export var health : int
@export var strength : int
@export var speed : int
