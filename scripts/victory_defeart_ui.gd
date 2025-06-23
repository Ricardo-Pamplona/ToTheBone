extends CanvasLayer

@onready var label: Label = $Panel/Label
@onready var button: Button = $Button

var on_victory_callback: Callable = Callable()
var is_victory := false

func _ready():
	hide()
	$VBoxContainer/AddStat.hide()
	$VBoxContainer/AddUnit.hide()
	$VBoxContainer/SwapUnit.hide()

func show_victory(callback: Callable):
	label.text = "Vitória!"
	is_victory = true
	on_victory_callback = callback
	$VBoxContainer/AddStat.show()
	$VBoxContainer/AddUnit.show()
	$VBoxContainer/SwapUnit.show()
	show()
	button.hide()
	get_tree().paused = true
	

func show_defeat():
	$VBoxContainer/AddStat.hide()
	$VBoxContainer/AddUnit.hide()
	$VBoxContainer/SwapUnit.hide()
	button.show()
	label.text = "Derrota!"
	is_victory = false 
	button.text = "Voltar"
	on_victory_callback = func(): get_tree().change_scene_to_file("res://scenes/menu.tscn")
	show()

	get_tree().paused = true

func _on_button_pressed() -> void:
	print("Botão clicado!")
	hide()
	get_tree().paused = false
	on_victory_callback.call()


func _on_add_unit_pressed() -> void:
	var hex_grid = get_tree().root.get_node("Board/HexGrid")
	hex_grid.num_players += 1
	hex_grid.start_round()
	if is_victory:
		continuar_pos_vitoria()



func _on_swap_unit_pressed() -> void:
	var hex_grid = get_tree().root.get_node("Board/HexGrid")
	hex_grid.swap_minion_por_unidade()
	if is_victory:
		continuar_pos_vitoria()

func _on_add_stat_pressed() -> void:
	var hex_grid = get_tree().root.get_node("Board/HexGrid")
	hex_grid.add_stat_aleatorio()
	if is_victory:
		continuar_pos_vitoria()
	
func continuar_pos_vitoria():
	is_victory = false
	hide()
	get_tree().paused = false
	on_victory_callback.call()
