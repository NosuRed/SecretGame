extends Area2D


func attackUsed():
	$Timer.start()
	queue_free()


func swordAttackRight():
	$CollisionShape2D.position.x = 27
func swordAttackLeft():
	$CollisionShape2D.position.x = -27

func _physics_process(delta):
	attackUsed()

func _on_Timer_timeout():
	queue_free()


func _on_SwordAttack_body_entered(body):
	if "Enemy" in body.name:
		body.enemyHP()
