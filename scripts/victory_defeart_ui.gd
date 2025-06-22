extends CanvasLayer

@onready var label: Label = $Label
@onready var button: Button = $Button

var on_victory_callback: Callable = Callable()

func _ready():
	hide()

func show_victory(callback: Callable):
	label.text = "Vitória!"
	on_victory_callback = callback
	button.text = "Adicionar Unidade e Começar Novo Round"
	show()
	get_tree().paused = true

func show_defeat():
	label.text = "Derrota!"
	button.text = "Voltar"
	on_victory_callback = func(): 	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	show()
	get_tree().paused = true

func _on_button_pressed() -> void:
	print("Botão clicado!")
	hide()
	get_tree().paused = false
	on_victory_callback.call()
