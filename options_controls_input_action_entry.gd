extends HBoxContainer

var input_prompt_focused = false

var most_recent_input_event_change
var current_input_event_constant
var current_input_event_platform
var current_input_event_texture_path
var current_input_event_label_text

var action_current_inputs = {}

onready var input_button_node_holder = $ControlHBox
onready var input_button_node_pc1 = $ControlHBox/InputKbM1
onready var input_button_node_pc2 = $ControlHBox/InputKbM2
onready var input_texture_button_node_ps = $ControlHBox/InputPS
onready var input_texture_button_node_xb = $ControlHBox/InputXbox

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_action_input_dict()
	update_all_buttons()
	convert_action_string_to_base_node_name_label(name)


func populate_action_input_dict():
	for button_node in input_button_node_holder.get_children():
		action_current_inputs[button_node.name] = null

	# going to set the dict from input map
	for input_event_item in InputMap.get_action_list(name):
		# keyboard & mouse handling
		if input_event_item is InputEventKey\
		or input_event_item is InputEventMouse:
			if action_current_inputs[input_button_node_pc1.name] == null:
				action_current_inputs[input_button_node_pc1.name] = input_event_item
			elif action_current_inputs[input_button_node_pc2.name] == null:
				action_current_inputs[input_button_node_pc2.name] = input_event_item
			# if more than two kbm events for this action, throw error
			else:
				GlobalDebug.log_error("action_entry_populate action_inp_dict: action "+str(name)+" has too many events of "+str(typeof(input_event_item))+", "+str(input_event_item)+" not added")
		
		# joypad handling
		elif input_event_item is InputEventJoypadButton\
		or input_event_item is InputEventJoypadMotion:
			if action_current_inputs[input_texture_button_node_ps.name] == null\
			and action_current_inputs[input_texture_button_node_xb.name] == null:
				action_current_inputs[input_texture_button_node_ps.name] = input_event_item
				action_current_inputs[input_texture_button_node_xb.name] = input_event_item
			# if more than one joypad event for this action, throw error
			else:
				GlobalDebug.log_error("action_entry_populate action_inp_dict: action "+str(name)+" has too many events of type "+str(typeof(input_event_item))+", "+str(input_event_item)+" not added")
		else:
			GlobalDebug.log_error("action_entry_populate action_inp_dict: action "+str(name)+" has an invalid input event ("+str(input_event_item)+") of type "+str(typeof(input_event_item)))


# TODO setting the joypad input should change both/all joypad inputs

# TODO CONTROLS SHOULD LOAD PROJECT MAP FROM DISK BEFOREHAND
# TODO ADD INITIAL ACI DICT SETUP FROM PROJECT MAP ONCE FORMER IS READY


func store_recent_input_event(target_button, new_input_event):
	if action_current_inputs.has(target_button.name):
		action_current_inputs[target_button.name] = new_input_event
		update_project_input_map()


func update_project_input_map():
	InputMap.action_erase_events(name)
	for entry in action_current_inputs:
		if action_current_inputs[entry] != null\
		and action_current_inputs[entry] is InputEvent:
			InputMap.action_add_event(name, action_current_inputs[entry])


func convert_action_string_to_base_node_name_label(action_name):
	if "player" in action_name:
		action_name = action_name.split("player")[0]
#		action_name = action_name[0]
	if "ui_" in action_name:
		action_name = action_name.split("ui_")[1]
#		action_name = action_name[1]

	action_name = action_name.replace("_", " ")
	action_name = action_name.to_upper()
	$ElementLabel.text = action_name


###############################################################################


# this function changes the icon used for the texture button,
# if target node is texture button
# it pulls a path from reference using the action constant
func set_button_input_texture(path_string, target_node, platform):
	
	var texture_normal
	var texture_hover
	
	if target_node == input_texture_button_node_ps\
	and platform == GlobalRef.PLATFORM.PLAYSTATION:
			texture_normal = GlobalRef.PlaystationIconPath_TextureNormal[path_string]
			texture_hover = GlobalRef.PlaystationIconPath_TextureHover[path_string]
			input_texture_button_node_ps.texture_normal = load(texture_normal)
			input_texture_button_node_ps.texture_hover = load(texture_hover)
	
	elif target_node == input_texture_button_node_xb\
	and platform == GlobalRef.PLATFORM.XBOX:
			texture_normal = GlobalRef.XboxIconPath_TextureNormal[path_string]
			texture_hover = GlobalRef.XboxIconPath_TextureHover[path_string]
			input_texture_button_node_xb.texture_normal = load(texture_normal)
			input_texture_button_node_xb.texture_hover = load(texture_hover)

func set_button_input_invalid_texture(target_texture_button_node):
	target_texture_button_node.texture_normal = load(GlobalRef.INVALID_TEXTURE_PATH)
	target_texture_button_node.texture_hover = load(GlobalRef.INVALID_TEXTURE_PATH)


# this function changes the text on the target node, if target node is button
func set_button_input_label(target_node, new_text):
	if target_node == input_button_node_pc1\
	or target_node == input_button_node_pc2:
		target_node.text = new_text


# call update_button_display on each dict entry
func update_all_buttons():
	var target_button_node = null
	for item in action_current_inputs:
		if action_current_inputs[item] != null:
			target_button_node = get_node("ControlHBox/"+str(item))
			update_button_display(target_button_node, action_current_inputs[item])
		else:
			GlobalDebug.log_error("update_all_buttons could not find action_current_inputs value for "+str(item)+" in "+str(name))


