extends CharacterBody3D

class_name Player

@export_group("These are set programatically")
@export var camera: Camera3D
@export var hud: PlayerHUD

const SPEED = 5.0
const JUMP_VELOCITY = 4
const STAMINA_LENGTH = 2

var stamina: float = 1.0
var sprintStarted: float

func _ready() -> void:
	camera = $Camera3D
	hud = $Camera3D/HUD

func _process(delta: float) -> void:
	$Camera3D/HUD/staminabar.size.x = $Camera3D/HUD/ColorRect2.size.x * stamina

func _physics_process(delta: float) -> void:
	var sprinting: bool = Input.is_action_pressed("sprint")
	var sprintMod: float = 1.75 if stamina >= 0.01 and sprinting else 1.0
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("yump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var distance: Vector3 = global_position
	var input_dir := Input.get_axis("forward", "backward")
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if direction:
		velocity.x = direction.x * SPEED * sprintMod
		velocity.z = direction.z * SPEED * sprintMod
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * sprintMod)
		velocity.z = move_toward(velocity.z, 0, SPEED * sprintMod)
	rotate_y(-Input.get_axis("left", "right") * Settoing.activeInstance.rotMod)

	move_and_slide()

	distance -= global_position

	if sprinting: stamina = max(0, stamina - delta*STAMINA_LENGTH*distance.length()) # scale stamina usage based on distance travelled
	else: stamina = min(stamina + delta/STAMINA_LENGTH/2, 1)
	#print(stamina)
