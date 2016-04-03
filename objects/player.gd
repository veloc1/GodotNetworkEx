
extends RigidBody2D

var _user


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func associate_user(user):
	_user = user

func get_user():
	return _user
