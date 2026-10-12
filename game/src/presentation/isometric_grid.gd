extends Node2D
class_name IsometricGrid

## Visualização isométrica mínima do hospital, desenhada por código
## (CanvasItem._draw) em vez de TileMap/TileSet — ainda não há nenhuma
## arte/sprite própria produzida para o projeto (ver LICENSE-ASSETS.md), e
## desenhar formas simples evita depender de imagens que não existem.
##
## Isto é um placeholder visual: mostra o grid e as salas construídas como
## losangos coloridos por categoria. Substituir por tiles/sprites reais é
## trabalho de uma fase futura, quando houver arte.

const TILE_WIDTH: float = 64.0
const TILE_HEIGHT: float = 32.0

const CATEGORY_COLORS := {
	"diagnosis": Color(0.3, 0.55, 0.9, 0.6),
	"treatment": Color(0.3, 0.75, 0.4, 0.6),
	"support": Color(0.6, 0.6, 0.6, 0.6),
}

var grid_size: Vector2i = Vector2i(16, 16)
var rooms: Array = [] # Array of Room
var room_definitions: Dictionary = {} # definition_id (String) -> RoomDefinition

var hover_cell: Vector2i = Vector2i.ZERO
var hover_size: Vector2i = Vector2i.ZERO
var hover_valid: bool = false

## Recebe o estado atual do hospital (salas construídas + catálogo de tipos
## de sala) e redesenha. Usa Array genérico (não Array[Room]) de propósito:
## HospitalSimulation.placed_rooms.values() retorna um Array comum, e
## atribuí-lo a um parâmetro Array[Room] falharia em tempo de execução.
func set_hospital_state(p_rooms: Array, p_room_definitions: Dictionary) -> void:
	rooms = p_rooms
	room_definitions = p_room_definitions
	queue_redraw()

func grid_to_screen(grid_pos: Vector2) -> Vector2:
	return Vector2(
		(grid_pos.x - grid_pos.y) * (TILE_WIDTH / 2.0),
		(grid_pos.x + grid_pos.y) * (TILE_HEIGHT / 2.0)
	)

## Inverso de grid_to_screen: converte uma posição em coordenadas de tela
## (mundo 2D local a este nó) para a célula do grid sob esse ponto. Usado
## para traduzir cliques/posição do mouse em coordenadas de construção.
func screen_to_grid(screen_pos: Vector2) -> Vector2i:
	var half_w := TILE_WIDTH / 2.0
	var half_h := TILE_HEIGHT / 2.0
	var grid_x := (screen_pos.x / half_w + screen_pos.y / half_h) / 2.0
	var grid_y := (screen_pos.y / half_h - screen_pos.x / half_w) / 2.0
	return Vector2i(int(floor(grid_x)), int(floor(grid_y)))

## Atualiza o destaque visual da célula sob o cursor (verde se a construção
## ali seria válida, vermelho caso contrário). `size` igual a Vector2i.ZERO
## esconde o destaque.
func set_hover(cell: Vector2i, size: Vector2i, valid: bool) -> void:
	hover_cell = cell
	hover_size = size
	hover_valid = valid
	queue_redraw()

func _draw() -> void:
	_draw_grid_lines()
	_draw_rooms()
	_draw_hover()

func _draw_grid_lines() -> void:
	var grid_color := Color(1.0, 1.0, 1.0, 0.15)
	for x in range(grid_size.x + 1):
		draw_line(grid_to_screen(Vector2(x, 0)), grid_to_screen(Vector2(x, grid_size.y)), grid_color)
	for y in range(grid_size.y + 1):
		draw_line(grid_to_screen(Vector2(0, y)), grid_to_screen(Vector2(grid_size.x, y)), grid_color)

func _draw_rooms() -> void:
	for room in rooms:
		var definition: RoomDefinition = room_definitions.get(room.definition_id)
		var color: Color = CATEGORY_COLORS.get(definition.category, Color.WHITE) if definition else Color.WHITE
		var top_left := Vector2(room.position)
		var top_right := top_left + Vector2(room.size.x, 0)
		var bottom_right := top_left + Vector2(room.size.x, room.size.y)
		var bottom_left := top_left + Vector2(0, room.size.y)
		var points := PackedVector2Array([
			grid_to_screen(top_left),
			grid_to_screen(top_right),
			grid_to_screen(bottom_right),
			grid_to_screen(bottom_left),
		])
		draw_colored_polygon(points, color)

func _draw_hover() -> void:
	if hover_size == Vector2i.ZERO:
		return
	var color := Color(0.3, 0.9, 0.3, 0.4) if hover_valid else Color(0.9, 0.3, 0.3, 0.4)
	var top_left := Vector2(hover_cell)
	var top_right := top_left + Vector2(hover_size.x, 0)
	var bottom_right := top_left + Vector2(hover_size.x, hover_size.y)
	var bottom_left := top_left + Vector2(0, hover_size.y)
	var points := PackedVector2Array([
		grid_to_screen(top_left),
		grid_to_screen(top_right),
		grid_to_screen(bottom_right),
		grid_to_screen(bottom_left),
	])
	draw_colored_polygon(points, color)
