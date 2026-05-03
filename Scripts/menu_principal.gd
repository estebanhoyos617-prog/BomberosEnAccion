extends CanvasLayer

@onready var panel_menu: Control              = $PanelFondo/VBox
@onready var panel_como_jugar: PanelContainer = $PanelComoJugar
@onready var btn_jugar: Button                = $PanelFondo/VBox/BtnJugar
@onready var btn_como_jugar: Button           = $PanelFondo/VBox/BtnComoJugar
@onready var btn_salir: Button                = $PanelFondo/VBox/BtnSalir
@onready var btn_cerrar_ayuda: Button         = $PanelComoJugar/VBox/BtnCerrar
@onready var chispas_container: Node2D        = $Chispas

var chispas: Array = []
var max_chispas: int = 40
var screen_size: Vector2 = Vector2(1152, 648)

func _ready() -> void:
	btn_jugar.pressed.connect(_on_jugar)
	btn_como_jugar.pressed.connect(_on_como_jugar)
	btn_salir.pressed.connect(_on_salir)
	btn_cerrar_ayuda.pressed.connect(_on_cerrar_ayuda)
	panel_como_jugar.visible = false

	for i in max_chispas:
		_crear_chispa(true)

	panel_menu.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel_menu, "modulate:a", 1.0, 0.8)

func _process(delta: float) -> void:
	_actualizar_chispas(delta)

func _crear_chispa(aleatorio_y: bool = false) -> void:
	var chispa = {
		"pos": Vector2(randf() * screen_size.x, randf() * screen_size.y if aleatorio_y else screen_size.y + 10.0),
		"vel": Vector2(randf_range(-20.0, 20.0), randf_range(-80.0, -160.0)),
		"vida": 0.0,
		"vida_max": randf_range(1.5, 3.5),
		"size": randf_range(2.0, 5.0),
		"node": null
	}
	var rect = ColorRect.new()
	rect.size = Vector2(chispa.size, chispa.size)
	rect.color = Color(1.0, randf_range(0.3, 0.9), 0.0, 1.0)
	chispas_container.add_child(rect)
	chispa.node = rect
	chispas.append(chispa)

func _actualizar_chispas(delta: float) -> void:
	var a_eliminar = []
	for chispa in chispas:
		chispa.vida += delta
		var t: float = chispa.vida / chispa.vida_max
		chispa.pos += chispa.vel * delta
		chispa.vel.x += randf_range(-10.0, 10.0) * delta
		chispa.vel.y -= 5.0 * delta
		chispa.node.color.a = 1.0 - t
		chispa.node.position = chispa.pos
		if chispa.vida >= chispa.vida_max:
			a_eliminar.append(chispa)
	for chispa in a_eliminar:
		chispa.node.queue_free()
		chispas.erase(chispa)
		_crear_chispa()

func _on_jugar() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://Escenas/main.tscn"))

func _on_como_jugar() -> void:
	panel_menu.visible = false
	panel_como_jugar.visible = true
	panel_como_jugar.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(panel_como_jugar, "modulate:a", 1.0, 0.3)

func _on_cerrar_ayuda() -> void:
	panel_como_jugar.visible = false
	panel_menu.visible = true

func _on_salir() -> void:
	get_tree().quit()
