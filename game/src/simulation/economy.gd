extends RefCounted
class_name Economy

## Estado financeiro e de reputação do hospital.

var cash: int
var reputation: float

func _init(starting_cash: int = 50000, starting_reputation: float = 0.5) -> void:
	cash = starting_cash
	reputation = starting_reputation

func can_afford(amount: int) -> bool:
	return cash >= amount

func spend(amount: int) -> void:
	cash -= amount

func earn(amount: int) -> void:
	cash += amount

func adjust_reputation(delta: float) -> void:
	reputation = clamp(reputation + delta, 0.0, 1.0)
