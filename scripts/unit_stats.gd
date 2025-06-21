extends Resource
class_name UnitStats

static func default() -> UnitStats:
	var stats := UnitStats.new()
	
	stats.health = 10
	stats.strength = 5 
	stats.speed = 5
	stats.level = 5
	stats.sword_m = 1
	stats.bow_m = 1
	stats.unarmed_m = 1
	stats.axe_m = 1
	stats.staff_m = 1
	stats.health_m = 1
	stats.strength_m = 1
	stats.speed_m = 1
	stats.xp_m = 1

	return stats

#stats
@export var health : int
@export var strength : int
@export var speed : int
@export var level : int

#weapon masteries
@export var sword_m : int
@export var bow_m : int
@export var unarmed_m : int
@export var axe_m : int
@export var staff_m : int

#stats multipliers
@export var health_m: int
@export var strength_m: int
@export var speed_m: int
@export var xp_m: int
