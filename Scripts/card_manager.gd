extends Node2D

var cardScene = preload("res://Scenes/card.tscn")

var full_deck: Array = []
var active_cards: Array = []
var used_cards_count := 0
var selected_card: Node = null

@onready var card_container = $card_container
@onready var card_slots = [
	$card_container/card_slot_1,
	$card_container/card_slot_2,
	$card_container/card_slot_3,
	$card_container/card_slot_4
]
@onready var deck_count_label = $deck_count
@onready var start_button = $start_button

# --- CREATE & FILTER DECK ---
func _create_full_deck() -> Array:
	var suits = ["H", "D", "C", "S"]
	var ranks = ["2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K", "A"]
	var deck = []
	for suit in suits:
		for rank in ranks:
			deck.append(rank + suit)

	# Remove red faces & aces
	var filtered = []
	for card in deck:
		var suit = card.substr(card.length() - 1)
		var rank = card.substr(0, card.length() - 1)
		if (suit == "H" or suit == "D") and (rank in ["J", "Q", "K", "A"]):
			continue
		filtered.append(card)
	return filtered


# --- DRAW CARDS ---
func _draw_cards_from_deck(amount: int) -> Array:
	if full_deck.size() < amount:
		amount = full_deck.size()
	var drawn = []
	for i in range(amount):
		var idx = randi() % full_deck.size()
		drawn.append(full_deck[idx])
		full_deck.remove_at(idx)
	_update_deck_label() 
	return drawn


# --- UPDATE DECK LABEL ---
func _update_deck_label():
	if full_deck.is_empty() :
		deck_count_label.text = "0"
	else:
		deck_count_label.text = "%d" % full_deck.size()


# --- SPAWN CARDS ---
func spawn_cards():
	if active_cards.size() > 0:
		print("Wait! Use all cards first.")
		return
	if full_deck.is_empty():
		print("No more cards left in the deck!")
		_update_deck_label()
		return

	var drawn_cards = _draw_cards_from_deck(4)
	print("Cards drawn this round:", drawn_cards)

	for i in range(drawn_cards.size()):
		var card_instance = cardScene.instantiate()
		card_container.add_child(card_instance)
		card_instance.position = card_slots[i].position

		card_instance.connect("card_used", Callable(self, "_on_card_used"))
		card_instance.connect("card_selected", Callable(self, "_on_card_selected"))
		card_instance.set_card(drawn_cards[i])
		active_cards.append(card_instance)

	_update_deck_label()


# --- CLEAR CARDS ---
func _clear_cards():
	for card in active_cards:
		if is_instance_valid(card):
			card.queue_free()
	active_cards.clear()
	used_cards_count = 0


# --- CARD USED ---
func _on_card_used(card):
	used_cards_count += 1
	print("Card used: %s (%d/%d used)" % [card.chosen_card, used_cards_count, active_cards.size()])

	if used_cards_count >= active_cards.size():
		print("All cards used. Next round!")
		_clear_cards()
		spawn_cards()


# --- CARD SELECTED ---
func _on_card_selected(card):
	if selected_card == card:
		card.hide_use_button()
		selected_card = null
		print("Deselected card:", card.chosen_card)
		return
	if selected_card and selected_card != card:
		selected_card.hide_use_button()
	selected_card = card
	selected_card.show_use_button()
	print("Selected card:", card.chosen_card)


# --- GAME START ---
func _start_game() -> void:
	start_button.visible = false
	randomize()
	full_deck = _create_full_deck()
	print("Game start: deck created with %d cards." % full_deck.size())
	_update_deck_label()
	spawn_cards()
