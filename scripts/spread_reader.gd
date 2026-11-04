extends Control
## One physical page of a two-page document. Text flows left -> right, then on to
## the next spread, turned with the book's page corners (Book._turn_reading()).
## The title (and the back button of a folded entry) sits on the left page only.
signal back_requested
signal step_requested(delta: int)
signal keyword_selected(id: String)
var body: RichTextLabel
## Height of the text under a clue's reveal figure (Book paginates with it).
const REVEAL_TEXT_HEIGHT := 140

static func plain(text: String) -> String:
	return RegEx.create_from_string('<link="[^\"]+">([^<]+)</link>').sub(text, '$1', true)

static func paginate(raw: String, font: Font, width: float, height: float) -> Array[String]:
	var pages: Array[String] = []
	var current := ""
	var tokens := RegEx.create_from_string('<link="[^\"]+">[^<]+</link>\\s*|[^\\s]+\\s*').search_all(raw)
	for token in tokens:
		var word := token.get_string()
		var candidate := current + word
		if not current.is_empty() and font.get_multiline_string_size(plain(candidate), HORIZONTAL_ALIGNMENT_LEFT, width, 22).y > height - 8:
			pages.append(current)
			current = word
		else:
			current = candidate
	if not current.is_empty(): pages.append(current)
	if pages.is_empty(): pages.append("")
	return pages

func _label(text: String, font: Font, ink: Color, at: Vector2, box: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.position = at
	label.size = box
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", ink)
	add_child(label)
	return label

func _button(text: String, at: Vector2, width: float, action: Callable, font: Font, ink: Color) -> void:
	var button := Button.new()
	button.text = text
	button.position = at
	button.size = Vector2(width, 30)
	button.add_theme_font_override("font", font)
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", ink)
	button.pressed.connect(action, CONNECT_DEFERRED)
	add_child(button)

## back_text: label of the button that returns to the entry list ("" = none).
## reveal: a rubbing reveal ({rubbing, object_texture}) drawn as a figure above the
## text on the first page; its text then has REVEAL_TEXT_HEIGHT on every page.
func setup(title: String, chunk: String, font: Font, ink: Color, left: bool, offset: int, count: int, manuscript: bool, interactive: bool, back_text: String = "", reveal: Dictionary = {}) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	if left:
		if not back_text.is_empty():
			_button(back_text, Vector2.ZERO, 190, func() -> void: back_requested.emit(), font, ink)
		_label(title, font, ink, Vector2(0, 30), Vector2(320, 52), 22)
	body = RichTextLabel.new()
	body.name = "DocumentBody"
	body.position = Vector2(0, 108)
	body.size = Vector2(320, 300)
	if not reveal.is_empty() and left and offset == 0:
		var figure := Control.new()
		figure.set_script(preload("res://scripts/reveal_figure.gd"))
		figure.name = "RevealFigure"
		figure.position = Vector2(0, 96)
		figure.size = Vector2(320, 160)
		add_child(figure)
		figure.setup(GameState.get_rubbing_texture(str(reveal.get("rubbing", ""))), str(reveal.get("object_texture", "")), ink)
		body.position = Vector2(0, 268)
		body.size = Vector2(320, REVEAL_TEXT_HEIGHT)
	body.bbcode_enabled = true
	body.scroll_active = false
	body.fit_content = false
	body.clip_contents = true
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_override("normal_font", font)
	body.add_theme_font_size_override("normal_font_size", 22)
	body.add_theme_color_override("default_color", ink)
	var content := GameState.fill_placeholders(chunk).replace("[", "[lb]")
	content = RegEx.create_from_string('<link="([^\"]+)">([^<]+)</link>').sub(content, '[url=$1][color=#843c42][u]$2[/u][/color][/url]', true)
	if manuscript and "infant" not in GameState.radio_progress.get("manuscript_keywords", []):
		content = content.replace('[url=infant][color=#843c42][u]infant[/u][/color][/url]', '[url=infant][color=#843c42][wave amp=3.0 freq=2.5][u]infant[/u][/wave][/color][/url]')
	if manuscript and chunk.contains('<link="infant">') and "infant" not in GameState.radio_progress.get("manuscript_keywords", []):
		var ripple = preload("res://scripts/keyword_ripple.gd").new()
		ripple.name = "KeywordRipple"
		ripple.position = Vector2(0, 84)
		ripple.size = Vector2(320, 26)
		ripple.tint = Color("843c42")
		add_child(ripple)
		_label("Click the underlined keyword.", font, Color("843c42"), Vector2(36, 86), Vector2(280, 24), 17)
	body.text = content
	body.mouse_filter = Control.MOUSE_FILTER_STOP if interactive else Control.MOUSE_FILTER_IGNORE
	body.meta_clicked.connect(func(meta: Variant) -> void: keyword_selected.emit(str(meta)), CONNECT_DEFERRED)
	add_child(body)
	if count > 1:
		_label(str(offset + (1 if left else 2)) + " / " + str(count) if left or offset + 1 < count else "", font, ink, Vector2(133, 420), Vector2(65, 28), 17)
	if manuscript and chunk.contains('<link='):
		body.tooltip_text = "Click underlined words to take notes."
