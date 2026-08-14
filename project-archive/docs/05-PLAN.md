# Plano de execução

O ciclo obrigatório é: **PLAN → RESEARCH → IMPLEMENT → VERIFY → TEST → REVIEW
→ FIX → VERIFY NOVAMENTE**. Repetições exigem hipótese, mudança ou evidência
nova.

| Fase | Objetivo e tarefas | PASS | Riscos / evidências |
|---|---|---|---|
| 0 | Workspace, task ledger, migração e isolamento | projeto e proveniência registrados | política, `00-MIGRATION`, estado |
| 1 | Baseline de clones, config, submódulos e pipeline | `af9e70e` e `79d7da6` reproduzidos | `04-BASELINE`, hashes |
| 2 | Skills | triagem e ledger completos | `02/03-SKILLS` |
| 3 | Pesquisa externa primária | fontes e conclusões rastreáveis | `06/07` |
| 4 | Auditoria Proton | candidatos classificados sem duplicação | `08-PROTON-AUDIT` |
| 5 | PLL/CAL/ACPM/FVMAP/ASV | frequência real e caminho de tensão definidos ou bloqueio provado | `09-GPU-OC-RESEARCH` |
| 6 | Design OC/DVFS/thermal | integração e segurança justificadas | `10-DESIGN-DECISIONS` |
| 7 | Implementação mínima e commits lógicos | somente mudanças validadas | `11-IMPLEMENTATION-LOG` |
| 8 | Validação estática e adversarial | tabelas, configs, locks e regressões revisadas | `14-STATIC-VALIDATION` |
| 9 | Toolchain e build limpa | build reproduzível | `13-BUILD-REPORT`, logs |
| 10 | Correções | falhas registradas e revalidadas | `12-ERRORS-AND-FIXES` |
| 11 | Empacotamento | pacote, hashes e metadata | `packages/` |
| 12 | Coleta ADB read-only | S21 identificado ou script pronto | `16-DEVICE-COLLECTION` |
| 13 | Prontidão runtime | plano de teste e monitor CLI completos | `15/17`, ferramentas |
| 14 | Revisão adversarial | nenhum clock falso ou regressão conhecida | `14-STATIC-VALIDATION` |
| 15 | Fechamento | status, rollback, relatório e índice atualizados | `19-FINAL-REPORT` |

Nenhuma implementação de OPP será iniciada antes de passar a Fase 5.

## Continuação GPU1092 — execução efetiva

| Fase | Resultado | Evidência |
|---|---|---|
| 0–4: recuperação, baseline, skills, Proton | PASS | `README.md`, `04-BASELINE.md`, `08-PROTON-AUDIT.md` |
| 5: FVMAP/ACPM e tensão | PASS para desenho experimental; aceitação do firmware fica runtime | `09-GPU-OC-RESEARCH.md`, coleta root com SHA256 válido |
| 6–7: design e implementação | PASS estático | branch `floppy-exynos2100-g3d-1092-test`, commits `78ba9c7..cc6540b` |
| 8: validação estática adversarial | PASS | `tools/static-validate-gpu1092.sh`, `14-STATIC-VALIDATION.md` |
| 9–10: build/correções | PASS | `logs/build/build-gpu1092-2026-08-13T04_06_32-03_00.log` |
| 11: empacotamento OrangeFox/AnyKernel | PASS | `packages/`, `SHA256SUMS`, `verify-package.sh` |
| 12–13: coleta/runtime | coleta PASS; runtime NOT TESTED | `16-DEVICE-COLLECTION.md`, `17-RUNTIME-VALIDATION.md` |
| 14–15: revisão/fechamento | PASS estático; sem alegação runtime | `14-STATIC-VALIDATION.md`, `19-FINAL-REPORT.md` |
