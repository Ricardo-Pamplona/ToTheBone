extends CanvasLayer
@onready var status_label := $"../HUD/Label"

func _ready():
	var hex_grid = get_node("/root/Board/HexGrid") # ajuste o caminho
	hex_grid.connect("unit_hovered", Callable(self, "_on_unit_hovered"))
	hex_grid.connect("unit_unhovered", Callable(self, "_on_unit_unhovered"))
	print("HUD conectado no hex_grid")

func _on_unit_hovered(stats):
	var text = "Health: %s\nStrength: %s\nSpeed: %s\nRange: %s" % [
		stats.health,
		stats.strength,
		stats.speed,
		stats.range
	]
	$Label.text = text
	$Label.visible = true

func _on_unit_unhovered():
	print("HUD recebeu unhover")
	$Label.visible = false
