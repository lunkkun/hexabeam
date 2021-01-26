extends StaticBody


var active = false setget set_active

onready var _tubes = $Tubes.get_children()


func _ready():
	for tube in _tubes:
		tube.connect("connected", self, "_on_Tube_connected", [tube])
		tube.connect("disconnected", self, "_on_Tube_disconnected", [tube])


func set_active(value: bool):
	if active == value:
		return
	
	active = value
	
	for tube in _tubes:
		tube.active = active


func _on_Tube_connected(tube):
	set_active(true)


func _on_Tube_disconnected(tube):
	set_active(false)
