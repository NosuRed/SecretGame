extends Area2D

export(int) var damageValue = 10

func _ready():
	pass # Replace with function body.



func _on_Spikes_body_entered(body):
	if "Player" in body.name:
		body.playerHP(damageValue)
		body.bounceback()
