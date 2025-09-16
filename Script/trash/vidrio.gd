extends Area2D

# Exportamos el tipo para poder definirlo en el editor para cada objeto (vidrio, plastico, lata)
@export var object_type: String = "vidrio"
var fall_speed: float = 100.0

func _physics_process(delta):
	position.y += fall_speed * delta

# Esta función será llamada desde el script del suelo
func stop_falling():
	set_physics_process(false)
