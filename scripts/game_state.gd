extends Node
## Global game data (autoload "GameState").

## Name the player wrote on the book cover.
var player_name: String = ""

## Placeholders in dialogue / page text that become the player's name.
const NAME_PLACEHOLDERS := ["#PLAYER#", "{name}"]


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
	for placeholder in NAME_PLACEHOLDERS:
		text = text.replace(placeholder, player_name)
	return text
