extends Node2D

static var board_dim: Vector2 = Vector2(25, 15)
@onready var board = []
var start = Vector2i(115, 107)

static var bombs = 0
static var bombs_found = 0

var block_data = load("res://block.tscn")

signal first_click(pos)

func _ready():
	# make blocks
	for i in range(board_dim.y):
		var row = []
		for j in range(board_dim.x):
			var new_block = block_data.instantiate()
			new_block.board_pos = Vector2i(j, i)
			new_block.get_node("Label").text = ""
			new_block.get_node("Label").add_theme_color_override("font_color", Data.number_color)
			new_block.get_node("Label").add_theme_color_override("font_outline_color", Data.number_outline)
			row.append(new_block)
			add_child(new_block)
			new_block.position = start + (new_block.board_pos * 32)
		board.append(row) # 2d list can now refer to all block by pos
	
	board[0][0].material.set_shader_parameter("bg_color", Data.bg_color)
	board[0][0].material.set_shader_parameter("border_color", Data.border_color)
	# wait for the first click before setting up
	var open_block = await first_click
	print("Clicked")
	
	for row in board: for block in row:
		if abs(block.board_pos.x - open_block.x) + abs(block.board_pos.y - open_block.y) >= 3:
			if randi_range(0, 3) == 3:
				block.bomb = true
				var expl = load("res://explosion.tscn").instantiate()
				expl.color_ramp = Data.explosion_color
				expl.name = "Explosion"
				block.add_child(expl)
				bombs += 1
	
	# connect all signals, set images for blocks
	for row in board: for block in row:
		# connect signals
		block.connect_to_adjs()
		
		var bomb_count = block.bomb_count()
		# check if this is a bomb. if it is, put a bomb sprite on it.
		if block.bomb:
			block.get_node("Label").text = ""
			var bomb_sprite = Sprite2D.new()
			bomb_sprite.texture = load("res://Bomb.png")
			block.add_child(bomb_sprite)
			bomb_sprite.scale = Vector2(0.7, 0.7)
			bomb_sprite.visible = false
			bomb_sprite.name = "Bomb"
		# if not a bomb, then put the number of bombs adjacent to itself
		elif bomb_count:
			block.get_node("Label").text = "%d" % bomb_count
			block.get_node("Label").visible = false
		# if no surrounding bombs, leave it empty
		else:
			block.get_node("Label").text = ""
	
	$Label.text = "Remaining: %d" % (bombs - bombs_found)


## given a position, return the matching block in the board
func get_block(pos: Vector2i):
	return board[pos.y][pos.x]


func update_bombs_msg(): $Label.text = "Remaining: %d" % (bombs - bombs_found)


func game_end():
	var flattened_board: Array = []
	for row in board:
		flattened_board.append_array(row)
	flattened_board.shuffle()
	
	for block in flattened_board:
		if block.flag: block.remove_child(block.get_node("Flag")); block.flag = false
		
		if block.covered:
			block.get_node("AnimationPlayer").play("grow")
			block.covered = false
			block.reveal()
			await get_tree().create_timer(0.001).timeout
			block.get_node("CPUParticles2D").emitting = true
			block.frame = 1
			#block.scale = Vector2.ONE
		
		if block.bomb:
			block.get_node("Explosion").emitting = true
			$Camera2D/AnimationPlayer.play("screen_shake")
