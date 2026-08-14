# Relatório de build

## Resultado

**CLEAN BUILD: PASS (baseline Floppy 949 MHz).**

O resultado não é uma build OC 1092: nenhum OPP novo foi adicionado porque a
investigação FVMAP/ASV/ACPM o bloqueou. A build preserva a árvore Floppy
`af9e70e6af7aa7f66903d883cd677b9147424ed1`, variante `KSUNext-SUSFS`, com o
topo OC existente de 949 MHz.

## Proveniência e ambiente

| Item | Valor | Estado |
|---|---|---|
| Fonte | Floppy `af9e70e6af7aa7f66903d883cd677b9147424ed1` | PASS, limpa antes/depois |
| Branch de origem | `floppy-main` | PASS, checkout destacado para forense |
| Variante | `KSUNext-SUSFS / Testing` | PASS |
| Defconfig | `exynos2100-unified_defconfig` + fragmento `ksu.config` | PASS |
| Toolchain | Android clang 22.0.2, build 15682573, baseado em `r596125`, LLVM `de03d430...` | PASS |
| Pipeline | `build/ckbuild.sh kclq` oficial | PASS |
| Otimizações declaradas | `+pgo,+bolt,+lto,+mlgo`; `l` seleciona Full LTO | PASS |
| Host impact | Bubblewrap privado, `nice 10`, `ionice -c 3`, shim `nproc=10` | PASS |
| Duração | 7 minutos e 25 segundos | PASS |

O clang foi obtido pelo fluxo oficial Floppy a partir do prebuilt AOSP e ficou
em `tools/toolchains/aospclang/`; seus bytes não são versionados no Git do
projeto, mas identidade e hashes foram registrados em `docs/06-RESEARCH-LOG.md`.
Não foi usado clang do host como substituto, nem instalado pacote do host.

## Comando reproduzível

```bash
cd '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
./scripts/build-ksunext-susfs.sh
./scripts/prepare-package.sh
./tools/preflight-check.sh
./tools/static-validate.sh
./tools/verify-package.sh packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-20260813-0242.zip
```

O wrapper exige fonte limpa no SHA alvo e toolchain 22.0.2. Ele cria um
worktree descartável em `build/floppy-build`, exposto somente ao filho como
`/mnt` porque o Makefile Linux 5.4 rejeita o espaço no caminho canônico do
WorkspaceAI. O `ckbuild.sh` dentro do worktree final ficou sem diff. A saída
contém timestamp do pipeline oficial, portanto reexecução foi documentada mas
**reprodutibilidade byte-a-byte não foi demonstrada**.

## Resultados de compilação e link

- `vmlinux`: 761170984 bytes.
- `Image`: 22880768 bytes, SHA256
  `8c291791c0347492535d549ce9a7cc67e861fe0c772bb89272f041c29c09b019`.
- `Image.gz`: 10043146 bytes.
- `exynos2100.dtb`: 393816 bytes, SHA256
  `db6bcd66ceb5c25f84efe928d92bc3dc2374f25271b9869d1da9baac19ccd7db`.
- `Module.symvers`: 739219 bytes; nenhuma ocorrência de `undefined reference`
  ou `undefined!` no log de compilação.
- 320 arquivos `.ko` foram encontrados em `out/` após a build. O pipeline
  gerou `modules.load` com 280 módulos selecionados para o vendor ramdisk.
- KSU/SUSFS: a config final tem `CONFIG_KSU_NEXT=y` e
  `CONFIG_KSU_SUSFS=y`; `llvm-nm vmlinux` encontrou
  `ksu_handle_execve_ksud` e marcadores/estado SUSFS.
- Mali: os diretórios e objetos `bv_r38p0`, `bv_r38p1`, `v_r38p1` e `v_r44p1`
  foram construídos. Isto é validação estática, não teste de seleção runtime.

Log completo: `logs/build/build-2026-08-13T02_42_31-03_00.log`.

## Avisos e classificação

