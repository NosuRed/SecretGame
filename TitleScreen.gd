extends Node


func _ready():
	$MarginContainer/VBoxContainer/VBoxContainer/StartGame.grab_focus()

func _physics_process(delta):
	if $MarginContainer/VBoxContainer/VBoxContainer/StartGame.is_hovered():
		$MarginContainer/VBoxContainer/VBoxContainer/StartGame.grab_focus()
		
		
	if $MarginContainer/VBoxContainer/VBoxContainer/ExitGame.is_hovered():
		$MarginContainer/VBoxContainer/VBoxContainer/ExitGame.grab_focus()
	

func _on_StartGame_pressed():
	get_tree().change_scene("World.tscn")
	



func _on_ExitGame_pressed():
	get_tree().quit()
