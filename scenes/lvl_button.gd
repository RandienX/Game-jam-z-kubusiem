extends TextureButton

@export var unlock_by_lvl: int
@export var lvl_scene_path: String

func _ready() -> void:
	if unlock_by_lvl <= Global.last_lvl:
		$TextureRect.visible = false
		disabled = false

func _on_pressed() -> void:
	get_tree().change_scene_to_file(lvl_scene_path)
