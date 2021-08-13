extends Node2D

var direction:Vector2 = Vector2(0, 64)
var lastMove:Vector2 
var infants:int = 0
var fruitsEaten:int = 0
var dead:bool = false
var freezer:bool = false
func _ready():
	$Body/Accessory.texture = load("res://Assets/Accessories/" + Global.cosmetics["accessory"] + ".png")
	$Body/Color.set_modulate(Global.cosmetics["color"])
	if "freezer" in Global.upgrades:
		if Global.upgrades.freezer.enabled:
			freezer = true
			$Timer.wait_time = 0.0001
		else:$Timer.start()
	else:$Timer.start()

func _on_Timer_timeout():
	var bodyCount:int = $Body/Color.get_child_count()-1
	var head:Area2D = $Body/Color.get_child(0)
		
	#All bodyparts have to move one forward in the chain, and take the leading parts place
	for i in bodyCount:
		if i == bodyCount: pass #except the first
		$Body/Color.get_child(bodyCount-i).set_rotation(($Body/Color.get_child(bodyCount-i).get_position() - $Body/Color.get_child(bodyCount-i-1).get_position()).angle()+PI/2)
		$Body/Color.get_child(bodyCount-i).set_position($Body/Color.get_child(bodyCount-i-1).get_position())
	head.set_position(head.get_position() + direction) #the first one shall guide to the new way
	head.set_rotation(direction.angle()-PI/2)
	$Body/Face.set_position($Body/Face.get_position() + direction) #and we want the face with us
	$Body/Face.set_rotation(direction.angle()-PI/2) #and turn that frown the right way up
	$Body/Accessory.set_position($Body/Accessory.get_position() + direction) #and  the hat
	$Body/Accessory.set_rotation(direction.angle()-PI/2)
	lastMove = direction
	
	#Just waiting two frames before checking stuff
	yield(get_tree(), "physics_frame")
	yield(get_tree(), "physics_frame")
	
	#If you have slammed head in a wall or a body, then you are dead, but if its an edible, then you are pregnant
	for area in head.get_overlapping_areas():
		if area.get_collision_layer_bit(0):
			death(area.get_parent().get_name())
		elif area.get_collision_layer_bit(2):
			infants += area.nutrition
			fruitsEaten += area.value
			Global.currencies["coins"] += area.value
			self.get_parent().fruitPos.erase(area.get_position())
			area.queue_free()
			
	#Tilemaps are bodies and not areas
	for body in head.get_overlapping_bodies():
		if body.get_collision_layer_bit(1):
			death(body.get_parent().get_name())
	
	if infants > 0: #if we're expecting, then a kid is born once every move
		var kid = load("res://Scripts/Player/BodyPart.tscn").instance()
		kid.set_position($Body/Color.get_child(bodyCount-1).get_position())
		kid.set_rotation($Body/Color.get_child(bodyCount-2).get_rotation())
		$Body/Color.add_child(kid)
		infants -= 1
		
	if !dead and !freezer: $Timer.start() #after everything is done, we go again
	
func _process(_delta): #input for movement
	var move:Vector2 = direction
	if Input.is_action_just_pressed("Up"):
		move = Vector2(0,-64)
		if freezer:
			$Timer.start()
	elif Input.is_action_just_pressed("Down"):
		move = Vector2(0,64)
		if freezer:
			$Timer.start()
	elif Input.is_action_just_pressed("Left"):
		move = Vector2(-64,0)
		if freezer:
			$Timer.start()
	elif Input.is_action_just_pressed("Right"):
		move = Vector2(64,0)
		if freezer:
			$Timer.start()
		
	if ! move == -lastMove: #if the player is stupid enough to go back the way they came
		direction = move #then we stop them from instantly committing suicide 
	
	
	
func death(levelName): #if we die, then we load the death menu, 
	dead = true#gain coins equal to fruits gained and kill player
	var deathMenu:Control = self.get_parent().get_node("deathMenu")
	deathMenu.get_node("ColorRect/VBoxContainer/HBoxContainer/Tekst").set_bbcode("[center] You died\n\n But you earned " + str(fruitsEaten) + " coins")
	deathMenu.visible = true
	$Timer.stop()
	if !Global.highScore.keys().has(levelName):
		Global.highScore[levelName] = fruitsEaten
		deathMenu.get_node("ColorRect/VBoxContainer/HBoxContainer/Tekst").set_bbcode("[center] New highscore!! \nYou died\n But you earned " + str(fruitsEaten) + " coins")
	elif Global.highScore[levelName] < fruitsEaten:
		Global.highScore[levelName] = fruitsEaten
		deathMenu.get_node("ColorRect/VBoxContainer/HBoxContainer/Tekst").set_bbcode("[center] New highscore!! \nYou died\n But you earned " + str(fruitsEaten) + " coins")
	Global._saveGame()

func coinAgain():
	Global.currencies["coins"] += fruitsEaten
	Global._saveGame()
