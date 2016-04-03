
extends Object

var User

var _network
var _users
var _self
var _username
var _addr
var _actions

func _init():
	_users = []
	_actions = []
	
	User = load("res://scripts/game/user.gd")
	_self = User.new()
	_self.id = -1
	var Network = load("res://scripts/network.gd")
	_network = Network.new()
	_addr = "localhost"

func set_addr(addr):
	_addr = addr

func start():
	_network.set_port(3999)
	_network.set_send_addr(_addr)
	_network.set_send_port(3998)
	_network.start()
	connect_self()

func get_network_data():
	if get_error() != OK:
		return
	var packets = _network.get_data()
	for packet in packets:
		if packet["data"].begins_with("Handshake"):
			var id = packet["data"].substr(packet["data"].find("Handshake ") + 10, packet["data"].length())
			_self.id = int(id)
		elif packet["data"].begins_with("Upd"):
			_users.clear()
			var updates = packet["data"].split("\n")
			for i in range(1, updates.size()):
				var user = {}
				user.parse_json(updates[i])
				if user.size() > 0:
					_users.append(user)
		else:
			pass

func handle_input(view_node):
	if OS.get_name() == "Android":
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			var mouse_pos = view_node.get_viewport().get_mouse_pos()
			if mouse_pos.y > 500:
				_actions.append("Key Up")
			if mouse_pos.x < 500:
				_actions.append("Key Left")
			if mouse_pos.x > 500:
				_actions.append("Key Right")
	else:
		if Input.is_action_pressed("ui_up"):
			_actions.append("Key Up")
		if Input.is_action_pressed("ui_left"):
			_actions.append("Key Left")
		if Input.is_action_pressed("ui_right"):
			_actions.append("Key Right")

func set_username(name):
	_self.name = name

func get_users():
	return _users

func update(view_node):
	get_network_data()
	if _self.id == -1:
		return
	var data = "Upd " + str(_self.id) + "\n"
	for a in _actions:
		data += a + "\n"
	data += "Endupd"
	_network.send(data)
	
	_actions.clear()
	
	handle_input(view_node)

func connect_self():
	_network.send("Handshake " + _self.name)

func get_error():
	return _network.get_error()
