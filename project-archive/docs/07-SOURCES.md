# Fontes

## Código primário

- FloppyKernel: https://github.com/FlopKernel-Series/flop_exynos2100_kernel
- Floppy 949 MHz: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/4f5b021d9c23ab02c724f90388b1566c681aed00
- Floppy thermal: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/59fef87a03826e5abe7bcd39179a7bf505a74d42
- Floppy runtime ceiling: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/df719bb76e24ce30bc9d58e97a6c32fc4be18045
- Floppy throttler protection: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/274922ce35b4b6789b37cf9c3ac1468c2482a282
- Floppy GPU clamp: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/091c2c61492f19a241efb88cc34b5db473342273
- Floppy hispeed correction: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/a697340ba8237c60104be5b60a5863b5de25174f
- ProtonKernel: https://github.com/ProtonKernel/Proton
- Exynos2100 correlato (xfwdrev): https://github.com/xfwdrev/android_kernel_samsung_ex2100

## Toolchain e LLVM

- AOSP clang repository: https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/
- AOSP archive usado pelo script Floppy:
  https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/mirror-goog-main-llvm-toolchain-source/clang-r596125.tar.gz
- LLVM documentation: https://llvm.org/docs/

## CAL, FVMAP, ACPM e Samsung

- Samsung Open Source portal: https://opensource.samsung.com/
- Google CAL reference (`cmucal-node.c`, somente comparação arquitetural):
  https://android.googlesource.com/kernel/gs/+/refs/tags/android-12.0.0_r0.17/drivers/soc/google/cal-if/gs101/cmucal-node.c
- Google CAL SFR reference (somente comparação arquitetural):
  https://android.googlesource.com/kernel/google-modules/soc/gs/+/204078758737776959ecc85c527a00fd2cabb62f/drivers/soc/google/cal-if/gs101/cmucal-sfr.c

## Root e empacotamento

- Samsung Open Source: https://opensource.samsung.com/
- Android Clang prebuilts: https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/
- LLVM: https://llvm.org/docs/
- KernelSU Next: https://github.com/KernelSU-Next/KernelSU-Next
- SUSFS: https://gitlab.com/simonpunk/susfs4ksu
- AnyKernel3 Exynos2100 usado pelo pipeline:
  https://github.com/FlopKernel-Series/AnyKernel3-exynos2100

Toda URL acima tem contexto e conclusão no `06-RESEARCH-LOG.md`; referências
Google de GS101 não são evidência de que Exynos2100 aceite um OPP 1092.

## Continuação GPU1092

- Coleta root primária SM-G991B (versionada localmente):
  `evidence/runtime/baseline-device/s21-exynos2100-RQCRA01QZ9J-2026-08-13T03_28_30-03_00/`
- Commit Floppy do OC 949: https://github.com/FlopKernel-Series/flop_exynos2100_kernel/commit/4f5b021d9c23ab02c724f90388b1566c681aed00
- Fonte Floppy FVMAP/CAL (commit base): https://github.com/FlopKernel-Series/flop_exynos2100_kernel/tree/af9e70e6af7aa7f66903d883cd677b9147424ed1/drivers/soc/samsung/cal-if
- Exemplo externo de FVMAP G3D com mais de 10 níveis (apenas evidência de
  formato, não de compatibilidade Exynos2100): https://gist.github.com/Piecuuu/390f776533c7fddc1278de3d1e2612bc

Não foi encontrada fonte primária que prove que o firmware ACPM de produção do
S21 aceite 1092 MHz. Esse limite é registrado como risco runtime, não omitido.
