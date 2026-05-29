extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -600.0

# Wall slide
const WALL_SLIDE_SPEED = 100.0

# Wall jump
const WALL_JUMP_FORCE_X = 1200.0
const WALL_JUMP_FORCE_Y = -500.0

# Double jump
const MAX_JUMPS = 2
var jump_count = 0

# Idle timer
var idle_timer = 0.0
const IDLE_DELAY = 3.0

@onready var anim = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
	
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Reset jumps when touching floor
		jump_count = 0

	# Movement input
	var direction := Input.get_axis("ui_left", "ui_right")

	# Flip sprite
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true

	# Normal movement
	if direction:
		velocity.x = direction * SPEED
		idle_timer = 0.0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Jump + Double Jump
	if Input.is_action_just_pressed("ui_accept") and jump_count < MAX_JUMPS:
		velocity.y = JUMP_VELOCITY
		jump_count += 1
		idle_timer = 0.0

	# Wall slide
	var wall_sliding = false

	if is_on_wall() and not is_on_floor() and direction != 0:
		if velocity.y > WALL_SLIDE_SPEED:
			velocity.y = WALL_SLIDE_SPEED
		
		wall_sliding = true
		idle_timer = 0.0

	# Wall jump
	if is_on_wall() and not is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
			
			# direction from wall
			var wall_dir = get_wall_normal().x
			
			velocity.x = wall_dir * WALL_JUMP_FORCE_X
			velocity.y = WALL_JUMP_FORCE_Y
			idle_timer = 0.0

	move_and_slide()

	# =========================
	# IDLE TIMER
	# =========================

	if direction == 0 and is_on_floor():
		idle_timer += delta
	else:
		idle_timer = 0.0

	# =========================
	# ANIMATIONS
	# =========================

	if wall_sliding:
		anim.play("wall_slide")

	elif not is_on_floor():

		if velocity.y < 0:
			anim.play("jump")
		else:
			anim.play("fall")

	elif direction != 0:
		anim.play("run")

	else:
		if idle_timer >= IDLE_DELAY:
			anim.play("idle")
