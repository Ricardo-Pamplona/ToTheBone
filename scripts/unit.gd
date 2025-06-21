extends CharacterBody3D

const UNIT = preload("res://scenes/unit.tscn")
const TEAM = preload("res://scripts/enums/teams.gd")

@onready var animation_player : AnimationPlayer = $unit/AnimationPlayer
@export var stats: UnitStats = UnitStats.new()
@export var team: TEAM.Teams

static func default(team: TEAM.Teams) -> CharacterBody3D:
	var unit := UNIT.instantiate()
	unit.stats = UnitStats.default()
	unit.team = team
	return unit

func take_damage(damage: int) -> bool:
	if damage >= stats.health:
		return true
	stats.health -= damage 
	return false
