extends Node2D

signal play_ui_focus_sound()

onready var config_tab_node = $MarginContainer/MainTabContainer/Configuration
onready var controls_tab_node = $MarginContainer/MainTabContainer/Controls

# Called when the node enters the scene tree for the first time.
func _ready():
	change_tab_container_state(false)
	# connect signals to every input button in group via code
	# this prevents user input misspelling
	# (additionally this allows for instancing input control elements via code if desired)
	connect_input_buttons_to_input_prompt_popup()
	# this parent script loads from disk the options setting
	# this script then calls child tab script methods for setting node options
	config_tab_node.set_config_node_properties(load_config_settings_from_disk())
	controls_tab_node.set_input_node_properties(load_input_settings_from_disk())


func _input(event):
	if event is InputEventJoypadButton\
	 or event is InputEventJoypadMotion and event.axis_value > 0.1:
		$MarginContainer/ControllerBumperPromptRight.visible = true
		$MarginContainer/ControllerBumperPromptLeft.visible = true
		if event is InputEventJoypadButton and event.pressed == true:
			if event.button_index in [JOY_BUTTON_5, JOY_BUTTON_4, JOY_R, JOY_L]:
				var main_tab_node = $MarginContainer/MainTabContainer
#				main_tab_node.grab_focus()
				if main_tab_node.current_tab + 1 > main_tab_node.get_child_count()-1:
					main_tab_node.current_tab = 0
				else:
					main_tab_node.current_tab += 1
				
	elif event is InputEventMouse:
		$MarginContainer/ControllerBumperPromptLeft.visible = false
		$MarginContainer/ControllerBumperPromptRight.visible = false

func change_focused_tab():
	pass

#####################################


func change_tab_container_state(options_menu_is_active):
	var main_tabs = $MarginContainer/MainTabContainer
	var control_tabs = $MarginContainer/MainTabContainer/Controls/ControlSubTabContainer
	if options_menu_is_active:
		main_tabs.mouse_filter = main_tabs.MOUSE_FILTER_STOP
		control_tabs.mouse_filter = control_tabs.MOUSE_FILTER_STOP
	elif not options_menu_is_active:
		main_tabs.mouse_filter = main_tabs.MOUSE_FILTER_IGNORE
		control_tabs.mouse_filter = control_tabs.MOUSE_FILTER_IGNORE


#####################################

func get_button_action(button_node):
	var bn_parent = button_node.get_parent()
	if bn_parent != null:
		if bn_parent.is_in_group("options_button_input_control_box"):
			if bn_parent.get_parent() != null:
				bn_parent = bn_parent.get_parent()
				if bn_parent.is_in_group("options_button_input_action"):
					return bn_parent.name
				else:
					return null


func get_button_platform(button_node):
	if button_node.is_in_group("options_button_kbm1") or\
	button_node.is_in_group("options_button_kbm2"):
#		return 0
		return GlobalRef.PLATFORM.PC
	elif button_node.is_in_group("options_button_ps"):
#		return 1
		return GlobalRef.PLATFORM.PLAYSTATION
	elif button_node.is_in_group("options_button_xbox"):
#		return 2
		return GlobalRef.PLATFORM.XBOX
	else:
		return null


#####################################

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#####################################

func play_focus_audio():
	emit_signal("play_ui_focus_sound")
	pass
	#defunct
#	if $TitleUI_FocusChange.playing:
#		$TitleUI_FocusChange.stop()
#	$TitleUI_FocusChange.play()


func _on_VolumeSE_play_ui_focus():
	play_focus_audio()


func _on_OptionsMenu_submenu_opened():
	change_tab_container_state(true)
	visible = true


func _on_OptionsMenu_submenu_return():
	change_tab_container_state(false)
	visible = false
	config_tab_node.write_config_node_properties()
	controls_tab_node.write_input_node_properties()


func connect_input_buttons_to_input_prompt_popup():
	for button_node in get_tree().get_nodes_in_group("options_button_input"):
		var action_name = get_button_action(button_node)
		var platform_id = get_button_platform(button_node)
		button_node.connect("pressed",\
		 $InputPromptPopup, "_on_Controls_call_input_prompt",\
		 [button_node, action_name, platform_id])#, owner_node])


func load_config_settings_from_disk():
	var config_settings
	# if user file doesn't exist revert to default settings in res://def
	if GlobalData.validate_file_path(GlobalRef.CONFIGURATION_SETTINGS_USER):
		config_settings = GlobalData.open_and_return_file_json_str_as_dict(\
		GlobalRef.CONFIGURATION_SETTINGS_USER)

	else:
		config_settings = GlobalData.open_and_return_file_json_str_as_dict(\
		GlobalRef.CONFIGURATION_SETTINGS_DEFAULT)
	return config_settings


func load_input_settings_from_disk():
	var config_settings
	# if user file doesn't exist revert to default settings in res://def
	if GlobalData.validate_file_path(GlobalRef.INPUT_MAP_SETTINGS_USER):
		config_settings = GlobalData.open_and_return_file_as_string(\
		GlobalRef.INPUT_MAP_SETTINGS_USER)
	else:
		config_settings = GlobalData.open_and_return_file_as_string(\
		GlobalRef.INPUT_MAP_SETTINGS_DEFAULT)
	return config_settings


# defunct
#func _on_Configuration_write_config_settings_to_disk(new_settings):
#	# will overwrite the user settings even if the file doesn't exist
#	# this ensures a user settings file is created if one can't be found
#	GlobalData.open_and_overwrite_file_with_string(\
#	GlobalRef.CONFIGURATION_SETTINGS_USER, new_settings, true)
