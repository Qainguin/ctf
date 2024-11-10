extends Area3D

@onready var collider: CollisionShape3D = $Collider
@onready var cooldown_timer: Timer = $CooldownTimer


func _on_body_entered(body: Node3D) -> void:
	print("entered health pack")
	if body is CharacterBody3D:
		body.health = 10
		hide()
		set_deferred("monitoring", false)
		cooldown_timer.start()


func _on_cooldown_timer_timeout() -> void:
	show()
	set_deferred("monitoring", true)
