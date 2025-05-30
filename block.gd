@tool
extends Sprite2D

# blocks detect when they are clicked on by the user
# (or space bar is pressed on it).

# then it recursively blows up surrounding blocks,
# revealing the empty spaces until you reach edges with numbers


# TODO: bomb explosion when you click a bomb (particles/smoke effect)

var covered: bool = true
var bomb = false
var flag = false

@export var number_color := Color(1, 1, 1, 1):
	set(value):
		number_color = value
		if $Label:
			$Label.add_theme_color_override("font_color", number_color)

@export var number_outline := Color(1, 1, 1, 1):
	set(value):
		number_outline = value
		if $Label:
			$Label.add_theme_color_override("font_outline_color", number_outline)

func _process(_delta):
	if Engine.is_editor_hint():
		if $Label:
			$Label.add_theme_color_override("font_color", number_color)
			$Label.add_theme_color_override("font_outline_color", number_outline)

static var alive = true

static var first_click = true

var clicking: bool = false

@export var board_pos: Vector2i = Vector2i(0, 0)

signal opened(to_open: Vector2i) # emitted when this block is opened

func _input(event):
	if !alive: return
	
	# space bar toggles a flag on the currently hovered block
	if Input.is_action_just_pressed("toggle_flag") && get_rect().has_point(get_global_mouse_position() - position):
		if covered:
			flag = !flag
			if flag:
				var flag_sprite = Sprite2D.new()
				flag_sprite.name = "Flag"
				flag_sprite.texture = load("res://Flag.png")
				flag_sprite.scale = Vector2(0.7, 0.7)
				add_child(flag_sprite)
				get_parent().bombs_found += 1
				get_parent().update_bombs_msg()
			else:
				var flag_sprite = $Flag
				remove_child(flag_sprite)
				flag_sprite.queue_free()
				get_parent().bombs_found -= 1
				get_parent().update_bombs_msg()
		elif bomb_count() && bomb_count() == flag_count():
			opened.emit(board_pos)
			
	
	if !flag && Input.is_action_just_pressed("click") && covered && get_rect().has_point(event.position - position):
		clicking = true
		$AnimationPlayer.play("grow")
	
	if Input.is_action_just_released("click") && covered && clicking:
		clicking = false
		if get_rect().has_point(event.position - position):
			if first_click:
				first_click = false
				get_parent().emit_signal("first_click", board_pos)
			covered = false
			reveal()
			#print("You opened the square")
			$CPUParticles2D.emitting = true
			await get_tree().create_timer(0.08).timeout
			frame = 1
			scale = Vector2(1, 1)
			
			if bomb:
				print("Game over")
				alive = false
				get_node("Explosion").emitting = true
				get_parent().game_end()
			
			if !bomb_count():
				opened.emit(board_pos)
		else:
			$AnimationPlayer.play_backwards("grow")


## returns a list of the adjacent blocks to this one
func get_adjs() -> Array[Vector2i]:
	var adjs: Array[Vector2i] = []
	for i in range(max(0, board_pos.x-1), min(get_parent().board_dim.x, board_pos.x+2)):
		for j in range(max(0, board_pos.y-1), min(get_parent().board_dim.y, board_pos.y+2)):
			var pair = Vector2i(i, j)
			if pair != board_pos: adjs.append(pair)
	return adjs


## count the number of bombs around this block
func bomb_count() -> int:
	return len(get_adjs()\
	.map(func(pos): return get_parent().board[pos.y][pos.x])\
	.filter(func(block): return block.bomb))


func flag_count() -> int:
	return len(get_adjs()\
	.map(func(pos): return get_parent().board[pos.y][pos.x])\
	.filter(func(block): return block.flag))


## connect signals properly to adjacent blocks for recursive opening
func connect_to_adjs():
	for adj in get_adjs():
		opened.connect(get_parent().get_block(adj).on_opened)


## callback function for what happens when a nearby block opens up
func on_opened(pos):
	if !flag && covered && pos in get_adjs():
		$AnimationPlayer.play("grow")
		covered = false
		reveal()
		$CPUParticles2D.emitting = true
		await get_tree().create_timer(0.08).timeout
		frame = 1
		scale = Vector2.ONE
		
		if bomb:
			print("Game over")
			alive = false
			get_node("Explosion").emitting = true
			get_parent().game_end()
		elif !bomb_count():
			opened.emit(board_pos)


func reveal():
	var bomb_child = get_node("Bomb")
	if bomb_child:
		bomb_child.visible = true
	else:
		$Label.visible = true
