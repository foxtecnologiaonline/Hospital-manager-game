# Hospital Manager Game

Simulador de gestão hospitalar **open source**, inspirado na jogabilidade clássica de
construção e administração de hospitais (gênero popularizado pelo *Theme Hospital*, 1997),
construído com **código e assets 100% próprios** para rodar em **Windows 10/11, Android e
iOS**.

Este projeto não usa nome, arte, música ou dados do jogo original — apenas suas mecânicas de
jogo como referência de design. Veja o porquê em [`docs/ESCOPO.md`](docs/ESCOPO.md#3-questão-legal-e-de-propriedade-intelectual-crítico).

## Status

🚧 Em fase de planejamento. Ainda não há código do jogo neste repositório — o primeiro passo é
a Fase 0 (Fundação) descrita no roadmap abaixo.

## Documentação

- [`docs/ESCOPO.md`](docs/ESCOPO.md) — escopo completo: mecânicas de referência, considerações
  legais, stack técnica, arquitetura e roadmap faseado.

## Stack planejada

- **Motor:** [Godot 4.x](https://godotengine.org/) (open source, exporta para Windows, Android
  e iOS a partir de uma única base de código).
- **Linguagem:** GDScript para gameplay, com possibilidade de C#/GDExtension para sistemas de
  performance crítica.

## Roadmap resumido

0. Fundação (setup do projeto, CI, licenças) → 1. MVP do loop central → 2. Expansão de
   conteúdo → 3. Progressão e eventos especiais → 4. Polimento multiplataforma (mobile) →
   5. Lançamento open source.

Detalhes de cada fase em [`docs/ESCOPO.md`](docs/ESCOPO.md#5-roadmap-faseado).

## Contribuindo

O projeto ainda não tem um fluxo de contribuição formal — isso faz parte da Fase 0. Abra uma
issue para discutir ideias enquanto isso.
