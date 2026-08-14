# Log de implementação

| Data | Ação | Arquivos | Resultado | Próxima decisão |
|---|---|---|---|---|
| 2026-08-13 | Política, índice e WAI inspecionados. | `docs/01-WORKSPACEAI.md` | PASS | Criar projeto e registrar migração. |
| 2026-08-13 | Evidências da auditoria anterior copiadas e SHA256 comparados. | `evidence/baseline/*`, `docs/00-MIGRATION.md` | PASS | Recriar fontes oficiais em `src/`. |
| 2026-08-13 | Clone parcial oficial Floppy iniciado com baixa prioridade. | `src/floppy/` | IN PROGRESS | Aguardar clone, evitar Git concorrente. |
| 2026-08-13 | Floppy e Proton fixados nos SHAs solicitados; configs, submódulos e variantes inspecionados. | `src/floppy/`, `src/references/proton/`, `docs/04-BASELINE.md` | PASS | Revalidar Proton e caminho G3D. |
| 2026-08-13 | Baixado pelo fluxo oficial o AOSP Clang r596125 e verificadas versão/hashes. | `tools/toolchains/aospclang/`, `docs/06-RESEARCH-LOG.md` | PASS | Usar somente esse clang. |
| 2026-08-13 | Revalidada auditoria de 27 candidatos Proton por estado final, reversões e patch-ids. | `PROTON_CANDIDATES.md`, `docs/08-PROTON-AUDIT.md` | PASS, PORT=0 | Não portar tweaks redundantes. |
| 2026-08-13 | Auditados CMUCAL, CAL, ACPM, FVMAP, DTS, thermal e UV. | `docs/09-GPU-OC-RESEARCH.md`, `docs/10-DESIGN-DECISIONS.md` | 1092 BLOCKED | Manter 949, não fabricar OPP/tensão. |
| 2026-08-13 | Criados scripts CLI read-only de coleta/monitor e gates de preflight/static/package. | `tools/`, `scripts/` | PASS | Executar build e validação final. |
| 2026-08-13 | Criado worktree de build; submódulo mkbootimg inicializado apenas nele. | `build/floppy-build/` | PASS | Compilar sem tocar `src/floppy`. |
| 2026-08-13 | Aplicadas compatibilidades locais do build: namespace `/mnt`, toolchain `/srv`, `bc` estrito e `zip` via 7-Zip. | `scripts/build-ksunext-susfs.sh`, `tools/build-bin/` | PASS | Acompanhar Full LTO, package e validação. |
| 2026-08-13 | A tentativa 1 compilou e instalou 320 módulos, mas o empacotador não os encontrou porque a adaptação temporária tornou `MOD_OUTDIR` relativo a `O=out`. | `logs/build/build-2026-08-13T02_32_27-03_00.log`, `docs/12-ERRORS-AND-FIXES.md` | FAIL documentado | Restaurar o `ckbuild.sh` oficial no worktree e repetir build limpa. |
| 2026-08-13 | Restaurado o `ckbuild.sh` oficial no worktree; o namespace `/mnt` já remove os espaços sem alterar a semântica de `MOD_OUTDIR`. | `scripts/build-ksunext-susfs.sh`, `build/floppy-build/build/ckbuild.sh` | PASS | A segunda build limpa está em andamento. |
| 2026-08-13 | Build oficial `kclq` concluída em 7m25s usando clang 22.0.2/r596125 e Full LTO; módulos, Image, DTB, DTBO, vendor boot, ZIP e TARs foram produzidos. | `logs/build/build-2026-08-13T02_42_31-03_00.log`, `build/floppy-build/` | PASS | Materializar e verificar artefatos. |
| 2026-08-13 | ZIP, TARs e imagens foram copiados para `packages/`/`output/release/`; SHA256, MD5 e manifest foram gerados. | `scripts/prepare-package.sh`, `packages/`, `output/release/` | PASS | Executar revisão adversarial estática. |
| 2026-08-13 | Executados preflight, validação estática, inventário de pacote, contagem de 320 `.ko`, `llvm-nm` KSU/SUSFS e verificações de símbolos. | `logs/tests/final-static-package-20260813T025209-0300.log` | PASS estático; 1092 BLOCKED | Finalizar documentação e não afirmar runtime. |
| 2026-08-13 | Executado `wai audit` após materialização; processo foi reduzido para `nice 10`/I/O idle e concluiu. `wai doctor` posterior confirmou banco íntegro. | `docs/01-WORKSPACEAI.md` | PASS | Commitar resultado final. |

Nenhum arquivo de código do kernel em `src/floppy` foi alterado. O worktree de
build também foi restaurado ao `ckbuild.sh` oficial antes da tentativa final;
as únicas mudanças persistentes são documentação e scripts de orquestração.

## Continuação GPU1092 — trilha cronológica

| Data/hora BRT | Ação e razão | Arquivos/commit | Resultado / próxima decisão |
|---|---|---|---|
| 2026-08-13 03:28–03:45 | Validada a nova coleta root sem tocar no telefone; ela resolve o dado de tensão baseline. | `evidence/runtime/baseline-device/...`, 12 SHA256 | PASS; reabrir somente desenho experimental, não alegar runtime. |
| 2026-08-13 03:45–04:00 | Rastreada FVMAP→CAL→VCLK→ACPM e pesquisados precedentes. | `fvmap.c`, `cal-if.c`, `vclk.c`, `ra.c` | `FREQ_REQ` recebe kHz; firmware continua risco residual. |
| 2026-08-13 04:00 | Criado worktree/branch isolado do commit Floppy exato. | `build/floppy-gpu1092-source`, `floppy-exynos2100-g3d-1092-test` | PASS; baseline `src/floppy` não foi modificada. |
| 2026-08-13 04:01 | Adicionados PLL M84/P2/S0, FVMAP guardado e LUT shadow. | `78ba9c7` | PASS estático; sem expansão cega de SRAM. |
| 2026-08-13 04:02 | Integrados DVFS, runtime ceiling, locks, sysfs e validações de taxa/FVMAP. | `eeaf871`, `c2fcc90`, `cc6540b` | PASS estático; o probe recusa incoerência CAL. |
| 2026-08-13 04:06–04:14 | Executada build limpa oficial `ckbuild.sh kclq` com clang r596125, prioridade reduzida. | `logs/build/build-gpu1092-2026-08-13T04_06_32-03_00.log` | PASS em 7m53s; revisar warnings, módulos e DTB. |
| 2026-08-13 04:14–04:20 | Executados validação adversarial, `llvm-nm`, DTB, módulos e empacotamento oficial AnyKernel. | `tools/static-validate-gpu1092.sh`, `scripts/prepare-gpu1092-packages.sh` | PASS estático/package; preparar ZIP rollback e documentação. |

O texto anterior de “nenhum arquivo de código alterado” descreve a rodada
baseline encerrada; a tabela acima é o estado vigente desta continuação.

| 2026-08-13 04:25 | Revisão adversarial pós-build confirmou que a LUT ACPM é alocada dinamicamente em `vclk_get_dfs_info()`; a troca para array 11 não aplica `kfree` a dados estáticos. | `vclk.c`, `fvmap.c`, `14-STATIC-VALIDATION.md` | PASS estático; nenhum código foi alterado nessa revisão. |
