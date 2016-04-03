
extends Node

var settings_file
var settings

func _ready():
	settings = {}
	_read_file()

func _read_file():
	settings_file = File.new()
	if !settings_file.file_exists("user://settings.sav"):
		return
	settings_file.open("user://settings.sav", File.READ)
	settings = {}
	settings.parse_json(settings_file.get_line())
	settings_file.close()

func get_param(name):
	if settings.has(name):
		return settings[name]
	return null

func get_param_with_def_value(name, def_val):
	if settings.has(name):
		return settings[name]
	else :
		return def_val

func save_param(name, value):
	settings[name] = value
	_save()

func _save():
	settings_file.open("user://settings.sav", File.WRITE)
	settings_file.store_line(settings.to_json())
	settings_file.close()