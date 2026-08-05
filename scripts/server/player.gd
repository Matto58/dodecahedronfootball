extends CharacterBody3D

class_name Player

signal getMovement()
#signal getCanHoldBall()
signal setBallPos(pos: Vector3, rot: Vector3)

var i: PlayerInfo
var inp: PlayerInputs

const SPEED = 5.0
const JUMP_VELOCITY = 4
const STAMINA_LENGTH = 2
const PURPLE_MATERIAL = preload("res://mats/goalourple.tres")
const YELLOW_MATERIAL = preload("res://mats/goalyello.tres")
const HALF_PI = PI / 2

var stamina: float = 1.0
var sprintStarted: float
var prevYumping: bool = false
var canHoldBall: bool = false

func _physics_process(delta: float) -> void:
	getMovement.emit(delta)

	inp.input_dir = minf(1.0, inp.input_dir)
	inp.input_dir = maxf(-1.0, inp.input_dir)
	inp.lookAroundDir = minf(1.0, inp.lookAroundDir)
	inp.lookAroundDir = maxf(-1.0, inp.lookAroundDir)
	inp.sensitivity = minf(0.15, inp.sensitivity)
	inp.sensitivity = maxf(0.005, inp.sensitivity)

	var sprintMod: float = 1.75 if stamina >= 0.01 and inp.sprinting else 1.0
	if not is_on_floor():
		velocity += get_gravity() * delta

	var distance: Vector3 = global_position
	var direction := (transform.basis * (Vector3.FORWARD * inp.input_dir)).normalized()
	if not inp.paused:
		if inp.yumping and not prevYumping and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction:
			velocity.x = direction.x * SPEED * sprintMod
			velocity.z = direction.z * SPEED * sprintMod
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * sprintMod)
			velocity.z = move_toward(velocity.z, 0, SPEED * sprintMod)
		rotate_y(-inp.lookAroundDir * inp.sensitivity)

		if inp.holdingBall and canHoldBall and stamina >= 0.01:
			stamina = max(0, stamina - delta)
			var newBallPos = Vector3(global_position)
			newBallPos.x += cos(-global_rotation.y-HALF_PI)*2
			newBallPos.z += sin(-global_rotation.y-HALF_PI)*2
			setBallPos.emit(newBallPos, global_rotation)

	move_and_slide()

	distance -= global_position

	if inp.sprinting: stamina = max(0, stamina - delta*STAMINA_LENGTH*distance.length()) # scale stamina usage based on distance travelled
	else: stamina = min(stamina + delta/STAMINA_LENGTH/2, 1)
	prevYumping = inp.yumping

	i.position = global_position
	i.rotation = global_rotation
	#print(stamina)
