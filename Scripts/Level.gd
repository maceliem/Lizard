class_name Level

extends Node2D

export var size := [15,15]

export var fruitAmount:int = 1

export var fruitTypes = {
	"waterMelon":100,
	"carrot":0,
	"egg": 0,
	"cheese": 0,
}

export var unlocked:bool = true

export var price:int = 0

export(String, "coins") var currency = "coins"

var alreadyContinued:bool = false

var mapPos := []

var fruitPos := []

var progress := [0,0]

var loaded:bool

var player:Node2D
func _ready():
	randomize() #It aint fun, if its always the same
	#if all the data is saved globally, then we use that
	if self.get_name() in Global.levelMapData: mapPos = Global.levelMapData[self.get_name()]
	else: 
		#else we "load" the map by logging all posible positions
		var mapper:Area2D = load("res://Scripts/Tools/Mapper.tscn").instance()
		$Map.add_child(mapper)
		mapper.position = $Map.position
		progress[1] = size[0]
		for x in size[0]:
			for y in size[1]:
				mapper.position = Vector2(x*64,y*64)
				yield(get_tree(), "physics_frame")
				yield(get_tree(), "physics_frame")
				for area in mapper.get_overlapping_areas():
					if area.get_name() == "Map":
						mapPos.push_back(mapper.position+$Map.position)
			progress[0] = x
	Global.levelMapData[self.get_name()] = mapPos
	loaded = true
	self.get_parent().get_node("CenterContainer").queue_free()
	
	player = load("res://Scripts/Player/Lizard.tscn").instance()
	player.position = $Spawnpoint.position
	player.set_name("Lizard")
	self.add_child(player)
	self.move_child(player,4) #sets player in front of fruit, but behind deathMenu 
	
	
	self.visible = true
	
	
func _process(_delta):
	if loaded:
		if $Fruits.get_child_count() < fruitAmount: #If we don't have enough food, then we 
			for i in fruitTypes.keys():
				if fruitTypes[i] == 0: fruitTypes.erase(i) #deleting all the types we haven't selected
			
			var selectedFruit
			var pool := []
			for fruit in fruitTypes.keys():
				for i in fruitTypes[fruit]:
					pool.push_back(fruit)
			selectedFruit = pool[randi() % pool.size()]
			var food:Area2D = load("res://Scripts/Fruit.tscn").instance() #add more
			food.get_node("Sprite").texture = load(Global.fruits[selectedFruit].image)
			food.nutrition = Global.fruits[selectedFruit].nutrition
			food.value = Global.fruits[selectedFruit].value
			var pos:Vector2 = randPos()
			
			var playerBodyPos := []
			for body in player.get_node("Body/Color").get_children():
				playerBodyPos.push_back(body.position) #logging all body positions
				
				
			while playerBodyPos.has(pos) or fruitPos.has(pos) or !mapPos.has(pos): #if the friut is in player
				pos = randPos() #or not in map, then we get new position for fruit
			food.set_position(pos)
			fruitPos.push_back(food.get_position())
			$Fruits.add_child(food)   
			
		
func randPos(): #returns a random vector2 in a grid based on the size of the map
	return Vector2(
			(randi() % (size[0]) -(size[0]-1)/2) *64,
			(randi() % (size[1]) -(size[1]-1)/2) *64
			)
