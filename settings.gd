extends Node
## Settings - Autoload singleton for managing game settings
## Handles settings, controls, and gameplay settings with save/load functionality

signal settings_changed(category: String, key: String, value: Variant)

# === Settings ===
var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0
var skip_cutscenes: bool = false

# === Control Settings ===
var control_mappings: Dictionary = {
	"left": "A",
	"jump": "Space", 
	"right": "D",
	"throw": "Enter",
}

const SETTINGS_FILE := "user://settings.json"

func _ready() -> void:
	load_settings()
	_apply_settings_settings()

func _apply_settings_settings() -> void:
	_apply_master_volume()
	_apply_music_volume()
	_apply_sfx_volume()

func _apply_master_volume() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus >= 0:
		AudioServer.set_bus_volume_db(master_bus, linear_to_db(master_volume))

func _apply_music_volume() -> void:
	var music_bus = AudioServer.get_bus_index("Music")
	if music_bus >= 0:
		AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))

func _apply_sfx_volume() -> void:
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if sfx_bus >= 0:
		AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

# ============================================================================

## Set master volume (0.0 to 1.0)
func set_master_volume(value: float) -> void:
	master_volume = clamp(value, 0.0, 1.0)
	_apply_settings_settings()
	settings_changed.emit("settings", "master_volume", master_volume)

## Set music volume (0.0 to 1.0)
func set_music_volume(value: float) -> void:
	music_volume = clamp(value, 0.0, 1.0)
	_apply_settings_settings()
	settings_changed.emit("settings", "music_volume", music_volume)

## Set SFX volume (0.0 to 1.0)
func set_sfx_volume(value: float) -> void:
	sfx_volume = clamp(value, 0.0, 1.0)
	_apply_settings_settings()
	settings_changed.emit("settings", "sfx_volume", sfx_volume)

## Toggle cutscene skipping
func set_skip_cutscenes(value: bool) -> void:
	skip_cutscenes = value
	settings_changed.emit("gameplay", "skip_cutscenes", skip_cutscenes)

## Update a control mapping
func set_control_mapping(action: String, key_name: String) -> void:
	control_mappings[action] = key_name
	settings_changed.emit("controls", action, key_name)

## Get all settings as a dictionary for saving
func get_save_data() -> Dictionary:
	return {
		"settings": {
			"master_volume": master_volume,
			"music_volume": music_volume,
			"sfx_volume": sfx_volume,
			"skip_cutscenes": skip_cutscenes
		},
		"controls": control_mappings.duplicate()
	}

## Load settings from a dictionary
func load_from_data(data: Dictionary) -> void:
	if data.has("settings"):
		var settings = data["settings"]
		master_volume = settings.get("master_volume", master_volume)
		music_volume = settings.get("music_volume", music_volume)
		sfx_volume = settings.get("sfx_volume", sfx_volume)
		skip_cutscenes = settings.get("skip_cutscenes", skip_cutscenes)
	
	if data.has("controls"):
		for key in data["controls"]:
			control_mappings[key] = data["controls"][key]
	
	_apply_settings_settings()

## Save settings to file
func save_settings() -> bool:
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	if not file:
		push_error("[Settings] Failed to open settings file for writing")
		return false
	
	var data = get_save_data()
	file.store_string(JSON.stringify(data, "  "))
	file.close()
	print("[Settings] Settings saved")
	return true

## Load settings from file
func load_settings() -> bool:
	if not FileAccess.file_exists(SETTINGS_FILE):
		print("[Settings] No settings file found, using defaults")
		return false
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
	if not file:
		push_error("[Settings] Failed to open settings file for reading")
		return false
	
	var json = JSON.parse_string(file.get_as_text())
	file.close()
	
	if not json or not json is Dictionary:
		push_error("[Settings] Corrupted settings file")
		return false
	
	load_from_data(json)
	print("[Settings] Settings loaded")
	return true

## Reset all settings to defaults
func reset_to_defaults() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	skip_cutscenes = false
	control_mappings = {
		"left": "A",
		"jump": "Space", 
		"right": "D",
		"throw": "Enter",
	}
	_apply_settings_settings()
	settings_changed.emit("all", "reset", null)
