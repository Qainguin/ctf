extends Node3D

const PLAYER = preload("res://Scenes/player.tscn")

@onready var orbit: Node3D = $Orbit
@onready var main_menu: CanvasLayer = $MainMenu

var address := "192.168.50.112"
var port := 7776
var peer := ENetMultiplayerPeer.new()

var spawn_points: Array[Area3D] = []

@export var next_team := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for sp in get_children():
		if sp.name.contains("SpawnPoint"):
			spawn_points.append(sp)

func _process(delta: float) -> void:
	orbit.rotate_y(delta / 2)

func add_player(peer_id := 1) -> void:
	var p = PLAYER.instantiate()
	p.team = next_team
	var sp = next_team * 2
	p.name = str(peer_id)
	p.position = spawn_points[sp].position
	add_child(p, true)
	p.owner = self
	
	print("added player on team " + str(p.team))

func remove_player(peer_id: int) -> void:
	get_node(NodePath(str(peer_id))).queue_free()

func host() -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.multiplayer_peer.peer_connected.connect(add_player)
	multiplayer.multiplayer_peer.peer_disconnected.connect(remove_player)
	main_menu.hide()
	orbit.get_child(0).current = false
	add_player(1)
	
	upnp_setup()

func upnp_setup() -> void:
	var upnp = UPNP.new()
	
	var discovery_result = upnp.discover()
	assert(discovery_result == UPNP.UPNP_RESULT_SUCCESS)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway())
	
	var map_result = upnp.add_port_mapping(port)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS)
	
	print("Success! Join Address: %s" % upnp.query_external_address())

func join() -> void:
	peer.create_client(address, port)
	multiplayer.multiplayer_peer = peer
	main_menu.hide()
	orbit.get_child(0).current = false
