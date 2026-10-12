extends RefCounted
class_name HospitalSimulation

## Orquestrador central da simulação. Recebe o conteúdo já carregado
## (doenças, salas, cargos) e mantém o estado de salas construídas, equipe
## contratada, pacientes ativos e economia.
##
## Modelo da Fase 1 (MVP do loop central): cada estágio de atendimento
## (diagnóstico, tratamento) consome exatamente 1 tick de simulação em uma
## sala livre e com equipe alocada. É uma simplificação deliberada — não há
## ainda duração variável, movimento no mapa ou pathfinding; isso é
## refinamento de fases futuras. O objetivo aqui é validar a máquina de
## estados fila -> diagnóstico -> tratamento -> alta/óbito de ponta a ponta.

# Conteúdo (catálogo, carregado uma vez a partir dos arquivos JSON)
var diseases: Dictionary = {}
var room_definitions: Dictionary = {}
var staff_roles: Dictionary = {}

# Estado em-jogo (instâncias)
var placed_rooms: Dictionary = {} # room_id (String) -> Room
var staff_members: Dictionary = {} # staff_id (int) -> StaffMember
var patients: Dictionary = {} # patient_id (int) -> Patient
var economy: Economy
var grid_size: Vector2i = Vector2i(20, 20)

var _next_room_id: int = 1
var _next_staff_id: int = 1
var _next_patient_id: int = 1

func _init(content: Dictionary) -> void:
	for entry in content.get("diseases", []):
		var disease := Disease.from_dict(entry)
		diseases[disease.id] = disease
	for entry in content.get("rooms", []):
		var room_definition := RoomDefinition.from_dict(entry)
		room_definitions[room_definition.id] = room_definition
	for entry in content.get("staff_roles", []):
		var role := StaffRole.from_dict(entry)
		staff_roles[role.id] = role
	economy = Economy.new()

## Verifica se é possível construir uma sala do tipo `definition_id` na
## posição/tamanho dados: tipo existe, tamanho respeita o mínimo do tipo,
## cabe dentro do grid, não sobrepõe nenhuma sala já construída, e o
## hospital tem caixa suficiente. Não tem efeito colateral (não gasta nem
## constrói) — serve tanto para `add_room` quanto para pré-visualização de
## construção (ex.: destacar a célula sob o cursor do jogador).
func can_place_room(definition_id: String, position: Vector2i, size: Vector2i) -> bool:
	var definition: RoomDefinition = room_definitions.get(definition_id)
	if definition == null:
		return false
	if size.x < definition.min_size.x or size.y < definition.min_size.y:
		return false
	if not _is_within_grid(position, size):
		return false
	if _overlaps_existing_room(position, size):
		return false
	return economy.can_afford(definition.cost)

func _is_within_grid(position: Vector2i, size: Vector2i) -> bool:
	return position.x >= 0 and position.y >= 0 and position.x + size.x <= grid_size.x and position.y + size.y <= grid_size.y

func _overlaps_existing_room(position: Vector2i, size: Vector2i) -> bool:
	for room in placed_rooms.values():
		if _rects_overlap(position, size, room.position, room.size):
			return true
	return false

func _rects_overlap(pos_a: Vector2i, size_a: Vector2i, pos_b: Vector2i, size_b: Vector2i) -> bool:
	return pos_a.x < pos_b.x + size_b.x and pos_a.x + size_a.x > pos_b.x and pos_a.y < pos_b.y + size_b.y and pos_a.y + size_a.y > pos_b.y

## Constrói uma sala do tipo `definition_id` na posição/tamanho dados.
## Retorna null se `can_place_room` rejeitar a construção (ver acima). O
## custo é debitado imediatamente ao construir.
func add_room(definition_id: String, position: Vector2i, size: Vector2i) -> Room:
	var definition: RoomDefinition = room_definitions.get(definition_id)
	if definition == null:
		push_error("Tipo de sala desconhecido: %s" % definition_id)
		return null
	if not can_place_room(definition_id, position, size):
		return null
	economy.spend(definition.cost)
	var room_id := "room_%d" % _next_room_id
	_next_room_id += 1
	var room := Room.new(room_id, definition_id, position, size)
	placed_rooms[room_id] = room
	return room

## Contrata um membro de equipe do cargo `role_id`. O custo é apenas o
## salário contínuo (ainda não debitado por tick — ver TODO na seção 7 de
## docs/ESCOPO.md).
func hire_staff(role_id: String) -> StaffMember:
	var staff := StaffMember.new(_next_staff_id, role_id)
	_next_staff_id += 1
	staff_members[staff.staff_id] = staff
	return staff

