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
	
	# Gravity.
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
# Reemplaza desde la función catch_object hasta el final de tu script con esto

# Función para recoger un objeto
func catch_object(object_to_catch):
	# Solo verificamos si podemos cargar y luego aplazamos el resto
	if can_carry:
		can_carry = false # Lo ponemos en 'false' aquí para evitar recoger varios objetos a la vez
		call_deferred("_deferred_catch", object_to_catch)

# Esta es la nueva función que se ejecutará en un momento seguro
func _deferred_catch(object_to_catch):
	# Revisa si el objeto estaba en el suelo
	if object_to_catch.is_grounded:
		SignalManager.on_grounded_object_collected.emit()
		object_to_catch.is_grounded = false
	
	held_object = object_to_catch
	# Ahora todas estas operaciones se ejecutan de forma segura
	object_to_catch.reparent(hand_position)
	object_to_catch.position = Vector2.ZERO
	object_to_catch.set_physics_process(false)
	object_to_catch.get_node("CollisionShape2D").set_deferred("disabled", true)


# Función para depositar un objeto (VERSIÓN CORREGIDA)
func deposit_object():
	# Comprobamos si el tipo de objeto corresponde al del contenedor
	if held_object.object_type == current_container.container_type:
		print("¡Correcto!")
		SignalManager.on_score_updated.emit(100)
		held_object.queue_free() # Si es correcto, el objeto desaparece
	else:
		print("¡Incorrecto!")
		SignalManager.on_score_updated.emit(-50)
		drop_object() # ¡Si es incorrecto, el objeto se suelta, no se destruye!
	
	# Reseteamos el estado del jugador
	held_object = null
	can_carry = true
	
# Función para soltar el objeto si el depósito es incorrecto
func drop_object():
	if not held_object: return

	var object_to_drop = held_object
	var main_scene = get_tree().current_scene
	
	var drop_position = object_to_drop.global_position
	
	object_to_drop.reparent(main_scene)
	object_to_drop.global_position = drop_position
	
	object_to_drop.set_physics_process(true)
	object_to_drop.get_node("CollisionShape2D").set_deferred("disabled", false)


# Conexión de la señal area_entered
func _on_area_2d_area_entered(area):
	if area.is_in_group("object") and can_carry:
		catch_object(area)
	elif area.is_in_group("container"):
		current_container = area

# Conexión de la señal area_exited
func _on_area_2d_area_exited(area):
	if area.is_in_group("container"):
		if area == current_container:
			current_container = null
