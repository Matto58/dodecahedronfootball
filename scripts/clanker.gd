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
var currentTarget: AITargets = AITargets.SelfToBall

# returns distance towards target
func moveSelfTowards(target: Node3D) -> Vector2:
	var distanceToTarget3D = target.global_position - global_position
	var distanceToTarget2D = Vector2(distanceToTarget3D.x, distanceToTarget3D.z).rotated(global_rotation.y)
	if distanceToTarget2D.y > 0:
		# todo: check if we're basically head-on with the target and don't rotate if we are
		lookAroundDir = 1.0 if distanceToTarget2D.x > 0 else -1.0
	else:
		# todo: for hard difficulty, make ai be able to move backwards
		# todo: also add looking backwards for the player
		# for easy difficulty, the ai will have to make a full 180° turn before going towards the ball
		lookAroundDir = 1.0
	return distanceToTarget2D

func _physics_process(delta: float) -> void:
	input_dir = 1.0
	# todo: for hard difficulty, go to the middle where the ball should spawn if ball is below the map
	match currentTarget:
		AITargets.None:
			input_dir = 0.0
			lookAroundDir = 0.0
		AITargets.SelfToBall:
			var distanceToBall2D = moveSelfTowards(ballTarget)
			if distanceToBall2D.length() < 0.25 and not isOnOwnSide:
				currentTarget = AITargets.BallToOppositeGoal
		AITargets.BallToOppositeGoal:
			# opp can be opponent or opposite. pick your poison
			var distanceToOppGoal2D = moveSelfTowards(purpleGoal if isYellow else yellowGoal)
			if distanceToOppGoal2D.length() > 1:
				currentTarget = AITargets.SelfToOwnGoal if isOnOwnSide else AITargets.BallToOppositeGoal
		AITargets.SelfToOwnGoal:
			var distanceToOwnGoal2D = moveSelfTowards(yellowGoal if isYellow else purpleGoal)
			if distanceToOwnGoal2D.length() > 1 and isOnOwnSide:
				currentTarget = AITargets.SelfToBall
