extends Control

@export var main: CenterContainer
@export var play: CenterContainer
@export var sett: CenterContainer

func _on_play_pressed() -> void:
	main.visible = false
	sett.visible = false
	play.visible = true

func _on_settings_pressed() -> void:
	main.visible = false
	sett.visible = true
	play.visible = false

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_save_settings_pressed() -> void:
	return_to_main_menu()

func return_to_main_menu():
	main.visible = true
	sett.visible = false
	play.visible = false

func _on_back_button_pressed() -> void:
	return_to_main_menu()
