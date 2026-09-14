# Implementation Plan: Desinstalacao Segura e Protecao de Backups

**Branch**: `001-uninstall-safety` | **Date**: 2026-09-13 | **Spec**: [spec.md](file:///home/norton/workspace/projects/ai-tooling-free/specs/001-uninstall-safety/spec.md)

**Input**: Feature specification de `specs/001-uninstall-safety/spec.md`

## Summary

Corrigir a logica de remocao e restauracao de backups nos desinstaladores (`uninstall.sh` e `uninstall.ps1`), implementando deduplicacao de alvos por caminho canonico real para impedir que instalacoes unificadas via symlink (`~/.agents/skills` -> `~/.claude/skills`) destruam os arquivos restaurados do usuario. Isolar a desvinculacao de links simbolicos e junctions no Windows sem recursao destrutiva sobre a pasta fonte do repositorio, e criar suite de testes deterministica para validar os fluxos.

## Technical Context

**Language/Version**: Bash 4+ / POSIX sh, PowerShell 5.1+ / pwsh 7+  
**Primary Dependencies**: Coreutils padrao (`readlink`, `rm`, `mv`), .NET BCL no PowerShell (`System.IO.Directory`)  
**Storage**: Sistema de arquivos local (diretorios de configuracao do usuario e links simbolicos)  
**Testing**: Suite de testes automatizada em Bash (`tests/test_uninstall.sh`) rodando em ambiente isolado (`mktemp -d`)  
**Target Platform**: Linux, macOS, WSL2, Windows nativo (PowerShell e CMD)  
**Project Type**: Scripts de ciclo de vida e automacao de CLI  
**Constraints**: Zero dependencias externas; portabilidade estrita; zero ocorrencias de em dash (Unicode U+2014 ou hifens espacados)

## Constitution Check

- **I. Portabilidade Multiplataforma**: Aprovado. `uninstall.sh` cobre sistemas Unix/macOS/WSL e `uninstall.ps1` cobre Windows nativo.
- **II. Seguranca e Integridade de Dados**: Aprovado. Elimina a vulnerabilidade de exclusao dupla de backups e remocao recursiva em links simbolicos.
- **III. Simplicidade (YAGNI)**: Aprovado. Deduplicacao baseada em conjunto de caminhos reais canonicos resolvidos em memoria durante a execucao.
- **IV. Handoff Obrigatorio para Superpowers**: Aprovado. A esteira sera conduzida por tarefas verificadas via TDD antes da conclusao.

## Project Structure

### Documentation (this feature)

```text
specs/001-uninstall-safety/
├── spec.md              # Especificacao funcional de requisitos e cenarios de usuario
├── plan.md              # Este plano de arquitetura tecnica
└── tasks.md             # Tarefas tecnicas ordenadas para execucao no Superpowers
```

### Source Code and Tests

```text
uninstall.sh             # Desinstalador Unix (higienizado e com deteccao canonica)
uninstall.ps1            # Desinstalador PowerShell (desvinculacao segura sem recursao)
uninstall.cmd            # Launcher Windows CMD
tests/
└── test_uninstall.sh    # Test harness automatizado para validacao de cenarios
```

## Arquitetura e Estrategia Tecnica

### 1. Resolucao Canonica e Deduplicacao em `uninstall.sh`
- Funcao portavel `canonical_path()`:
  - Tenta `realpath "$1" 2>/dev/null`
  - Caso indisponivel, resolve recursivamente com `readlink`
- Registro de alvos visitados: manter array/lista associativa com os caminhos canonicos ja processados.
- Se o caminho canonico de `$HOME/.agents/skills/$name` coincidir com um alvo ja desinstalado/restaurado em `$HOME/.claude/skills/$name`, o script remove apenas o link simbolico residual sem disparar remocao de arquivo real nem reexecutar `mv "$target.bak" "$target"`.
- Validacao estrita de tipo: testar `[ -L "$target" ]` antes de `[ -e "$target" ]` para que symlinks quebrados (dangling) sejam removidos sem erro.

### 2. Desvinculacao Segura no Windows em `uninstall.ps1`
- Para cada alvo, obter o caminho canonico normalizado via `Resolve-Path` (ou `[System.IO.Path]::GetFullPath`).
- Tratar `LinkType`:
  - Se for `Junction`: executar `cmd /c rmdir "$Target" | Out-Null` ou `[System.IO.Directory]::Delete($Target)`.
  - Se for `SymbolicLink`: se for diretorio, utilizar `[System.IO.Directory]::Delete($Target)` (que apaga exclusivamente a reparse point / link sem remover o conteudo do diretorio apontado), NUNCA `Remove-Item -Recurse`.
  - Apenas arquivos e diretorios reais comuns recebem `Remove-Item -Force`.
- Deduplicar operacoes de restauracao para entidades fisicas ja restauradas.

### 3. Test Harness Automatizado (`tests/test_uninstall.sh`)
- Cria diretorio temporario isolado simulando `$HOME`.
- Testa 4 cenarios mandatorios:
  1. **Cenario Baseline**: Instalacao padrao em pastas separadas com desinstalacao limpa.
  2. **Cenario Symlink Compartilhado**: `~/.agents/skills` aponta para `~/.claude/skills`. Backup `.bak` existe. Apos o uninstall, o arquivo restaurado DEVE estar preservado intacto.
  3. **Cenario Dangling Symlink**: Symlink apontando para pasta inexistente deve ser removido sem abortar a execucao.
  4. **Cenario Idempotencia**: Executar o desinstalador duas vezes seguidas nao gera falhas nem altera arquivos de terceiros.

**Structure Decision**: Scripts de raiz existentes (`uninstall.sh`, `uninstall.ps1`, `uninstall.cmd`) serao refatorados mantendo compatibilidade de API e paths. Test harness sera adicionado em `tests/test_uninstall.sh`. Sem violacoes de complexidade.
