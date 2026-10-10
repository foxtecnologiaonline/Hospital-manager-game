extends RefCounted
class_name Disease

## Definição de uma doença, carregada de game/content/diseases.json.
## Nomes e mecânicas são originais deste projeto — ver docs/ESCOPO.md, seção 3.

var id: String
var display_name: String
var diagnosis_room_ids: Array
var treatment_room_id: String
var base_cure_chance: float
var untreated_risk_per_tick: float

static func from_dict(data: Dictionary) -> Disease:
	var disease := Disease.new()
	disease.id = data.get("id", "")
	disease.display_name = data.get("display_name", disease.id)
	disease.diagnosis_room_ids = data.get("diagnosis_room_ids", [])
	disease.treatment_room_id = data.get("treatment_room_id", "")
	disease.base_cure_chance = data.get("base_cure_chance", 0.9)
	disease.untreated_risk_per_tick = data.get("untreated_risk_per_tick", 0.01)
	return disease
