extends CanvasLayer

# ── Nodos del HUD ──────────────────────────────────────────────────────────
@onready var barra_caos: ProgressBar = $PanelSuperior/HBox/VBoxCaos/BarraCaos
@onready var label_caos: Label = $PanelSuperior/HBox/VBoxCaos/LabelCaos
@onready var label_tiempo: Label = $PanelSuperior/HBox/LabelTiempo
@onready var label_puntaje: Label = $PanelSuperior/HBox/LabelPuntaje
@onready var panel_notificacion: PanelContainer = $Notificacion
@onready var label_notificacion: Label = $Notificacion/Label
@onready var panel_fin: PanelContainer = $PanelFin
@onready var label_fin_titulo: Label = $PanelFin/VBox/LabelTitulo
@onready var label_fin_puntaje: Label = $PanelFin/VBox/LabelPuntaje
@onready var boton_reiniciar: Button = $PanelFin/VBox/BotonReiniciar

# ── Colores de la barra de caos ────────────────────────────────────────────
var color_calma:  Color = Color("4caf50")   # verde
var color_alerta: Color = Color("ff9800")   # naranja
var color_crisis: Color = Color("f44336")   # rojo

# ── Temporizador de notificación ───────────────────────────────────────────
var timer_notificacion: float = 0.0
var duracion_notificacion: float = 3.5

func _ready() -> void:
	# Conectar al GameManager
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.caos_actualizado.connect(_on_caos_actualizado)
		gm.tiempo_actualizado.connect(_on_tiempo_actualizado)
		gm.juego_terminado.connect(_on_juego_terminado)
		gm.notificacion_incendio.connect(_on_notificacion_incendio)

	# Estado inicial
	barra_caos.max_value = 100.0
	barra_caos.value = 0.0
	_actualizar_color_barra(0.0)
	panel_notificacion.visible = false
	panel_fin.visible = false
	boton_reiniciar.pressed.connect(_on_reiniciar)

func _process(delta: float) -> void:
	# Ocultar notificación tras su duración
	if panel_notificacion.visible:
		timer_notificacion -= delta
		if timer_notificacion <= 0.0:
			panel_notificacion.visible = false

# ── Barra de caos ──────────────────────────────────────────────────────────
func _on_caos_actualizado(valor: float) -> void:
	barra_caos.value = valor
	_actualizar_color_barra(valor)
	_actualizar_label_caos(valor)

func _actualizar_color_barra(valor: float) -> void:
	var color: Color
	if valor < 25.0:
		color = color_calma
	elif valor < 75.0:
		# Interpolar naranja entre 25 y 75
		var t: float = (valor - 25.0) / 50.0
		color = color_calma.lerp(color_alerta, t)
	else:
		# Interpolar rojo entre 75 y 100
		var t: float = (valor - 75.0) / 25.0
		color = color_alerta.lerp(color_crisis, t)

	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	barra_caos.add_theme_stylebox_override("fill", style)

func _actualizar_label_caos(valor: float) -> void:
	if valor < 25.0:
		label_caos.text = "🟢 Calma"
	elif valor < 75.0:
		label_caos.text = "🟠 Alerta"
	else:
		label_caos.text = "🔴 ¡CRISIS!"

# ── Tiempo ─────────────────────────────────────────────────────────────────
func _on_tiempo_actualizado(segundos_restantes: float) -> void:
	var min: int = int(segundos_restantes) / 60
	var seg: int = int(segundos_restantes) % 60
	label_tiempo.text = "⏱ %01d:%02d" % [min, seg]

# ── Puntaje ────────────────────────────────────────────────────────────────
func actualizar_puntaje(valor: int) -> void:
	label_puntaje.text = "⭐ %d" % valor

# ── Notificación de incendio ───────────────────────────────────────────────
func _on_notificacion_incendio(razon: String, _posicion: Vector2) -> void:
	label_notificacion.text = "🔥 ¡INCENDIO!\n" + razon
	panel_notificacion.visible = true
	timer_notificacion = duracion_notificacion

	# Animación simple de entrada
	panel_notificacion.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel_notificacion, "modulate:a", 1.0, 0.3)

# ── Fin de juego ───────────────────────────────────────────────────────────
func _on_juego_terminado(victoria: bool, puntaje_final: int) -> void:
	panel_fin.visible = true
	if victoria:
		label_fin_titulo.text = "🏆 ¡CIUDAD SALVADA!"
		label_fin_titulo.add_theme_color_override("font_color", Color("ffd700"))
	else:
		label_fin_titulo.text = "💀 GAME OVER"
		label_fin_titulo.add_theme_color_override("font_color", Color("f44336"))
	label_fin_puntaje.text = "Puntaje final: %d" % puntaje_final

func _on_reiniciar() -> void:
	get_tree().reload_current_scene()
