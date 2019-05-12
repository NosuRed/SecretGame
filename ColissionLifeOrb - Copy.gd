extends Area2D

export(int) var healtRestored = 10

# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	$"17_felspell_spritesheet/AnimationPlayer".play("LifeOrbPlay")

func _on_LifeOrb_body_entered(body):
	if "Player" in body.name:
		body.playerHealed(healtRestored)
		$Timer.start()
		

func _on_Timer_timeout():
	queue_free()
