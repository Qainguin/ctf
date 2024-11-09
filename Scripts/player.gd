extends CharacterBody3D

const DEATH_SOUNDS = [
	preload("res://Assets/Audio/Death/deathc1.WAV"),
	preload("res://Assets/Audio/Death/deathc3.WAV"),
	preload("res://Assets/Audio/Death/deathc4.WAV"),
	preload("res://Assets/Audio/Death/deathc51.WAV"),
	preload("res://Assets/Audio/Death/deathc52.WAV"),
	preload("res://Assets/Audio/Death/deathc53.WAV")
]

const WALK_SPEED = 5.0
const RUN_SPEED = 6.5

const WALK_FOV = 70.0
const RUN_FOV = 80.0

const JUMP_VELOCITY = 4.0
const MOUSE_SENSTIVITY = 0.002
const ACCELERATION_SPEED = 10.0
const DECELERATION_SPEED = 10.0

@onready var pivot: Node3D = $Pivot
@onready var camera: Camera3D = %Camera

@onready var death_sound: AudioStreamPlayer3D = $DeathSound
@onready var death_animator: AnimationPlayer = $DeathOverlay/DeathAnimator

@onready var announcer: AudioStreamPlayer = $Announcer

var speed := WALK_SPEED
var running := false

@export var health := 10

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * MOUSE_SENSTIVITY)
			pivot.rotate_x(-event.relative.y * MOUSE_SENSTIVITY)
			pivot.rotation.x = clampf(pivot.rotation.x, -1.57, 1.57)
			return

func _physics_process(delta) -> void:
	if not is_multiplayer_authority(): return
	
	camera.current = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if health <= 0:
		kill()

	# Handle running.
	running = Input.is_action_pressed("run")
	if running:
		speed = move_toward(speed, RUN_SPEED, delta * 7.5)
		camera.fov = lerpf(camera.fov, RUN_FOV, delta * 7.5)
	else:
		speed = lerpf(speed, WALK_SPEED, delta * 7.5)
		camera.fov = lerpf(camera.fov, WALK_FOV, delta * 7.5)

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta * DECELERATION_SPEED)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta * DECELERATION_SPEED)
	else:
		velocity.x = lerpf(velocity.x, 0.0, delta * DECELERATION_SPEED)
		velocity.z = lerpf(velocity.z, 0.0, delta * DECELERATION_SPEED)

	move_and_slide()

@rpc("any_peer")
func hit() -> void:
	health -= 1

func kill() -> void:
	death_sound.stream = DEATH_SOUNDS.pick_random()
	death_sound.play()
	death_animator.play("death")
	position = get_parent().spawn_points.pick_random().position
	health = 10
