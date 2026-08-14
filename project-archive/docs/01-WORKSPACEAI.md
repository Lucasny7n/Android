# WorkspaceAI e ferramentas

## Política aplicada

- `POLICY.md` foi lido antes da criação de artefatos persistentes.
- Fonte normativa: `00-Shared/09-Policies/workspace-ai-policy.yaml`, versão 2,
  efetiva em 2026-07-28.
- Project root canônico: `/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC`.
- Task-id: `codex-floppy-exynos2100-oc-20260813`.
- Runtime reservado: `/run/user/$(id -u)/workspace-ai/codex-floppy-exynos2100-oc-20260813`.

## WAI descoberto e usado

| Comando | Objetivo | Resultado |
|---|---|---|
| `wai --help` | descobrir interface | PASS; subcomandos documentados. |
| `wai doctor` | integridade do índice | PASS; banco íntegro. |
| `wai health` | saúde ampla | FAIL pré-existente: 42 violações e 8 entradas da Home fora da política; não relacionadas a este projeto e não alteradas. |
| `wai exact 'Floppy-Exynos2100-OC'` | colisão nominal | sem resultado antes da criação. |
| `wai find 'Floppy Exynos2100 OC'` | localizar projeto/artefato | sem resultado antes da criação. |
| `wai refs <caminho-antigo>` | dependências conhecidas | sem resultado. |
| `wai task new ...` | registrar missão | PASS no ledger; a ferramenta registra no SQLite, mas não cria bundle de arquivos. |
| `wai audit` | indexação final após materializar artefatos | PASS; completou sem saída textual. `wai doctor` posterior confirmou `integrity=ok`, 16 tabelas. |

`wai task new` foi confirmado pelo código local como operação de ledger. O
bundle exigido pela política será mantido manualmente em
`Codex/01-Active/codex-floppy-exynos2100-oc-20260813/`, com ponte para este
projeto.

Nenhuma violação pré-existente da Home foi movimentada, removida ou corrigida.
