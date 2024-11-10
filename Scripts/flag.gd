extends Area3D

@export var team := 0

var being_carried := false

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		if team == body.team:
			if body.carrying_flag:
				Madden.scores[team] += 1
				body.carrying_flag = false
				body.carried_flag.show()
				body.carried_flag.being_carried = false
				body.carried_flag = null
		elif not being_carried:
			print(body.name + " carrying flag!")
			body.carrying_flag = true
			body.carried_flag = self
			being_carried = true
			hide()
