extends RefCounted
class_name Patient

## Instância de um paciente durante a simulação (não é conteúdo de dados).

enum Stage { QUEUED, DIAGNOSIS, TREATMENT, DISCHARGED, DECEASED }

var patient_id: int
var disease_id: String
var health: float = 1.0
var happiness: float = 1.0
var patience: float = 1.0
var stage: Stage = Stage.QUEUED

func _init(p_id: int, p_disease_id: String) -> void:
	patient_id = p_id
	disease_id = p_disease_id
