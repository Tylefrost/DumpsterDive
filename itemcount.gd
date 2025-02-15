extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$glasscount.text = "Count: "
	$leathercount.text = "Count: "
	$stringcount.text = "Count: "
	$wirecount.text = "Count: "



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$glasscount.text = ("Count: " + str(MainScene.glasses))
	$leathercount.text = ("Count: " + str(MainScene.leathers))
	$stringcount.text = ("Count: " + str(MainScene.strings))
	$wirecount.text = ("Count: " + str(MainScene.wires))
	
