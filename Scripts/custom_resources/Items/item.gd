extends Resource
class_name Item

@export var name: String
@export var description: String
@export var icon: Texture2D
@export var value : int = 1
#also include 3D reference but we'll do that later
#this is the later :)
@export var scene : String
@export var is_usable : bool
@export var is_consumable : bool
