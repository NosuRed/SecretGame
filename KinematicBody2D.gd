extends KinematicBody2D
const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 150
const JUMP_HEIGHT = -375
const DOUBLE_JUMP_HEIGHT = -250
const DASH_SPEED = 225
const SWORDATTACK = preload("res://SwordAttack.tscn")
const CHECKPOINT = preload("res://CheckPoint/CheckPoint.tscn")

export(int) var lifePoints = 100
export(int) var MAX_HEALTH = 100
onready var hpBar = $Bar/TextureProgress
onready var hpLb = $Bar/TextureProgress/HP_Lb
var hitPoints = 0
var isDead = false
var SLIDE_SPEED = 200
var motion = Vector2()
var DashCount = 0
var InAir = 0
var slideBool = false
var direction = 1
var doubleJump = true
var displayDeathHP= "HP: 0"
var checkPoint = CHECKPOINT.instance()
var checkPointReached = false
var checkPointPos
var isAttacking = false

func hitBoxColl():
	
	#Changes the collission of the Player when slieding
	# disables the Vertical hitbox
	$CollisionShape2D.disabled = true 
	#hides the PlayerChar Sprite that is not sliding
	$CollisionShape2D/PlayerChar.hide()
	#enables the slide hitbox
	$Slide.disabled = false
	#shows the slide sprite
	$Slide/PlayerChar.show()
	#to check if the Player is sliding
	slideBool = true
	
func _on_Attack_animation_finished():
	$Attack/Attack.frame = 0


func attackAnimation():
	if direction == 1:
		$Attack/Attack.flip_h = false
	else:
		$Attack/Attack.flip_h = true
	$Attack/Attack.show()
	#$Attack.disabled = true
	$CollisionShape2D/PlayerChar.hide()
	$Slide/PlayerChar.hide()

func Attack():
	attackAnimation()
	if $Attack/Attack.frame == 3:
		print($Attack/Attack.frame)
		leftRightAtk()

			

func checkPointWasReached():
	checkPointReached = true


	
func respawnPlayer(global):
		if checkPointReached:
			checkPointPos = global
		 
	
	
func leftRightAtk():
	var swordAtk = SWORDATTACK.instance()
	get_parent().add_child(swordAtk)
	swordAtk.position = $Position2D.global_position
	if direction == 1:
		swordAtk.swordAttackRight()
		#$Attack/Attack.flip_h = false
		$Attack.position.x = 16
		$Attack/Attack.position.x = -15
	else:
		swordAtk.swordAttackLeft()
		#$Attack/Attack.flip_h = true
		$Attack.position.x = -16
		$Attack/Attack.position.x = 15
func setStartValues():
	isAttacking = false
	$Attack/Attack.hide()
	$Attack.disabled = true
	#Hides the Slide Sprot
	$Slide/PlayerChar.hide()
	#Turns on the Player Sprite that is not sliding
	$CollisionShape2D/PlayerChar.show()
	#Enables the Vertical hitbox
	$CollisionShape2D.disabled = false
	# Disables the slide Hitbox
	$Slide.disabled = true
	#Player is not Sliding
	slideBool = false


func playerHP(damage):
	hitPoints +=1
	#if hitPoints >= 10:
	hitPoints = 0
	lifePoints -=damage
	if hpLb.get_text() == displayDeathHP:
		lifePoints = 0
		$CollisionShape2D.disabled = true
		playerDeath()

func playerRespawnPos():
		global_position.x = checkPointPos.x +70
		global_position.y = checkPointPos.y + 60
		lifePoints = 20
	

func playerDeath():
		if !checkPointReached:
			isDead = true
			motion = Vector2(0,0)
			$CollisionShape2D/PlayerChar.play("Dead")
			$CollisionShape2D.disabled = true
			$Timer.start()
		else:
			playerRespawnPos()
			
