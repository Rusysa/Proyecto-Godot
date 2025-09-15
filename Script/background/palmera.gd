extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TileMapLayer2/AnimatedSprite2D.play("palma")
	$TileMapLayer3/AnimatedSprite2D.play("palma")
	$TileMapLayer4/AnimatedSprite2D.play("default")
	$TileMapLayer5/AnimatedSprite2D.play("default")
	$TileMapLayer6/AnimatedSprite2D.play("default")
	$TileMapLayer7/AnimatedSprite2D.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
