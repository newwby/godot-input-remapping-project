extends MarginContainer

signal return_input(new_input, target_node)

const TOTAL_INPUT_WINDOW_COUNTDOWN = 5.0

var input_countdown_remaining = TOTAL_INPUT_WINDOW_COUNTDOWN
var popup_is_active = false

var popup_body_text = "Press any key to change the button.\nPress cancel or click outside the popup to exit."

var node_data = {
	"node scene" : null,
	"input action" : null,
	"platform" : null,
}

onready var popup_node_title = $PopupBackPanel/PopupContainer/Header/MarginContainer/HeaderLabel
onready var popup_node_body = $PopupBackPanel/PopupContainer/Content/MarginContainer/ContentHBox/ContentLabel
onready var confirm_button = $PopupBackPanel/PopupContainer/Footer/ConfirmMargin/ConfirmButton
onready var return_button = $PopupBackPanel/PopupContainer/Footer/CancelMargin/CancelButton

# Called when the node enters the scene tree for the first time.
func _ready():
	change_popup_button_mouse_states(false)

func change_popup_button_mouse_states(buttons_active):
	if buttons_active:
		confirm_button.mouse_filter = MOUSE_FILTER_STOP
		return_button.mouse_filter = MOUSE_FILTER_STOP
	elif not buttons_active:
		confirm_button.mouse_filter = MOUSE_FILTER_IGNORE
		return_button.mouse_filter = MOUSE_FILTER_IGNORE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if popup_is_active:
		if Input.is_action_just_pressed("ui_cancel"):
			close_popup()


func _input(event):
	if popup_is_active:
		get_tree().set_input_as_handled()
		if event is InputEventKey\
		or event is InputEventMouseButton\
		or event is InputEventJoypadButton:#\
			send_new_input_event(event)
			# triggers could send twice w/o return here
			return
	
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) >= 0.4:
				send_new_input_event(event)


func send_new_input_event(event_data):
	emit_signal("return_input", event_data, node_data)
	close_popup()


func close_popup():
			$PopupBackPanel/InputPromptCountdown.stop()
			$PopupBackPanel.visible = false
			save_node_data(null, null, null)
			change_popup_button_mouse_states(false)
			popup_is_active = false


func save_node_data(scene, action, platform):
	node_data["node scene"] = scene
	node_data["input action"] = action
	node_data["platform"] = platform


func _on_PopupBackPanel_popup_hide():
	close_popup()


func _on_Controls_call_input_prompt(button_node, action_name, platform_id):
	
	input_countdown_remaining = TOTAL_INPUT_WINDOW_COUNTDOWN
	$PopupBackPanel/InputPromptCountdown.start()
	$PopupBackPanel.popup()
	set_popup_body_text()
	save_node_data(button_node, action_name, platform_id)
	popup_node_title.text = str(action_name)
	change_popup_button_mouse_states(true)
	popup_is_active = true
#	popup_node_body.text = str(node_name) + " : " + str(action_name) + " : " + str(platform_id)


func _on_InputPromptCountdown_timeout():
	input_countdown_remaining -= 1
	if input_countdown_remaining >= 1:
		set_popup_body_text()
	else:
		close_popup()


func set_popup_body_text():
	popup_node_body.text = popup_body_text+"\n\n"+str(input_countdown_remaining)
