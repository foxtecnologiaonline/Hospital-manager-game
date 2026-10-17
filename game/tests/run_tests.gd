extends SceneTree

## Executor de testes headless, sem dependências externas (sem GUT ou outro
## framework — simples o bastante para rodar com (a partir da raiz do repo):
##   godot --headless --path game --script res://tests/run_tests.gd
## Cada _test_* retorna 0 em caso de sucesso, 1 em caso de falha.

func _init() -> void:
	var failures := 0
	failures += _test_patient_completes_full_cycle()
	failures += _test_room_requires_matching_staff_role()
	failures += _test_two_patients_contend_for_rooms()
	failures += _test_room_placement_validation()
	failures += _test_handyman_reduces_room_wear()
	failures += _test_receptionist_halves_untreated_risk()
	failures += _test_find_room_at_and_idle_staff()
	failures += _test_staff_fatigue_and_happiness()

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

## Garante que, com só 1 sala de diagnóstico e 1 de tratamento disponíveis,
## dois pacientes simultâneos nunca ocupam a mesma sala ao mesmo tempo — eles
## se alternam corretamente e ambos acabam curados.
func _test_two_patients_contend_for_rooms() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var diag_room := simulation.add_room("test_diag", Vector2i(0, 0), Vector2i(3, 3))
	var treat_room := simulation.add_room("test_treat", Vector2i(4, 0), Vector2i(3, 3))
	var doctor1 := simulation.hire_staff("doctor")
	var doctor2 := simulation.hire_staff("doctor")
	simulation.assign_staff_to_room(doctor1.staff_id, diag_room.room_id)
	simulation.assign_staff_to_room(doctor2.staff_id, treat_room.room_id)

	var patient_a := simulation.spawn_patient("test_disease")
	var patient_b := simulation.spawn_patient("test_disease")

	var ticks := 0
	var both_done := false
	while not both_done and ticks < 10:
		simulation.tick()
		ticks += 1
		both_done = (patient_a.stage == Patient.Stage.DISCHARGED or patient_a.stage == Patient.Stage.DECEASED) and (patient_b.stage == Patient.Stage.DISCHARGED or patient_b.stage == Patient.Stage.DECEASED)

	if patient_a.stage != Patient.Stage.DISCHARGED or patient_b.stage != Patient.Stage.DISCHARGED:
		print("  [FALHA] test_two_patients_contend_for_rooms — estágios finais: A=%s, B=%s (em %d ticks)" % [Patient.Stage.keys()[patient_a.stage], Patient.Stage.keys()[patient_b.stage], ticks])
		return 1
	if simulation.economy.cash != 50400:
		print("  [FALHA] test_two_patients_contend_for_rooms — caixa final inesperado: %d (esperado 50400)" % simulation.economy.cash)
		return 1
	print("  [OK] test_two_patients_contend_for_rooms (%d ticks)" % ticks)
	return 0

## Garante que add_room rejeita sobreposição com uma sala existente e
## posições fora do grid, mas aceita uma posição válida — base da
## construção interativa (clique no grid) adicionada na Fase 2.
func _test_room_placement_validation() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())

	var first := simulation.add_room("test_diag", Vector2i(0, 0), Vector2i(3, 3))
	if first == null:
		print("  [FALHA] test_room_placement_validation — construção inicial deveria ter funcionado")
		return 1

	var overlapping := simulation.add_room("test_treat", Vector2i(1, 1), Vector2i(3, 3))
	if overlapping != null:
		print("  [FALHA] test_room_placement_validation — sala sobreposta não deveria ter sido construída")
		return 1

	var out_of_bounds := simulation.add_room("test_treat", Vector2i(-1, 0), Vector2i(3, 3))
	if out_of_bounds != null:
		print("  [FALHA] test_room_placement_validation — sala fora do grid não deveria ter sido construída")
		return 1

	var valid := simulation.add_room("test_treat", Vector2i(5, 0), Vector2i(3, 3))
	if valid == null:
		print("  [FALHA] test_room_placement_validation — sala válida deveria ter sido construída")
		return 1

	print("  [OK] test_room_placement_validation")
	return 0

## Garante que o desgaste de uma sala só diminui quando há um zelador
## contratado (efeito global, sem precisar de alocação a uma sala).
func _test_handyman_reduces_room_wear() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var room := simulation.add_room("test_treat", Vector2i(0, 0), Vector2i(3, 3))
	room.wear = 5.0

	simulation.tick()
	if not is_equal_approx(room.wear, 5.0):
		print("  [FALHA] test_handyman_reduces_room_wear — desgaste mudou sem zelador contratado (%.2f)" % room.wear)
		return 1

	simulation.hire_staff("handyman")
	simulation.tick()
	if not is_equal_approx(room.wear, 4.0):
		print("  [FALHA] test_handyman_reduces_room_wear — esperado 4.0 após manutenção, obtido %.2f" % room.wear)
		return 1

	print("  [OK] test_handyman_reduces_room_wear")
	return 0

