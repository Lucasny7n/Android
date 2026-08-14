# Floppy Exynos2100 OC

Projeto forense e reproduzível para avaliar uma build `KSUNext-SUSFS` do
FloppyKernel para Galaxy S21 Series Exynos 2100, preservando a base
`af9e70e6af7aa7f66903d883cd677b9147424ed1` e investigando um topo G3D de
aproximadamente 1,09 GHz sem fabricar suporte de firmware, tensão ou runtime.

## Estado rápido

Consulte [STATUS.md](STATUS.md). A coleta root real do S21 foi validada e
removeu a lacuna da curva base: 949 MHz usa 825000 uV com `gpu_uv_percent=0`.
Há agora uma build **experimental** com caminho FVMAP/CAL/ACPM guardado de 11
níveis e um ZIP AnyKernel/OrangeFox rotulado `GPU1092-EXPERIMENTAL`. Isto é
`STATIC PASS` e `BUILD PASS`, **não** prova boot, aceitação do firmware ACPM
ou estabilidade: runtime permanece `NOT TESTED`.

## Navegação

- `docs/00-MIGRATION.md`: proveniência do trabalho anterior.
- `docs/05-PLAN.md`: fases, evidências e critérios.
- `docs/08-PROTON-AUDIT.md`: validação comparativa Floppy/Proton.
- `docs/09-GPU-OC-RESEARCH.md`: PLL, CAL, FVMAP, ACPM e ASV.
- `docs/19-FINAL-REPORT.md`: relatório de encerramento, atualizado ao final.
- `tools/`: coleta, preflight, verificação de pacote e monitor runtime.

## Artefato e integridade

Pacote experimental principal:
`packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-GPU1092-EXPERIMENTAL-20260813-0406.zip`.
O rollback explícito 949 MHz é
`packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip`.
Verifique todos os arquivos com:

```bash
cd '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
(cd packages && sha256sum -c SHA256SUMS)
./tools/verify-package.sh packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-GPU1092-EXPERIMENTAL-20260813-0406.zip
```

O resumo da build e os riscos experimentais estão em `docs/13-BUILD-REPORT.md`
e `docs/09-GPU-OC-RESEARCH.md`; não faça flash antes de ler
`docs/15-TEST-PLAN.md` e `docs/18-ROLLBACK.md`.

## Segurança e rollback

Não há flash automático. Consulte `docs/18-ROLLBACK.md` antes de usar qualquer
artefato. O projeto usa somente CLI/headless e não manipula a sessão gráfica.
