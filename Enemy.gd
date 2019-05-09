extends KinematicBody2D

const GRAVITY = 15
const FLOOR = Vector2(0,-1)

var velocity = Vector2()
export(int) var max_speed = 75
export(int) var lifePoints = 1
var direction = -1
var hitCounter = 0
var isDead = false

func enemyDeath():
		isDead = true
		velocity = Vector2(0,0)
		$AnimatedSprite.play("dead")
		$Timer.start()
	
func enemyHP():
	hitCounter +=1
	if hitCounter >= 15:
		hitCounter = 0
		lifePoints -=1
	if lifePoints <= 0:
		enemyDeath()
		
	
func _physics_process(delta):
	if not isDead:
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
				get_slide_collision(i).collider.playerHP()