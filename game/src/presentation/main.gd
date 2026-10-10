extends Node2D

## Cena de bootstrap da Fase 1 (MVP do loop central): monta um hospital
## mínimo (2 salas + 2 membros de equipe), gera um paciente e roda a
## simulação tick a tick até ele receber alta ou falecer, imprimindo o
## progresso no console. Ainda não há renderização de mapa/HUD — isso
## continua pendente (ver backlog em docs/ESCOPO.md).

func _ready() -> void:
	var content := ContentLoader.load_all()
	var simulation := HospitalSimulation.new(content)

	var diagnosis_room := simulation.add_room("general_checkup", Vector2i(0, 0), Vector2i(4, 4))
	var treatment_room := simulation.add_room("static_discharge_room", Vector2i(5, 0), Vector2i(4, 4))
	if diagnosis_room == null or treatment_room == null:
		push_error("Não foi possível construir as salas de demonstração (conteúdo ausente ou caixa insuficiente).")
		return

	var doctor := simulation.hire_staff("doctor")
	var nurse := simulation.hire_staff("nurse")
	simulation.assign_staff_to_room(doctor.staff_id, diagnosis_room.room_id)
	simulation.assign_staff_to_room(nurse.staff_id, treatment_room.room_id)

	var patient := simulation.spawn_patient("static_hair")

	print("Hospital Manager — demo da Fase 1 (fila -> diagnóstico -> tratamento -> alta):")
	var tick_count := 0
	while patient.stage != Patient.Stage.DISCHARGED and patient.stage != Patient.Stage.DECEASED and tick_count < 20:
		simulation.tick()
		tick_count += 1
		print("  tick %d — paciente #%d, estágio: %s, saúde: %.2f" % [tick_count, patient.patient_id, Patient.Stage.keys()[patient.stage], patient.health])

	print("Resultado final — estágio: %s" % Patient.Stage.keys()[patient.stage])
	print("Economia — caixa: %d, reputação: %.2f" % [simulation.economy.cash, simulation.economy.reputation])
