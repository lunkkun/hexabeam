tool
extends StaticBody


const EMISSION_COLOR = Color("1bd037")

signal connected
signal disconnected

var connected = false setget set_connected
var active = false setget set_active


func _physics_process(_delta):
	check_connected()


func set_connected(value: bool):
	if connected == value:
		return
	
	connected = value
	
	if connected:
		emit_signal("connected")
	else:
		emit_signal("disconnected")


func set_active(value: bool):
	if active == value:
		return
	
	active = value
	
	var material = $MeshInstance.mesh.material
	material.emission = EMISSION_COLOR
	material.emission_enabled = active
	
	print("tube activated" if active else "tube deactivated")


func check_connected():
	var overlapping = $ConnectingArea.get_overlapping_areas()
	
	var conn = false
	if overlapping.size() > 0:
		var tube = overlapping[0].get_parent()
		if tube.active and not tube.connected:
			conn = true
		
	set_connected(conn)
