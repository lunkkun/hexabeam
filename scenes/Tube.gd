tool
extends StaticBody


signal connected
signal disconnected

const EMISSION_COLOR = Color("1bd037")
const EMISSION_ENERGY = 0.75

export var has_joint = false setget set_has_joint

var ready = false
var connected = false setget set_connected
var active = false setget set_active


func _ready():
	ready = true
	set_has_joint(has_joint)


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
	
	var material = $MeshInstanceTube.mesh.material
	material.emission = EMISSION_COLOR
	material.emission_energy = EMISSION_ENERGY
	material.emission_enabled = active
	
	print("tube activated" if active else "tube deactivated")


func set_has_joint(value):
	has_joint = value
	
	if ready:
		$CollisionShapeJoint.disabled = not has_joint
		$MeshInstanceJoint.visible = has_joint


func check_connected():
	var overlapping = $ConnectingArea.get_overlapping_areas()
	
	var conn = false
	if overlapping.size() > 0:
		var tube = overlapping[0].get_parent()
		if tube.active and not tube.connected:
			conn = true
		
	set_connected(conn)
