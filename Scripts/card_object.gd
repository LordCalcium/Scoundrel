extends Node2D

signal card_used
signal card_selected(card)

var suits = ["H", "D", "C", "S"]
var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]

# The final card that this object represents
var chosen_card: String
var card_value: int = 0

# Path mapping
var suit_to_texture_path = {
	"C": "res://Sprites/cards/clubs/",
	"D": "res://Sprites/cards/diamonds/",
	"H": "res://Sprites/cards/hearts/",
	"S": "res://Sprites/cards/spades/"
}

# Button 
@onready var button = $useButton

# --- CREATE & FILTER DECK ---
func create_deck() -> Array:
	var deck = []
	for suit in suits:
		for rank in ranks:
			deck.append(rank + suit)
	return deck

func remove_red_faces_and_aces(deck: Array) -> Array:
	var filtered = []
	for card in deck:
		var suit = card.substr(card.length() - 1)
		var rank = card.substr(0, card.length() - 1)

		if (suit == "H" or suit == "D") and (rank in ["J", "Q", "K", "A"]):
			continue
		filtered.append(card)
	return filtered

# --- SELECT RANDOM CARD ---
func pick_random_card(filtered_deck: Array) -> String:
	if filtered_deck.is_empty():
		return ""
	var idx = randi() % filtered_deck.size()
	return filtered_deck[idx]

# --- CALCULATE CARD VALUE ---
func calculate_card_value(card: String) -> int:
	var suit = card.substr(card.length() - 1)
	var rank = card.substr(0, card.length() - 1)
	var base_value = 0

	match rank:
		"J": base_value = 10
		"Q": base_value = 11
		"K": base_value = 12
		"A": base_value = 13
		_: base_value = int(rank)

	# Heart/Diamond = positive, Club/Spade = negative
	if suit in ["H", "D"]:
		return base_value
	else:
		return -base_value

# --- LOAD TEXTURE BASED ON CARD ---
func set_card_texture(card: String):
	var suit = card.substr(card.length() - 1)
	var texture_path = suit_to_texture_path.get(suit, "") + card + ".png"
	var texture = load(texture_path)
	if texture:
		$Sprite2D.texture = texture

# --- READY ---
func _ready():
	randomize()
	var deck = create_deck()
	var filtered = remove_red_faces_and_aces(deck)
	chosen_card = pick_random_card(filtered)
	card_value = calculate_card_value(chosen_card)
	set_card_texture(chosen_card)

	print("Card drawn: %s (value: %d)" % [chosen_card, card_value])


func use_card() -> void:
	visible = false # Hide the card itself not the parent node
	emit_signal("card_used", self)

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_selected", self)

func show_use_button():
	button.visible = true

func hide_use_button():
	button.visible = false

func _on_use_pressed():
	# Optional: emit a signal for the card_manager to know this card was used
	print("Use pressed on:", self.name)
	get_parent().emit_signal("card_used", self)
