extends StaticBody


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
	
	$MeshInstance.mesh.material.emission_enabled = active
	$MeshInstance2.mesh.material.emission_enabled = active
	
	$ConnectingArea.monitorable = active and not connected
	
	print("tube activated" if active else "tube deactivated")


func check_connected():
	var conn = $ConnectingArea.get_overlapping_areas().size() > 0
	set_connected(conn)
