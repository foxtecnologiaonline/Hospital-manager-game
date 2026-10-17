extends Node2D

## Cena principal da Fase 2 (construção interativa): mantém uma simulação
## viva (tick periódico + geração periódica de pacientes) e permite ao
## jogador construir novas salas clicando no grid isométrico.
##
## Controles temporários (sem HUD gráfico de botões ainda — ver backlog em
## docs/ESCOPO.md): teclas 1–6 selecionam o tipo de sala a construir
## (na ordem definida em game/content/rooms.json); clique esquerdo em área
## livre constrói a sala selecionada, se a posição for válida. Clique
## esquerdo numa sala já construída, em vez disso, aloca a ela um membro de
## equipe ocioso e compatível (se houver). Teclas Q/W/E/R contratam
## médico/enfermeira/zelador/recepcionista — zelador e recepcionista têm
## efeito imediato (são cargos "globais" neste modelo simplificado), já
## médico/enfermeira só ajudam depois de alocados a uma sala (pelo clique).

const TICK_INTERVAL: float = 1.0
const PATIENT_SPAWN_INTERVAL: float = 4.0

var simulation: HospitalSimulation
var room_definition_order: Array = []
var selected_room_definition_id: String = ""
var status_message: String = ""

var _tick_accumulator: float = 0.0
var _patient_spawn_accumulator: float = 0.0

@onready var grid: IsometricGrid = $IsometricGrid
@onready var status_label: Label = $HUD/StatusLabel

func _ready() -> void:
	var content := ContentLoader.load_all()
	simulation = HospitalSimulation.new(content)
	room_definition_order = simulation.room_definitions.keys()
	if not room_definition_order.is_empty():
		selected_room_definition_id = room_definition_order[0]

	# Hospital inicial mínimo, para já haver algo funcionando ao abrir a
	# cena: 2 salas + 2 membros de equipe, suficientes para tratar a doença
	# "static_hair". Novas salas (e o restante do catálogo) ficam a cargo do
	# jogador construir — ainda não há UI de contratação, então salas novas
	# só terão efeito quando houver equipe compatível já contratada aqui.
	var diagnosis_room := simulation.add_room("general_checkup", Vector2i(0, 0), Vector2i(4, 4))
	var treatment_room := simulation.add_room("static_discharge_room", Vector2i(5, 0), Vector2i(4, 4))
	if diagnosis_room == null or treatment_room == null:
		push_error("Não foi possível construir as salas iniciais (conteúdo ausente ou caixa insuficiente).")
		return

	var doctor := simulation.hire_staff("doctor")
	var nurse := simulation.hire_staff("nurse")
	simulation.assign_staff_to_room(doctor.staff_id, diagnosis_room.room_id)
	simulation.assign_staff_to_room(nurse.staff_id, treatment_room.room_id)

	simulation.spawn_patient("static_hair")

	_refresh_grid()
	_update_hud()

func _process(delta: float) -> void:
	if simulation == null:
		return

	_tick_accumulator += delta
	while _tick_accumulator >= TICK_INTERVAL:
		_tick_accumulator -= TICK_INTERVAL
		simulation.tick()
		_refresh_grid()

	_patient_spawn_accumulator += delta
	if _patient_spawn_accumulator >= PATIENT_SPAWN_INTERVAL:
		_patient_spawn_accumulator -= PATIENT_SPAWN_INTERVAL
		_spawn_random_patient()

	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if simulation == null:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		var index: int = event.keycode - KEY_1
		if index >= 0 and index < room_definition_order.size():
			selected_room_definition_id = room_definition_order[index]
			status_message = ""
			_update_hover()
		else:
			_handle_hire_shortcut(event.keycode)
	elif event is InputEventMouseMotion:
		_update_hover()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_try_build_at_mouse()

func _update_hover() -> void:
	var definition: RoomDefinition = simulation.room_definitions.get(selected_room_definition_id)
	if definition == null:
		grid.set_hover(Vector2i.ZERO, Vector2i.ZERO, false)
		return
	var cell := grid.screen_to_grid(get_global_mouse_position())
	var valid := simulation.can_place_room(selected_room_definition_id, cell, definition.min_size)
	grid.set_hover(cell, definition.min_size, valid)

