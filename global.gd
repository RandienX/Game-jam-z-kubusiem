extends Node

var damian: CharacterBody2D = null
var ksiegi: int = 0 #jak 8 to secret lvl jezeli damy rade
var last_lvl: int = 0 #jaki lvl unlock

func finish_level():
	var level = get_tree().current_scene
	if level.level_id > last_lvl:
		last_lvl = level.level_id
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
