extends KinematicBody2D

const GRAVITY = 15
const FLOOR = Vector2(0,-1)

var velocity = Vector2()
export(int) var max_speed = 75
export(int) var lifePoints = 1
export(int) var damageDone = 1
export(int) var lifePointsDivider = 5
var direction = -1
var hitCounter = 0
var isDead = false

func playerRestoreHP():
	pass
	
func enemyDeath():
		isDead = true
		$CollisionShape2D2.disabled = true
		velocity = Vector2(0,0)
		$spritesheet.show()
		$spritesheet/AnimationPlayer.play("DeathExplosion")
		$Timer.start()
	
func enemyHP():
	direction *= direction
	hitCounter +=1
	if hitCounter >= lifePointsDivider:
		hitCounter = 0
		lifePoints -=1
	if lifePoints <= 0:
		enemyDeath()
		
	
func _physics_process(delta):
	if not isDead:
		$spritesheet.hide()
		velocity.x = max_speed * direction
		$AnimatedSprite.play("walk")
		if direction == 1:
			$AnimatedSprite.flip_h = true
		else:
			$AnimatedSprite.flip_h = false
			
		velocity.y += GRAVITY
	
		velocity = move_and_slide(velocity, FLOOR)
	else:
		$CollisionShape2D2.disabled = true
		
	if is_on_wall():
		direction = direction * -1
		$RayCast2D.position.x *= -1
	
	if !$RayCast2D.is_colliding():
		direction = direction * -1
		$RayCast2D.position.x *= -1
	
	if get_slide_count() > 0:
		enemyColWithPlayer()
	
func _on_Timer_timeout():
	queue_free()
	
func enemyColWithPlayer():
	for i in range (get_slide_count()):
			if "Player" in get_slide_collision(i).collider.name:
				get_slide_collision(i).collider.playerHP(damageDone)
				get_slide_collision(i).collider.bounceback()
				


func _on_AnimationPlayer_animation_started(anim_name):
	pass # Replace with function body.


func _on_AnimationPlayer_animation_finished(anim_name):
	pass # Replace with function body.
