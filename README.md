# godot-input-remapping-project
An unfinished repo demonstrating the input remapping system utilised in my game 'Star Survivors'

**To be clear**: this is sample code and not a functioning project. In particular the scenes that manage the included gdscript files are not included. I would like to build a community plugin (ideally after Godot 4.0 releases later this year), which would include everything necessary to run in any project, but it is not currently a high priority.

The included scripts are a considerable mess at the moment, as I am midway through reparenting various functions for better readability and simpler function flow. If it is something you'd really like to see, feel free to bug me until I uncouple the scenes & tidy/document the remapper properly for release.

Of note all singletons (GlobalRef, GlobalDebug, GlobalData) are not included. All you need to know about these three is that their respective functions handle access to file paths (Ref), the method in which to log errors (Debug), and loading/writing to disk (Data).

---
**REMAPPING STRUCTURE**
---

The loose structure of the input remap handling goes as follows:

1) The Options Input Submenu reads the Project Input Map an creates 'Input Action Entry' scenes for each action registered.
2) The Input Action Entry scenes each create platform-specific buttons under their purview (each button displays the currently mapped input).
3) The Options Input Submenu calls the DataManager to load input mappings from disk. These overwrite the default project input map.
4) The Options Input Submenu connects the button.pressed signal of each button to the Input Prompt Popup.
5) If the player clicks any button, the Input Prompt Popup is called and the player is asked what new input they'd like to remap with.
6) If the player enters an input, the Input Prompt Popup returns this information, and button information, to the Options Input Submenu.
7) The relevant Input Action Entry is called, and it stores the new input information under its own scope.
8) The Input Action Entry calls the Project Input Map and rewrites the event data for the corresponding action.
9) The Input Action Entry calls all its child button nodes to display their correct 
10a) On exiting and confirming changes, the Options Input Submenu calls the DataManager to save these changes to disk.
10b) If the player does not confirm changes, the Options Input Submenu calls the DataManager to reload the project input map from disk, as it did it step 3.

Feel free to ask for any clarification as necessary!

---
**IMPORTANT FUNCTIONS**
---

The important functions, summarised, are as follows:

**submenu_options.gd/get_button_action**
Returns the input event controller that parents the active button scene.

**submenu_options.gd/get_button_platform**
Gets the correct platform (currently supporting pc, playstation, and xbox) from the active button scene.

**submenu_options.gd/connect_input_buttons_to_input_prompt_popup**
Connects newly instantiated active button scenes to the input prompt, so that it can listen for signals from button scenes receiving input.

**popup_prompt_input.gd/input**
Whilst the popup prompt is active any valid input (key, mouse button, joypad button, or joypad motion with an error margin for low axis values) will call send_new_input_event.

**popup_prompt_input.gd/send_new_input_event**
The popup prompt sends back 1) the input event that prompted this call and 2) the button node data received when the prompt was called.

**popup_prompt_input.gd/close_popup**
An alternate exit function if no valid input is received. The popup prompt returns null node data, which will be ignored by the receiving node/function.

**options_controls_input_action_entry**
Each user action generates a scene of button nodes within the input remapping submenu of the options menu. Each button of this scene is assigned to a node group rerpesenting its platform, and the owner scene (the 'input_action_entry') is assigned to a node group for others like it. When instantiated the IAE reads its child nodes to 

**options_controls_input_action_entry/store_recent_input_event**
**options_controls_input_action_entry/update_project_input_map**
The project input map is called with the information stored on the IAE scene. The corresponding action is cleared of all events and then repopulated with events tied to each of its input buttons.

**options_tab_controls.gd/on_InputPromptPopup_return_input**
this func is called when input is remapped, recieving both input event information and node data from the input remapping prompt as the prompt closes