## Aloca um membro de equipe a uma sala construída. Falha (retorna false) se
## o cargo do membro não corresponder ao exigido pela sala.
func assign_staff_to_room(staff_id: int, room_id: String) -> bool:
	var staff: StaffMember = staff_members.get(staff_id)
	var room: Room = placed_rooms.get(room_id)
	if staff == null or room == null:
		return false
	var definition: RoomDefinition = room_definitions.get(room.definition_id)
	if definition and definition.required_staff_role != "" and definition.required_staff_role != staff.role_id:
		return false
	room.assigned_staff_id = staff_id
	staff.assigned_room_id = room_id
	return true

func spawn_patient(disease_id: String) -> Patient:
	var patient := Patient.new(_next_patient_id, disease_id)
	_next_patient_id += 1
	patients[patient.patient_id] = patient
	return patient

## Avança a simulação em um passo discreto: libera salas cujo atendimento
## terminou, tenta alocar pacientes em espera a salas livres e aplica o
## risco de ficar sem tratamento aos pacientes ainda em espera.
func tick() -> void:
	_resolve_finished_services()
	_assign_waiting_patients()
	_apply_untreated_risk()

func _resolve_finished_services() -> void:
	for room in placed_rooms.values():
		if not room.is_occupied():
			continue
		var patient: Patient = patients.get(room.occupant_patient_id)
		if patient == null:
			room.occupant_patient_id = -1
			continue
		if patient.stage == Patient.Stage.DIAGNOSIS:
			room.occupant_patient_id = -1
			patient.stage = Patient.Stage.AWAITING_TREATMENT
		elif patient.stage == Patient.Stage.TREATMENT:
			room.occupant_patient_id = -1
			_resolve_treatment(patient, room)

func _assign_waiting_patients() -> void:
	for patient in patients.values():
		if patient.stage == Patient.Stage.QUEUED:
			_try_assign_room(patient, _find_free_room_for(patient, "diagnosis"))
		elif patient.stage == Patient.Stage.AWAITING_TREATMENT:
			_try_assign_room(patient, _find_free_room_for(patient, "treatment"))

func _apply_untreated_risk() -> void:
	for patient in patients.values():
		if patient.stage != Patient.Stage.QUEUED and patient.stage != Patient.Stage.AWAITING_TREATMENT:
			continue
		var disease: Disease = diseases.get(patient.disease_id)
		if disease == null:
			continue
		patient.health -= disease.untreated_risk_per_tick
		if patient.health <= 0.0:
			patient.health = 0.0
			patient.stage = Patient.Stage.DECEASED
			economy.adjust_reputation(-0.05)

func _find_free_room_for(patient: Patient, phase: String) -> Room:
	var disease: Disease = diseases.get(patient.disease_id)
	if disease == null:
		return null
	var candidate_ids: Array = disease.diagnosis_room_ids if phase == "diagnosis" else [disease.treatment_room_id]
	for room in placed_rooms.values():
		if candidate_ids.has(room.definition_id) and room.is_staffed() and not room.is_occupied():
			return room
	return null

func _try_assign_room(patient: Patient, room: Room) -> void:
	if room == null:
		return
	room.occupant_patient_id = patient.patient_id
	if patient.stage == Patient.Stage.QUEUED:
		patient.stage = Patient.Stage.DIAGNOSIS
	elif patient.stage == Patient.Stage.AWAITING_TREATMENT:
		patient.stage = Patient.Stage.TREATMENT

func _resolve_treatment(patient: Patient, room: Room) -> void:
	var disease: Disease = diseases.get(patient.disease_id)
	var staff: StaffMember = staff_members.get(room.assigned_staff_id)
	var role: StaffRole = staff_roles.get(staff.role_id) if staff else null
	var skill: float = role.base_skill if role else 0.5
	var cure_chance: float = clamp(disease.base_cure_chance * (0.5 + skill), 0.0, 1.0) if disease else 0.0

	if randf() < cure_chance:
		patient.stage = Patient.Stage.DISCHARGED
		economy.earn(200)
		economy.adjust_reputation(0.02)
		return

	# Tratamento não funcionou desta vez: perde saúde e tenta de novo, a
	# menos que isso seja fatal.
	patient.health -= 0.3
	if patient.health <= 0.0:
		patient.health = 0.0
		patient.stage = Patient.Stage.DECEASED
		economy.adjust_reputation(-0.05)
	else:
		patient.stage = Patient.Stage.QUEUED
