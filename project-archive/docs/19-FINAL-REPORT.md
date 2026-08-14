# Relatório final

## 1. Objetivo e resultado

Missão: FloppyKernel Exynos2100 `KSUNext-SUSFS`, auditoria Proton e topo G3D
aproximado de 1,09 GHz. Auditoria, preservação Floppy, build limpa e pacote
baseline foram concluídos. Novo OPP: **BLOCKED**. 1092 MHz é candidato PLL,
mas não há FVMAP/ASV/ACPM 1092 comprovado. Não foi fabricado clock, tensão,
DVFS ou thermal; o pacote é baseline Floppy 949 MHz, não OC 1092.

## 2. WorkspaceAI e migração

- PROJECT_ROOT: `/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC`.
- Política e interface `wai` foram lidas antes das escritas. `wai doctor`
  passou; achados prévios de `wai health` fora do projeto permaneceram intactos.
- O worktree legado foi inspecionado em `d69b0cd249f4`, limpo. Documentos
  anteriores foram copiados como evidência com SHA256 conferido; nada em
  `/home/lucas/kernel-sources` foi removido. Ver `docs/00-MIGRATION.md`.

## 3. Skills, plano, pesquisa e logs

Skills candidatas/decisões: `docs/02-SKILLS-AUDIT.md`. A única skill usada foi
`github:github`, para proveniência Git, com entrada/saída/impacto em
`docs/03-SKILLS-USAGE.md`. Não havia skill Linux/kernel/Android aplicável.

Plano: `docs/05-PLAN.md`; pesquisa e fontes: `docs/06-RESEARCH-LOG.md` e
`docs/07-SOURCES.md`; execução: `docs/11-IMPLEMENTATION-LOG.md`; erros:
`docs/12-ERRORS-AND-FIXES.md`. O trabalho foi CLI/headless: sem GUI, alteração
de janela/áudio, reinício do host, flash ou reboot.

## 4. Base, root e Mali

| Item | Evidência | Estado |
|---|---|---|
| Base Floppy | `floppy-main` em `af9e70e6af7aa7f66903d883cd677b9147424ed1` | PASS |
| Kernel | 5.4.302 | PASS |
| KernelSU Next | `CONFIG_KSU_NEXT=y`; símbolos `ksu_handle_*` ligados | STATIC PASS |
| SUSFS | `CONFIG_KSU_SUSFS=y`, `v2.2.0`, símbolos ligados | STATIC PASS |
| Mali | `bv_r38p0`, `bv_r38p1`, `v_r38p1`, `v_r44p1` compilados | STATIC PASS |
| Root/Mali em aparelho | requer boot físico | NOT TESTED |

Não houve atualização cega de KernelSU/SUSFS ou troca para Magisk/APatch.

## 5. Auditoria Proton

Foram revalidados **27 grupos** no Proton
`79d7da625ff3fbfa0c84cdedb07a4dcdc055baf4` por patch-id, reversões e estado
final: `ALREADY_PRESENT=5`, `FLOPPY_BETTER=8`, `REJECT=14`, `PORT=0`.

Não foi portado tweak agressivo de scheduler/CFS/EMS, foreground/input,
CPUFreq, GPU/DVFS, thermal, MGLRU/ZRAM, I/O, rede, idle ou power. A matriz
com justificativas está em `PROTON_CANDIDATES.md` e `docs/08-PROTON-AUDIT.md`.

## 6. GPU, 1091/1092, FVMAP e decisão

CMUCAL usa 26 MHz e M/P/S inteiros: 949 é `26 × 73 / 2`; o candidato seguinte
é **1092 MHz**, `26 × 84 / 2`. 1091 não foi tratado como o mesmo número.

O caminho real é DTS/driver → CAL → `cal_dfs_set_rate()` →
`exynos_acpm_set_rate(FREQ_REQ)` → ACPM. FVMAP copia níveis/tensões ASV da
SRAM ACPM; o kernel ajusta margens existentes, mas não há caminho validado de
anexar novo nível. Acima do topo, a tensão recai em 949, hipótese rejeitada.

Nenhuma fonte primária forneceu FVMAP/firmware/código Exynos2100 G3D 1092, e
não havia `g3d_fv_table` físico. Acrescentar DTS/PLL/locks seria clock falso.
**1092 IMPLEMENTATION: BLOCKED.** Ver `docs/09-GPU-OC-RESEARCH.md` e
`docs/10-DESIGN-DECISIONS.md`.

## 7. DVFS, thermal e preservação

