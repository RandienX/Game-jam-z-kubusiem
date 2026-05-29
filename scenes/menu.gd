extends Control

@export var main: CenterContainer
@export var play: CenterContainer
@export var sett: CenterContainer

func _on_play_pressed() -> void:
	main.visible = false
	sett.visible = false
	play.visible = true

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_exit_pressed() -> void:
	get_tree().quit()
