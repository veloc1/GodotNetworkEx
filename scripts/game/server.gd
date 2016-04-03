
extends Object

var User

var _network
var _users
var _id

func _init():
	_users = []
	var Network = load("res://scripts/network.gd")
	_network = Network.new()
	_network.set_port(3998)
	_network.set_send_addr("localhost")
	_network.set_send_port(3999)
	_network.start()
	User = load("res://scripts/game/user.gd")
	_id = 0

func get_network_data(view_node):
	if get_error() != OK:
		return
	var packets = _network.get_data()
	for packet in packets:
		if packet["data"].begins_with("Handshake"):
			var username = packet["data"].substr(packet["data"].find("Handshake ") + 10, packet["data"].length())
			var user = User.new()
			user.id = _id
			_id = _id + 1
			user.name = username
			user.host = packet.host
			user.last_online = OS.get_ticks_msec()
			_network.set_send_addr(packet.host)
			_network.send("Handshake " + str(user.id))
			_users.append(user)
		elif packet["data"].begins_with("Upd"):
			var actions = packet["data"].split("\n")
			var id = actions[0].substr(4, packet["data"].length())
			for u in _users:
				if u.id == int(id):
					u.last_online = OS.get_ticks_msec()
					if u.actions == null:
						u.actions = []
					for a in actions:
						u.actions.append(a)
		else:
			pass
	for i in range(_users.size()):
		if i >= _users.size():
			return
		if _users[i].last_online + 1000 < OS.get_ticks_msec():
			_users.remove(i)
			i = i - 1

func send_update():
	var data = ""
	for user in _users:
		data += user.save().to_json() + "\n"
	for user in _users:
		_network.set_send_addr(user.host)
		_network.send("Upd \n" + data)

func update(view_node):
	for user in _users:
		var node = view_node.get_node(str(user.id))
		if node != null:
			user.x = node.get_pos().x
			user.y = node.get_pos().y
			user.rotation = node.get_rot()
	get_network_data(view_node)
	
	send_update()

func get_users():
	return _users

func get_error():
	return _network.get_error()