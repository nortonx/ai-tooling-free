# ai-tooling-free Constitution

## Core Principles

### I. Agent Skills Standard e Portabilidade Multiplataforma
Todas as skills no catalogo devem seguir estritamente o padrao Agent Skills:
- Frontmatter YAML valido contendo `name` e `description` concisa e informativa.
- Idioma estrito: todas as skills, instrucoes tecnicas, comentarios de codigo e mensagens de commit DEVEM ser escritos em ingles.
- Compatibilidade operacional verificada em Linux, macOS e Windows nativo (PowerShell e CMD).
- Proibicao estrita do uso de em dashes (travessoes Unicode `—` ou hifens espacados ` - `) na documentacao e instrucoes.

### II. Seguranca Operacional e Integridade de Dados
Scripts de ciclo de vida (`setup.*` e `uninstall.*`) devem garantir seguranca absoluta:
- Desinstaladores nunca devem apagar ou sobrescrever arquivos reais atraves de links simbolicos ou junctions.
- Restauracao de backups deve ser idempotente, deterministica e nao destrutiva.

### III. Simplicidade e Escopo Minimo (YAGNI)
- Codigo minimo que resolve o problema sem abstracoes especulativas.
- Reuso de comandos padrao do sistema antes de dependencias externas.

### IV. Handoff Obrigatorio para Superpowers (NON-NEGOTIABLE)
Implementacao de qualquer lista de tasks DEVE seguir o fluxo do Superpowers:
worktree -> TDD (red-green-refactor) -> execucao via subagente -> code review -> fechamento de branch.

Documento manda, codigo obedece: nenhuma implementacao deve ser iniciada sem que `spec.md`, `plan.md` e `tasks.md` tenham sido aprovados.

## Governance

A presente constituicao rege todas as especificacoes, planos e implementacoes do repositorio `ai-tooling-free`.
Qualquer alteracao nestes principios requer revisao formal de governanca.

**Version**: 1.0.0 | **Ratified**: 2026-09-13 | **Last Amended**: 2026-09-13
