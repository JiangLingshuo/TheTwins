class_name DialogueLoader
extends RefCounted
## Reads a dialogue XML file into an array of { "speaker": String, "content": String }.
##
## Expected format:
##   <dialogue>
##       <line speaker="Name">What they say.</line>
##   A line may carry a sound cue: sfx="wind" plays as the line starts,
##   sfx_after="busy" plays when the player moves past it (see dialogue_box.gd).
##   </dialogue>


static func load_xml(path: String) -> Array[Dictionary]:
	var lines: Array[Dictionary] = []
	var parser := XMLParser.new()
	var err := parser.open(path)
	if err != OK:
		push_error("DialogueLoader: cannot open '%s' (error %d)" % [path, err])
		return lines

	var in_line := false
	var speaker := ""
	var content := ""
	var cues := {}

	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var tag := parser.get_node_name()
				if tag == "line":
					speaker = parser.get_named_attribute_value_safe("speaker")
					content = ""
					cues = {}
					for cue in ["sfx", "sfx_after"]:
						if parser.has_attribute(cue):
							cues[cue] = parser.get_named_attribute_value(cue)
					if parser.is_empty():
						lines.append(_make_line(speaker, content, cues))
					else:
						in_line = true
				elif tag == "br" and in_line:
					content += "\n"
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if in_line:
					content += _collapse_whitespace(parser.get_node_data())
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "line" and in_line:
					lines.append(_make_line(speaker, content, cues))
					in_line = false

	return lines


static func _make_line(speaker: String, content: String, cues: Dictionary = {}) -> Dictionary:
	var cleaned := content.xml_unescape()
	# Trim spaces around manual line breaks and at both ends.
	var parts := cleaned.split("\n")
	for i in parts.size():
		parts[i] = parts[i].strip_edges()
	var line := {
		"speaker": speaker.xml_unescape().strip_edges(),
		"content": "\n".join(parts).strip_edges(),
	}
	line.merge(cues)
	return line


static func _collapse_whitespace(text: String) -> String:
	var regex := RegEx.create_from_string("\\s+")
	return regex.sub(text, " ", true)
