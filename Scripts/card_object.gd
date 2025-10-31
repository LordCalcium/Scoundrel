extends Node2D

signal card_used
signal card_selected(card)

@onready var button = $useButton

var chosen_card: String
var card_value: int = 0

var suit_to_texture_path = {
	"C": "res://Sprites/cards/clubs/",
	"D": "res://Sprites/cards/diamonds/",
	"H": "res://Sprites/cards/hearts/",
	"S": "res://Sprites/cards/spades/"
}


# --- PUBLIC METHOD TO ASSIGN CARD ---
func set_card(card_code: String):
	chosen_card = card_code
	card_value = calculate_card_value(card_code)
	set_card_texture(card_code)
	print("Card initialized:", chosen_card, "Value:", card_value)


# --- CALCULATE VALUE ---
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

	if suit in ["H", "D"]:
		return base_value
	else:
		return -base_value


# --- SET TEXTURE ---
func set_card_texture(card: String):
	var suit = card.substr(card.length() - 1)
	var texture_path = suit_to_texture_path.get(suit, "") + card + ".png"
	var texture = load(texture_path)
	if texture:
		$Sprite2D.texture = texture


# --- BUTTON LOGIC ---
func use_card():
	visible = false
	emit_signal("card_used", self)

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("card_selected", self)

func show_use_button():
	button.visible = true

func hide_use_button():
	button.visible = false

func _on_use_pressed():
	print("Use pressed on:", chosen_card)
	use_card()
