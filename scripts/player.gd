extends CharacterBody3D

class_name Player

@export_group("Configurable values")
@export var isYellow: bool = false
@export var purpleMaterial: StandardMaterial3D
@export var yellowMaterial: StandardMaterial3D
@export var nickname: String

var sprinting: bool = false
var input_dir: float = 0.0
var yumping: bool = false
var lookAroundDir: float = 0.0

const SPEED = 5.0
const JUMP_VELOCITY = 4
const STAMINA_LENGTH = 2

# local copies
var scorePurple: int = 0
var scoreYellow: int = 0

var stamina: float = 1.0
var sprintStarted: float

func _ready() -> void:
	$MeshInstance3D.mesh.surface_set_material(0, yellowMaterial if isYellow else purpleMaterial)

func initPlayerNickInHUD():
	$Camera3D/HUD/RichTextLabel.append_text("[color=\"#999\"]Playing as[/color] [b][color=\"#%s\"]%s[/color][/b]" % ["ff0" if isYellow else "7f00ff", nickname])

func _process(delta: float) -> void:
	$Camera3D/HUD/staminabar.size.x = $Camera3D/HUD/ColorRect2.size.x * stamina
	if Input.is_action_just_pressed("pause"):
		$Camera3D/pause_menu.visible = not $Camera3D/pause_menu.visible

func _physics_process(delta: float) -> void:
	input_dir = minf(1.0, input_dir)
	input_dir = maxf(-1.0, input_dir)
	lookAroundDir = minf(1.0, lookAroundDir)
	lookAroundDir = maxf(-1.0, lookAroundDir)

	var sprintMod: float = 1.75 if stamina >= 0.01 and sprinting else 1.0
	if not is_on_floor():
		velocity += get_gravity() * delta

	var distance: Vector3 = global_position
	var direction := (transform.basis * Vector3(0, 0, input_dir)).normalized()
	if not $Camera3D/pause_menu.visible:
		if Input.is_action_just_pressed("yump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		if direction:
			velocity.x = direction.x * SPEED * sprintMod
			velocity.z = direction.z * SPEED * sprintMod
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED * sprintMod)
			velocity.z = move_toward(velocity.z, 0, SPEED * sprintMod)
		rotate_y(lookAroundDir * Settoing.activeInstance.rotMod)

	move_and_slide()

	distance -= global_position

	if sprinting: stamina = max(0, stamina - delta*STAMINA_LENGTH*distance.length()) # scale stamina usage based on distance travelled
	else: stamina = min(stamina + delta/STAMINA_LENGTH/2, 1)
	#print(stamina)
