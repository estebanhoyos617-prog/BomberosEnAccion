extends CharacterBody2D

@export var speed: float = 200.0


func _physics_process(delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * speed
	move_and_slide()

	# Rotar el sprite hacia la dirección de movimiento
	if direction.length_squared() > 0:
		var target_rotation: float = direction.angle() # dirección de movimiento
		# Si el sprite por defecto está mirando hacia ARRIBA (Vector2.UP), su rotación es -PI/2 (o 270 grados).
		# Para que 'direction.angle()' (donde 0 es derecha) funcione correctamente,
		# necesitamos compensar la orientación inicial del sprite.
		# Un sprite que mira hacia ARRIBA (Vector2(0,-1)) tiene un ángulo de -PI/2. 
		# Si queremos que 0 grados del sprite apunten hacia ARRIBA, entonces
		# la dirección 'angle' debe ser rotada para coincidir con la 'angle' del sprite.
		# Una forma común es restar PI / 2 (90 grados) si el sprite por defecto está mirando hacia arriba.
		$Sprite2D.rotation = lerp_angle($Sprite2D.rotation, target_rotation + (PI / 2), 0.1)