func _try_build_at_mouse() -> void:
	var cell := grid.screen_to_grid(get_global_mouse_position())

	var existing_room := simulation.find_room_at(cell)
	if existing_room != null:
		_try_assign_staff_to_room(existing_room)
		return

	var definition: RoomDefinition = simulation.room_definitions.get(selected_room_definition_id)
	if definition == null:
		return
	var room := simulation.add_room(selected_room_definition_id, cell, definition.min_size)
	if room == null:
		status_message = "Não é possível construir '%s' em (%d, %d)." % [definition.display_name, cell.x, cell.y]
	else:
		status_message = "Construído: %s em (%d, %d)." % [definition.display_name, cell.x, cell.y]
	_refresh_grid()
	_update_hover()
	_update_hud()

## Clicar numa sala já construída (em vez de área livre) tenta alocar um
## membro de equipe ocioso e compatível a ela, em vez de tentar construir
## ali (o que falharia por sobreposição de qualquer forma).
func _try_assign_staff_to_room(room: Room) -> void:
	var definition: RoomDefinition = simulation.room_definitions.get(room.definition_id)
	var room_label: String = definition.display_name if definition else room.definition_id

	if room.is_staffed():
		status_message = "'%s' já tem equipe alocada." % room_label
		_update_hud()
		return

	var required_role: String = definition.required_staff_role if definition else ""
	if required_role == "":
		status_message = "'%s' não exige equipe." % room_label
		_update_hud()
		return

	var idle_staff := simulation.find_idle_staff(required_role)
	if idle_staff == null:
		var role: StaffRole = simulation.staff_roles.get(required_role)
		var role_label: String = role.display_name if role else required_role
		status_message = "Nenhum(a) %s disponível para alocar em '%s' (contrate com Q/W)." % [role_label, room_label]
		_update_hud()
		return

	simulation.assign_staff_to_room(idle_staff.staff_id, room.room_id)
	status_message = "Equipe alocada em '%s'." % room_label
	_refresh_grid()
	_update_hud()

func _handle_hire_shortcut(keycode: int) -> void:
	var role_id := ""
	match keycode:
		KEY_Q:
			role_id = "doctor"
		KEY_W:
			role_id = "nurse"
		KEY_E:
			role_id = "handyman"
		KEY_R:
			role_id = "receptionist"
		_:
			return
	var role: StaffRole = simulation.staff_roles.get(role_id)
	if role == null:
		return
	simulation.hire_staff(role_id)
	status_message = "Contratado: %s." % role.display_name
	_update_hud()

func _spawn_random_patient() -> void:
	var disease_ids := simulation.diseases.keys()
	if disease_ids.is_empty():
		return
	var disease_id: String = disease_ids[randi() % disease_ids.size()]
	simulation.spawn_patient(disease_id)

func _refresh_grid() -> void:
	grid.set_hospital_state(simulation.placed_rooms.values(), simulation.room_definitions)

func _count_active_patients() -> int:
	var count := 0
	for patient in simulation.patients.values():
		if patient.stage != Patient.Stage.DISCHARGED and patient.stage != Patient.Stage.DECEASED:
			count += 1
	return count

func _count_staff_with_role(role_id: String) -> int:
	var count := 0
	for staff in simulation.staff_members.values():
		if staff.role_id == role_id:
			count += 1
	return count

## Equipe com felicidade visivelmente reduzida (abaixo de 1.0 — ver
## HospitalSimulation._refresh_staff_happiness) por trabalho sustentado sem
## descanso. Só tem sentido olhar para quem está alocado a uma sala: equipe
## ociosa não acumula fadiga neste modelo.
func _count_tired_staff() -> int:
	var count := 0
	for staff in simulation.staff_members.values():
		if staff.happiness < 1.0:
			count += 1
	return count

func _update_hud() -> void:
	var definition: RoomDefinition = simulation.room_definitions.get(selected_room_definition_id)
	var lines := [
		"Hospital Manager — prototipo (Fase 2)",
		"Caixa: %d | Reputação: %.2f" % [simulation.economy.cash, simulation.economy.reputation],
		"Pacientes ativos: %d" % _count_active_patients(),
		"Equipe — zeladores: %d | recepcionistas: %d | cansados: %d" % [_count_staff_with_role("handyman"), _count_staff_with_role("receptionist"), _count_tired_staff()],
		"Sala selecionada [1-%d]: %s (custo %d)" % [room_definition_order.size(), definition.display_name if definition else "?", definition.cost if definition else 0],
		"Clique em área livre constrói; clique numa sala aloca equipe ociosa.",
		"Q/W/E/R contrata médico/enfermeira/zelador/recepcionista.",
	]
	if status_message != "":
		lines.append(status_message)
	status_label.text = "\n".join(lines)
