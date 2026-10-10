extends RefCounted
class_name HospitalSimulation

## Orquestrador central da simulação. Recebe o conteúdo já carregado
## (doenças, salas, cargos) e mantém o estado de pacientes e economia.
##
## Nesta Fase 0, contém apenas o esqueleto de carregamento de conteúdo e um
## "tick" de demonstração. O fluxo completo (fila -> diagnóstico ->
## tratamento -> alta, com alocação de salas e equipe) é trabalho da Fase 1
## do roadmap (docs/ESCOPO.md).

var diseases: Dictionary = {}
var rooms: Dictionary = {}
var staff_roles: Dictionary = {}
var economy: Economy
var patient_queue: Array[Patient] = []
var _next_patient_id: int = 1

func _init(content: Dictionary) -> void:
	for entry in content.get("diseases", []):
		var disease := Disease.from_dict(entry)
		diseases[disease.id] = disease
	for entry in content.get("rooms", []):
		var room := RoomDefinition.from_dict(entry)
		rooms[room.id] = room
	for entry in content.get("staff_roles", []):
		var role := StaffRole.from_dict(entry)
		staff_roles[role.id] = role
	economy = Economy.new()

func spawn_patient(disease_id: String) -> Patient:
	var patient := Patient.new(_next_patient_id, disease_id)
	_next_patient_id += 1
	patient_queue.append(patient)
	return patient

## Tick de demonstração/smoke-test: prova que o conteúdo data-driven carrega
## e que a economia inicial está consistente. Não representa o loop de jogo
## final.
func start_demo_tick() -> void:
	print("Hospital Manager — conteúdo carregado:")
	print("  doenças: %d" % diseases.size())
	print("  salas: %d" % rooms.size())
	print("  cargos de equipe: %d" % staff_roles.size())
	if diseases.size() > 0:
		var first_disease_id: String = diseases.keys()[0]
		spawn_patient(first_disease_id)
		var demo_patient: Patient = patient_queue[0]
		print("  paciente de demonstração #%d com doença '%s'" % [demo_patient.patient_id, first_disease_id])
	print("Economia — caixa: %d, reputação: %.2f" % [economy.cash, economy.reputation])
	# TODO (Fase 1): fila -> diagnóstico -> tratamento, alocação de salas/equipe.
