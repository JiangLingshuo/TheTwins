class_name SoftIcon
## Gives a tool button the soft, grainy look shared with the dialogue boxes
## (see shaders/soft_icon.gdshader).

const SHADER := preload("res://shaders/soft_icon.gdshader")

static func apply(item: CanvasItem) -> void:
	var material := ShaderMaterial.new()
	material.shader = SHADER
	item.material = material


## For a drawn, scaled-down control tree (the notebook's picture): the root takes
## the material and everything under it shares it, measured in screen pixels.
static func apply_tree(root: CanvasItem) -> void:
	apply(root)
	(root.material as ShaderMaterial).set_shader_parameter("screen_space", true)
	for node in root.find_children("*", "CanvasItem", true, false):
		(node as CanvasItem).use_parent_material = true