A curva continua `130, 221, 312, 403, 494, 585, 676, 767, 858, 949 MHz`.
Foram preservados stock ceiling 858, runtime ceiling 949, thermal 949→858→767,
PM QoS de 10 entradas, hispeed 676, clamp, throttler protection e UV/FVMAP.
Nenhum TMU, PI, cooling ou shutdown crítico foi removido.

## 8. Commits e toolchain

Não existe commit de código kernel OC. Fonte Floppy e `ckbuild.sh` final do
worktree estão limpos. Commits de projeto anteriores:

1. `d32198d baseline: record workspace migration and Floppy source`
2. `ad850e5 audit: validate Proton candidates and G3D feasibility`
3. `0e27c72 build: add headless KSUNext-SUSFS validation tooling`
4. `62cd7cc build: exclude generated Python bytecode`
5. Commit final de documentação desta build.

Toolchain: Android clang 22.0.2, build 15682573, baseado em `r596125`, LLVM
`de03d430...`, PGO+BOLT+LTO+MLGO. O pipeline `kclq` usou Full LTO, Bubblewrap
privado, `nice 10`, `ionice -c 3` e 10 jobs. Timestamp oficial impede alegar
reprodução byte-a-byte sem segunda build, mas comandos/versões/hashes existem.

## 9. Build e validação

**CLEAN BUILD: PASS**, 7m25s. Foram gerados `vmlinux`, Image, DTB, 320 `.ko`,
Module.symvers, boot/vendor boot, DTBO, ZIP e TAR.

| Checagem | Estado |
|---|---|
| fonte/diff/config/DT/Module.symvers | PASS estático |
| 130–949, ceilings, PM QoS, thermal, UV, clamp, throttlers | PASS estático |
| KSUNext-SUSFS/Mali | STATIC PASS |
| símbolos não resolvidos | PASS: nenhum encontrado |
| ZIP/TAR/checksums | PASS |
| OPP/FVMAP/ACPM 1092 | BLOCKED |
| S21 conectado | BLOCKED: nenhum aparelho físico |
| boot/root/GPU/thermal/benchmark/estabilidade | NOT TESTED |
| flash | NOT TESTED |

Dois avisos KSU/SUSFS, 24 `no symbols`, três mensagens Git mkbootimg e três
avisos depmod do ramdisk foram analisados. Nenhum foi ocultado ou causou falha
de link/pacote. Ver `docs/12-ERRORS-AND-FIXES.md`, `docs/13-BUILD-REPORT.md`
e `docs/14-STATIC-VALIDATION.md`.

## 10. Pacote e checksum

Pacote: `packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-20260813-0242.zip`

SHA256: `3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4`

`packages/` contém ZIP, TAR OneUI/AOSP, quatro TARs DTBO, `SHA256SUMS`,
SHA256/MD5 e metadata. `output/release/` contém Image, DTB, boot/vendor boot,
DTBO e manifest. `unzip -t`, `sha256sum -c` e `tar -tf` passaram. O ZIP inclui
Image, vendor_boot e DTBO r9s/o1s/p3s/t2s.

## 11. Runtime, continuidade e rollback

`adb devices -l` não encontrou S21 Exynos2100. O coletor somente leitura saiu
BLOCKED sem `su`, escrita, flash ou reboot. Use
`docs/16-DEVICE-COLLECTION.md` e `docs/15-TEST-PLAN.md` quando houver aparelho;
pare em Mali/MMU fault, reset, artifact, oops, panic, watchdog, freeze, reboot
ou temperatura crítica.

Para reabrir OC, obtenha FVMAP/ASV/ACPM G3D 1092 confiável, colete baseline e
confirme FREQ_REQ/voltagem antes de compilar/testar. Não copie 949. Rollback
está em `docs/18-ROLLBACK.md`; nenhum dado do usuário foi apagado.

## 12. Resumo

**BASE / WORKSPACE MIGRATION / SKILLS AUDIT / RESEARCH / PROTON AUDIT: PASS**

**GPU DESIGN / 1092 IMPLEMENTATION: BLOCKED por FVMAP/ASV/ACPM**

**KSUNEXT-SUSFS / MALI: STATIC PASS**

**CLEAN BUILD / PACKAGE: PASS (baseline 949)**

**DEVICE RUNTIME / FLASH: NOT TESTED**

# Continuação final — GPU1092 experimental (estado vigente)

## Objetivo, base e nova evidência

