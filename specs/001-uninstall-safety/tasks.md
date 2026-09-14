# Tasks: Desinstalacao Segura e Protecao de Backups

**Branch**: `001-uninstall-safety` | **Spec**: [spec.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/001-uninstall-safety/spec.md) | **Plan**: [plan.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/001-uninstall-safety/plan.md)

## Phase 1: Setup e Test Harness (TDD Red)

**Purpose**: Criar suite de testes automatizada para reproduzir e documentar as falhas antes de qualquer alteracao de codigo.

- [x] T001 Criar suite de testes em `tests/test_uninstall.sh` reproduzindo os cenarios de falha: delecao circular com symlink compartilhado, remocao de symlink quebrado e idempotencia.
- [x] T002 Conceder permissao de execucao (`chmod +x tests/test_uninstall.sh`) e executar o teste para confirmar falha no script atual (Red Gate).

---

## Phase 2: User Story 1 - Desinstalacao Segura em Unix/Bash (Priority: P1) 🎯 MVP

**Goal**: Eliminar o risco de delecao definitiva de backups no `uninstall.sh` quando `~/.agents/skills` compartilha alvos fisicos com `~/.claude/skills`.

- [x] T003 [US1] Implementar funcao de resolucao de caminho canonico e deteccao antecipada de symlinks com `[ -L "$target" ]` em `uninstall.sh`.
- [x] T004 [US1] Implementar rastreamento e deduplicacao de alvos fisicos processados em `uninstall.sh` para garantir que um caminho canonico ja restaurado nao seja deletado por symlinks subsequentes.
- [x] T005 [US1] Executar `tests/test_uninstall.sh` e verificar passagem verde (Green Gate) no cenario de symlinks compartilhados e backups preservados.

---

## Phase 3: User Story 2 - Remocao Segura no Windows/PowerShell (Priority: P1)

**Goal**: Garantir que o `uninstall.ps1` desvincule junctions e links simbolicos de diretorio sem executar `Remove-Item -Recurse` no diretorio do repositorio.

- [x] T006 [US2] Refatorar a funcao `Remove-And-Restore` em `uninstall.ps1` para remover junctions e symbolic links de diretorio via desvinculacao segura (`[System.IO.Directory]::Delete($Target)`), sem flag recursiva destrutiva.
- [x] T007 [US2] Implementar deduplicacao de alvos canonicos por `Resolve-Path` / `[System.IO.Path]::GetFullPath` em `uninstall.ps1` para prevenir delecao circular de backups no Windows.

---

## Phase 4: User Story 3 - Higienizacao de Estilo e Conformidade Global (Priority: P2)

**Goal**: Limpar todos os cabecalhos e mensagens de texto dos scripts de desinstalacao, garantindo zero caracteres de em dash (Unicode U+2014 ou hifens espacados).

- [x] T008 [US3] Substituir o caractere de travessao Unicode no cabecalho de `uninstall.sh` por parenteses ou dois-pontos.
- [x] T009 [US3] Substituir o caractere de travessao Unicode no cabecalho de `uninstall.ps1` por parenteses ou dois-pontos.
- [x] T010 [US3] Auditar estaticamente `uninstall.sh`, `uninstall.ps1` e `uninstall.cmd` confirmando zero ocorrencias de em dash.

---

## Phase 5: Verificacao Final e Gate de Integracao

**Purpose**: Verificacao completa de qualidade antes de finalizar o batch.

- [x] T011 Executar a suite completa `tests/test_uninstall.sh` em ambiente isolado e confirmar 100% de sucesso em todos os cenarios.
- [x] T012 Validar idempotencia executando o desinstalador consecutivamente sem efeitos colaterais.
- [x] T013 Atualizar status das tarefas em `tasks.md` e preparar o handoff de conclusao da branch.

---

## Dependencies & Execution Order

- **Phase 1 (Setup & Test Harness)**: Bloqueia implementacao das demais fases (TDD obrigatório).
- **Phase 2 (US1 - Unix)**: Pode ser implementada e validada imediatamente apos a Phase 1.
- **Phase 3 (US2 - Windows)**: Pode ser implementada em sequencia ou em paralelo.
- **Phase 4 (US3 - Higienizacao de Estilo)**: Pode rodar em paralelo ou apos US1/US2.
- **Phase 5 (Verificacao Final)**: Depende da conclusao de todas as fases anteriores.
