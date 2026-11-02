extends Node
## Global game data (autoload "GameState").

## Name the player wrote on the book cover.
var player_name: String = ""
## Notebook contents carried from the start screen into the game.
var notebook_pages: PackedStringArray = []
## Spread the notebook was left open on.
var notebook_spread: int = 0
## Spread the in-game (sectioned) notebook opens on: where it was last left, or
## the page of the latest recorded gravestone. 0 = first page of Gravestones.
var notebook_section_spread: int = 0
## Ids of the symbols the player has rubbed.
var rubbings: Array[String] = []
## Ids of the gravestones the player has recorded in the notebook (e.g. "baby_tomb").
var gravestones: Array[String] = []
## What the player wrote on each recorded gravestone's notebook page:
## gravestone id -> {"identity": String, "death": String}.
var gravestone_reports: Dictionary = {}

## Placeholders in dialogue / page text that become the player's name.
const NAME_PLACEHOLDERS := ["#PLAYER#", "{name}"]


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
	for placeholder in NAME_PLACEHOLDERS:
		text = text.replace(placeholder, player_name)
	return text