## Garante que uma recepcionista contratada reduz à metade o risco de
## piora de pacientes que ainda não foram atendidos.
func _test_receptionist_halves_untreated_risk() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var disease: Disease = simulation.diseases["test_disease"]
	disease.untreated_risk_per_tick = 0.1
	# Sem nenhuma sala construída, o paciente fica preso em QUEUED —
	# isso isola o efeito do risco por falta de atendimento.
	var patient := simulation.spawn_patient("test_disease")

	simulation.tick()
	var health_before_receptionist := patient.health
	if not is_equal_approx(health_before_receptionist, 0.9):
		print("  [FALHA] test_receptionist_halves_untreated_risk — saúde esperada 0.90 sem recepcionista, obtida %.3f" % health_before_receptionist)
		return 1

	simulation.hire_staff("receptionist")
	simulation.tick()
	var drop_with_receptionist := health_before_receptionist - patient.health
	if not is_equal_approx(drop_with_receptionist, 0.05):
		print("  [FALHA] test_receptionist_halves_untreated_risk — queda esperada 0.05 com recepcionista, obtida %.3f" % drop_with_receptionist)
		return 1

	print("  [OK] test_receptionist_halves_untreated_risk")
	return 0

## Garante que find_room_at distingue corretamente dentro/fora do footprint
## de uma sala, e que find_idle_staff só retorna equipe ainda não alocada —
## a base da alocação de equipe pelo clique na UI.
func _test_find_room_at_and_idle_staff() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var room := simulation.add_room("test_diag", Vector2i(2, 2), Vector2i(3, 3))

	var inside := simulation.find_room_at(Vector2i(3, 3))
	if inside != room:
		print("  [FALHA] test_find_room_at_and_idle_staff — ponto dentro da sala não encontrou a sala")
		return 1

	var outside := simulation.find_room_at(Vector2i(0, 0))
	if outside != null:
		print("  [FALHA] test_find_room_at_and_idle_staff — ponto fora da sala encontrou uma sala")
		return 1

	var hired := simulation.hire_staff("doctor")
	var idle := simulation.find_idle_staff("doctor")
	if idle != hired:
		print("  [FALHA] test_find_room_at_and_idle_staff — não encontrou o médico recém-contratado como ocioso")
		return 1

	simulation.assign_staff_to_room(hired.staff_id, room.room_id)
	var idle_after_assignment := simulation.find_idle_staff("doctor")
	if idle_after_assignment != null:
		print("  [FALHA] test_find_room_at_and_idle_staff — médico já alocado não deveria aparecer como ocioso")
		return 1

	print("  [OK] test_find_room_at_and_idle_staff")
	return 0

## Garante que fadiga sobe com atendimento sustentado (reduzindo felicidade
## depois de passar o limiar livre) e desce — junto com a felicidade — em
## repouso. Chama _update_staff_fatigue diretamente (método "privado" só
## por convenção em GDScript) para isolar o mecanismo sem precisar montar
## um paciente real a cada tick.
func _test_staff_fatigue_and_happiness() -> int:
	var simulation := HospitalSimulation.new(_make_test_content())
	var room := simulation.add_room("test_treat", Vector2i(0, 0), Vector2i(3, 3))
	var staff := simulation.hire_staff("doctor")
	simulation.assign_staff_to_room(staff.staff_id, room.room_id)

	room.occupant_patient_id = 1
	for i in range(7):
		simulation._update_staff_fatigue()

	if not is_equal_approx(staff.fatigue, 0.7):
		print("  [FALHA] test_staff_fatigue_and_happiness — fadiga esperada 0.70 após 7 atendimentos, obtida %.2f" % staff.fatigue)
		return 1
	if is_equal_approx(staff.happiness, 1.0):
		print("  [FALHA] test_staff_fatigue_and_happiness — felicidade deveria ter caído com fadiga alta")
		return 1

	room.occupant_patient_id = -1
	for i in range(14):
		simulation._update_staff_fatigue()

	if not is_equal_approx(staff.fatigue, 0.0):
		print("  [FALHA] test_staff_fatigue_and_happiness — fadiga deveria zerar após descanso, obtida %.2f" % staff.fatigue)
		return 1
	if not is_equal_approx(staff.happiness, 1.0):
		print("  [FALHA] test_staff_fatigue_and_happiness — felicidade deveria voltar a 1.0 após descanso, obtida %.2f" % staff.happiness)
		return 1

	print("  [OK] test_staff_fatigue_and_happiness")
	return 0
