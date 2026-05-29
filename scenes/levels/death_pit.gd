extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body == Global.damian:
		call_deferred("reset")
 
func reset():
	get_tree().change_scene_to_file(get_tree().current_scene.scene_file_path)
