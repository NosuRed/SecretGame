extends KinematicBody2D
const UP = Vector2(0,-1)
const GRAVITY = 20
const ACCELERATION = 50
const MAX_SPEED = 150
const JUMP_HEIGHT = -375
const DOUBLE_JUMP_HEIGHT = -250
const DASH_SPEED = 225
const SWORDATTACK = preload("res://SwordAttack.tscn")


export(int) var lifePoints = 100
onready var hpBar = $Bar/TextureProgress
onready var hpLb = $Bar/TextureProgress/HP_Lb
var hitPoints = 0
var isDead = false
var SLIDE_SPEED = 200
var motion = Vector2()
var DashCount = 0
var InAir = 0
var slideBool = false
var AtkAllowed = true
var direction = 1
var doubleJump = true

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
	AtkAllowed = false
	

	
func Attack():

	if Input.is_action_pressed("ui_cancel"):
		if AtkAllowed:
			if $Attack/Attack.get_frame() != 5 && $Attack/Attack.get_frame() != 0 && $Attack/Attack.get_frame() != 1:
				leftRightAtk()
				$Attack/Attack.show()
				$Attack/Attack.play("default")
				$Attack.disabled = true
				$CollisionShape2D/PlayerChar.hide()
				$Slide/PlayerChar.hide()
				

func leftRightAtk():
	var swordAtk = SWORDATTACK.instance()
	get_parent().add_child(swordAtk)
	swordAtk.position = $Position2D.global_position
	if direction == 1:
		swordAtk.swordAttackRight()
		$Attack/Attack.flip_h = false
		$Attack.position.x = 16
		$Attack/Attack.position.x = -15
	else:
		swordAtk.swordAttackLeft()
		$Attack/Attack.flip_h = true
		$Attack.position.x = -16
		$Attack/Attack.position.x = 15
func setStartValues():
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


func charDead():
	hitPoints +=1
	if hitPoints == 10:
		hitPoints = 0
		lifePoints -=1
		print(lifePoints)
		if lifePoints == 0:
			isDead = true
			if isDead:
				motion = Vector2(0,0)
				$CollisionShape2D/PlayerChar.play("Dead")
				$CollisionShape2D.disabled = true
				$Timer.start()
		

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
func player_Hp_UpDate():
	hpBar.set_value(lifePoints)
	if lifePoints >= -1:
		hpLb.set_text("HP: " + str(lifePoints))
	else:
		hpLb.set_text("0")
	
func _physics_process(delta):
	player_Hp_UpDate()
		
	motion.y += GRAVITY
	setStartValues()
	var friction = false
	if !isDead:
		Attack()
		
		if Input.is_action_pressed("ui_right"):
			movementCharRight(InAir)
			AtkAllowed = true
		elif Input.is_action_pressed("ui_left"):
			movementCharLeft(InAir)
			AtkAllowed = true
			
		else:
			$CollisionShape2D/PlayerChar.play("Idle")
			AtkAllowed = true
			friction = true
			
		if is_on_floor():
			#reset Dashcount and InAir
			DashCount = 0
			InAir = 0
			doubleJump = true
			if Input.is_action_just_pressed("ui_up"):
				motion.y = JUMP_HEIGHT
			if friction:
				motion.x = lerp(motion.x, 0, 0.2)
				
		else:
			if not DashCount:
				#Dash to the left
				if Input.is_action_just_pressed("ui_select") && $CollisionShape2D/PlayerChar.flip_h:
					#Sets InAir to 1, this is so that we know we are in the air
					#Sets DashCount to 1, to check if we dashed already
					InAir = 1
					DashCount = 1
				#Dash to the Right
				#Sets InAir to 1, this is so that we know we are in the air
				#Sets DashCount to 1, to check if we dashed already
				elif Input.is_action_just_pressed("ui_select") && not $CollisionShape2D/PlayerChar.flip_h:
					InAir = 1
					DashCount = 1
					
			if motion.y < 0:
				$CollisionShape2D/PlayerChar.play("Jump")
			else:
				# Plays the Dash Animation
				if DashCount:
					$CollisionShape2D/PlayerChar.play("Dash")
					AtkAllowed = false
				#Plays the Fall Animatuon
				else:
					$CollisionShape2D/PlayerChar.play("Fall")
				
			if friction:
				motion.x = lerp(motion.x, 0, 0.05)
				
				
			if !InAir:
				if Input.is_action_just_pressed("ui_up"):
					if doubleJump:
						motion.y = DOUBLE_JUMP_HEIGHT
						$CollisionShape2D/PlayerChar.play("Double")
						doubleJump = false
			
		motion = move_and_slide(motion,UP)
	
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if "Enemy" in get_slide_collision(i).collider.name:
					charDead()

		
func _on_Timer_timeout():
	get_tree().change_scene("TitleScreen.tscn")
