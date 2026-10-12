# Guia de validação (primeira abertura num Godot real)

Todo o código em `game/` foi escrito e revisado manualmente em sessões sem acesso ao binário do
Godot nem à internet para baixá-lo. A lógica foi conferida com cuidado (inclusive traçando ticks
à mão para prever valores exatos nos testes), mas **nada disso foi de fato executado**. Este
guia é o roteiro para a primeira pessoa com um Godot 4.3+ disponível confirmar que tudo funciona
como descrito — e o que fazer se não funcionar.

## 1. Importar o projeto

```sh
godot --headless --path game --import
```

Deve terminar sem erros. Se der erro, o mais provável é um problema de sintaxe em algum `.gd` ou
de referência em `main.tscn`/`project.godot` — confira a mensagem de erro, ela deve apontar o
arquivo e a linha.

## 2. Rodar os testes automatizados

```sh
godot --headless --path game --script res://tests/run_tests.gd
```

Saída esperada: `OK — todos os testes passaram.` e código de saída 0. Hoje são 7 testes em
`game/tests/run_tests.gd`, cobrindo só a camada de simulação (`game/src/simulation/`) — nenhum
deles testa input/UI, porque isso não é possível de forma headless.

Se algum teste falhar, a mensagem `[FALHA] ...` identifica qual e o valor esperado vs. obtido —
isso aponta direto para o bug (ou para um erro de cálculo meu ao escrever o teste).

## 3. Abrir o projeto no editor e rodar a cena

Abra `game/project.godot` no editor e rode a cena principal (`F5` ou o botão de play).
Checklist do que deveria acontecer:

- [ ] A janela abre sem erros no console, mostrando um grid isométrico (losangos com linhas
      brancas translúcidas) e um HUD de texto no canto superior esquerdo.
- [ ] Duas salas já aparecem construídas (losango azul = diagnóstico, verde = tratamento).
- [ ] Um paciente é gerado automaticamente ao abrir, e mais um a cada ~4 segundos — o HUD deve
      mostrar o contador de "Pacientes ativos" mudando.
- [ ] Mover o mouse sobre o grid mostra um losango de destaque verde (posição válida) ou vermelho
      (inválida/sobrepõe outra sala) seguindo o cursor.
- [ ] Teclas `1` a `6` trocam o tipo de sala selecionado — o HUD deve atualizar o nome e custo.
- [ ] Clicar em área livre com destaque verde constrói a sala e debita o custo do caixa.
- [ ] Clicar em área livre com destaque vermelho não constrói nada (mensagem de erro no HUD).
- [ ] Teclas `Q`/`W`/`E`/`R` contratam médico/enfermeira/zelador/recepcionista (mensagem no HUD).
- [ ] Clicar numa sala já construída (em vez de área livre) aloca um membro de equipe ocioso
      compatível a ela, se houver (mensagem no HUD confirma ou explica por que não).
- [ ] Depois de várias curas na mesma sala de tratamento sem zelador, a chance de cura deveria
      cair perceptivelmente (mais pacientes voltando para a fila); contratar um zelador (`E`)
      deveria reverter isso em poucos segundos.

Nenhuma arte real existe ainda — tudo isso é formas geométricas desenhadas por código
(`game/src/presentation/isometric_grid.gd`). Isso é esperado, não é um bug.

## 4. Rodar o CI

`.github/workflows/ci.yml` já está configurado para rodar os passos 1 e 2 a cada push. Confirme
que ele passa no GitHub Actions na primeira oportunidade — ele nunca rodou de fato até agora.

## 5. Se algo estiver quebrado

- **Erro de importação/sintaxe:** corrija o arquivo apontado pela mensagem de erro; é
  provavelmente um deslize de digitação meu, não um problema de design.
- **Teste automatizado falhando:** compare o valor esperado vs. obtido na mensagem — ou a lógica
  tem um bug, ou minha conta manual (feita sem rodar nada) estava errada. Ambos são possíveis;
  corrija o que estiver errado e, se for a lógica, ajuste o teste também se o novo
  comportamento for o correto.
- **Cena abre mas nada aparece:** confira o console do editor por erros de `_draw()` ou de nó
  não encontrado (`$IsometricGrid`, `$HUD/StatusLabel`) — provavelmente um nome de nó
  divergente entre `main.tscn` e `main.gd`.
- **Input não responde:** confira se o projeto está capturando foco de teclado/mouse
  corretamente (comum em alguns ambientes de CI/headless, mas não deveria ocorrer no editor).

Depois de validar, atualize o checklist de `docs/ESCOPO.md` (seção 7) removendo os avisos de
"pendente de validação real" — eles existem precisamente para serem removidos quando este guia
for seguido com sucesso.