func movementCharRight(InAir):
	direction = 1
	if InAir:
		motion.x = DASH_SPEED
		$CollisionShape2D/PlayerChar.flip_h = false
	else:
		motion.x = min(motion.x+ACCELERATION, MAX_SPEED)
		$CollisionShape2D/PlayerChar.flip_h = false
		if Input.is_action_pressed("ui_select"):
			hitBoxColl()	
			motion.x = max(motion.x+ACCELERATION, +SLIDE_SPEED)
			$Slide/PlayerChar.set_flip_h(false)
		else:
			$CollisionShape2D/PlayerChar.play("Run")

func movementCharLeft(InAir):
	direction = -1
	if InAir:
		motion.x = -DASH_SPEED
		$CollisionShape2D/PlayerChar.flip_h = true
		$CollisionShape2D/PlayerChar.play("Dash")
	else:
		motion.x = max(motion.x-ACCELERATION, -MAX_SPEED)
		$CollisionShape2D/PlayerChar.flip_h = true
		
		if Input.is_action_pressed("ui_select"):
			hitBoxColl()
			motion.x = max(motion.x-ACCELERATION, -SLIDE_SPEED)
			$Slide/PlayerChar.set_flip_h(true)
		else:
			$CollisionShape2D/PlayerChar.play("Run")

func playerHealed(healed):
	lifePoints += healed
	if lifePoints >= MAX_HEALTH:
		lifePoints = MAX_HEALTH
	

func player_Hp_UpDate():
	hpBar.set_value(lifePoints)
	if lifePoints >= -1:
		hpLb.set_text("HP: " + str(lifePoints))
	else:
		hpLb.set_text(displayDeathHP)

func _physics_process(delta):
		
	player_Hp_UpDate()
		
	motion.y += GRAVITY
	setStartValues()
	var friction = false
	if !isDead:
		if Input.is_action_just_released("ui_cancel"):
				$Attack/Attack.frame = 0
		
		if Input.is_action_pressed("ui_cancel") && !isAttacking:
			isAttacking = true
			Attack()
		
		if Input.is_action_pressed("ui_right"):
			movementCharRight(InAir)
			
		elif Input.is_action_pressed("ui_left"):
			movementCharLeft(InAir)
			
		else:
			$CollisionShape2D/PlayerChar.play("Idle")
			friction = true
			
		if is_on_floor():
			jumpUp(friction)
				
		else:
			dashPlayer()
					
			if motion.y < 0:
				$CollisionShape2D/PlayerChar.play("Jump")
			else:
				# Plays the Dash Animation
				if DashCount:
					$CollisionShape2D/PlayerChar.play("Dash")
				#Plays the Fall Animation
				else:
					$CollisionShape2D/PlayerChar.play("Fall")
				
			if friction:
				motion.x = lerp(motion.x, 0, 0.05)
				
				
			if !InAir:
				doubleJump()
	else:
		$CollisionShape2D.disabled = true
		motion.y = 0
		
	motion = move_and_slide(motion,UP)
	
	if get_slide_count() > 0:
			checkPlEnemyCol()
		
func _on_Timer_timeout():
	get_tree().change_scene("TitleScreen.tscn")
	

func doubleJump():
	if Input.is_action_just_pressed("ui_up"):
					if doubleJump:
						motion.y = DOUBLE_JUMP_HEIGHT
						$CollisionShape2D/PlayerChar.play("Double")
						doubleJump = false
func jumpUp(friction):
	doubleJump = true
	DashCount = 0
	InAir = 0
	if Input.is_action_just_pressed("ui_up"):
		motion.y = JUMP_HEIGHT
	if friction:
		motion.x = lerp(motion.x, 0, 0.2)
		

func dashPlayer():
	if Input.is_action_just_pressed("ui_select"):
		if not DashCount:
			InAir = 1
			DashCount = 1 
					

func checkPlEnemyCol():
	for i in range(get_slide_count()):
				if "Enemy" in get_slide_collision(i).collider.name:
					#motion.y = JUMP_HEIGHT
					#motion.x = 150
					playerHP(0)

func bounceback():
	if !isDead:
		motion.y = JUMP_HEIGHT
		motion.x = MAX_SPEED



