extends Area2D

enum Estado { NORMAL, EN_LLAMAS, DESTRUIDA }

@export var textura_normal: Texture2D
@export var textura_fuego: Texture2D  
@export var textura_destruida: Texture2D
@export var velocidad_fuego: float = 10.0
@export var radio_propagacion: float = 120.0

var estado: Estado = Estado.NORMAL
var intensidad: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

signal casa_destruida(posicion)
signal estado_cambiado(nuevo_estado)

func _ready() -> void:
	_actualizar_textura()

func _process(delta: float) -> void:
	if estado == Estado.EN_LLAMAS:
		intensidad += velocidad_fuego * delta
		if intensidad >= 100.0:
			cambiar_estado(Estado.DESTRUIDA)

func iniciar_fuego() -> void:
	if estado == Estado.NORMAL:
		cambiar_estado(Estado.EN_LLAMAS)
		intensidad = 0.0

func apagar_fuego(cantidad: float) -> void:
	if estado == Estado.EN_LLAMAS:
		intensidad -= cantidad
		if intensidad <= 0.0:
			intensidad = 0.0
			cambiar_estado(Estado.NORMAL)

func cambiar_estado(nuevo_estado: Estado) -> void:
	estado = nuevo_estado
	_actualizar_textura()
	emit_signal("estado_cambiado", nuevo_estado)
	if nuevo_estado == Estado.DESTRUIDA:
		emit_signal("casa_destruida", global_position)

func _actualizar_textura() -> void:
	match estado:
		Estado.NORMAL:
			sprite.texture = textura_normal
		Estado.EN_LLAMAS:
			sprite.texture = textura_fuego
		Estado.DESTRUIDA:
			sprite.texture = textura_destruida

func get_intensidad() -> float:
	return intensidad
