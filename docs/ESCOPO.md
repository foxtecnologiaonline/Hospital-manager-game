# Escopo do Projeto — Simulador de Gestão Hospitalar Open Source

> Documento de referência de design, técnico e legal para reconstruirmos, em formato open
> source, um jogo de gestão hospitalar inspirado no clássico **Theme Hospital** (Bullfrog
> Productions / Electronic Arts, 1997), rodando em **Windows 10/11**, **Android** e **iOS**.

## 1. Visão geral

Theme Hospital é um simulador de gestão em que o jogador constrói e administra um hospital,
contrata equipe, diagnostica e trata pacientes com doenças cômicas/fictícias, e progride por
níveis com metas de reputação, lucro e número de curas. O loop de jogo é simples de entender e
profundo de dominar — por isso continua sendo referência de gênero quase 30 anos depois.

**Objetivo deste projeto:** não é "piratear" ou clonar literalmente o Theme Hospital, e sim
construir um jogo **com DNA de jogabilidade equivalente**, código e assets 100% próprios,
publicável livremente (inclusive nas lojas móveis) e aberto à comunidade.

## 2. Pesquisa: mecânicas de referência extraídas do Theme Hospital

Estas são as mecânicas centrais que precisamos reproduzir (com nomes e conteúdo próprios) para
entregar a mesma sensação de jogo:

### 2.1 Loop central
1. Jogador recebe um mapa/edifício vazio e um orçamento inicial.
2. Constrói salas (define tamanho, portas, janelas, compra equipamentos/móveis).
3. Contrata equipe e a alinha às salas certas.
4. Pacientes chegam, passam pela recepção, são encaminhados a diagnóstico e depois a
   tratamento.
5. Jogador monitora saúde/felicidade dos pacientes, finanças, reputação do hospital e reinveste
   lucro em expansão, pesquisa e marketing.
6. Nível é vencido ao atingir metas (ex.: reputação mínima, nº de curas, valor do hospital,
   caixa mínimo) antes de certos limites (mortes máximas, tempo).

### 2.2 Salas
- **Diagnóstico** (várias salas diferentes, cada uma aumenta a chance de identificar a doença
  certa; nem todo paciente precisa passar por todas).
- **Tratamento/Cura** (uma sala por "família" de doença/mecânica de cura: injeção, cirurgia,
  inalação, maca vibratória, etc. — na nossa versão, batizaremos com nomes próprios).
- **Suporte**: sala de descanso da equipe, banheiro, departamento de pesquisa, sala de
  treinamento, central de arquivos/administração.
- Cada sala exige: tamanho mínimo, móveis/equipamentos específicos (comprados e alocados),
  e **membro de equipe qualificado** para operar.

### 2.3 Equipe
- **Médico** — com especializações/níveis (clínico geral → cirurgião → consultor) e habilidades
  (ex.: pesquisa, psiquiatria, cirurgia). Habilidade afeta velocidade e taxa de sucesso.
- **Enfermeira** — atende enfermarias, farmácia e triagem de fraturas.
- **Zelador** (handyman) — manutenção de máquinas, limpeza, jardinagem, controle de poças de
  água/sujeira que afetam felicidade.
- **Recepcionista** — direciona o fluxo de pacientes na entrada.
- Atributos de equipe: salário, cansaço, felicidade, habilidade — tudo isso afeta desempenho e
  precisa ser gerenciado (contratação, treinamento, descanso, aumento de salário).

### 2.4 Pacientes e doenças
- Cada paciente tem: doença (visível apenas após diagnóstico), nível de saúde, felicidade,
  paciência (fila), e eventualmente dinheiro/seguro que paga pelo atendimento.
- Doenças têm causa cômica, sala(s) de diagnóstico possíveis, sala de cura, taxa de sucesso, e
  risco de óbito se não tratada a tempo.
- **Epidemias**: uma doença contagiosa se propaga: o jogador decide entre vaciná-la
  discretamente (ganha bônus) ou arriscar ser descoberto por um fiscal de saúde (penalidade
  severa de reputação).
