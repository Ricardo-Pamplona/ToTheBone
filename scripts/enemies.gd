extends CharacterBody3D

@export var enemy_stats : Resource

func build(model: PackedScene, health: float, strength: float, speed: int, range: float):
	enemy_stats.model = model
	enemy_stats.health = health
	enemy_stats.strength = strength
	enemy_stats.speed = speed
	enemy_stats.range = range
