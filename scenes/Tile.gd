tool
extends StaticBody


const SELECT_ELEVATION = 0.5

export(int, 1, 2) var layout = 1 setget set_layout
export(int, 0, 5) var orientation setget set_orientation

var active = false setget set_active
var selected = false setget set_selected
var buffered_selected = false
var can_rotate = false

onready var initial_z = translation.z
onready var _tubes = $Tubes.get_children()


func _ready():
	for tube in _tubes:
		tube.connect("connected", self, "_on_Tube_connected", [tube])
		tube.connect("disconnected", self, "_on_Tube_disconnected", [tube])


func _input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		set_selected(!selected)


func set_layout(value: int):
	layout = value
	
	$Tubes.get_child(1).rotation_degrees.z = -60 * layout


func set_orientation(value: int):
	orientation = value
	
	rotation_degrees.z = -60 * orientation


func set_active(value: bool):
	if active == value:
		return
	
	active = value
	
	for tube in _tubes:
		tube.active = active


func set_selected(value: bool):
	if buffered_selected == value:
		return
	
	buffered_selected = value
	can_rotate = false
	
	if $Tween.is_active():
		yield($Tween, "tween_completed")
	
	selected = value
	
	var to = initial_z + selected * SELECT_ELEVATION
	$Tween.interpolate_property(self, "translation:z", null, to, 0.4)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	can_rotate = selected


func _on_Tube_connected(_tube):
	set_active(true)


func _on_Tube_disconnected(_tube):
	set_active(false)
