
extends Object

var _udp = PacketPeerUDP.new()
var _port = 15998
var _send_port = 15999
var _addr = "127.0.0.1"
var _err = null

func _init():
	pass

func set_port(port):
	_port = port

func set_send_addr(addr):
	_addr = addr
	if _udp.is_listening():
		_udp.set_send_address(_addr, _send_port)

func set_send_port(port):
	_send_port = port
	if _udp.is_listening():
		_udp.set_send_address(_addr, _send_port)

func start():
	_err = _udp.listen(_port)
	if _err != OK:
		_err = "Can't listen specified port"
	else:
		_udp.set_send_address(_addr, _send_port)

func get_error():
	return _err

func send(data):
	_udp.put_var(data)

func get_data():
	var data = []
	while(_udp.get_available_packet_count() > 0):
		var packet = _udp.get_var()
		if (typeof(packet) == TYPE_STRING):
				var host = _udp.get_packet_ip()
				var port = _udp.get_packet_port()
				data.append({"host": host, "data": packet})
				
	return data