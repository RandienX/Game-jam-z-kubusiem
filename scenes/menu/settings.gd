extends CenterContainer

@onready var master_slider = $TabContainer/Settings_/Settings/MasterVolume/VBoxContainer/Slider
@onready var music_slider = $TabContainer/Settings_/Settings/MusicVolume/VBoxContainer/Slider
@onready var sfx_slider = $TabContainer/Settings_/Settings/SfxVolume/VBoxContainer/Slider

@onready var master_value_label = $TabContainer/Settings_/Settings/MasterVolume/VBoxContainer/ValueLabel
@onready var music_value_label = $TabContainer/Settings_/Settings/MusicVolume/VBoxContainer/ValueLabel
@onready var sfx_value_label = $TabContainer/Settings_/Settings/SfxVolume/VBoxContainer/ValueLabel

@onready var skip_cutscenes_checkbox = $TabContainer/Settings_/Settings/SkipCutscenes/CheckBox

func _ready() -> void:
	_load_settings_to_ui()

func _load_settings_to_ui() -> void:
	if not Settings:
		return

	var settings = Settings
	master_slider.value = settings.master_volume
	music_slider.value = settings.music_volume
	sfx_slider.value = settings.sfx_volume
	skip_cutscenes_checkbox.button_pressed = settings.skip_cutscenes

	_update_value_labels()

func _update_value_labels() -> void:
	master_value_label.text = str(round(master_slider.value * 100)) + "%"
	music_value_label.text = str(round(music_slider.value * 100)) + "%"
	sfx_value_label.text = str(round(sfx_slider.value * 100)) + "%"

func _on_master_volume_changed(value: float) -> void:
	if Settings:
		Settings.set_master_volume(value)
	_update_value_labels()

func _on_music_volume_changed(value: float) -> void:
	if Settings:
		Settings.set_music_volume(value)
	_update_value_labels()

func _on_sfx_volume_changed(value: float) -> void:
	if Settings:
		Settings.set_sfx_volume(value)
	_update_value_labels()

func _on_skip_cutscenes_toggled(toggled_on: bool) -> void:
	if Settings:
		Settings.set_skip_cutscenes(toggled_on)

func _on_save_pressed() -> void:
	if Settings:
		Settings.save_settings()
		print("[Settings UI] Settings saved successfully!")
