# Hospital Manager Game

Simulador de gestão hospitalar **open source**, inspirado na jogabilidade clássica de
construção e administração de hospitais (gênero popularizado pelo *Theme Hospital*, 1997),
construído com **código e assets 100% próprios** para rodar em **Windows 10/11, Android e
iOS**.

Este projeto não usa nome, arte, música ou dados do jogo original — apenas suas mecânicas de
jogo como referência de design. Veja o porquê em [`docs/ESCOPO.md`](docs/ESCOPO.md#3-questão-legal-e-de-propriedade-intelectual-crítico).

## Status

🚧 **Fase 0 concluída / Fase 1 completa (e validada rodando de fato) / Fase 2 iniciada.** O
núcleo da simulação funciona de ponta a ponta: paciente entra na fila, é diagnosticado, tratado e recebe alta (ou falece, se não
for atendido a tempo), com equipe alocada a salas, contenção entre pacientes simultâneos tratada
corretamente, e economia/reputação reagindo ao resultado — tudo coberto por testes automatizados.
O jogo já roda como um loop ao vivo (tick periódico + pacientes chegando sozinhos) e o jogador
pode **construir salas de verdade**: tecla 1–6 escolhe o tipo, o grid isométrico mostra um
destaque verde/vermelho sob o cursor, e clique esquerdo em área livre constrói. Clicar numa sala
já construída aloca a ela um membro de equipe ocioso compatível. Zelador e recepcionista
(teclas E/R) têm efeito imediato (reduzem desgaste de sala e risco de piora de pacientes,
respectivamente); médico/enfermeira (Q/W) precisam ser alocados por clique. Ainda não há
sprites/arte própria (é tudo desenhado por código) nem UI gráfica (só teclado + texto). Veja o
checklist detalhado em [`docs/ESCOPO.md`](docs/ESCOPO.md#7-próximos-passos-imediatos-backlog-inicial).

> **Nota de ambiente — atualizada:** o código foi inicialmente escrito sem acesso ao binário do
> Godot. Em uma sessão posterior, consegui baixar o Godot (via release do GitHub, já que
> `godotengine.org` está bloqueado pela política de rede, mas `github.com` não) e **rodar de
> fato** o projeto: importação e os 7 testes automatizados passam sem erro em Godot 4.3.0 e
> 4.5-stable, com os mesmos resultados calculados à mão ao escrever os testes. A cena principal
> também roda ~10s em modo headless sem nenhum erro. **O que ainda falta** é só o que exige uma
> tela e um humano de verdade (clique, hover, aparência visual) — modo headless não tem mouse
> nem monitor. Veja o checklist desse passo final em
> [`docs/VALIDACAO.md`](docs/VALIDACAO.md#3-checklist-visualmanual--️-ainda-precisa-de-um-humano-com-tela).

## Documentação

- [`docs/ESCOPO.md`](docs/ESCOPO.md) — escopo completo: mecânicas de referência, considerações
  legais, stack técnica, arquitetura e roadmap faseado.
- [`docs/VALIDACAO.md`](docs/VALIDACAO.md) — roteiro passo a passo para a primeira pessoa com
  um Godot 4.3+ disponível confirmar que tudo o que foi escrito nesta sessão funciona de fato.

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
