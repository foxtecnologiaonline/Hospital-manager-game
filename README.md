# Hospital Manager Game

Simulador de gestão hospitalar **open source**, inspirado na jogabilidade clássica de
construção e administração de hospitais (gênero popularizado pelo *Theme Hospital*, 1997),
construído com **código e assets 100% próprios** para rodar em **Windows 10/11, Android e
iOS**.

Este projeto não usa nome, arte, música ou dados do jogo original — apenas suas mecânicas de
jogo como referência de design. Veja o porquê em [`docs/ESCOPO.md`](docs/ESCOPO.md#3-questão-legal-e-de-propriedade-intelectual-crítico).

## Status

🚧 **Fase 0 concluída / Fase 1 (MVP do loop central) em andamento.** O núcleo da simulação já
funciona de ponta a ponta em texto (sem gráficos ainda): paciente entra na fila, é diagnosticado,
tratado e recebe alta (ou falece, se não for atendido a tempo), com equipe alocada a salas e
economia/reputação reagindo ao resultado. Falta a camada visual (câmera isométrica + grid de
construção de salas) para o jogo deixar de ser só um log de console. Veja o checklist detalhado em
[`docs/ESCOPO.md`](docs/ESCOPO.md#7-próximos-passos-imediatos-backlog-inicial).

> **Nota de ambiente:** os arquivos do projeto Godot (incluindo a lógica de simulação e os
> testes automatizados) foram escritos manualmente nesta sessão porque o container de execução
> não tem o binário do Godot instalado nem acesso de rede para baixá-lo. Eles seguem o formato
> de texto padrão do Godot 4 e a sintaxe do GDScript 4, mas **ainda não foram executados em um
> Godot real**. O primeiro passo de quem continuar o trabalho com acesso ao Godot deve ser
> rodar `godot --headless --path game --script res://tests/run_tests.gd` e abrir o projeto no
> editor para confirmar que tudo importa e roda sem erro.

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
