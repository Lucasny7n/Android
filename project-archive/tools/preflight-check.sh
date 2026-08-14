#!/usr/bin/env bash
# Static, read-only gate before a build or a human flash decision.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$project_root/src/floppy"
target=af9e70e6af7aa7f66903d883cd677b9147424ed1
failures=0

check() {
    local label=$1
    shift
    if "$@"; then
        printf 'PASS  %s\n' "$label"
    else
        printf 'FAIL  %s\n' "$label" >&2
        failures=$((failures + 1))
    fi
}

[[ -d "$source_root/.git" ]] || { printf 'BLOCKED: fonte ausente: %s\n' "$source_root" >&2; exit 2; }
check 'Floppy HEAD exato' test "$(git -C "$source_root" rev-parse HEAD)" = "$target"
check 'Floppy fonte limpa' test -z "$(git -C "$source_root" status --porcelain)"
check 'diff --check limpo' git -C "$source_root" diff --check
check 'KSUNext habilitado' grep -qx 'CONFIG_KSU_NEXT=y' "$source_root/arch/arm64/configs/ksu.config"
check 'SUSFS habilitado' grep -qx 'CONFIG_KSU_SUSFS=y' "$source_root/arch/arm64/configs/ksu.config"
check 'SUSFS v2.2.0 identificado' grep -qx '#define SUSFS_VERSION "v2.2.0"' "$source_root/include/linux/susfs.h"
check '949 MHz G3D PLL preservado' grep -q 'PLL_RATE_MPS(949000000, 73, 2, 0)' "$source_root/drivers/soc/samsung/cal-if/exynos2100/cmucal-node.c"
check '949 MHz DTS preservado' grep -q '949000 78  95 5' "$source_root/arch/arm64/boot/dts/exynos/exynos2100.dts"
check '858 MHz stock ceiling preservado' grep -q 'gpu_stock_max_clock = <858000>' "$source_root/arch/arm64/boot/dts/exynos/exynos2100.dts"
check 'Mali r38p0 presente' test -d "$source_root/drivers/gpu/arm/bv_r38p0"
check 'Mali r38p1 presente' test -d "$source_root/drivers/gpu/arm/bv_r38p1"
check 'Mali r44p1 presente' test -d "$source_root/drivers/gpu/arm/v_r44p1"

if grep -Eq '1091|1092' "$source_root/arch/arm64/boot/dts/exynos/exynos2100.dts"; then
    printf 'INFO  nível ~1,09 GHz presente no DTS; requer validação FVMAP/ACPM específica.\n'
else
    printf 'INFO  nenhum nível ~1,09 GHz foi introduzido sem FVMAP/ACPM validada.\n'
fi

if (( failures )); then
    printf 'RESULT: FAIL (%d checks)\n' "$failures" >&2
    exit 1
fi
printf 'RESULT: PASS\n'
