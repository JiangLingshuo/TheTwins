class_name SoftIcon
## Gives a tool button the soft, grainy look shared with the dialogue boxes
## (see shaders/soft_icon.gdshader).

const SHADER := preload("res://shaders/soft_icon.gdshader")

static func apply(item: CanvasItem) -> void:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	item.material = material
