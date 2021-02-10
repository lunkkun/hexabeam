extends Spatial


signal completed

const TRANSITION_Z = 5
const TRANSITION_DEG_Z = 180

var tile_transition_time: float
var tiles_transitioned = 0

onready var _tiles = $Tiles.get_children()
onready var _tile_count = _tiles.size()


func _ready():
	for tile in _tiles:
		tile.connect("selected", self, "_on_Tile_selected", [tile])


func transition_in(transition_time, transition_x):
	_transition_x(transition_time, transition_x)
	_transition_tiles(transition_time)


func transition_out(transition_time, transition_x):
	_transition_x(transition_time, transition_x)


func _transition_x(transition_time, transition_x):
	for tile in _tiles:
		tile.selected = false
		tile.input_ray_pickable = false
		
	var to_x = translation.x + transition_x
	$TransitionTween.interpolate_property(self, "translation:x", null, to_x, transition_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$TransitionTween.start()


func _transition_tiles(transition_time):
	for tile in _tiles:
		tile.translation.z -= TRANSITION_Z
		tile.rotation_degrees.z -= TRANSITION_DEG_Z
	
	var tile_time_offset = transition_time / 2 / _tile_count
	tile_transition_time = transition_time - (tile_time_offset * (_tile_count - 1))
	
	tiles_transitioned = 0
	_transition_tile()
	
	$TransitionTimer.wait_time = tile_time_offset
	$TransitionTimer.start()


func _transition_tile():
	if tiles_transitioned < _tile_count:
		print("transitioning tile " + str(tiles_transitioned))
		var tile = _tiles[tiles_transitioned]
		tile.transition_in(tile_transition_time, TRANSITION_Z, TRANSITION_DEG_Z)
		tiles_transitioned += 1


func _on_TransitionTimer_timeout():
	_transition_tile()
	
	if tiles_transitioned >= _tile_count:
		$TransitionTimer.stop()


func _on_TransitionTween_tween_all_completed():
	for tile in _tiles:
		tile.input_ray_pickable = true


func _on_Tile_selected(selected_tile):
	for tile in _tiles:
		if tile != selected_tile:
			tile.selected = false


func _on_SidePaneRight_connected():
	print("level completed")
	emit_signal("completed")
