extends Node3D

class_name Map

@export_group("Properties")
@export var title: String
@export var author: String
@export var maxPlayersPerTeam: int
@export var roundTimer: Timer

# map loader layover stuff
# todo: after splitting client/server side, remove this
var yellowBots: int = 0
var purpleBots: int = 0
var mainPlayerIsYellow: bool
