extends CharacterBody2D

# --- Variables de Movimiento (ya deberías tener algo similar) ---
@export var speed = 300.0
@export var gravity = 1000

# --- Variables para la mecánica de recolección ---
var can_carry: bool = true
var held_object = null
var current_container = null # Para saber si estamos cerca de un contenedor

@onready var hand_position = $Hand # Referencia al nodo "Mano"

	
		
func _physics_process(delta):
	# --- Tu código de movimiento horizontal ---
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		
	# --- Lógica para depositar el objeto ---
	if Input.is_action_just_pressed("ui_accept") and held_object and current_container:
		deposit_object()
		
	move_and_slide()
	# ----------------------------------------
	if velocity.x == 0:
		$AnimatedSprite2D.play("idle")
	elif velocity.x > 0:
		$AnimatedSprite2D.play("run_right")
	elif velocity.x < 0:
		$AnimatedSprite2D.play("run_left")
	# --- Lógica para depositar el objeto ---
	# Si presionamos "Z", tenemos un objeto y estamos cerca de un contenedor
	if Input.is_action_just_pressed("ui_accept") and held_object and current_container:
		deposit_object()

# Función para recoger un objeto
func catch_object(object):
	if can_carry:
		can_carry = false
		held_object = object
		
		# Reparentamos el objeto a la "mano" del jugador
		object.reparent(hand_position)
		object.position = Vector2.ZERO # Lo centramos en la mano
		# Desactivamos su proceso de física para que no siga cayendo
		object.set_physics_process(false)
		object.get_node("CollisionShape2D").disabled = true # Desactivamos su colisión para no recoger más

# Función para depositar un objeto
func deposit_object():
	# Comprobamos si el tipo de objeto corresponde al del contenedor
	if held_object.object_type == current_container.container_type:
		print("¡Correcto!")
		# Emitimos una señal para que el script principal sume puntos
		SignalManager.on_score_updated.emit(100)
	else:
		print("¡Incorrecto!")
		# Emitimos una señal para restar puntos
		SignalManager.on_score_updated.emit(-50)
	
	# Liberamos el objeto y reseteamos el estado
	held_object.queue_free()
	held_object = null
	can_carry = true

# Conectaremos la señal area_entered de nuestro Area2D a esta función
func _on_area_2d_area_entered(area):
	# Si el área es un objeto y podemos cargarlo
	if area.is_in_group("object") and can_carry:
		catch_object(area)
	# Si el área es un contenedor
	elif area.is_in_group("container"):
		current_container = area

# Conectaremos la señal area_exited para saber cuándo nos alejamos del contenedor
func _on_area_2d_area_exited(area):
	if area.is_in_group("container"):
		if area == current_container:
			current_container = null
