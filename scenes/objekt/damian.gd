extends CharacterBody2D

@export var SPEED := 300.0
@export var JUMP_VELOCITY := -600.0
@export var WALL_SLIDE_SPEED := 100.0

# Wall jump
@export var WALL_JUMP_FORCE_Y := -500.0
@export var WALL_JUMP_FORCE_X := 600.0 
@export var WALL_JUMP_ACCEL := 2000.0
@export var WALL_JUMP_DURATION := 0.1

# Movement & Slipperiness
@export var ACCELERATION := 1800.0
@export var FRICTION := 2000.0   # Lower = more slippery
@export var AIR_ACCELERATION := 1200.0
@export var AIR_FRICTION := 200.0 # Low air friction preserves momentum

@export var MAX_JUMPS := 1
@export var MAX_WALL_JUMPS := 3

var jump_count := 0
var wall_jumps_remaining := 0
var wall_jump_active := false
var wall_jump_target_x := 0.0
var wall_jump_timer := 0.0
var was_on_wall := false

@onready var anim = $AnimatedSprite2D

func _ready() -> void:
	Global.damian = self

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jump_count = 0
		wall_jumps_remaining = MAX_WALL_JUMPS

	var direction := Input.get_axis("left", "right")
	var on_wall := is_on_wall() and not is_on_floor()

	# Wall slide
	var wall_sliding := false
	if on_wall and direction != 0 and not wall_jump_active:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		wall_sliding = true

	# Wall jump
	_handle_wall_jump(direction, on_wall, delta)

	# Normal horizontal movement (acceleration/friction)
	if not wall_jump_active:
		var current_accel := ACCELERATION
		var current_friction := FRICTION
		
		# Adjust for air control (less friction = more momentum)
		if not is_on_floor():
			current_accel = AIR_ACCELERATION
			current_friction = AIR_FRICTION

		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, current_accel * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_friction * delta)

	# Regular jump
	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS and not on_wall:
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Apply physics & sync with platforms
	move_and_slide()
	_animate(direction, wall_sliding)

func _handle_wall_jump(direction: float, on_wall: bool, delta: float) -> void:
	if on_wall and not wall_jump_active:
		if Input.is_action_just_pressed("jump") and wall_jumps_remaining > 0:
			var wall_dir := get_wall_normal().x
			wall_jump_target_x = wall_dir * WALL_JUMP_FORCE_X
			wall_jump_active = true
			wall_jump_timer = WALL_JUMP_DURATION
			velocity.y = WALL_JUMP_FORCE_Y
			wall_jumps_remaining -= 1

	if wall_jump_active:
		# Smooth pushback override
		velocity.x = move_toward(velocity.x, wall_jump_target_x, WALL_JUMP_ACCEL * delta)
		wall_jump_timer -= delta
		if wall_jump_timer <= 0:
			wall_jump_active = false

func _animate(direction: float, wall_sliding: bool) -> void:
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true

	if wall_sliding:
		anim.play("wall_slide")
	elif not is_on_floor():
		anim.play("jump" if velocity.y < 0 else "fall")
	elif direction != 0:
		anim.play("run")
	else:
		anim.play("idle")
