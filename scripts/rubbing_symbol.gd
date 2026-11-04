class_name RubbingSymbol
extends TextureRect
## A symbol carved into a tombstone that the rubbing tool can reveal.
##
## Give it a white symbol on a transparent background (`texture`) and place it
## over the tombstone art. In the game it is drawn only `darken` darker than the
## stone underneath, so it is hard to see. Brushing over it with the rubbing
## tool reveals the brushed parts in the inverted stone colour (or in
## `revealed_color`); once `reveal_threshold` of the symbol has
## been brushed, it fades in completely and `rubbed` is emitted.

## Emitted once, when the symbol has been fully rubbed.
signal rubbed(rubbing_id: String)

## Evidence id of this rubbing (as in evidence_master.ink, e.g. "infant_moon_rubbing").
@export var rubbing_id: String = ""
## target_id of the scene object (a DecipherTarget) this symbol is deciphered by:
## dragging the rubbing from the notebook onto that object reveals its meaning.
@export var matching_target_id: String = ""
## How much darker than the stone the carving is drawn (0.1 = 10% darker).
@export_range(0.0, 1.0, 0.01) var darken: float = 0.1
## Revealed symbol drawn in the inverted colour of the stone under it.
@export var reveal_inverted: bool = true
## Colour of the revealed symbol when `reveal_inverted` is off.
@export var revealed_color: Color = Color.WHITE
## Brush radius, in screen pixels.
@export var brush_radius: float = 22.0
## How much one pass of the brush reveals (several passes are needed below 1).
@export_range(0.05, 1.0, 0.05) var brush_strength: float = 0.4
## Share of the symbol that must be brushed before it counts as rubbed.
@export_range(0.1, 1.0, 0.05) var reveal_threshold: float = 0.6
## Charcoal left on the stone where it was brushed (0 = none).
@export_range(0.0, 1.0, 0.05) var charcoal_strength: float = 0.0
@export var charcoal_color: Color = Color(0.16, 0.15, 0.15)

const SHADER := preload("res://shaders/rubbing_symbol.gdshader")
## Mask resolution: one mask pixel per this many symbol pixels.
const MASK_CELL := 3.0

## True once the symbol has been fully rubbed.
var is_rubbed := false
## Ordered tutorial can temporarily defer this symbol without altering collection.
var collection_enabled := true

var _mask: Image
var _mask_texture: ImageTexture
var _material: ShaderMaterial
var _symbol_cells: PackedInt32Array = []  # mask cells covered by the symbol
var _blink_tween: Tween


func _ready() -> void:
	add_to_group("rubbing_symbols")
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	stretch_mode = TextureRect.STRETCH_SCALE
	_material = ShaderMaterial.new()
	_material.shader = SHADER
	material = _material
	_build_mask()
	resized.connect(_on_resized)
	_material.set_shader_parameter("darken", darken)
	_material.set_shader_parameter("revealed_color", revealed_color)
	_material.set_shader_parameter("reveal_inverted", reveal_inverted)
	_material.set_shader_parameter("charcoal_strength", charcoal_strength)
	_material.set_shader_parameter("charcoal_color", charcoal_color)
	_use_parent_as_stone()


## Brush from `from_global` to `to_global` (screen positions).
func brush(from_global: Vector2, to_global: Vector2) -> void:
	if not collection_enabled or is_rubbed or _mask == null:
		return
	var to_local := get_global_transform().affine_inverse()
	var a := _to_mask(to_local * from_global)
	var b := _to_mask(to_local * to_global)
	var radius := brush_radius / get_global_transform().get_scale().x \
		* _mask.get_width() / maxf(size.x, 1.0)
	# Skip strokes that are nowhere near this symbol.
	var area := Rect2(Vector2.ZERO, Vector2(_mask.get_size())).grow(radius)
	if not Rect2(a, Vector2.ZERO).expand(b).grow(1.0).intersects(area):
		return
	var steps := maxi(1, int(ceil(a.distance_to(b) / maxf(radius * 0.5, 0.5))))
	for i in steps + 1:
		_stamp(a.lerp(b, float(i) / steps), radius)
	_mask_texture.update(_mask)
	if get_coverage() >= reveal_threshold:
		_complete()


