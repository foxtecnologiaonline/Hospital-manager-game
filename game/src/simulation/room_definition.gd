extends RefCounted
class_name RoomDefinition

## Definição de um tipo de sala, carregada de game/content/rooms.json.

var id: String
var display_name: String
var category: String # "diagnosis", "treatment" ou "support"
var min_size: Vector2i
var required_staff_role: String
var cost: int

static func from_dict(data: Dictionary) -> RoomDefinition:
	var room := RoomDefinition.new()
	room.id = data.get("id", "")
	room.display_name = data.get("display_name", room.id)
	room.category = data.get("category", "support")
	var size: Array = data.get("min_size", [3, 3])
	room.min_size = Vector2i(size[0], size[1])
	room.required_staff_role = data.get("required_staff_role", "")
	room.cost = data.get("cost", 0)
	return room
