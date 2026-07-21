extends Player

class_name Clanker

enum AITargets {
	None, SelfToBall, BallToOppositeGoal, SelfToOwnGoal
}

# values assigned from other parts of the code
var ballTarget: Node3D
var purpleGoal: Goal
var yellowGoal: Goal
var isEasyDifficulty: bool = true # does nothing as of yet
var isOnOwnSide: bool

# values utilized to make the next step
var currentTarget: AITargets = AITargets.None
var heldBallAlready: bool = false

func _ready() -> void:
	print("%s (isYellow=%s)" % [nickname, isYellow])
	getMovement.connect(inputSim)
	$MeshInstance3D.mesh.surface_set_material(0, YELLOW_MATERIAL if isYellow else PURPLE_MATERIAL)

func newTarget(t: AITargets):
	print("%s is changing targets from %s to %s" % [nickname, AITargets.keys()[currentTarget], AITargets.keys()[t]])
	currentTarget = t

# returns distance towards target
func moveSelfTowards(target: Node3D) -> Vector2:
	var distanceToTarget2D = calcDist2D(target)
	if distanceToTarget2D.y > 0:
		# todo: check if we're basically head-on with the target and don't rotate if we are
		lookAroundDir = 1.0 if distanceToTarget2D.x > 0 else -1.0
	else:
		# todo: for hard difficulty, make ai be able to move backwards
		# for easy difficulty, the ai will have to make a full 180° turn before going towards the ball
		lookAroundDir = 1.0
	return distanceToTarget2D

func calcDist3D(target: Node3D):
	return target.global_position - global_position

func calcDist2DFrom3D(dist: Vector3):
	return Vector2(dist.x, dist.z).rotated(global_rotation.y)

func calcDist2D(target: Node3D):
	return calcDist2DFrom3D(calcDist3D(target))

func inputSim(delta: float) -> void:
	if paused:
		input_dir = 0.0
		lookAroundDir = 0.0
		return


	input_dir = 1.0
	# todo: for hard difficulty, go to the middle where the ball should spawn if ball is below the map
	match currentTarget:
		AITargets.None:
			input_dir = 0.0
			lookAroundDir = 0.0
		AITargets.SelfToBall:
			var distanceToBall2D = moveSelfTowards(ballTarget)
			if distanceToBall2D.length() < 1.5:
				newTarget(AITargets.BallToOppositeGoal)
		AITargets.BallToOppositeGoal:
			yumping = true
			# opp can be opponent or opposite. pick your poison
			var distanceToOppGoal2D = moveSelfTowards(purpleGoal if isYellow else yellowGoal)
			var distanceToBall2D = calcDist2D(ballTarget).length()
			if distanceToBall2D > 5:
				newTarget(AITargets.SelfToBall)
			if distanceToOppGoal2D.length() < 2.5:
				newTarget(AITargets.SelfToOwnGoal if isOnOwnSide else AITargets.SelfToBall)
			if not heldBallAlready and distanceToBall2D < 2.0:
				holdingBall = true
			if stamina < 0.75:
				holdingBall = false
				heldBallAlready = true
			#$nametag.text = str(distanceToBall2D) + str(heldBallAlready) + str(holdingBall) + str(canHoldBall)
		AITargets.SelfToOwnGoal:
			var distanceToOwnGoal2D = moveSelfTowards(yellowGoal if isYellow else purpleGoal)
			if distanceToOwnGoal2D.length() > 1 and isOnOwnSide:
				newTarget(AITargets.SelfToBall)
