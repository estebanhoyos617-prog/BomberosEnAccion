extends CanvasLayer

@onready var barra_vida: ProgressBar = $BarraVida

var vida_maxima: float = 100.0
var vida_actual: float = 100.0

func _ready() -> void:
	barra_vida.max_value = vida_maxima
	barra_vida.value = vida_actual

func reducir_vida(cantidad: float) -> void:
	vida_actual -= cantidad
	vida_actual = max(0.0, vida_actual)
	barra_vida.value = vida_actual
	
	if vida_actual <= 0:
		get_tree().get_first_node_in_group("game_manager")._game_over()
