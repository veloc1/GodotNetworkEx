
extends Object

var id
var name
var host
var last_online
var x
var y
var rotation
var actions

func save():
	var savedict = {
		"id": id,
		"name": name,
		"host": host,
		"x": x,
		"y": y,
		"rotation": rotation,
		"last_online": last_online
	}
	return savedict