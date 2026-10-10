# Contribuindo

Obrigado por querer contribuir com o Hospital Manager! Antes de tudo, leia
[`docs/ESCOPO.md`](docs/ESCOPO.md) — especialmente a seção 3 (legal/IP): este
projeto **não pode** conter nomes, arte, áudio ou dados extraídos do jogo
"Theme Hospital" (Bullfrog/EA) ou de qualquer outro jogo comercial. Tudo aqui
é original ou licenciado livremente.

## Abrindo o projeto

1. Instale o [Godot Engine 4.3+](https://godotengine.org/download).
2. Abra o editor e importe a pasta `game/` (é um projeto Godot independente
   dentro do repositório).
3. A cena `res://src/presentation/main.tscn` é a cena principal atual — ao
   rodar, ela carrega o conteúdo data-driven e imprime um resumo no console
   (ainda não há mapa/HUD jogável; isso é trabalho em andamento da Fase 1).

## Estrutura do repositório

```
/docs                 documentação de design, técnica e legal
/game                 projeto Godot
  /src/simulation     lógica de jogo pura (sem dependência de nós de cena)
  /src/presentation   cenas, sprites, câmera
  /src/ui             HUD desktop e mobile
  /src/platform       save system, carregamento de conteúdo, abstrações de plataforma
  /content            doenças, salas e cargos definidos em JSON
  /assets             arte, áudio, fontes (ver LICENSE-ASSETS.md)
/tools                scripts de build e geração de conteúdo
/tests                testes automatizados
```

## Adicionando conteúdo (doenças, salas, cargos)

O conteúdo de jogo é **data-driven**: fica em `game/content/*.json`, não em
código. Para adicionar uma doença, sala ou cargo novo, edite o JSON
correspondente seguindo o esquema já usado pelos exemplos existentes — não é
necessário tocar em GDScript para isso. Dê nomes e descrições originais
(nada copiado do Theme Hospital ou de outro jogo).

## Estilo de código

- GDScript com **tipagem estática** sempre que possível (`var x: int`,
  `func foo() -> void:`).
- Lógica de simulação (`game/src/simulation/`) não deve depender de `Node`
  nem de cenas — isso mantém a lógica testável isoladamente.
- Prefira nomes em inglês para identificadores de código; textos visíveis ao
  jogador (display names) podem estar em português.

## Licenças

- Código: MIT (`LICENSE`).
- Assets (arte, áudio, fontes): CC BY-SA 4.0 (`LICENSE-ASSETS.md`).

## Dúvidas / propostas de design

Abra uma issue descrevendo a ideia antes de implementar mudanças grandes de
mecânica ou arquitetura, para alinharmos com o roadmap em
[`docs/ESCOPO.md`](docs/ESCOPO.md).
