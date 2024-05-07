extends CharacterBody2D


@export var maxSpeed = 125.0
@export var maxSpeedWhileDashing = 300
@export var jumpVelocity = -300.0
@export var acceleration : int = 20
@export var decceleration : float = 0.2
@export var jumpBufferTime : int = 5
@export var coyoteTime : int = 10
@export var dashPower : int = 300
@export var dashDuration : int = 15
@export var dashCooldown : int = 60


var lastDirection : int = -1
var flippedGhost : bool = false
var dashing : bool = false
var dashDurTimer : int = 0
var dashTimer : int = 0
var jumpBufferCounter : int = 0
var coyoteCounter : int = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var dash_effect = $DashEffect
@onready var ghost = $Ghost
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	var img = dash_effect.texture.get_image()
	
	# Add the gravity and start coyoteCounter
	if not is_on_floor():
		coyoteCounter -= 1
		if dashing == false:
			velocity.y += gravity * delta
		elif dashing == true:
			velocity.y = 0
		
	# Coyote counter
	if is_on_floor():
		coyoteCounter = coyoteTime
		
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		jumpBufferCounter = jumpBufferTime
	
	if jumpBufferCounter > 0:
		jumpBufferCounter -= 1
	
	if dashTimer > 0:
		dashTimer -= 1
	
	if dashDurTimer > 0:
		dashDurTimer -= 1
	
	if jumpBufferCounter > 0 and coyoteCounter > 0:
		velocity.y = jumpVelocity
		jumpBufferCounter = 0
		coyoteCounter = 0
	
	# Variable Jump Height
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = 0

	# Get the input direction: -1, 0, 1
	var direction = Input.get_axis("move_left", "move_right")
	
	# Flip sprite
	if direction > 0:
		flippedGhost = true
		animated_sprite.flip_h = true
	elif direction < 0:
		flippedGhost = false
		animated_sprite.flip_h = false
		
	# Play anims
	if is_on_floor():
		if direction == 0 and direction > -0.3 and direction < 0.3:
			animated_sprite.play("newIdle")
		else:
			animated_sprite.play("newRun")
	else:
		animated_sprite.play("newJump")
	
	# Dash
	if Input.is_action_just_pressed("dash") and dashTimer == 0:
		dashing = true
		dashTimer = dashCooldown
		velocity.x = dashPower * direction
		dashDurTimer = dashDuration
		if direction != lastDirection:
			img.flip_x()
			dash_effect.texture = ImageTexture.create_from_image(img)
			lastDirection = direction
	elif dashDurTimer == 0:
		dashing = false
		
	# Movement
	if direction > 0.3:
		velocity.x += acceleration
	elif direction < -0.3:
		velocity.x -= acceleration 
	else:
	#	velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.x = lerp(velocity.x,float(0),decceleration)
		
	if dashing == false:
		velocity.x = clamp(velocity.x, -maxSpeed, maxSpeed)
		dash_effect.emitting = false
	if dashing == true:
		dash_effect.emitting = true
		velocity.x = clamp(velocity.x, -maxSpeedWhileDashing, maxSpeedWhileDashing)

	move_and_slide()
