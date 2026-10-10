extends Node2D

## Cena de bootstrap da Fase 0: carrega o conteúdo data-driven e executa um
## tick de demonstração no console. Ainda não há renderização de mapa/HUD —
## isso é trabalho da Fase 1 (docs/ESCOPO.md).

func _ready() -> void:
	var content := ContentLoader.load_all()
	var simulation := HospitalSimulation.new(content)
	simulation.start_demo_tick()
