tool
extends StaticBody


const SELECT_ELEVATION_Z = 0.35
const SELECT_ELEVATION_TIME = 0.25
const ROTATE_LEFT = 60
const ROTATE_RIGHT = -60
const ROTATE_TIME = 0.2

export(int, 1, 2) var layout = 1 setget set_layout
export(int, 0, 5) var orientation setget set_orientation # initial

var active = false setget set_active
var selected = false setget set_selected
var buffered_selected = false
var can_rotate = false

var _rotating = false

onready var initial_z = translation.z
onready var _tubes = $Tubes.get_children()


func _ready():
	for tube in _tubes:
		tube.connect("connected", self, "_on_Tube_connected", [tube])
		tube.connect("disconnected", self, "_on_Tube_disconnected", [tube])


func _unhandled_key_input(event):
	if event.is_action_pressed("rotate_left"):
		tween_rotate(ROTATE_LEFT)
	elif event.is_action_pressed("rotate_right"):
		tween_rotate(ROTATE_RIGHT)

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
	
	if $Tween.is_active():
		yield($Tween, "tween_completed")
	
	selected = value
	can_rotate = selected
	
	var to = initial_z + (SELECT_ELEVATION_Z if selected else 0)
	$Tween.interpolate_property(self, "translation:z", null, to, SELECT_ELEVATION_TIME)
	$Tween.start()


func tween_rotate(degrees):
	if not can_rotate:
		return
	
	can_rotate = false # prevent further rotation inputs
	
	if $Tween.is_active():
		yield($Tween, "tween_completed")
	
	var to = rotation_degrees.z + degrees
	$Tween.interpolate_property(self, "rotation_degrees:z", null, to, ROTATE_TIME)
	$Tween.start()
	
	can_rotate = selected # accept rotation inputs again


func _on_Tube_connected(_tube):
	set_active(true)


func _on_Tube_disconnected(_tube):
	set_active(false)
