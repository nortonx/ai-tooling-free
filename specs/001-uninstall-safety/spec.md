# Feature Specification: Desinstalacao Segura e Protecao de Backups

**Feature Branch**: `001-uninstall-safety`

**Created**: 2026-09-13

**Status**: Draft

**Input**: User description: "Seguranca e remocao nao destrutiva nos desinstaladores"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Desinstalacao Segura com Symlinks Compartilhados (Priority: P1)

Como usuario de multiplos agentes em estacao Linux/macOS/WSL onde `~/.agents/skills` aponta para `~/.claude/skills` (ou ambos para um hub compartilhado), desejo executar `uninstall.sh` sem que o script delete sumariamente o arquivo recem-restaurado do meu backup (.bak).

**Why this priority**: Evita perda definitiva e irreversivel de dados e personalizacoes do usuario causados por delecao circular em caminhos canonicos duplicados.

**Independent Test**:
Criar diretorio temporario simulando `$HOME`, com `~/.agents/skills` como symlink para `~/.claude/skills`. Criar uma skill preexistente `test-skill` e seu backup `test-skill.bak`. Executar `uninstall.sh` e verificar se `test-skill` foi devidamente restaurada e preservada intacta ao final da execucao.

**Acceptance Scenarios**:

1. **Given** que `~/.agents/skills` e um symlink apontando para `~/.claude/skills`, e existe um backup `my-skill.bak` em `~/.claude/skills`, **When** `uninstall.sh` for executado, **Then** a skill do repositorio e desinstalada, `my-skill.bak` e restaurado para `my-skill`, e nenhuma remocao subsequente apaga o `my-skill` restaurado.
2. **Given** que ambos os diretorios `~/.claude/skills` e `~/.agents/skills` sao diretorios reais e independentes, **When** `uninstall.sh` for executado, **Then** as skills e backups sao removidos e restaurados corretamente em ambos os locais de forma isolada.

---

### User Story 2 - Remocao Segura de Symlinks de Diretorio no Windows (Priority: P1)

Como usuario em ambiente Windows executando `uninstall.ps1` ou `uninstall.cmd`, desejo que a remocao de links simbolicos e junctions de diretorios instalados em `%USERPROFILE%\.claude\skills` ou `%USERPROFILE%\.agents\skills` remova apenas o apontamento no destino, sem deletar recursivamente os arquivos fonte contidos no repositorio `ai-tooling-free`.

**Why this priority**: Impede que a desinstalacao no Windows corrompa a arvore de trabalho clonada do repositorio por meio de `Remove-Item -Recurse` atuando sobre alvos de SymbolicLink.

**Independent Test**:
Criar um link simbolico de diretorio e um junction apontando para um diretorio com arquivos de teste. Invocar a rotina de remocao do `uninstall.ps1` e comprovar que apenas o link no destino e desfeito, enquanto o diretorio fonte e seus arquivos permanecem intocados.

**Acceptance Scenarios**:

1. **Given** um link simbolico ou junction em `%USERPROFILE%\.claude\skills\my-skill` apontando para o repositorio, **When** `uninstall.ps1` for executado, **Then** o link e removido e os arquivos dentro de `skills\my-skill\` no repositorio permanecem 100% intactos.

---

### User Story 3 - Higienizacao de Estilo e Compatibilidade com Regras Globais (Priority: P2)

Como mantenedor do repositorio, desejo que os scripts `uninstall.sh`, `uninstall.ps1` e `uninstall.cmd` nao utilizem caracteres de em dash (Unicode U+2014 ou hifen espacado) em comentarios ou mensagens de saida, mantendo conformidade com as regras globais do projeto.

**Why this priority**: Garante consistencia com as diretrizes de estilo do projeto e previne problemas de codificacao em terminais legados Windows.

**Independent Test**:
Escanear os arquivos de desinstalacao com verificacao de caracteres Unicode para garantir 0 ocorrencias de `\u2014` ou hifens soltos.

**Acceptance Scenarios**:

1. **Given** os scripts de desinstalacao no repositorio, **When** executada busca estatica por `\u2014` ou ` - `, **Then** nenhuma ocorrencia e encontrada.

---

### Edge Cases

- **Symlink quebrado (Dangling Symlink)**: O script deve remover o ponteiro sem falhar ou gerar erro impeditivo de arquivo nao encontrado (`[ -L "$target" ]` antes de `[ -e "$target" ]`).
- **Backup orfao sem instalacao ativa**: Se existir apenas `$target.bak` e o `$target` nao existir, o backup deve ser restaurado normalmente.
- **Inexistencia de comandos externos**: `realpath` pode nao estar instalado em sistemas minimalistas (ex: BusyBox/Alpine/macOS antigo); o script deve ter fallback confiavel via `readlink` ou deteccao portavel.
- **Execucao repetida (Idempotencia)**: Rodar o desinstalador duas vezes consecutivas deve ser seguro e nao causar erros nem apagar novos arquivos criados pelo usuario.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: `uninstall.sh` DEVE determinar o caminho canonico (`realpath` ou equivalente) de cada alvo antes da delecao ou restauracao para evitar processar o mesmo arquivo fisico duas vezes na mesma execucao.
- **FR-002**: `uninstall.sh` DEVE verificar a presenca de links simbolicos via `[ -L "$target" ]` antes de checar existencia de arquivo, garantindo a remocao correta de symlinks quebrados.
- **FR-003**: `uninstall.ps1` DEVE tratar especificamente `SymbolicLink` e `Junction` sem usar `Remove-Item -Recurse`, desvinculando o link de forma segura sem navegar nos filhos do alvo.
- **FR-004**: `uninstall.ps1` DEVE verificar se os caminhos de destino apontam para a mesma entidade no sistema de arquivos antes de processar backups duplicados.
- **FR-005**: `uninstall.cmd` DEVE repassar argumentos e codigos de retorno de forma transparente para `uninstall.ps1`.
- **FR-006**: Todos os cabecalhos, comentarios e mensagens emitidas pelos scripts de desinstalacao DEVEM estar livres de travessoes (em dashes).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Em cenario simulado com symlink entre `~/.agents/skills` e `~/.claude/skills`, 100% dos arquivos restaurados de backups `.bak` sao preservados apos a execucao de `uninstall.sh`.
- **SC-002**: A execucao de `uninstall.ps1` desvincula junctions e links simbolicos com 0 arquivos deletados no diretorio de origem do repositorio.
- **SC-003**: Suite de testes automatizados (test harness) cobre cenarios de desinstalacao basica, symlinks circulares, backups orfaos e repeticao idempotente, com 100% de sucesso.
- **SC-004**: 0 ocorrencias de caracteres de em dash (Unicode U+2014 ou hifens espacados) nos arquivos `uninstall.sh`, `uninstall.ps1` e `uninstall.cmd`.

## Assumptions

- O usuario executa os scripts com permissoes adequadas sobre os diretorios em seu `$HOME` / `$USERPROFILE`.
- Backups foram gerados pelos instaladores correspondentes com o sufixo `.bak`.
- A suite de verificacao pode ser executada em Linux/macOS via bash e no Windows via PowerShell 5.1/7+.