O mesmo projeto WorkspaceAI foi continuado, sem apagar a baseline Floppy
`af9e70e6af7aa7f66903d883cd677b9147424ed1` (5.4.302). A fonte experimental
está em `build/floppy-gpu1092-source`, branch
`floppy-exynos2100-g3d-1092-test`, commit `cc6540be7336`; `src/floppy`
permanece na base exata.

Foram validados os 12 hashes da coleta root SM-G991B/Exynos2100. O FVMAP G3D
tem dez níveis e UV=0, com topo real 949000 kHz/825000 uV. Isso substitui o
antigo blocker de curva desconhecida. A investigação de FVMAP, CAL, VCLK, RA e
ACPM confirmou cópia SRAM→local, LUT/voltable com mesma contagem e `FREQ_REQ`
por frequência em kHz. Não há fonte do firmware ACPM que prove aceitação de
1092: esse risco permanece runtime NOT TESTED.

## Design e implementação

1092 MHz é M=84/P=2/S=0 com referência de 26 MHz; não é rotulado como 1091.
A tensão experimental é **925000 uV**: extrapolação superior conservadora de
923214 uV arredondada ao degrau FVMAP de 6250 uV. Não é ASV de fábrica nem
declaração de estabilidade.

O código cria um décimo-primeiro nível somente após validar ambas cópias de
FVMAP, os dez pares coletados, o offset seguinte e espaço livre. Não reloca
domínios SRAM. Uma LUT VCLK shadow mantém CAL em 11×11. Falhas de
layout/CAL falham fechadas; após `FREQ_REQ`, a taxa física RA/PLL é confirmada
para evitar clock fake.

A revisão pós-build confirmou que a LUT ACPM original é alocada dinamicamente
por `vclk_get_dfs_info()`. A substituição preserva os dez parâmetros existentes
e cria apenas os parâmetros do novo topo; não libera dados estáticos.

DVFS final: 130, 221, 312, 403, 494, 585, 676, 767, 858, 949 e 1092 MHz.
O estágio padrão é 858; unlock preserva 949; `gpu_oc1092` habilita 1092 apenas
após unlock. Cooling passa por 1092→949→858→767; TMU/crítico e hispeed 676
permanecem. UV, KSU Next, SUSFS e seletor Mali não foram atualizados ou
substituídos; r38p0/r38p1/r44p1 foram compilados.

## Auditoria, build e pacotes

Os 27 candidatos Proton foram revalidados: 0 `PORT`; Floppy continua a base.
`github:github` foi a única skill usada para orientar a busca; não existe skill
instalada para Exynos/Mali/FVMAP.

Build oficial `ckbuild.sh kclq` com clang 22.0.2 r596125,
PGO+BOLT+Full LTO+MLGO: **PASS**, 7m53s, em
`logs/build/build-gpu1092-2026-08-13T04_06_32-03_00.log`. Foram gerados 320
módulos, Image, DTB, DTBO, vendor_boot e KMDs; não houve símbolo não resolvido.
Os avisos de namespace/depmod estão em `12-ERRORS-AND-FIXES.md`.

- Experimental OrangeFox/AnyKernel:
  `packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-GPU1092-EXPERIMENTAL-20260813-0406.zip`
  — SHA256 `e737a647875cccc6d1a27de6c9396c59b41b5ffca608e72ffc6634772329d8e7`.
- Rollback baseline 949:
  `packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip`
  — SHA256 `3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4`.

Ambos passaram `unzip -t`, `verify-package.sh` e `sha256sum -c`. A validação
adversarial estática é PASS (`14-STATIC-VALIDATION.md`).

## Limites, teste e rollback

**RUNTIME NOT TESTED.** Não houve ADB, flash, reboot ou alteração no telefone.
O firmware ACPM pode rejeitar a taxa e 925000 uV não foi provada estável. O
primeiro boot deve seguir `15-TEST-PLAN.md`, executar o monitor read-only e
parar em fault/reset/MMU/artifact/oops/panic/watchdog/freeze/reboot ou
temperatura crítica. O rollback está em `18-ROLLBACK.md`.

## Commits kernel

`78ba9c74292f gpu: add guarded 1092 MHz G3D FVMAP entry`

`eeaf8714c7ec gpu: expose 1092 MHz DVFS ceiling and locks`

`c2fcc90010c0 gpu: validate FVMAP 1092 maximum rate`
`cc6540be7336 gpu: fail probe when CAL OPP validation fails`

Status: **BASE/RESEARCH/PROTON/STATIC/BUILD/PACKAGE PASS; GPU1092
STATIC+BUILD PASS; DEVICE RUNTIME e FLASH NOT TESTED.**
