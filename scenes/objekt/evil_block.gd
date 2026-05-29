extends StaticBody2D

@export var bounce_force := -400.0
@export var start_delay := 0.0 # Optional: delay before becoming solid

var is_active := false
@onready var col_shape := $CollisionShape2D
@onready var anim := $AnimationPlayer

func _ready() -> void:
	visible = false
	col_shape.disabled = true

func _on_start_body_entered(body: Node2D) -> void:
	if body == Global.damian and is_active == false and Global.damian.velocity.y <= 0:
		activate()

func activate() -> void:
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
		
	is_active = true
	visible = true
	col_shape.set_deferred("disabled", false)
	
	# Bounce player
	if Global.damian.velocity.y <= 0: 
		Global.damian.velocity.y = bounce_force
		
	$AnimationPlayer.play("bonk")
