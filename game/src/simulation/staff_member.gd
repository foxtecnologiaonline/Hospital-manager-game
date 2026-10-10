extends RefCounted
class_name StaffMember

## Instância de um membro de equipe contratado durante a simulação
## (não é conteúdo de dados — ver StaffRole para o cargo/catálogo).

var staff_id: int
var role_id: String
var assigned_room_id: String = ""
var fatigue: float = 0.0
var happiness: float = 1.0

func _init(p_id: int, p_role_id: String) -> void:
	staff_id = p_id
	role_id = p_role_id
