class_name DialogueLoader
extends RefCounted
## Reads a dialogue XML file into an array of { "speaker": String, "content": String }.
##
## Expected format:
##   <dialogue>
##       <line speaker="Name">What they say.</line>
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

	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var tag := parser.get_node_name()
				if tag == "line":
					speaker = parser.get_named_attribute_value_safe("speaker")
					content = ""
					if parser.is_empty():
						lines.append(_make_line(speaker, content))
					else:
						in_line = true
				elif tag == "br" and in_line:
					content += "\n"
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if in_line:
					content += _collapse_whitespace(parser.get_node_data())
			XMLParser.NODE_ELEMENT_END:
				if parser.get_node_name() == "line" and in_line:
					lines.append(_make_line(speaker, content))
					in_line = false

	return lines


static func _make_line(speaker: String, content: String) -> Dictionary:
	var cleaned := content.xml_unescape()
	# Trim spaces around manual line breaks and at both ends.
	var parts := cleaned.split("\n")
	for i in parts.size():
		parts[i] = parts[i].strip_edges()
	return {
		"speaker": speaker.xml_unescape().strip_edges(),
		"content": "\n".join(parts).strip_edges(),
	}


static func _collapse_whitespace(text: String) -> String:
	var regex := RegEx.create_from_string("\\s+")
	return regex.sub(text, " ", true)
