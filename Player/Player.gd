extends KinematicBody2D

# x and y position
var velocity = Vector2.ZERO
# roll vector
var roll_vector = Vector2.DOWN
# speed things
const MAX_SPEED = 4500 * 2
#roll speed
const ROLL_SPEED = MAX_SPEED * 1.3
#const ACCELERATION = 100
const FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}
var state = MOVE
#onready var is initilzated without _ready function
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	log_message("DEBUG","_ready()", "Player is ready..")
	animationTree.active = true

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state()
	
	
func move_state(delta):
	# How to move
	# Think of this like a ps4 controller
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector 
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)		
		animationState.travel("Run")
		velocity = input_vector * MAX_SPEED
		#velocity += input_vector * ACCELERATION * deltad
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
		#velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move(delta)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move(delta)

func attack_animation_finished():
	log_message("DEBUG", "attack_animation_finished", "Attack animation finished")	
	state = MOVE

func roll_animation_finished():
	log_message("DEBUG", "roll_animation_finished", "Roll animation finished")
	state = MOVE
	velocity = Vector2.ZERO
	
func move(delta):
	velocity = move_and_slide(velocity * delta)	
	

func log_message(log_level: String,method_name: String, message: String):
	var date = OS.get_datetime()
	var formatted_date = "%s.%s.%s %s:%s:%s" % [date.year, str(date.month).pad_zeros(2), str(date.day).pad_zeros(2), str(date.hour).pad_zeros(2), str(date.minute).pad_zeros(2), str(date.second).pad_zeros(2)]
	print( "(" + log_level + ") " + formatted_date + " | " + method_name + " | " + message)
