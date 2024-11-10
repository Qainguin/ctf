extends PanelContainer

@onready var score_label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var score_text = str(Madden.scores).replace("[", "")
	score_text = score_text.replace("]", "")
	score_text = score_text.replace(",", "-")
	score_text = score_text.replace(" ", "")
	score_label.text = score_text
