extends RefCounted
class_name Room

## Instância de uma sala construída no mapa, com posição concreta.
## Distinta de RoomDefinition, que descreve apenas o *tipo* de sala no
## catálogo de conteúdo (ex.: "Consulta Geral" é uma RoomDefinition; cada
## sala que o jogador constrói no mapa é um Room).

var room_id: String
var definition_id: String
var position: Vector2i
var size: Vector2i
var assigned_staff_id: int = -1
var occupant_patient_id: int = -1

func _init(p_room_id: String, p_definition_id: String, p_position: Vector2i, p_size: Vector2i) -> void:
	room_id = p_room_id
	definition_id = p_definition_id
	position = p_position
	size = p_size

func is_staffed() -> bool:
	return assigned_staff_id != -1

func is_occupied() -> bool:
	return occupant_patient_id != -1
