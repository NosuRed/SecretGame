extends Area2D
export(int) var checkPointNum = 0
func _physics_process(delta):
	$AnimatedSprite/AnimationPlayer.play("Blink")


func _on_CheckPoint_body_entered(body):
	if "Player" in body.name:
		body.checkPointWasReached()
		body.respawnPlayer(global_position)
		print(global_position)
		$Timer.start()

func _on_CheckPoint_body_exited(body):
	pass # Replace with function body.


func _on_Timer_timeout():
	$CollisionShape2D.disabled = true
