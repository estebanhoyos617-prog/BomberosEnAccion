extends CharacterBody2D

@export var speed: float = 200.0
@export var potencia_apagado: float = 30.0

var casa_cercana: Area2D = null

func _ready() -> void:
	# Conectar señales del Area2D hijo (lo agregamos ahora)
	pass

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	# Rotar el sprite
	if direction.length_squared() > 0:
		var target_rotation: float = direction.angle()
		$Sprite2D.rotation = lerp_angle($Sprite2D.rotation, target_rotation + (PI / 2), 0.1)
	
	# Apagar fuego si está cerca y presiona ESPACIO
	if Input.is_action_pressed("ui_accept") and casa_cercana != null:
		if casa_cercana.estado == casa_cercana.Estado.EN_LLAMAS:
			casa_cercana.apagar_fuego(potencia_apagado * delta)

func _on_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("casas"):
		casa_cercana = area

func _on_detector_area_exited(area: Area2D) -> void:
	if area == casa_cercana:
		casa_cercana = null