## Share (0–1) of the symbol that has been brushed.
func get_coverage() -> float:
	if _symbol_cells.is_empty():
		return 1.0
	var w := _mask.get_width()
	var done := 0
	for cell in _symbol_cells:
		if _mask.get_pixel(cell % w, cell / w).r >= 0.75:
			done += 1
	return float(done) / _symbol_cells.size()


## Share (0–1) of the symbol that has been touched by the brush at all.
func get_touched() -> float:
	if _symbol_cells.is_empty():
		return 1.0
	var w := _mask.get_width()
	var touched := 0
	for cell in _symbol_cells:
		if _mask.get_pixel(cell % w, cell / w).r > 0.0:
			touched += 1
	return float(touched) / _symbol_cells.size()


## Show the symbol as already rubbed (e.g. when loading a save).
func set_rubbed() -> void:
	is_rubbed = true
	_material.set_shader_parameter("complete", 1.0)


## Pulse the symbol on the stone (e.g. right after it was rubbed) until stop_blinking().
func start_blinking(period: float = 0.8) -> void:
	stop_blinking()
	_blink_tween = create_tween().set_loops()
	_blink_tween.tween_property(self, "modulate:a", 0.2, period * 0.5).set_trans(Tween.TRANS_SINE)
	_blink_tween.tween_property(self, "modulate:a", 1.0, period * 0.5).set_trans(Tween.TRANS_SINE)


func stop_blinking() -> void:
	if _blink_tween:
		_blink_tween.kill()
		_blink_tween = null
	modulate.a = 1.0


## If this symbol sits on a TextureRect (the tombstone art), keep the charcoal on
## the stone: the shader samples the art's transparency under the symbol.
func _use_parent_as_stone() -> void:
	var stone := get_parent() as TextureRect
	if stone == null or stone.texture == null or stone.size.x <= 0.0 or stone.size.y <= 0.0:
		return
	var uv_offset := position / stone.size
	var uv_scale := size / stone.size
	_material.set_shader_parameter("stone_tex", stone.texture)
	_material.set_shader_parameter("stone_uv_rect", Vector4(uv_offset.x, uv_offset.y, uv_scale.x, uv_scale.y))
	_material.set_shader_parameter("use_stone_mask", true)


func _complete() -> void:
	is_rubbed = true
	var t := create_tween()
	t.tween_method(func(v: float) -> void: _material.set_shader_parameter("complete", v), 0.0, 1.0, 0.6)
	rubbed.emit(rubbing_id)


func _stamp(center: Vector2, radius: float) -> void:
	var w := _mask.get_width()
	var h := _mask.get_height()
	for y in range(maxi(0, int(center.y - radius)), mini(h, int(center.y + radius) + 1)):
		for x in range(maxi(0, int(center.x - radius)), mini(w, int(center.x + radius) + 1)):
			var d := Vector2(x, y).distance_to(center)
			if d > radius:
				continue
			var add := brush_strength * (1.0 - d / radius * 0.6)
			var v := minf(1.0, _mask.get_pixel(x, y).r + add)
			_mask.set_pixel(x, y, Color(v, v, v))


func _to_mask(local: Vector2) -> Vector2:
	return local / size.max(Vector2.ONE) * Vector2(_mask.get_size())


func _on_resized() -> void:
	_use_parent_as_stone()
	# Rebuild the mask at the new size unless the player has already brushed.
	if get_touched() == 0.0 and not is_rubbed:
		_build_mask()


func _build_mask() -> void:
	var mask_size := Vector2i(maxi(4, int(ceil(size.x / MASK_CELL))), maxi(4, int(ceil(size.y / MASK_CELL))))
	_mask = Image.create(mask_size.x, mask_size.y, false, Image.FORMAT_L8)
	_mask.fill(Color.BLACK)
	_mask_texture = ImageTexture.create_from_image(_mask)
	_material.set_shader_parameter("reveal_mask", _mask_texture)
	_symbol_cells.clear()
	if texture == null:
		return
	# Which mask cells the symbol covers, to measure how much has been brushed.
	var symbol_image := texture.get_image()
	if symbol_image.is_compressed():
		symbol_image.decompress()
	symbol_image.resize(mask_size.x, mask_size.y, Image.INTERPOLATE_BILINEAR)
	for y in mask_size.y:
		for x in mask_size.x:
			if symbol_image.get_pixel(x, y).a > 0.35:
				_symbol_cells.append(y * mask_size.x + x)
