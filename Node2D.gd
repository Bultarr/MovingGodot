extends Node2D

@onready var icon = $Icon
@onready var godot_happy_face = $GodotHappyFace
@onready var godot_mad_face = $GodotMadFace
@onready var godot_happy_faceV2 = $GodotHappyFaceV2
@onready var godot_happy_faceV3 = $GodotHappyFaceV3

@export var move_speed: float = 50.0  # Pixels per second
@export var move_time: float = 2.0    # Time moving
@export var idle_time: float = 1.0    # Time idling
@export var area_size: Vector2 = Vector2(1500, 1200)  # Movement boundary
@export var pause_chance: float = 0.3  # 30% chance to idle

var direction: Vector2 = Vector2.ZERO  # Movement direction
var move_timer: float = 0.0
var idle: bool = false
var start_position: Vector2i  # Store as Vector2i for window position

func _ready():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)  # Hides window
	get_viewport().transparent_bg = true
	start_position = get_window().position  # Store initial window position
	choose_next_action()

func _physics_process(delta: float) -> void:
	move_timer -= delta

	if move_timer <= 0:
		choose_next_action()

	if not idle:
		# Move the Window
		var window = get_window()
		var movement = (direction * move_speed * delta).round()  # Round to avoid fractions
		var new_position = window.position + Vector2i(movement)  # Calculate new position

		# Clamp position to stay within the allowed area
		var min_x = start_position.x - area_size.x / 2
		var max_x = start_position.x + area_size.x / 2
		var min_y = start_position.y - area_size.y / 2
		var max_y = start_position.y + area_size.y / 2

		window.position = Vector2i(
			clamp(new_position.x, min_x, max_x),
			clamp(new_position.y, min_y, max_y)
		)

func _process(delta):
	# Get mouse position relative to the desktop screen
	var window_pos = Vector2(get_window().position)  # Convert Vector2i to Vector2
	var mouse_pos = get_viewport().get_mouse_position()  # Mouse position relative to window
	var absolute_mouse_pos = window_pos + mouse_pos  # Get absolute screen coordinates

	# Define the first box area (mad face appears)
	var box1_min = Vector2(2305, 1010)  # Bottom-left corner
	var box1_max = Vector2(2410, 742)   # Top-right corner

	# Define the second box area (icon & mad face disappear)
	var box2_min = Vector2(2426, 981)  # Bottom-left corner
	var box2_max = Vector2(2521, 890)  # Top-right corner
	
	var box3_min = Vector2(2414, 545)  # Bottom-left corner
	var box3_max = Vector2(2525, 450)  # Top-right corner

	# Check if the mouse is inside box2
	if absolute_mouse_pos.x >= box2_min.x and absolute_mouse_pos.x <= box2_max.x and \
	   absolute_mouse_pos.y <= box2_min.y and absolute_mouse_pos.y >= box2_max.y:
		# Mouse is inside box2, hide both icon and mad face
		icon.visible = false
		godot_happy_face.visible = false
		godot_mad_face.visible = true

	# Check if the mouse is inside box1
	elif absolute_mouse_pos.x >= box1_min.x and absolute_mouse_pos.x <= box1_max.x and \
	   absolute_mouse_pos.y <= box1_min.y and absolute_mouse_pos.y >= box1_max.y:
		# Mouse is inside box1, show mad face
		icon.visible = false
		godot_happy_face.visible = false
		godot_mad_face.visible = true
	
	# Check if the mouse is inside box3
	elif absolute_mouse_pos.x >= box3_min.x and absolute_mouse_pos.x <= box3_max.x and \
	   absolute_mouse_pos.y <= box3_min.y and absolute_mouse_pos.y >= box3_max.y:
		# Mouse is inside box1, show mad face
		icon.visible = false
		godot_happy_face.visible = false
		godot_mad_face.visible = false
		godot_happy_faceV2.visible = true

	else:
		# Mouse is outside both boxes, show icon by default
		icon.visible = true
		godot_happy_face.visible = false
		godot_mad_face.visible = false
		godot_happy_faceV2.visible = false

func choose_next_action():
	if randf() < pause_chance:
		direction = Vector2.ZERO  # Stop moving
		move_timer = idle_time
		idle = true
	else:
		var directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
		direction = directions[randi() % directions.size()]
		move_timer = move_time
		idle = false

#grab cords on the desktop
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		var window_pos = Vector2(get_window().position)  # Convert Vector2i to Vector2
		var mouse_pos = get_viewport().get_mouse_position()  # Mouse position relative to window

		var absolute_mouse_pos = window_pos + mouse_pos  # Get absolute screen coordinates

		print("Mouse Position (Absolute): X =", absolute_mouse_pos.x, " Y =", absolute_mouse_pos.y)
