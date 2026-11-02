extends Node
## Global game data (autoload "GameState").

## Emitted when a rubbing is recorded or its meaning is confirmed.
signal rubbings_changed

## Name the player wrote on the book cover.
var player_name: String = ""
## Notebook contents carried from the start screen into the game.
var notebook_pages: PackedStringArray = []
## Spread the notebook was left open on.
var notebook_spread: int = 0
## Spread the in-game (sectioned) notebook opens on: where it was last left, or
## the page of the latest recorded gravestone. 0 = first page of Gravestones.
var notebook_section_spread: int = 0
## Ids of the symbols the player has rubbed, in the order they were collected.
var rubbings: Array[String] = []
## Rubbing id -> {"gravestone": source gravestone id, "texture": symbol texture
## path, "target": target_id of the scene object that deciphers it,
## "meaning": confirmed meaning ("" until deciphered)}.
var rubbing_records: Dictionary = {}
## Ids of the gravestones the player has recorded in the notebook (e.g. "baby_tomb").
var gravestones: Array[String] = []
## What the player wrote on each recorded gravestone's notebook page:
## gravestone id -> {"identity": String, "death": String}.
var gravestone_reports: Dictionary = {}

## Placeholders in dialogue / page text that become the player's name.
const NAME_PLACEHOLDERS := ["#PLAYER#", "{name}"]


## Record a rubbing the first time its symbol is revealed. Returns false if it
## was already recorded (nothing changes then).
func record_rubbing(rubbing_id: String, gravestone_id: String = "", texture_path: String = "",
		target_id: String = "") -> bool:
	if rubbing_id.is_empty() or rubbings.has(rubbing_id):
		return false
	rubbings.append(rubbing_id)
	rubbing_records[rubbing_id] = {"gravestone": gravestone_id, "texture": texture_path,
		"target": target_id, "meaning": ""}
	rubbings_changed.emit()
	return true


## Decipher a collected rubbing: store its confirmed `meaning` so the notebook
## shows it (with a tick) in the Rubbings section and on its gravestone's page.
## For story progression, e.g.
##     GameState.confirm_rubbing_meaning("infant_moon_rubbing", "Night / the other city")
## Returns false if the rubbing has not been collected or `meaning` is blank.
## Calling it again replaces the meaning; collection order never changes.
func confirm_rubbing_meaning(rubbing_id: String, meaning: String) -> bool:
	meaning = meaning.strip_edges()
	if meaning.is_empty() or not rubbings.has(rubbing_id):
		return false
	var record: Dictionary = rubbing_records.get(rubbing_id, {})
	if record.get("meaning", "") != meaning:
		record["meaning"] = meaning
		rubbing_records[rubbing_id] = record
		rubbings_changed.emit()
	return true


## True once a rubbing's meaning has been confirmed.
func is_rubbing_deciphered(rubbing_id: String) -> bool:
	return not get_rubbing_meaning(rubbing_id).is_empty()


## Confirmed meaning of a rubbing, or "" while it is undeciphered.
func get_rubbing_meaning(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("meaning", "")


## target_id of the scene object that deciphers a rubbing ("" if none).
func get_rubbing_target(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("target", "")


## Texture path of a rubbing's symbol ("" if unknown).
func get_rubbing_texture(rubbing_id: String) -> String:
	return rubbing_records.get(rubbing_id, {}).get("texture", "")


## Rubbings taken from one gravestone, in collection order.
func get_gravestone_rubbings(gravestone_id: String) -> Array[String]:
	return rubbings.filter(func(id: String) -> bool:
		return rubbing_records.get(id, {}).get("gravestone", "") == gravestone_id)


## Returns `text` with every name placeholder replaced by the player's name.
func fill_placeholders(text: String) -> String:
	for placeholder in NAME_PLACEHOLDERS:
		text = text.replace(placeholder, player_name)
	return text
