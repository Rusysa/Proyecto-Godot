extends Node2D

# Precargamos las escenas de los objetos para poder instanciarlas
@export var object_scenes: Array[PackedScene] = []

# Variables del juego
var score: int = 0
var high_score: int = 0
@export var grounded_objects_count: int = 0
var base_fall_speed: float = 100.0
var time_elapsed: float = 0.0

@onready var spawn_timer = $SpawnTimer
@onready var player = $Main_character
@onready var spawn_path = $Path2D # Usaremos un Path2D para definir el área de spawn
@onready var spawn_location = $Path2D/PathFollow2D
@onready var ui = $UI

func _ready():
	grounded_objects_count = 0
	# Conectamos las señales del SignalManager
	SignalManager.on_score_updated.connect(_on_score_updated)
	SignalManager.on_object_grounded.connect(_on_object_grounded)
	SignalManager.on_grounded_object_collected.connect(_on_grounded_object_collected)

	
	load_high_score()
	ui.update_score(score)
	ui.update_high_score(high_score)
	spawn_timer.start()

func _process(delta):
	time_elapsed += delta
	# Aumentamos la dificultad cada 15 segundos
	if fmod(time_elapsed, 15) < delta:
		base_fall_speed += 20.0
		spawn_timer.wait_time = max(0.5, spawn_timer.wait_time * 0.9) # Hacemos que aparezcan más rápido
		print("¡Velocidad aumentada! Nueva velocidad base: ", base_fall_speed)


# Esta función se conecta a la señal timeout del Timer
func _on_spawn_timer_timeout():
	if object_scenes.is_empty(): return

	# Elegimos un objeto al azar
	var random_object_scene = object_scenes.pick_random()
	var new_object = random_object_scene.instantiate()

	# Posición de spawn aleatoria
	spawn_location.progress_ratio = randf()
	new_object.position = spawn_location.position
	
	# Asignamos la velocidad de caída actual
	new_object.fall_speed = base_fall_speed

	add_child(new_object)

# Esta función se conecta a la señal area_entered del Suelo (Ground)
		
func _on_ground_area_entered(area):
	if area.is_in_group("object"):
		# Solo contamos si no ha sido contado antes
		if not area.is_grounded:
			area.set_physics_process(false)
			# Marcamos el objeto para que recuerde que está en el suelo
			area.is_grounded = true
			
			grounded_objects_count += 1
			print("Objeto ha tocado el suelo. Total: ", grounded_objects_count)
			
			# Comprobamos la condición de derrota (ahora con 10)
			if grounded_objects_count >= 10:
				game_over()


# Se ejecutará cuando el jugador recoja un objeto del suelo
func _on_grounded_object_collected():
	if grounded_objects_count > 0:
		grounded_objects_count -= 1
	print("Objeto del suelo recogido. Quedan: ", grounded_objects_count)


func _on_score_updated(points):
	score += points
	ui.update_score(score)

func _on_object_grounded():
	grounded_objects_count += 1
	print("Objetos en el suelo: ", grounded_objects_count)
	if grounded_objects_count > 10:
		game_over()

func game_over():
	print("GAME OVER")
	# Guardamos el high score si es necesario
	if score > high_score:
		high_score = score
		save_high_score()
	
	# Guardamos el score para mostrarlo en la pantalla de Game Over
	Global.last_score = score
	Global.high_score = high_score
	
	get_tree().change_scene_to_file("res://Scenes/UI/game_over.tscn")

# --- Guardado y carga de High Score ---
func save_high_score():
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	file.store_var(high_score)

func load_high_score():
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		high_score = file.get_var()
	else:
		high_score = 0
