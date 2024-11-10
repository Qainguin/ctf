extends Area3D

@onready var collider: CollisionShape3D = $Collider
@onready var cooldown_timer: Timer = $CooldownTimer


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Players"):
		body.health = 10
		hide()
		collider.disabled = true
		cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	show()
	collider.disabled = false
