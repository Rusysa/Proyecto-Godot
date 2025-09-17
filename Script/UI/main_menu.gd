extends Control

# Esta función se conectará al botón "Jugar"
func _on_play_button_pressed():
	# Cambia a la escena principal del juego.
	get_tree().change_scene_to_file("res://Scenes/levels/Main.tscn")

func _on_exit_button_pressed():
	# Cierra el juego.
	get_tree().quit()


func _on_control_button_pressed():

	print("Mostrar pantalla de controles.")
	# Ejemplo si tuvieras una escena de controles:
	# get_tree().change_scene_to_file("res://controls_menu.tscn")