- **Emergências**: ônibus/grupo de pacientes graves chega de repente e precisa de tratamento
  rápido para bônus de reputação/dinheiro.

### 2.5 Progressão e metas
- Dinheiro, reputação do hospital, valor patrimonial, nº de pacientes curados/mortos.
- Pesquisa (desbloqueia máquinas melhores, novas curas, itens de decoração).
- Marketing (publicidade, atrai mais pacientes de tipos específicos).
- Visita de VIPs e do **inspetor de saúde** (avaliação que pode gerar prêmios ou multas).
- Eventos aleatórios: terremotos, incêndios, problemas elétricos.
- Estrutura em **níveis/campanha** com dificuldade crescente (mapas maiores, metas mais duras,
  doenças novas).

### 2.6 Interface e apresentação
- Visão **isométrica 2D** (câmera fixa, sem rotação livre na versão original).
- HUD com: caixa, reputação, nível de dificuldade/status geral, menu de construção de salas,
  lista de equipe, mapa da cidade/nível.
- Tom de humor leve (doenças absurdas, animações caricatas) — importante para a identidade do
  gênero, mas construiremos nosso próprio humor/arte para não violar direitos autorais.

## 3. Questão legal e de propriedade intelectual (crítico)

**Theme Hospital é propriedade da Electronic Arts** (via Bullfrog Productions). Isso inclui:
nome, logotipo, arte original, músicas, efeitos sonoros, nomes de doenças/salas exatamente como
usados no jogo, e os arquivos de dados do jogo original.

### 3.1 O precedente: CorsixTH
O projeto **[CorsixTH](https://github.com/CorsixTH/CorsixTH)** é um motor open source (licença
GPL‑2.0, C++ e Lua) que **reimplementa apenas o motor/engine** do Theme Hospital. Ele **não
distribui nenhum asset da EA** — exige que o próprio jogador possua uma cópia original do jogo
(DOS, GOG, Origin ou a demo) para fornecer gráficos, sons e dados de nível. É multiplataforma
(Windows, macOS, Linux, BSD) mas **não está nas lojas móveis** (Google Play / App Store) —
justamente porque esse modelo de "engine vazio + dados de terceiros" não é aceito pelas lojas e
teria risco de notificação de remoção por parte da EA.

### 3.2 Recomendação para este projeto
Como o objetivo aqui é publicar também em **Android e iOS** (lojas com curadoria e políticas de
IP estritas), o modelo do CorsixTH **não é viável como está**. A rota segura e sustentável,
usada com sucesso por sucessores espirituais como *Two Point Hospital* e *Project Hospital*
(ambos criados sem usar assets da EA, só a "ideia de gênero"), é:

1. **IP 100% original**: novo nome de jogo, novo logotipo, novos nomes de doenças, salas,
   equipe e falas — inspirados no tom de humor do gênero, mas sem copiar texto/nomes literais.
2. **Assets 100% próprios**: arte, sprites, música e efeitos sonoros produzidos do zero (ou sob
   licenças livres/compradas com direito de uso comercial), nunca extraídos do jogo original.
3. **Código 100% nosso**: podemos estudar a arquitetura do CorsixTH como referência de
   *engenharia* (como ele é um GitHub público, dá para ler a estrutura, não o código-arte), mas
   não copiar seu código fonte a menos que adotemos GPL‑2.0 compatível e cumpramos a licença —
   o que nem é necessário, já que vamos escrever do zero.
4. Usar o Theme Hospital apenas como **referência de design/jogabilidade** (o que é legítimo e
   comum na indústria — mecânicas de jogo, de forma geral, não são protegidas por direitos de
   autor, só a expressão específica: arte, nomes, texto, música).

**Nome de trabalho sugerido:** `Hospital Manager` (já é o nome do repositório) — manter um nome
genérico e descritivo evita qualquer semelhança com marcas registradas.

## 4. Stack tecnológica recomendada

