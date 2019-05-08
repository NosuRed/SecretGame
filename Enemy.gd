extends KinematicBody2D

const GRAVITY = 15
const MAX_SPEED = 75
const FLOOR = Vector2(0,-1)

var velocity = Vector2()

var direction = -1

var isDead = false


func dead():
	isDead = true
	velocity = Vector2(0,0)
	$AnimatedSprite.play("dead")
	$Timer.start()
	
func _physics_process(delta):
	if not isDead:
		velocity.x = MAX_SPEED * direction
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
	
	if $RayCast2D.is_colliding() == false:
		direction = direction * -1
		$RayCast2D.position.x *= -1
		
	
func _on_Timer_timeout():
	queue_free()
