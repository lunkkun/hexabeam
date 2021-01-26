tool
extends StaticBody


signal selected

const MAX_INPUT_BUFFER = 1
const SELECT_ELEVATION_Z = 0.35
const SELECT_ELEVATION_TIME = 0.25
const ROTATE_LEFT = 60
const ROTATE_RIGHT = -60
const ROTATE_TIME = 0.2

export(int, 1, 2) var layout = 1 setget set_layout
export(int, 0, 5) var orientation setget set_orientation # initial

var active = false setget set_active
var selected = false setget set_selected
var input_buffering = false
var input_buffer = []

onready var initial_z = translation.z
onready var _tubes = $Tubes.get_children()


func _ready():
	for tube in _tubes:
		tube.connect("connected", self, "_on_Tube_connected", [tube])
		tube.connect("disconnected", self, "_on_Tube_disconnected", [tube])


func _unhandled_input(event):
	if event.is_action_pressed("rotate_left"):
		if input_buffering:
			_buffer_input([event, "_unhandled_input"])
		else:
			tween_rotate(ROTATE_LEFT)
	elif event.is_action_pressed("rotate_right"):
		if input_buffering:
			_buffer_input([event, "_unhandled_input"])
		else:
			tween_rotate(ROTATE_RIGHT)

func _input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		if input_buffering:
			_buffer_input([camera, event, click_position, click_normal, shape_idx, "_input_event"])
		else:
			set_selected(!selected)


func _buffer_input(input):
	if input_buffer.size() < MAX_INPUT_BUFFER:
		input_buffer.append(input)


func _process(_delta):
	if not input_buffering and input_buffer.size():
		var input = input_buffer.pop_front()
		callv(input.pop_back(), input)


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
	if selected == value:
		return
	
	input_buffering = true
	
	selected = value
	
	if selected:
		emit_signal("selected")
	
	var to = initial_z + (SELECT_ELEVATION_Z if selected else 0.0)
	$Tween.interpolate_property(self, "translation:z", null, to, SELECT_ELEVATION_TIME)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	input_buffering = false


func tween_rotate(degrees):
	if not selected:
		return
	
	input_buffering = true
	
	var to = rotation_degrees.z + degrees
	$Tween.interpolate_property(self, "rotation_degrees:z", null, to, ROTATE_TIME)
	$Tween.start()
	
	yield($Tween, "tween_completed")
	
	input_buffering = false


func _on_Tube_connected(_tube):
	set_active(true)


func _on_Tube_disconnected(_tube):
	set_active(false)
