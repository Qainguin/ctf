extends RayCast3D

const DRAW = preload("res://Assets/Audio/draw.wav")
const REGFIRE = preload("res://Assets/Audio/regfire.wav")
const WINDDOWN = preload("res://Assets/Audio/winddown.wav")

@onready var shoot_timer: Timer = $ShootTimer

@onready var shoot_sound: AudioStreamPlayer3D = $ShootSound
@onready var wind_sound: AudioStreamPlayer3D = $WindSound
@onready var draw_sound: AudioStreamPlayer3D = $DrawSound
@onready var shoot_light: OmniLight3D = $ShootLight

const MAX_BARREL_VELOCITY = 0.35

var barrel_velocity := 0.0

var is_shooting := false
var is_firing := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action("shoot"):
		if event.is_pressed():
			is_shooting = true
			draw_sound.play()
		else:
			is_firing = false
			is_shooting = false
			shoot_timer.stop()
			shoot_sound.stop()
			wind_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_pressed("shoot"):
		barrel_velocity += 0.01
	elif barrel_velocity < 0.0:
		barrel_velocity = 0.0
	elif barrel_velocity > 0.0:
		barrel_velocity -= 0.01
	barrel_velocity = clampf(barrel_velocity, 0.0, MAX_BARREL_VELOCITY)

	$Minigun/Barrel.rotation.z += barrel_velocity
	
	if is_firing:
		shoot_light.light_energy = float(get_tree().get_frame() % 5 == 0) * 0.1
	else:
		shoot_light.light_energy = 0

@rpc("any_peer")
func shoot() -> void:
	if is_multiplayer_authority():
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("Players"):
				collider.hit.rpc_id(collider.get_multiplayer_authority())
		owner.rotate_y(randf_range(-0.01, 0.01))
		owner.pivot.rotate_x(0.02)

func _on_draw_sound_finished() -> void:
	if is_shooting:
		is_firing = true
		shoot_timer.start()
		shoot_sound.play()

func _on_shoot_timer_timeout() -> void:
	shoot()
