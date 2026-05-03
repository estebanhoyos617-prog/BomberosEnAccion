extends Node

# ── Reproductores ──────────────────────────────────────────────────────────
var musica: AudioStreamPlayer
var efectos: AudioStreamPlayer
var loops: Dictionary = {}  # sonidos en loop (fuego, sirena)

func _ready() -> void:
	# Reproductor de música (loop)
	musica = AudioStreamPlayer.new()
	musica.bus = "Master"
	add_child(musica)

	# Reproductor de efectos (one-shot)
	efectos = AudioStreamPlayer.new()
	efectos.bus = "Master"
	add_child(efectos)

# ── Música ─────────────────────────────────────────────────────────────────
func play_musica(nombre: String, volumen_db: float = -10.0) -> void:
	var stream = _cargar(nombre)
	if not stream:
		return
	stream.loop = true
	musica.stream = stream
	musica.volume_db = volumen_db
	musica.play()

func stop_musica() -> void:
	musica.stop()

# ── Efectos one-shot ───────────────────────────────────────────────────────
func play_efecto(nombre: String, volumen_db: float = 0.0) -> void:
	var stream = _cargar(nombre)
	if not stream:
		return
	efectos.stream = stream
	efectos.volume_db = volumen_db
	efectos.play()

# ── Loops (fuego, sirena) ──────────────────────────────────────────────────
func play_loop(nombre: String, volumen_db: float = -5.0) -> void:
	if loops.has(nombre):
		return  # ya está sonando
	var player = AudioStreamPlayer.new()
	add_child(player)
	var stream = _cargar(nombre)
	if not stream:
		player.queue_free()
		return
	stream.loop = true
	player.stream = stream
	player.volume_db = volumen_db
	player.play()
	loops[nombre] = player

func stop_loop(nombre: String) -> void:
	if loops.has(nombre):
		loops[nombre].queue_free()
		loops.erase(nombre)

func stop_todos_loops() -> void:
	for nombre in loops:
		loops[nombre].queue_free()
	loops.clear()

# ── Interno ────────────────────────────────────────────────────────────────
func _cargar(nombre: String) -> AudioStream:
	var path = "res://Sonidos/" + nombre
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("AudioManager: no se encontró " + path)
	return null
