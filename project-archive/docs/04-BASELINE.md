# Baseline inicial

## Host de build

- Data inicial: 2026-08-13T02:02:52-03:00.
- CPUs lógicas: 12.
- Memória física: 15,5 GiB.
- Espaço livre no filesystem do WorkspaceAI: 53 GiB.
- Política de carga: `nice -n 10`, `ionice -c 3` e máximo inicial de 10 jobs
  (`nproc - 2`), ajustável se a pressão de memória exigir. Não haverá stress
  test no host.

## Floppy esperado

- URL: `https://github.com/FlopKernel-Series/flop_exynos2100_kernel.git`.
- Branch: `floppy-main`.
- Commit alvo: `af9e70e6af7aa7f66903d883cd677b9147424ed1`.
- Kernel declarado pelo usuário: 5.4.302.
- Variante alvo: `KSUNext-SUSFS / Testing`.

## Proton esperado

- URL: `https://github.com/ProtonKernel/Proton.git`.
- Branch: `testing`.
- Commit alvo: `79d7da625ff3fbfa0c84cdedb07a4dcdc055baf4`.

## Baseline congelado

### Floppy

- Clone oficial parcial em `src/floppy`, detached e limpo em
  `af9e70e6af7aa7f66903d883cd677b9147424ed1`.
- Commit: `media: mfc: Arm the NAL-Q timeout watchdog on queue start`,
  2026-08-11T23:32:05-03:00.
- `exynos2100-unified_defconfig` SHA256:
  `3a67c032df2b7cf6295b48ffba65b941967b23212c557f52899a60440d82adeb`.
- `ksu.config` SHA256:
  `a70f1504d0c9f14a7740d9bd77cad4a6df14523a1f94146b3477bdd2dc824270`.
- `droidspaces.config` SHA256:
  `4cf4235168f06019fda774e2daa6705a83d13f2e88f03793cb8a2276fcf621c1`.
- Submódulos declarados, inicialmente não inicializados: `build/mkbootimg`
  `d2bb0af5ba6d3198a3e99529c97eda1be0b5a093` e NetHunter firmware
  `50f2c42a77957999d216c2a7da62c58577be7cd1`. Somente `mkbootimg` é
  inicializado no worktree descartável de build; firmware NetHunter não é
  necessário para a variante alvo.

### Proton

- Clone oficial parcial em `src/references/proton`, detached e limpo em
  `79d7da625ff3fbfa0c84cdedb07a4dcdc055baf4`.
- Commit: `Revert "block: Do not allow boosters to adjusting scheduler"`,
  2026-04-06.

### Integração KSUNext-SUSFS estática

- O pipeline oficial recebe `k` e anuncia `KSUNext-SUSFS` / `KN` para build
  Testing.
- `CONFIG_KSU_NEXT=y`, `CONFIG_KSU=y`, `CONFIG_KSU_MANUAL_HOOK=y` e
  `CONFIG_KSU_SUSFS=y` estão no fragmento alvo.
- O `drivers/Makefile` seleciona exclusivamente `kernelsu/kernel/` quando
  `CONFIG_KSU_NEXT` está ativo; os diretórios alternativos SukiSU e XXKSU
  permanecem preservados, mas não são selecionados para esta variante.
- SUSFS identificado no fonte como `v2.2.0`.
- A integração em árvore do KernelSU Next não é um submódulo Git separado:
  seu `Kbuild` declara fallback `KSU_VERSION=33214` e
  `KSU_VERSION_TAG=v3.3.0-legacy-unofficial`. Logo, isso é identidade de build
  estática, não uma alegação de validação runtime.

### Mali e recursos preservados

Os diretórios `drivers/gpu/arm/bv_r38p0`, `bv_r38p1`, `v_r38p1` e `v_r44p1`
estão presentes. A validação estática não removeu nem trocou o seletor/KMD.

Resultado do baseline: **PASS**. O clone forense permanece imutável; builds
ocorrem somente em `build/floppy-build`.
