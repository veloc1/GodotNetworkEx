
extends VBoxContainer

# member variables here, example:
# var a=2
# var b="textvar"

var settings

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	settings = get_node("/root/settings")
	get_node("name").set_text(settings.get_param_with_def_value("username", "player"))
	get_node("HBoxContainer/addr").set_text(settings.get_param_with_def_value("join_addr", "localhost"))

func _on_start_server_pressed():
	settings.save_param("username", get_node("name").get_text())
	get_node("/root/globals").is_server = true
	get_tree().change_scene("res://scenes/test.scn")


func _on_join_server_pressed():
	settings.save_param("username", get_node("name").get_text())
	settings.save_param("join_addr", get_node("HBoxContainer/addr").get_text())
	get_node("/root/globals").is_server = false
	get_node("/root/globals").addr = get_node("HBoxContainer/addr").get_text()
	get_tree().change_scene("res://scenes/test.scn")
