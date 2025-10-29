extends Node2D

var cardScene = preload("res://Scenes/card.tscn")
var active_cards = []
var used_cards_count = 0

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
		card_instance.connect("card_used", Callable(self, "_on_card_used"))
		active_cards.append(card_instance)

	# Print all card values to simulate dealer knowledge
	for card in active_cards:
		print("Dealer sees card: %s (value: %d)" % [card.chosen_card, card.card_value])

func _on_card_used(card):
	used_cards_count += 1
	print("Card used: %s (%d/%d used)" % [card.chosen_card, used_cards_count, active_cards.size()])

	if used_cards_count >= active_cards.size():
		print("All cards used. You can now draw new cards.")
		_clear_cards()  # remove or reset old cards

func _clear_cards():
	for card in active_cards:
		if is_instance_valid(card):
			card.queue_free()
	active_cards.clear()

func _init_random_cards() -> void:
	spawn_cards()
