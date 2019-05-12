extends Area2D


func attackUsed():
	$Timer.start()
	queue_free()
	


func swordAttackRight():
	$CollisionShape2D.position.x = 27
func swordAttackLeft():
	$CollisionShape2D.position.x = -27

func enable():
	$CollisionShape2D.disabled = false

func _physics_process(delta):
	$Timer.start() 
	attackUsed()

func _on_Timer_timeout():
	$CollisionShape2D.disabled = true
	


func _on_SwordAttack_body_entered(body):
	if "Enemy" in body.name:
		print(body)
		body.enemyHP()




