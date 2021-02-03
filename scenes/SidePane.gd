tool
extends StaticBody


signal connected


export var is_source = false setget set_is_source

onready var _tube = $Tube


func _ready():
	_tube.active = is_source


func set_is_source(value: bool):
	is_source = value
	if _tube:
		_tube.active = is_source


func _on_Tube_connected():
	_tube.active = true
	
	emit_signal("connected")


func _on_Tube_disconnected():
	_tube.active = is_source
