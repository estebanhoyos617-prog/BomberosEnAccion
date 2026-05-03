extends CharacterBody2D

@export var speed: float = 200.0
@export var potencia_apagado: float = 30.0

var casa_cercana: Area2D = null
var _material: ShaderMaterial
var _flash_tween: Tween
var _rimlight_activo: bool = false

func _ready() -> void:
	_material = $Sprite2D.material as ShaderMaterial

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	# Rotar el sprite
	if direction.length_squared() > 0:
		var target_rotation: float = direction.angle()
		$Sprite2D.rotation = lerp_angle($Sprite2D.rotation, target_rotation + (PI / 2), 0.1)

	# Apagar fuego + flash
	if Input.is_action_pressed("ui_accept") and casa_cercana != null:
		if casa_cercana.estado == casa_cercana.Estado.EN_LLAMAS:
			casa_cercana.apagar_fuego(potencia_apagado * delta)
			_activar_flash()

	# Rim light
	_actualizar_rimlight()

func _activar_flash() -> void:
	if not _material:
		return
	if _flash_tween:
		_flash_tween.kill()
	_material.set_shader_parameter("flash_intensity", 0.9)
	_flash_tween = create_tween()
	_flash_tween.tween_method(
		func(v): _material.set_shader_parameter("flash_intensity", v),
		0.9, 0.0, 0.12
	)

func _actualizar_rimlight() -> void:
	if not _material:
		return
	var hay_fuego_cerca: bool = false
	if casa_cercana != null and casa_cercana.estado == casa_cercana.Estado.EN_LLAMAS:
		hay_fuego_cerca = true

	if hay_fuego_cerca and not _rimlight_activo:
		_rimlight_activo = true
		var t = create_tween()
		t.tween_method(
			func(v): _material.set_shader_parameter("rim_intensity", v),
			0.0, 0.85, 0.4
		)
	elif not hay_fuego_cerca and _rimlight_activo:
		_rimlight_activo = false
		var t = create_tween()
		t.tween_method(
			func(v): _material.set_shader_parameter("rim_intensity", v),
			0.85, 0.0, 0.4
		)

func _on_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("casas"):
		casa_cercana = area

func _on_detector_area_exited(area: Area2D) -> void:
	if area == casa_cercana:
		casa_cercana = null
