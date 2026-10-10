extends RefCounted
class_name StaffRole

## Definição de um cargo de equipe, carregada de game/content/staff_roles.json.

var id: String
var display_name: String
var base_salary: int
var base_skill: float

static func from_dict(data: Dictionary) -> StaffRole:
	var role := StaffRole.new()
	role.id = data.get("id", "")
	role.display_name = data.get("display_name", role.id)
	role.base_salary = data.get("base_salary", 0)
	role.base_skill = data.get("base_skill", 0.5)
	return role