### 4.1 Motor de jogo: **Godot 4.x**
- Open source (MIT), alinhado ao espírito "open" do projeto.
- Exporta nativamente para **Windows, Android e iOS** a partir de uma única base de código.
- Suporte maduro a 2D isométrico (TileMap com modo isométrico, Y-sort automático de camadas).
- GDScript para lógica de gameplay (produtividade) com opção de módulos em C# ou GDExtension
  (C++/Rust) para sistemas de performance crítica (ex.: pathfinding de muitos pacientes
  simultâneos).
- Comunidade grande, ciclo de releases ativo, bom tooling de UI responsiva (essencial para
  adaptar HUD a telas de celular).

**Alternativas avaliadas e por que não foram escolhidas como primeira opção:**
- *Unity*: tooling mobile muito maduro, mas modelo de licenciamento comercial e runtime fee
  recente geram incerteza para um projeto open source; motor não é open source.
- *Flutter/Flame*: bom para jogos 2D simples, mas ecossistema de simulação/pathfinding/IA de
  agentes (centenas de pacientes e equipe) é muito menos maduro que engines de jogo dedicadas.
- *MonoGame/C# puro*: controle total, mas exige construir manualmente exportação
  iOS/Android, UI responsiva e tooling de editor — custo de engenharia muito maior para a
  equipe.

### 4.2 Arquitetura de software (alto nível)
Seguindo o aprendizado do próprio CorsixTH (que separa **motor genérico** de **conteúdo
orientado a dados**), estruturar em camadas:

1. **Camada de simulação** (determinística, independente de renderização): entidades de
   paciente, equipe, sala, economia, fila de eventos. Testável isoladamente (unit tests).
2. **Camada de conteúdo "data-driven"**: doenças, salas, itens, falas e níveis definidos em
   arquivos de recurso (`.tres`/JSON), não hardcoded — permite adicionar conteúdo sem recompilar
   e facilita contribuições da comunidade.
3. **Camada de apresentação**: cenas Godot (sprites, animações, câmera isométrica, efeitos).
4. **Camada de UI**: HUD adaptativo com dois layouts (desktop com mouse/teclado; mobile com
   toque, botões maiores, gestos de pan/zoom).
5. **Camada de plataforma**: save/load, input abstraction (mouse vs. touch), telemetria
   opcional, compras/anúncios (se aplicável) isolados em um módulo substituível.

### 4.3 Estrutura de repositório proposta
```
/docs                 documentação de design, técnica e de contribuição
/game                 projeto Godot (cenas, scripts, assets)
  /src
    /simulation       lógica de jogo pura (gdscript/C#), sem dependência de nós de cena
    /presentation     cenas, sprites, câmera, efeitos
    /ui               HUD desktop e mobile
    /platform         save system, input abstraction, plataformas
  /content            dados de doenças, salas, equipe, níveis (.tres/json)
  /assets             arte, áudio, fontes (originais ou licenciados)
  /tests              testes automatizados da camada de simulação (GDScript; rodam dentro
                       do projeto Godot via `godot --headless --script res://tests/...`)
