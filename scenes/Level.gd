extends Spatial


signal completed


onready var _tiles = $Tiles.get_children()


func _ready():
	for tile in _tiles:
		tile.connect("selected", self, "_on_Tile_selected", [tile])


func _on_Tile_selected(selected_tile):
	for tile in _tiles:
		if tile != selected_tile:
			tile.selected = false


func _on_SidePaneRight_connected():
	print("level completed")
	emit_signal("completed")
