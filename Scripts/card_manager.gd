extends Node2D

var cardScene = preload("res://Scenes/card.tscn")
var active_cards = []
var used_cards_count = 0
var selected_card: Node = null

@onready var card_container = $card_container
@onready var card_slots = [
	$card_container/card_slot_1,
	$card_container/card_slot_2,
	$card_container/card_slot_3,
	$card_container/card_slot_4
]


# --- SPAWN & DISPLAY CARDS ---
func spawn_cards():
	if active_cards.size() > 0:
		print("Wait! You must use all current cards before drawing new ones.")
		return

	used_cards_count = 0 # Reset

	for i in range(card_slots.size()):
		var card_instance = cardScene.instantiate()
		card_container.add_child(card_instance)  # Add to container
		card_instance.position = card_slots[i].position  # Position at slot

		# Connect signals immediately after creating the card
		card_instance.connect("card_used", Callable(self, "_on_card_used"))
		card_instance.connect("card_selected", Callable(self, "_on_card_selected"))
		active_cards.append(card_instance)

	# Print all card values to simulate dealer knowledge
	for card in active_cards:
		print("Dealer sees card: %s (value: %d)" % [card.chosen_card, card.card_value])

# Count used cards
func _on_card_used(card):
	used_cards_count += 1
	print("Card used: %s (%d/%d used)" % [card.chosen_card, used_cards_count, active_cards.size()])

	if used_cards_count >= active_cards.size():
		print("All cards used. You can now draw new cards.")
		_clear_cards()  # remove or reset old cards

# Once all cards are used, clear them
func _clear_cards():
	for card in active_cards:
		if is_instance_valid(card):
			card.queue_free()
	active_cards.clear()

# Button Node to start
func _init_random_cards() -> void:
	spawn_cards()

func _on_card_selected(card):
	# If the same card is clicked again → toggle off
	if selected_card == card:
		card.hide_use_button()
		selected_card = null
		print("Deselected card:", card.chosen_card)
		return

	# Hide previous card’s button (if different card selected)
	if selected_card and selected_card != card:
		selected_card.hide_use_button()

	# Show new card’s button
	selected_card = card
	selected_card.show_use_button()
	print("Selected card:", card.chosen_card)