/tools                scripts de build, geração de conteúdo, CI (fora do Godot)
```

## 5. Roadmap faseado

| Fase | Objetivo | Entregáveis principais |
|---|---|---|
| **0. Fundação** (1–2 semanas) | Preparar base técnica | Projeto Godot inicializado, licença definida (ex.: MIT para código, CC‑BY‑SA para assets), CI (lint + testes + build Windows/Android), estrutura de pastas, documento de design vivo |
| **1. MVP do loop central** | Provar o loop de jogo | 1 mapa pequeno, 3–4 salas, 3–4 doenças, equipe básica (médico, enfermeira, recepcionista), fila de pacientes, caixa e reputação simples, sem níveis ainda |
| **2. Expansão de conteúdo** | Profundidade de gameplay | Todas as categorias de sala, catálogo maior de doenças, zelador e manutenção, pesquisa, marketing, contratação/felicidade de equipe |
| **3. Progressão e eventos especiais** | Estrutura de campanha | Sistema de níveis/metas, epidemias, emergências, VIPs, inspetor de saúde, eventos aleatórios |
| **4. Polimento multiplataforma** | Qualidade mobile | UI touch dedicada, controles de câmera por gesto, performance em dispositivos de entrada, ajuste de UX para tela pequena, testes em dispositivos reais Android/iOS |
| **5. Lançamento open source** | Publicação | Builds assinados Windows (instalador + portátil), publicação Android (APK/AAB, Google Play), publicação iOS (TestFlight → App Store), guia de contribuição, changelog, site/documentação pública |

## 6. Riscos e mitigação

| Risco | Mitigação |
|---|---|
| Confusão de marca com Theme Hospital/EA | Nome, arte, texto e áudio 100% originais; disclaimers claros de "inspirado por", nunca "baseado em assets de" |
| Complexidade de IA de agentes (muitos pacientes/equipe simultâneos) | Começar com pathfinding simples em grid, otimizar incrementalmente, usar GDExtension/C# só onde perfilamento mostrar necessidade |
| UX desktop não funciona em touch | Definir cedo dois fluxos de UI (desktop/mobile) compartilhando a mesma lógica de simulação |
| Custo de produção de arte/áudio originais | Priorizar estilo visual simples e consistente (pixel art ou vetor flat) que seja rápido de produzir e ainda assim identificável |
| Escopo "explode" tentando copiar 100% do jogo original | MVP enxuto na Fase 1; novo conteúdo só entra via arquivos de dados, não via código novo |

## 7. Próximos passos imediatos (backlog inicial)

1. ✅ Decidir e documentar licença de código e de assets (`LICENSE` — MIT,
   `LICENSE-ASSETS.md` — CC BY-SA 4.0).
2. ✅ Inicializar projeto Godot 4 com a estrutura de pastas da seção 4.3 e um workflow de CI
   básico (`.github/workflows/ci.yml`).
   ⚠️ **Pendente de validação real:** os arquivos foram escritos manualmente nesta sessão (sem
   Godot instalado/acessível no container); precisam ser abertos no editor Godot 4.3+ para
   confirmar que importam e rodam sem erro, e o CI precisa de uma primeira execução real no
   GitHub Actions.
3. ✅ Câmera isométrica + grid visual das salas construídas, agora **interativo**
   (Fase 2): `isometric_grid.gd` desenha o grid e as salas por código (`CanvasItem._draw`,
   losangos coloridos por categoria), sem depender de TileSet/sprites (não há arte própria
   produzida ainda — ver `LICENSE-ASSETS.md`). `main.gd` agora roda um loop de jogo real
   (`_process` com tick periódico da simulação + geração periódica de pacientes) e permite
   construir salas: teclas 1–6 selecionam o tipo (ordem de `rooms.json`), o grid mostra um
   destaque verde/vermelho sob o cursor (`IsometricGrid.screen_to_grid` +
   `HospitalSimulation.can_place_room`) e clique esquerdo constrói de fato.
   **O que ainda falta aqui:** não há UI gráfica (botões/ícones, só teclado + texto no HUD),
   não há como contratar equipe pela interface (só os 2 iniciais, via código), e não há
   movimento visual de pacientes/equipe pelo mapa.
4. ✅ Entidade de Paciente com máquina de estados completa (fila → diagnóstico → tratamento →
   alta/óbito) — implementada em `game/src/simulation/patient.gd` (enum `Stage`) e na lógica de
   transição em `HospitalSimulation.tick()`.
5. ✅ Entidade de Equipe (`game/src/simulation/staff_member.gd`) e de Sala construída
   (`game/src/simulation/room.gd`), com alocação sala↔equipe que valida o cargo exigido
   (`HospitalSimulation.assign_staff_to_room`).
6. ✅ Loop validado com seis cenários automatizados em `game/tests/run_tests.gd`: ciclo
   completo de 1 paciente, rejeição de cargo incompatível na alocação de equipe, contenção
   de 2 pacientes simultâneos por salas únicas (garante que nenhuma sala é ocupada por dois
   pacientes ao mesmo tempo), validação de posicionamento de sala (rejeita sobreposição e
   posição fora do grid, aceita posição válida — base da construção interativa do item 3),
   zelador reduzindo o desgaste acumulado de uma sala, e recepcionista reduzindo à metade o
   risco de piora de pacientes não atendidos. Também validado manualmente em
   `game/src/presentation/main.gd`.
   ⚠️ **Pendente de execução real:** os testes foram escritos e revisados manualmente nesta
   sessão (sem o binário do Godot disponível no container para rodá-los); precisam ser
   executados com `godot --headless --path game --script res://tests/run_tests.gd` na primeira
   oportunidade, e o resultado real confirmado (o CI em `.github/workflows/ci.yml` já roda esse
   comando a cada push). Isso inclui, agora, a parte de input (seleção de sala, clique para
   construir) que não tem como ser exercitada por um teste headless — só abrindo o jogo mesmo.

