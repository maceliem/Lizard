extends Control


func _on_Quit_pressed(): #if you quit, then we go to the main menu
	get_tree().change_scene("res://Scripts/Menues/mainMenu.tscn")
	queue_free()
