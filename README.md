# Hospital Manager Game

Simulador de gestão hospitalar **open source**, inspirado na jogabilidade clássica de
construção e administração de hospitais (gênero popularizado pelo *Theme Hospital*, 1997),
construído com **código e assets 100% próprios** para rodar em **Windows 10/11, Android e
iOS**.

Este projeto não usa nome, arte, música ou dados do jogo original — apenas suas mecânicas de
jogo como referência de design. Veja o porquê em [`docs/ESCOPO.md`](docs/ESCOPO.md#3-questão-legal-e-de-propriedade-intelectual-crítico).

## Status

🚧 **Fase 0 (Fundação) em andamento.** Estrutura inicial do projeto Godot, camada de simulação
data-driven, licenças e CI já estão no repositório (`game/`). Ainda não há mapa, HUD ou loop de
jogo jogável — isso é a Fase 1. Veja o checklist de progresso em
[`docs/ESCOPO.md`](docs/ESCOPO.md#7-próximos-passos-imediatos-backlog-inicial).

> **Nota de ambiente:** os arquivos do projeto Godot foram criados manualmente nesta sessão
> porque o container de execução não tem o binário do Godot instalado nem acesso de rede para
> baixá-lo. Eles seguem o formato de texto padrão do Godot 4, mas **ainda não foram abertos e
> validados no editor real** — isso deve ser o primeiro passo de quem continuar o trabalho com
> acesso ao Godot.

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
