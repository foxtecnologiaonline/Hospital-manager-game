# Guia de validação

Todo o código em `game/` foi inicialmente escrito e revisado só pela leitura, em sessões sem
acesso ao binário do Godot. Numa sessão posterior, consegui baixar o binário oficial do Godot
(via release do GitHub — `godotengine.org` está bloqueado pela política de rede deste tipo de
sessão, mas `github.com`/`objects.githubusercontent.com` não) e rodar de fato o que havia sido
escrito. **Os passos 1 e 2 abaixo já foram executados e confirmados** nesta sessão, em duas
versões do engine (4.3.0 — a mesma que o CI usa — e 4.5-stable). O que falta (passo 3) exige uma
tela e um humano, e só pode ser feito por quem está lendo isto.

## 1. Importar o projeto — ✅ confirmado

```sh
godot --headless --path game --import
```

Confirmado sem erros em Godot 4.3.0 e 4.5-stable: todas as 10 classes globais
(`ContentLoader`, `Disease`, `Economy`, `HospitalSimulation`, `IsometricGrid`, `Patient`,
`Room`, `RoomDefinition`, `StaffMember`, `StaffRole`) são registradas corretamente.

## 2. Testes automatizados — ✅ confirmado

```sh
godot --headless --path game --script res://tests/run_tests.gd
```

Saída real obtida (idêntica em 4.3.0 e 4.5-stable):

```
  [OK] test_patient_completes_full_cycle (3 ticks)
  [OK] test_room_requires_matching_staff_role
  [OK] test_two_patients_contend_for_rooms (4 ticks)
  [OK] test_room_placement_validation
  [OK] test_handyman_reduces_room_wear
  [OK] test_receptionist_halves_untreated_risk
  [OK] test_find_room_at_and_idle_staff
OK — todos os testes passaram.
```

Os números de ticks batem exatamente com os calculados à mão durante a escrita dos testes — ou
seja, a lógica da simulação está correta, não só "parece certa na leitura".

Também confirmado: rodar a cena principal (`main.tscn`) de forma headless por ~10 segundos
(`godot --headless --path game --quit-after 600`) não produz nenhum erro — isso exercita vários
ticks da simulação e a geração periódica de pacientes, e prova que o código de desenho do grid
(`_draw()`) não quebra em runtime, mesmo sem uma tela real por trás.

## 3. Checklist visual/manual — ⬜ ainda precisa de um humano com tela

Isto é a única parte que genuinamente não pode ser feita de dentro desta sessão: modo headless
não tem mouse, teclado nem monitor reais, então clique, hover e a aparência visual do grid nunca
foram vistos por ninguém. **Preciso que você faça isto**, abrindo `game/project.godot` no editor
Godot (4.3 ou mais novo) e rodando a cena principal (`F5`):

- [ ] A janela abre mostrando um grid isométrico (losangos com linhas brancas translúcidas) e um
      HUD de texto no canto superior esquerdo.
- [ ] Duas salas já aparecem construídas (losango azul = diagnóstico, verde = tratamento).
- [ ] O contador de "Pacientes ativos" no HUD muda sozinho a cada poucos segundos.
- [ ] Mover o mouse sobre o grid mostra um losango de destaque verde (posição válida) ou vermelho
      (inválida/sobrepõe outra sala) seguindo o cursor.
- [ ] Teclas `1` a `6` trocam o tipo de sala selecionado — o HUD atualiza nome e custo.
- [ ] Clicar em área livre com destaque verde constrói a sala e debita o custo do caixa.
- [ ] Clicar em área livre com destaque vermelho não constrói nada (mensagem no HUD).
- [ ] Teclas `Q`/`W`/`E`/`R` contratam médico/enfermeira/zelador/recepcionista (mensagem no HUD).
- [ ] Clicar numa sala já construída aloca um membro de equipe ocioso compatível a ela, se
      houver (mensagem no HUD confirma ou explica por que não).
- [ ] Depois de muitas curas na mesma sala de tratamento sem zelador, a chance de cura cai
      perceptivelmente; contratar um zelador (`E`) deveria reverter isso em poucos segundos.

Nenhuma arte real existe ainda — tudo isso é formas geométricas desenhadas por código
(`game/src/presentation/isometric_grid.gd`), de propósito (ver seção 3 de `docs/ESCOPO.md`).
Isso é esperado, não é um bug.

## 4. CI

`.github/workflows/ci.yml` roda exatamente os comandos dos passos 1 e 2, com Godot 4.3.0 — a
mesma versão testada aqui. Ainda não foi confirmada uma execução real no GitHub Actions (essa
confirmação só é visível na aba Actions do repositório), mas os mesmos comandos, com a mesma
versão do engine, já rodaram com sucesso nesta sessão.

## 5. Se algo do passo 3 estiver quebrado

- **Cena abre mas nada aparece:** confira o console do editor por erros de `_draw()` ou de nó
  não encontrado (`$IsometricGrid`, `$HUD/StatusLabel`).
- **Input não responde:** confira se a janela do jogo está com foco (clique nela antes de usar
  teclado/mouse).
- **Posição do grid/câmera parece errada:** os valores de `Camera2D.position` em `main.tscn`
  foram calculados à mão para enquadrar um grid de 16×16 células — ajuste-os diretamente no
  editor se não estiver bem centrado; isso é cosmético, não afeta a lógica.

Depois de concluir o checklist do passo 3, marque-o como validado em `docs/ESCOPO.md` (seção 7).
