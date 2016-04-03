
extends Node

var Player

var _server
var _client
var _last_id

func _ready():
	Player = load("res://objects/player.scn")
	if get_node("/root/globals").is_server:
		var Server = load("res://scripts/game/server.gd")
		_server = Server.new()
		set_status(_server.get_error())
		
		if (_server.get_error() == OK):
			set_status("Connected")
	else :
		set_status("Waiting")
	
	var Client = load("res://scripts/game/client.gd")
	_client = Client.new()
	_client.set_username(get_node("/root/settings").get_param("username"))
	if get_node("/root/globals").is_server:
		_client.set_addr("localhost")
	else:
		_client.set_addr(get_node("/root/globals").addr)
	_client.start()
	
	_last_id = 0
	
	set_fixed_process(true)

func _fixed_process(delta):
	if get_node("/root/globals").is_server:
		if (_server.get_error() != OK):
			return
			
		_server.update(self)
		
		var data = ""
		var users = _server.get_users()
		for i in users:
			var player
			if not has_node(str(i.id)):
				player = Player.instance()
				player.set_name(str(i.id))
				player.set_pos(Vector2(300, 0))
				player.associate_user(i)
				add_child(player)
				
				if int(i.id) > _last_id:
					_last_id = int(i.id)
			else:
				if i.actions == null:
					continue
				else:
					player = get_node(str(i.id))
					for a in i.actions:
						if a == "Key Up":
							player.apply_impulse(Vector2(0, 0), Vector2(0, -20))
						if a == "Key Left":
							player.apply_impulse(Vector2(0, 0), Vector2(-20, 0))
						if a == "Key Right":
							player.apply_impulse(Vector2(0, 0), Vector2(20, 0))
					i.actions.clear()
			data += str(i.id) + " " + i.host + " \t" + i.name + "\n"
		set_status(data)
		
		if _last_id > 0:
			for i in range(_last_id + 1):
				if has_node(str(i)):
					if get_node(str(i)).get_user() != null:
						if get_node(str(i)).get_user().last_online + 1000 < OS.get_ticks_msec():
							remove_child(get_node(str(i)))
	else:
		var users = _client.get_users()
		for i in users:
			var player
			if not has_node(str(i.id)):
				player = Player.instance()
				player.set_name(str(i.id))
				player.set_pos(Vector2(300, 0))
				player.associate_user(i)
				add_child(player)
				
				if int(i.id) > _last_id:
					_last_id = int(i.id)
			else:
				var node = get_node(str(i.id))
				if i.x != null:
					node.set_pos(Vector2(i.x, i.y))
					node.set_rot(i.rotation)
					node.associate_user(i)
		if _last_id > 0:
			for i in range(_last_id + 1):
				if has_node(str(i)):
					if get_node(str(i)).get_user() != null:
						if has_node(str(19)):
							print(get_node(str(19)).get_user().last_online)
							print(str(OS.get_ticks_msec()))
						if get_node(str(i)).get_user().last_online + 1000 < OS.get_ticks_msec():
							print("remove")
							remove_child(get_node(str(i)))
	_client.update(self)

func set_status(status):
	get_node("Status").set_text(str(status))