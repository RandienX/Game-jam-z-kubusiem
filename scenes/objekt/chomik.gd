extends AnimatableBody2D

@export var local_points: Array[Vector2] = [Vector2.ZERO, Vector2.RIGHT * 300]
@export var segment_speeds: Array[float] = [150.0]
@export var loop_path: bool = true
@export var pause_at_points: bool = false
@export var pause_duration: float = 0.2
@export var debug_output: bool = false

var global_points: Array[Vector2] = []
var current_idx: int = 0
var next_idx: int = 1
var is_paused: bool = false
var pause_timer: float = 0.0

func _ready() -> void:
	# Convert local editor coordinates to world space ONCE
	global_points.clear()
	for p in local_points:
		global_points.append(to_global(p))
	
	# Start exactly at the first point
	global_position = global_points[0]
	
	# Auto-pad speeds so we never get an index out of bounds
	if segment_speeds.is_empty():
		segment_speeds.append(150.0)
	while segment_speeds.size() < global_points.size():
		segment_speeds.append(segment_speeds[-1])

func _physics_process(delta: float) -> void:
	if global_points.size() < 2:
		if debug_output: printerr("⚠️ Points array has less than 2 entries!")
		return

	if is_paused:
		pause_timer -= delta
		if pause_timer <= 0.0:
			is_paused = false
		return

	var target_pos: Vector2 = global_points[next_idx]
	var speed: float = segment_speeds[current_idx]
	var move_step: float = speed * delta
	var current_pos: Vector2 = global_position
	var dist: float = current_pos.distance_to(target_pos)

	if debug_output:
		print("📍 IDX: %d→%d | Speed: %.1f | Dist: %.1f | Step: %.1f" % [current_idx, next_idx, speed, dist, move_step])

	# Snap to target if we're close enough or will overshoot
	if dist <= move_step + 1.5:
		global_position = target_pos
		if pause_at_points:
			is_paused = true
			pause_timer = pause_duration
		_advance_target()
	else:
		# Smooth linear movement
		var direction: Vector2 = (target_pos - current_pos).normalized()
		global_position += direction * move_step

func _advance_target() -> void:
	current_idx = next_idx
	next_idx += 1

	if next_idx >= global_points.size():
		if loop_path:
			next_idx = 0
		else:
			next_idx = global_points.size() - 1
			# Stops moving at the final point
