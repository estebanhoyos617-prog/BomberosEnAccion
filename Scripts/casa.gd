extends StaticBody2D

class_name Casa

enum State { NORMAL, ON_FIRE, BURNED }

signal house_on_fire(house_node)
signal house_extinguished(house_node)
signal house_burned_down(house_node)

@export var initial_state: State = State.NORMAL
@export var fire_spread_delay_min: float = 5.0 # Tiempo mínimo antes de que el fuego se propague
@export var fire_spread_delay_max: float = 15.0 # Tiempo máximo antes de que el fuego se propague
@export var fire_damage_time: float = 10.0 # Tiempo que tarda en quemarse por completo

var current_state: State
var time_on_fire: float = 0.0
var fire_spread_timer: Timer

# Referencias a nodos visuales para los diferentes estados
@onready var normal_sprite: Sprite2D = $NormalSprite
@onready var fire_sprite: Sprite2D = $FireSprite
@onready var burned_sprite: Sprite2D = $BurnedSprite

func _ready() -> void:
	set_state(initial_state)

	fire_spread_timer = Timer.new()
	add_child(fire_spread_timer)
	fire_spread_timer.one_shot = true
	fire_spread_timer.timeout.connect(_on_fire_spread_timer_timeout)

func _process(delta: float) -> void:
	if current_state == State.ON_FIRE:
		time_on_fire += delta
		if time_on_fire >= fire_damage_time:
			set_state(State.BURNED)

func set_state(new_state: State) -> void:
	current_state = new_state

	match current_state:
		State.NORMAL:
			normal_sprite.visible = true
			fire_sprite.visible = false
			burned_sprite.visible = false
			fire_spread_timer.stop()
			time_on_fire = 0.0
		State.ON_FIRE:
			normal_sprite.visible = false
			fire_sprite.visible = true
			burned_sprite.visible = false
			# Iniciar temporizador para propagación del fuego
			fire_spread_timer.wait_time = randf_range(fire_spread_delay_min, fire_spread_delay_max)
			fire_spread_timer.start()
			house_on_fire.emit(self)
		State.BURNED:
			normal_sprite.visible = false
			fire_sprite.visible = false
			burned_sprite.visible = true
			fire_spread_timer.stop()
			house_burned_down.emit(self)

func ignite() -> void:
	if current_state == State.NORMAL:
		set_state(State.ON_FIRE)

func extinguish() -> void:
	if current_state == State.ON_FIRE:
		set_state(State.NORMAL)
		house_extinguished.emit(self)

func _on_fire_spread_timer_timeout() -> void:
	# Este método será llamado cuando el temporizador de propagación termine.
	# La lógica de encontrar casas cercanas y propagar el fuego se implementará
	# en un script de nivel superior (ej. GameManager o el propio World).
	# Por ahora, solo emitimos una señal para indicar que una casa está lista para propagar.
	pass # La lógica de propagación real irá en el GameManager o World
