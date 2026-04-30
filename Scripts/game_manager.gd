extends Node

# ── Casas ──────────────────────────────────────────────────────────────────
var casas: Array = []

# ── Barra de Caos ──────────────────────────────────────────────────────────
var caos: float = 0.0                     # 0..100
var caos_por_segundo_base: float = 1.5    # sube solo con el tiempo
var caos_por_casa_ardiendo: float = 3.0   # extra por cada casa en llamas
var caos_por_destruccion: float = 15.0    # golpe al destruirse una casa

# ── Supervivencia (condición de victoria) ──────────────────────────────────
var tiempo_objetivo: float = 120.0        # segundos para ganar (2 min)
var tiempo_transcurrido: float = 0.0

# ── Spawn de incendios ─────────────────────────────────────────────────────
var tiempo_spawn_fuego: float = 8.0
var timer_spawn: float = 0.0

# ── Razones de incendio ────────────────────────────────────────────────────
var razones_incendio: Array[String] = [
	"⚡ Cortocircuito eléctrico",
	"🕯️ Una vela sin apagar",
	"🍳 Cocina descuidada",
	"🎆 Fuegos artificiales",
	"☀️ Vidrio concentró el sol",
	"🚬 Colilla mal apagada",
	"👦 Niño jugando con fósforos",
	"🔥 Chimenea sin mantenimiento",
	"⛽ Derrame de combustible",
	"🌩️ Rayo cayó en el techo",
]

# ── Estado general ─────────────────────────────────────────────────────────
var juego_activo: bool = true
var puntaje: int = 0
var incendios_apagados: int = 0

# ── Refs ───────────────────────────────────────────────────────────────────
@onready var hud = $"../HUD"

# ── Señales ────────────────────────────────────────────────────────────────
signal caos_actualizado(valor: float)
signal tiempo_actualizado(segundos_restantes: float)
signal juego_terminado(victoria: bool, puntaje: int)
signal notificacion_incendio(razon: String, posicion: Vector2)

func _ready() -> void:
	add_to_group("game_manager")
	print("GameManager iniciado")
	_registrar_casas()
	print("Casas encontradas: ", casas.size())

func _process(delta: float) -> void:
	if not juego_activo:
		return

	# ── Temporizador de victoria ──────────────────────────────────────────
	tiempo_transcurrido += delta
	var restante: float = max(0.0, tiempo_objetivo - tiempo_transcurrido)
	emit_signal("tiempo_actualizado", restante)

	if tiempo_transcurrido >= tiempo_objetivo:
		_victoria()
		return

	# ── Subir caos ────────────────────────────────────────────────────────
	var casas_ardiendo: int = 0
	for casa in casas:
		if casa.estado == casa.Estado.EN_LLAMAS:
			casas_ardiendo += 1

	var subida: float = (caos_por_segundo_base + casas_ardiendo * caos_por_casa_ardiendo) * delta
	_modificar_caos(subida)

	# ── Spawn de incendios ────────────────────────────────────────────────
	timer_spawn += delta
	if timer_spawn >= tiempo_spawn_fuego:
		timer_spawn = 0.0
		_iniciar_fuego_aleatorio()
		tiempo_spawn_fuego = max(3.0, tiempo_spawn_fuego - 0.3)

# ── Casas ──────────────────────────────────────────────────────────────────
func _registrar_casas() -> void:
	for nodo in get_tree().get_nodes_in_group("casas"):
		casas.append(nodo)
		nodo.casa_destruida.connect(_on_casa_destruida)
		nodo.fuego_apagado.connect(_on_fuego_apagado)
		print("Casa registrada: ", nodo.name)

func _iniciar_fuego_aleatorio() -> void:
	var casas_normales: Array = []
	for casa in casas:
		if casa.estado == casa.Estado.NORMAL:
			casas_normales.append(casa)
	if casas_normales.is_empty():
		return

	var indice: int = randi() % casas_normales.size()
	var casa_elegida = casas_normales[indice]
	var razon: String = razones_incendio[randi() % razones_incendio.size()]

	emit_signal("notificacion_incendio", razon, casa_elegida.global_position)
	casa_elegida.iniciar_fuego()

func _on_casa_destruida(_posicion: Vector2) -> void:
	_modificar_caos(caos_por_destruccion)

func _on_fuego_apagado() -> void:
	incendios_apagados += 1
	sumar_puntaje(50)
	# Bajar un poco el caos como recompensa
	_modificar_caos(-8.0)

# ── Caos ───────────────────────────────────────────────────────────────────
func _modificar_caos(delta_caos: float) -> void:
	caos = clamp(caos + delta_caos, 0.0, 100.0)
	emit_signal("caos_actualizado", caos)
	if caos >= 100.0:
		_game_over()

# ── Puntuación ─────────────────────────────────────────────────────────────
func sumar_puntaje(cantidad: int) -> void:
	puntaje += cantidad

# ── Fin de juego ───────────────────────────────────────────────────────────
func _victoria() -> void:
	juego_activo = false
	puntaje += incendios_apagados * 10 + 500  # bonus por sobrevivir
	emit_signal("juego_terminado", true, puntaje)

func _game_over() -> void:
	juego_activo = false
	emit_signal("juego_terminado", false, puntaje)
