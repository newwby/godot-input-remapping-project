extends MarginContainer

var input_prompt_popup_is_active = false

###########################################################################


# NOTE (TODO fix this)
# due to gradual refactor/reparenting of functions from this script to the
# input_action_entry script, this function (an important function for handling
# setting new inputs via input prompt popup) is a bit of a damn mess.
# It will perhaps be eventually worth refactoring this whole thing.
# Can rewrite to just tell the action entry scene to update every
# child button scene whenever recieving a new (and valid) input.
func _on_InputPromptPopup_return_input(new_input, given_node_data):
	# to allow multiple accepted inputs for pc still need the button node
	var target_button_node = given_node_data["node scene"]
	# functions are methods of the input action entry scene holding the button
	var input_action_entry_node = target_button_node.owner
	# TODO move this all to input action entry scenes?
	
	if target_button_node != null:
	
		# IF PC BUTTON
		if given_node_data["platform"] == GlobalRef.PLATFORM.PC:
			if new_input is InputEventMouseButton:
				input_action_entry_node.set_button_input_label(target_button_node,\
				input_action_entry_node.get_mouse_button_string(new_input.button_index))
				input_action_entry_node.store_recent_input_event(\
				target_button_node, new_input)
			elif new_input is InputEventKey:
				input_action_entry_node.set_button_input_label(\
				target_button_node, new_input.as_text())
				input_action_entry_node.store_recent_input_event(\
				target_button_node, new_input)
			
			else:
				GlobalDebug.log_error("no keyboard/mouse match for pc new input on "+str(new_input)+" options_tab_controls/_on_InputPromptPopup_return_input failed to recognise input")
		
		# IF CONSOLE BUTTON MUST BE PS/XBOX INPUT
		if given_node_data["platform"] == GlobalRef.PLATFORM.PLAYSTATION\
		or given_node_data["platform"] == GlobalRef.PLATFORM.XBOX:
			var string_constant
			if new_input is InputEventJoypadButton:
				string_constant = str(input_action_entry_node.convert_input_event_to_input_constant(new_input))
				input_action_entry_node.set_button_input_texture(string_constant, target_button_node, given_node_data["platform"])
				
				input_action_entry_node.store_recent_input_event(\
				target_button_node, new_input)
			
			# GAMEPAD AXIS MOTION
			elif new_input is InputEventJoypadMotion:
				# GAMEPAD TRIGGER BUTTONS/AXIS
				if new_input.axis == 6:
					string_constant = "JOY_L2"
#					input_action_entry_node.set_button_input_texture(\
#					string_constant, target_button_node, given_node_data["platform"])
				
				elif new_input.axis == 7:
					string_constant = "JOY_R2"
#					input_action_entry_node.set_button_input_texture(\
#					string_constant, target_button_node, given_node_data["platform"])
				
				# GAMEPAD ANALOG STICK AXIS
				elif new_input.axis >= 0 and new_input.axis <= 3:
					if new_input.axis_value >= 0.4:
						string_constant = input_action_entry_node.get_joypad_axis_constant(new_input.axis, true)
					elif new_input.axis_value <= -0.4:
						string_constant = input_action_entry_node.get_joypad_axis_constant(new_input.axis, false)
#					
				else:
					GlobalDebug.log_error("no axis match on "+str(new_input)+" options_tab_controls/_on_InputPromptPopup_return_input failed to recognise input")
				
				
				input_action_entry_node.set_button_input_texture(\
				string_constant, target_button_node, given_node_data["platform"])
				input_action_entry_node.store_recent_input_event(\
				target_button_node, new_input)
			
			# ERROR LOGGING IF NOT InputEventMouseButton on Platform PC,
			# or InputEventJoypadButton/InputEventJoypadMotion w/acceptable axis on Platform PS/Xbox
			else:
				GlobalDebug.log_error("not joypad match for joypad new input on "+str(new_input)+" options_tab_controls/_on_InputPromptPopup_return_input failed to recognise input")
		else:
			# TODO BUGFIX sometimes inputeventkey on pc platform (id 0) throws an error here without affecing function? is it checking the released action as well as pressed?
			GlobalDebug.log_error("no input platform match on options_tab_controls/_on_InputPromptPopup_return_input")
			GlobalDebug.log_error("platform id error is "+str(given_node_data["platform"])+" (for "+str(new_input)+str(given_node_data)+")")
	else:
		GlobalDebug.log_error("invalid node on options_tab_controls/_on_InputPromptPopup_return_input, node id error is "+str(target_button_node))


func _on_InputPromptPopup_input_prompt_state(popped_up):
	input_prompt_popup_is_active = popped_up


###############################################################################


func set_input_node_properties(config_settings):
	config_settings = config_settings
	GlobalData.load_input_map()
	get_tree().call_group("options_button_input_action", "populate_action_input_dict")
	get_tree().call_group("options_button_input_action", "update_all_buttons")


func write_input_node_properties():
	GlobalData.save_input_map()

