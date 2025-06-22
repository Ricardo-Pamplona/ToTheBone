extends CharacterBody3D

const TEAM = preload("res://scripts/enums/teams.gd")

@export_enum("Mage", "Warrior", "Rogue") var asset_type: String = "Mage"
@export var stats: UnitStats = UnitStats.new()
@export var team: TEAM.Teams

var current_model: Node3D
@onready var model_root := $ModelRoot
@onready var animation_player: AnimationPlayer = null

static func default(team: TEAM.Teams) -> CharacterBody3D:
	var character_scene = preload("res://scenes/entity.tscn")  
	var unit := character_scene.instantiate()
	unit.stats = UnitStats.default()
	unit.team = team
	if team == TEAM.Teams.Player:
		unit.asset_type = "Rogue"
	else:
		unit.asset_type = "Mage"
	return unit

func _ready():
	current_model = load_model(asset_type)
	if current_model:
		model_root.add_child(current_model)
		animation_player = current_model.get_node_or_null("AnimationPlayer")
		if not animation_player:
			push_warning("No AnimationPlayer found on model: %s" % asset_type)

func load_model(name: String) -> Node3D:
	var model_paths = {
		"Mage": "res://Assets/KayKit_Skeletons_1.0_FREE/characters/fbx/Skeleton_Mage.fbx",
		"Warrior": "res://Assets/KayKit_Skeletons_1.0_FREE/characters/fbx/Skeleton_Warrior.fbx",
		"Rogue": "res://Assets/KayKit_Skeletons_1.0_FREE/characters/fbx/Skeleton_Rogue.fbx",
	}

	if model_paths.has(name):
		var packed_scene = load(model_paths[name]) as PackedScene
		return packed_scene.instantiate()
	else:
		return null

func take_damage(damage: int) -> bool:
	if damage >= stats.health:
		return true
	stats.health -= damage
	return false
	
func die():
	animation_player.play("Death_C_Skeletons")

func hit():
	animation_player.play("Hit_A")

func idle():
	animation_player.play("Idle")

func attack():
	animation_player.play("1H_Melee_Attack_Stab")
