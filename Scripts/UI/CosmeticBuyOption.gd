extends Button

export var price:int

export(String, "coins") var currency

export var unlocked:bool

export(String, "body", "color", "face", "hat") var property

export var value:String

func _ready():
	var textRect = $VBoxContainer/CenterContainer/TextureRect 
	if property == "color": textRect.set_modulate(value)
	else: textRect.set_modulate(Global.cosmetics["color"])
	if property == "body": textRect.texture = load("res://Assets/Bodies/" + value + ".png")
	else: textRect.texture = load("res://Assets/Bodies/" + Global.cosmetics["body"] + ".png")
	if property == "face":
		var textureNode := TextureRect.new()
		textureNode.texture = load("res://Assets/Faces/" + value + ".png")
		textureNode.rect_min_size = Vector2(128, 128)
		textureNode.expand = true
		$VBoxContainer/CenterContainer.remove_child(textRect)
		textRect.rect_position = Vector2(0,0)
		textureNode.add_child(textRect)
		$VBoxContainer/CenterContainer.add_child(textureNode)
	if property == "hat":
		var textureNodeFace := TextureRect.new()
		textureNodeFace.texture = load("res://Assets/Faces/" + Global.cosmetics["face"] + ".png")
		textureNodeFace.rect_min_size = Vector2(128, 128)
		textureNodeFace.expand = true
		$VBoxContainer/CenterContainer.remove_child(textRect)
		textRect.rect_position = Vector2(0,0)
		textureNodeFace.add_child(textRect)
		$VBoxContainer/CenterContainer.add_child(textureNodeFace)
		var textureNodeHat := TextureRect.new()
		textureNodeHat.texture = load("res://Assets/Hats/" + value + ".png")
		textureNodeHat.rect_min_size = Vector2(128, 128)
		textureNodeHat.expand = true
		textureNodeFace.add_child(textureNodeHat)
		
	updateText()
	
func _on_BuyOption_pressed():
	if !unlocked and price > Global.currencies[currency]:
		Global.currencies[currency] -= price
		unlocked = true
	if unlocked:
		Global.cosmetics[property] = value
	updateText()


func updateText():
	#if Global.cosmetics[property] == value:
		#$VBoxContainer/RichTextLabel.bbcode_text = "[center] Selected"
	if unlocked:
		$VBoxContainer/RichTextLabel.bbcode_text = "[center] Unlocked"
	else:
		$VBoxContainer/RichTextLabel.bbcode_text = "[center] Price"
	
	
	
	