# all purpose function finder for setting each of the child buttons
func update_button_display(target_button, new_input_event):
	# keyboard and mouse / pc platform
	if target_button is Button:
		var new_button_string = ""
		if new_input_event is InputEventKey:
			new_button_string = convert_input_event_to_input_constant(new_input_event)
		elif new_input_event is InputEventMouseButton:
			new_button_string = get_mouse_button_string(new_input_event.button_index)
		if new_button_string != "":
			# set as empty
			set_button_input_label(target_button, new_button_string)
		else:
			set_button_input_label(target_button, "")
			GlobalDebug.log_error("update_button_display was passed invalid event and couldn't generate label string, id: "+str(new_input_event))
		
	
	# joypad / xbox or ps platform
	if target_button is TextureButton:
		var path_constant = null
		if new_input_event is InputEventJoypadButton:
			path_constant = convert_input_event_to_input_constant(new_input_event)

		elif new_input_event is InputEventJoypadMotion:
			var axis_is_pos
			if new_input_event.axis_value >= 0.4:
				axis_is_pos = true
			elif new_input_event.axis_value <= -0.4:
				axis_is_pos = false
			else:
				GlobalDebug.log_error("update_button_display given invalid axis value, id " + str(new_input_event))
			
			path_constant = get_joypad_axis_constant(new_input_event.axis, axis_is_pos)
		
		if path_constant != null:
			# set if path constant isn't null
			if target_button == input_texture_button_node_ps:
				set_button_input_texture(path_constant,\
				input_texture_button_node_ps, GlobalRef.PLATFORM.PLAYSTATION)
			elif target_button == input_texture_button_node_xb:
				set_button_input_texture(path_constant,\
				input_texture_button_node_xb, GlobalRef.PLATFORM.XBOX)
			else:
				GlobalDebug.log_error("update_button_display was passed invalid button, id: "+str(target_button)+" & input: "+str(new_input_event))
		else:
			# throw error
			GlobalDebug.log_error("update_button_display did not get path_constant with button: "+str(target_button)+" & input: "+str(new_input_event))
			# set as empty
			set_button_input_invalid_texture(input_texture_button_node_ps)
			set_button_input_invalid_texture(input_texture_button_node_xb)
			
			


# this function converts specific InputEvents
# (Key, MouseButton, JoypadButton, JoypadMotion)
# into the constants listed under globalscope.ButtonList
# will return null if not one of the valid InputEvents
func convert_input_event_to_input_constant(given_input_event):
	var event_string = ""
	if given_input_event is InputEventKey:
		event_string = "KEY_"+str(given_input_event.as_text())
	if given_input_event is InputEventMouseButton:
		event_string = get_mouse_button_list_constant_by_index(given_input_event.button_index)
	if given_input_event is InputEventJoypadButton:
		event_string = "JOY_BUTTON_"+str(given_input_event.button_index)
	if given_input_event is InputEventJoypadMotion:
		if abs(given_input_event.axis_value) >= 0.4:
			event_string = "JOY_AXIS_"+str(given_input_event.axis)
	
	if event_string == "":
		return null
	else:
		return event_string.to_upper()


# TODO combine get_mouse_button_string & convert_mouse_button_list_constant_to_string??
# this function converts from an InputEventMouseButton.button_index
# to an Upper Case string useful for descriptive text on UI buttons
# return null if it is not passed a valid parameter
# for 'get_mouse_button_list_constant_by_index'
func get_mouse_button_string(given_index):
	var button_string = ""
	if given_index is int:
		button_string = get_mouse_button_list_constant_by_index(given_index)
	
	if button_string == "":
		return null
	else:
		return convert_mouse_button_list_constant_to_string(button_string)


# this function converts from an InputEventMouseButton.button_index
# to a string matching the constant in globalscope.ButtonList
# e.g. 1 becomes BUTTON_LEFT, 6 becomes BUTTON_WHEEL_LEFT 
# will return null if not passed an integer between 1 and 9
# note not all button indexes are accounted for
# this function exists to get a string for button labels
func get_mouse_button_list_constant_by_index(given_mouse_button_index):
	var button_constant = ""
	
	match given_mouse_button_index:
		1 : button_constant = "BUTTON_LEFT"
		2 : button_constant = "BUTTON_RIGHT"
		3 : button_constant = "BUTTON_MIDDLE"
		4 : button_constant = "BUTTON_WHEEL_UP"
		5 : button_constant = "BUTTON_WHEEL_DOWN"
		6 : button_constant = "BUTTON_WHEEL_LEFT"
		7 : button_constant = "BUTTON_WHEEL_RIGHT"
		8 : button_constant = "BUTTON_XBUTTON1"
		9 : button_constant = "BUTTON_XBUTTON2"
	
	if button_constant == "":
		return null
	else:
		return button_constant


# this function removes the 'BUTTON_' prefix from a mouse button constant
# if the constant has multiple underscores (i.e. with WHEEL constants)
# the function additionally converts those underscores to space characters
# will return null if not passed a string argument
func convert_mouse_button_list_constant_to_string(given_button_constant):
	if given_button_constant is String:
		var constant_split = given_button_constant.split("_", false, 1)[1]
		if "_" in constant_split:
			constant_split = constant_split.replace("_", " ")
		return "MOUSE " + constant_split
	else:
		return null


# get modified InputEventJoypadMotion constant strings from analog motion
func get_joypad_axis_constant(axis_index, is_positive):
	var axis_constant = "JOY_AXIS_"+str(axis_index)
	# see GlobalRef and the dicts for IconPath_Texture for the full constants
	if is_positive:
		axis_constant = axis_constant+"+"
	else:
		axis_constant = axis_constant+"-"
	return axis_constant

func debug_warning_handler():
	input_prompt_focused = input_prompt_focused
	most_recent_input_event_change = most_recent_input_event_change
	current_input_event_constant = current_input_event_constant
	current_input_event_platform = current_input_event_platform
	current_input_event_texture_path = current_input_event_texture_path
	current_input_event_label_text = current_input_event_label_text
