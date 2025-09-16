extends CanvasLayer

@onready var score_label = $ScoreLabel
@onready var high_score_label = $HighScoreLabel

func update_score(new_score):
	score_label.text = "Puntución: %s" % new_score

func update_high_score(new_high_score):
	high_score_label.text = "Mejor Puntuación: %s" % new_high_score