| Categoria | Quantidade | Estado | Decisão |
|---|---:|---|---|
| `warning:` de configuração KSU/SUSFS | 2 | non-fatal | preservado, config/símbolos validados |
| `no symbols` em objetos arquivados | 24 | non-fatal, não comparado a baseline | não alterar KMD especulativamente |
| Git mkbootimg no namespace | 3 | non-fatal | imagens/pacotes foram criados |
| `depmod` no ramdisk reduzido | 3 | non-fatal | vendor boot/ZIP íntegros; runtime pendente |
| unresolved/duplicate symbol | 0 encontrados | PASS | nenhuma correção necessária |

Os detalhes de causa, limites e evidência estão em
`docs/12-ERRORS-AND-FIXES.md`.

## Pacotes e hashes

| Artefato | SHA256 |
|---|---|
| ZIP AnyKernel principal | `3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4` |
| TAR OneUI | `b52aea9fffe0852f6d92ac64a2e2aaebb79ebea1928328ba3cc91a4207397893` |
| TAR AOSP | `56996f335fa1bbe49342d67d3a9220894f40492fe00e1a0a16043c2a07e60f86` |

Os quatro TARs DTBO, todos os hashes e o MD5 do ZIP estão em
`packages/SHA256SUMS`, `packages/*.sha256` e `packages/*.md5`. O ZIP passou
em `unzip -t`, inclui `Image`, `vendor_boot.img` e DTBOs r9s/o1s/p3s/t2s. Os
TARs passaram em `tar -tf`. Imagens brutas estão em `output/release/`.

**PACKAGE: PASS para a baseline 949 MHz. 1092: BLOCKED e ausente.**

## Build experimental GPU1092 — resultado vigente

- Fonte/branch: `build/floppy-gpu1092-source`,
  `floppy-exynos2100-g3d-1092-test` em `cc6540be7336` (ancestral de
  `af9e70e6af7aa7f66903d883cd677b9147424ed1`).
- Pipeline: `build/ckbuild.sh kclq`, dentro do namespace headless `/mnt`,
  `nice 10`, `ionice -c3`, limite de 10 jobs, Android clang 22.0.2/r596125,
  PGO+BOLT+Full LTO+MLGO conforme pipeline Floppy.
- Log: `logs/build/build-gpu1092-2026-08-13T04_06_32-03_00.log`.
- Resultado: **CLEAN BUILD PASS**, 7m53s; source e projeto foram verificados
limpos antes do commit documental final.
- Link/modpost: não há `undefined reference`/`undefined!` no log. Foram
produzidos 320 módulos; KMDs r38p0/r38p1/r44p1 existem no staging.
- Config estática: `CONFIG_KSU_NEXT=y`, `CONFIG_KSU_SUSFS=y`,
  `CONFIG_MALI_MIDGARD_R38P0=m`, `R38P1=m`, `R44P1=m` e
  `CONFIG_MALI_VERSION_SELECTOR=y`.
- Imagens: Image `00fec11262a531fd1075d20698dd8e35f643c1cdce1f33f99c4a08986dc78f22`,
  Image.gz `4c4152e586af5214021be50cba009bf68f2ccaa531632303f95deda6f21c9603`,
  DTB `2846e110fd19ab0b5766fd33b03c8a0225661d247ef734dee20e43d64394e1b8`.
- Pacote experimental: `packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-GPU1092-EXPERIMENTAL-20260813-0406.zip`, SHA256
  `e737a647875cccc6d1a27de6c9396c59b41b5ffca608e72ffc6634772329d8e7`.
- Rollback baseline: `packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip`, SHA256
  `3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4`.

Os dois ZIPs passaram `unzip -t`, `verify-package.sh` e `sha256sum -c
packages/SHA256SUMS`. A estrutura é o AnyKernel3 oficial Floppy (Image,
vendor_boot e DTBOs r9s/o1s/p3s/t2s), portanto é compatível estruturalmente
com o fluxo OrangeFox manual já usado pela baseline. Isso não é flash/boot
testado.
