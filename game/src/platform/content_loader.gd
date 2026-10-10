extends RefCounted
class_name ContentLoader

## Carrega o conteúdo data-driven (doenças, salas, cargos) dos arquivos JSON
## em game/content/. Mantém o conteúdo fora do código para permitir que a
## comunidade contribua com novo conteúdo sem recompilar nada.

const DISEASES_PATH := "res://content/diseases.json"
const ROOMS_PATH := "res://content/rooms.json"
const STAFF_ROLES_PATH := "res://content/staff_roles.json"

static func load_all() -> Dictionary:
	return {
		"diseases": _load_json_array(DISEASES_PATH),
		"rooms": _load_json_array(ROOMS_PATH),
		"staff_roles": _load_json_array(STAFF_ROLES_PATH),
	}

static func _load_json_array(path: String) -> Array:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Não foi possível abrir o arquivo de conteúdo: %s" % path)
		return []
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		push_error("JSON inválido (esperado array) em: %s" % path)
		return []
	return parsed