**Fase 1 está completa** (loop fila → diagnóstico → tratamento → alta/óbito + visual
interativo básico). **Fase 2 já começou** com a construção interativa de salas; o que falta
dela está listado abaixo.

**Simplificações conhecidas do modelo de simulação atual** (documentadas para não serem
confundidas com bugs): cada etapa de diagnóstico/tratamento dura exatamente 1 tick (sem duração
variável), não há ainda posição/movimento real de pacientes e equipe no mapa (pathfinding),
salário de equipe não é debitado por tick, e não há sistema de níveis/metas. Esses pontos
pertencem à Fase 1 (continuação) e à Fase 2.

7. ✅ Zelador e recepcionista ganharam função real: zelador reduz o desgaste acumulado das
   salas (sem manutenção, desgaste reduz a chance de cura em tratamentos — ver
   `HospitalSimulation._room_wear_multiplier`); recepcionista reduz à metade o risco de piora
   de pacientes não atendidos (`_apply_untreated_risk`). Ambos são efeitos globais (basta
   contratar — não precisam de uma sala própria neste modelo simplificado) e já contratáveis
   no protótipo pelas teclas E/R.
8. ✅ Alocação de médico/enfermeira pela interface: clicar numa sala já construída (em vez de
   área livre) aloca a ela um membro de equipe ocioso e compatível, via
   `HospitalSimulation.find_room_at` + `find_idle_staff` (cobertos por teste automatizado) e
   `main.gd._try_assign_staff_to_room`. Agora toda equipe contratada pelas teclas Q/W/E/R é
   de fato utilizável sem editar código.

**Próximo passo recomendado (Fase 2 — restante):**
- UI gráfica mínima (botões/ícones) para contratar equipe e selecionar o tipo de sala — hoje é
  só teclado (1–6, Q/W/E/R) e HUD de texto.
- Pesquisa, marketing e felicidade de equipe afetando desempenho.
- Validar com um Godot real tudo o que foi construído até aqui — ver `docs/VALIDACAO.md`, o
  roteiro passo a passo para essa validação (prioridade acima de qualquer item novo; a
  superfície de código não verificada só cresceu a cada incremento).

## 8. Referências consultadas

- [Theme Hospital — Wikipedia](https://en.wikipedia.org/wiki/Theme_Hospital)
- [Theme Hospital — GiantBomb](https://www.giantbomb.com/games/3030-12188/)
- [Theme Hospital/Staff — StrategyWiki](https://strategywiki.org/wiki/Theme_Hospital/Staff)
- [CorsixTH — repositório oficial](https://github.com/CorsixTH/CorsixTH)
- [CorsixTH — Wiki "Lua And C" (arquitetura)](https://github.com/CorsixTH/CorsixTH/wiki/Lua-And-C)
- [Godot Engine — documentação e asset de demo isométrico oficial](https://godotengine.org)
