extends Node
## Global game data (autoload "GameState").

## Name the player wrote on the book cover.
var player_name: String = ""
## Notebook contents carried from the start screen into the game.
var notebook_pages: PackedStringArray = []
## Spread the notebook was left open on.
var notebook_spread: int = 0

## Placeholders in dialogue / page text that become the player's name.
const NAME_PLACEHOLDERS := ["#PLAYER#", "{name}"]


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
	for placeholder in NAME_PLACEHOLDERS:
		text = text.replace(placeholder, player_name)
	return text
