extends Node

# Array de casas registradas en el juego
var casas: Array = []

# Variables de juego
var puntaje: int = 0
var casas_destruidas: int = 0
var max_casas_destruidas: int = 3
var juego_activo: bool = true

# Temporizadores
var tiempo_spawn_fuego: float = 5.0
var timer_spawn: float = 0.0

# Referencia al jugador
@onready var jugador = $Camion

func _ready() -> void:
	# Registrar todas las casas de la escena
	_registrar_casas()

func _process(delta: float) -> void:
	if not juego_activo:
		return
	
	# Temporizador para iniciar fuegos aleatorios
	timer_spawn += delta
	if timer_spawn >= tiempo_spawn_fuego:
		timer_spawn = 0.0
		_iniciar_fuego_aleatorio()
		# Dificultad progresiva: cada fuego el intervalo baja
		tiempo_spawn_fuego = max(2.0, tiempo_spawn_fuego - 0.2)

func _registrar_casas() -> void:
	# Busca todos los nodos Casa en la escena
	for nodo in get_tree().get_nodes_in_group("casas"):
		casas.append(nodo)
		# Conectar señal de casa destruida
		nodo.casa_destruida.connect(_on_casa_destruida)

func _iniciar_fuego_aleatorio() -> void:
	if casas.is_empty():
		return
	
	# Filtrar solo casas normales (sin fuego)
	var casas_normales: Array = []
	for casa in casas:
		if casa.estado == casa.Estado.NORMAL:
			casas_normales.append(casa)
	
	if casas_normales.is_empty():
		return
	
	# Elegir una casa aleatoria y prenderle fuego
	var indice: int = randi() % casas_normales.size()
	casas_normales[indice].iniciar_fuego()

func _on_casa_destruida(posicion: Vector2) -> void:
	casas_destruidas += 1
	if casas_destruidas >= max_casas_destruidas:
		_game_over()

func sumar_puntaje(cantidad: int) -> void:
	puntaje += cantidad

func _game_over() -> void:
	juego_activo = false
	print("GAME OVER - Casas destruidas: ", casas_destruidas)
