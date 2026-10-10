extends SceneTree

## Executor de testes headless, sem dependências externas (sem GUT ou outro
## framework — simples o bastante para rodar com (a partir da raiz do repo):
##   godot --headless --path game --script res://tests/run_tests.gd
## Cada _test_* retorna 0 em caso de sucesso, 1 em caso de falha.

func _init() -> void:
	var failures := 0
	failures += _test_patient_completes_full_cycle()
	failures += _test_room_requires_matching_staff_role()

	if failures == 0:
		print("OK — todos os testes passaram.")
	else:
		print("FALHA — %d teste(s) falharam." % failures)
	quit(failures)

func _make_test_content() -> Dictionary:
	return {
		"diseases": [
			{
				"id": "test_disease",
				"display_name": "Doença de Teste",
				"diagnosis_room_ids": ["test_diag"],
				"treatment_room_id": "test_treat",
				"base_cure_chance": 1.0,
				"untreated_risk_per_tick": 0.0,
			}
		],
		"rooms": [
			{
				"id": "test_diag",
				"display_name": "Diagnóstico de Teste",
				"category": "diagnosis",
				"min_size": [3, 3],
				"required_staff_role": "doctor",
				"cost": 0,
			},
			{
				"id": "test_treat",
				"display_name": "Tratamento de Teste",
				"category": "treatment",
				"min_size": [3, 3],
				"required_staff_role": "doctor",
				"cost": 0,
			},
		],
		"staff_roles": [
			{"id": "doctor", "display_name": "Médico de Teste", "base_salary": 0, "base_skill": 1.0},
		],
	}

func _test_patient_completes_full_cycle() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var diag_room := simulation.add_room("test_diag", Vector2i(0, 0), Vector2i(3, 3))
	var treat_room := simulation.add_room("test_treat", Vector2i(4, 0), Vector2i(3, 3))
	var doctor1 := simulation.hire_staff("doctor")
	var doctor2 := simulation.hire_staff("doctor")
	simulation.assign_staff_to_room(doctor1.staff_id, diag_room.room_id)
	simulation.assign_staff_to_room(doctor2.staff_id, treat_room.room_id)

	var patient := simulation.spawn_patient("test_disease")

	var ticks := 0
	while patient.stage != Patient.Stage.DISCHARGED and patient.stage != Patient.Stage.DECEASED and ticks < 10:
		simulation.tick()
		ticks += 1

	if patient.stage != Patient.Stage.DISCHARGED:
		print("  [FALHA] test_patient_completes_full_cycle — estágio final inesperado: %s (em %d ticks)" % [Patient.Stage.keys()[patient.stage], ticks])
		return 1
	if simulation.economy.cash != 50200:
		print("  [FALHA] test_patient_completes_full_cycle — caixa final inesperado: %d (esperado 50200)" % simulation.economy.cash)
		return 1
	print("  [OK] test_patient_completes_full_cycle (%d ticks)" % ticks)
	return 0

func _test_room_requires_matching_staff_role() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var diag_room := simulation.add_room("test_diag", Vector2i(0, 0), Vector2i(3, 3))
	# "test_diag" exige o cargo "doctor" — contratar uma enfermeira (cargo
	# inexistente neste conteúdo de teste teria falhado antes; aqui
	# simulamos um cargo incompatível registrando um StaffMember manualmente).
	var mismatched_staff := StaffMember.new(999, "nurse")
	simulation.staff_members[mismatched_staff.staff_id] = mismatched_staff

	var assigned := simulation.assign_staff_to_room(mismatched_staff.staff_id, diag_room.room_id)
	if assigned:
		print("  [FALHA] test_room_requires_matching_staff_role — alocação deveria ter sido rejeitada")
		return 1
	if diag_room.is_staffed():
		print("  [FALHA] test_room_requires_matching_staff_role — sala não deveria estar com equipe")
		return 1
	print("  [OK] test_room_requires_matching_staff_role")
	return 0
