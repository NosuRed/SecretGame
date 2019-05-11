extends RichTextLabel
# []

export(Array) var dialog = []
var page = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_bbcode(dialog[page])
	set_visible_characters(0)
	set_process_input(true)

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		if get_visible_characters() > get_total_character_count():
			if page < dialog.size()-1:
				page +=1
				set_bbcode(dialog[page])
				set_visible_characters(0)
	if Input.is_action_just_pressed("ui_cancel"):
		set_visible_characters(get_total_character_count())
		if page+1 == dialog.size():
			print("Cool")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	set_visible_characters(get_visible_characters()+1)


func _on_TurnOff_timeout():
	queue_free()
