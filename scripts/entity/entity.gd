extends CharacterBody3D


const TEAM = preload("res://scripts/enums/teams.gd")

const ENEMY_STATS_MAP = {
	"Archer": preload("res://resources/enemies/archer.tres"),
	"Barbarian": preload("res://resources/enemies/barbarian.tres"),
	"Mage": preload("res://resources/enemies/mage.tres"),
	"Warrior": preload("res://resources/enemies/warrior.tres") 
}

const UNIT_STATS_MAP = {
	"Mage": preload("res://resources/unit/S_Mage.tres"),
	"Minion": preload("res://resources/unit/S_Minion.tres"),
	"Rogue": preload("res://resources/unit/S_Rogue.tres"),
	"Warrior": preload("res://resources/unit/S_Warrior.tres") 
}

var asset_type: String
@export var stats: EnemyStats = EnemyStats.new()
@export var team: TEAM.Teams

var current_model: Node3D
@onready var model_root := $ModelRoot
@onready var animation_player: AnimationPlayer = null

static func default(team: TEAM.Teams) -> CharacterBody3D:
	var character_scene = preload("res://scenes/entity.tscn")  
	var unit := character_scene.instantiate()
	
	if team == TEAM.Teams.Player:
		unit.asset_type = "Minion"
		unit.stats = UNIT_STATS_MAP.get(unit.asset_type, null).duplicate()

	else:
		var keys = ENEMY_STATS_MAP.keys()
		unit.asset_type = keys[randi() % keys.size()]
		unit.stats = ENEMY_STATS_MAP.get(unit.asset_type, null).duplicate()

	unit.team = team
	return unit

func _ready():
	current_model = load_model()
	if current_model:
		model_root.add_child(current_model)
		animation_player = current_model.get_node_or_null("AnimationPlayer")
		if not animation_player:
			push_warning("No AnimationPlayer found on model")
	animation_player.animation_finished.connect(_on_animation_finished)
	idle()

func load_model() -> Node3D:
	if stats and stats.model:
		return stats.model.instantiate()
	else:
		push_warning("Nenhum modelo encontrado no EnemyStats.")
		return null

func take_damage(damage: int) -> bool:
	if damage >= stats.health:
		return true
	stats.health -= damage
	return false
	
func die():
	animation_player.play("Death_A")

func hit():
	animation_player.play("Hit_A")

func idle():
	animation_player.play("Idle")

func _on_animation_finished(anim_name):
	if anim_name != "idle":
		idle()

func attack():
	animation_player.play("1H_Melee_Attack_Stab")

func look_at_target(target_position: Vector3):
	look_at_from_position(global_transform.origin, target_position, Vector3.UP)
	rotation.y += PI
	rotation.x = 0
	rotation.z = 0
