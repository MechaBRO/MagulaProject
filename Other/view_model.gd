extends Camera3D

@onready var weapons_all = $Weapons_Manager
@onready var mosquete_javelino_1 = $Weapons_Manager/Weapons/Mosquete_Javelino/Cube_001
@onready var pistola_gilliard = $Weapons_Manager/Weapons/Pistola_Gilliard/Plano

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	mosquete_javelino_1.position.x = lerp(mosquete_javelino_1.position.x,0.0,delta*5)
	mosquete_javelino_1.position.y = lerp(mosquete_javelino_1.position.y,0.0,delta*5)
	
	pistola_gilliard.position.x = lerp(mosquete_javelino_1.position.x,0.0,delta*5)
	pistola_gilliard.position.y = lerp(mosquete_javelino_1.position.y,0.0,delta*5)

func sway(sway_amount):
	mosquete_javelino_1.position.x -= sway_amount.x*0.0008
	mosquete_javelino_1.position.y += sway_amount.y*0.002
	
	pistola_gilliard.position.x -= sway_amount.x*0.0008
	pistola_gilliard.position.y += sway_amount.y*0.002


func _input(event):
	if(event.is_action_pressed("FIRE")):
		pass
	if(event.is_action_pressed("RELOAD")):
		pass
