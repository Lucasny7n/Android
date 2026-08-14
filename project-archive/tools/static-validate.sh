#!/usr/bin/env bash
# Deterministic static checks.  It does not claim device/runtime validation.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$project_root/src/floppy"
build_root="$project_root/build/floppy-build"
dts="$source_root/arch/arm64/boot/dts/exynos/exynos2100.dts"
errors=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; errors=$((errors + 1)); }
require() {
    local label=$1
    shift
    if "$@"; then pass "$label"; else fail "$label"; fi
}

[[ -d "$source_root/.git" ]] || { printf 'BLOCKED: fonte Floppy ausente.\n' >&2; exit 2; }
require 'fonte Floppy limpa' test -z "$(git -C "$source_root" status --porcelain)"
require 'git diff --check limpo' git -C "$source_root" diff --check
require 'DTS possui 10 linhas DVFS' test "$(sed -n '/gpu_dvfs_table = </,/>;/p' "$dts" | grep -Ec '^[[:space:]]*[0-9]+[[:space:]]')" -eq 10
for mhz in 130 221 312 403 494 585 676 767 858 949; do
    if grep -Eq "^[[:space:]]*${mhz}000[[:space:]]" "$dts"; then pass "DVFS ${mhz} MHz"; else fail "DVFS ${mhz} MHz"; fi
done
require 'PLL G3D 949 (M=73/P=2/S=0)' grep -q 'PLL_RATE_MPS(949000000, 73, 2, 0)' "$source_root/drivers/soc/samsung/cal-if/exynos2100/cmucal-node.c"
require 'PLL G3D EVT0 949' grep -q 'PLL_RATE_MPS(949000000, 73, 2, 0)' "$source_root/drivers/soc/samsung/cal-if/exynos2100_evt0/cmucal-node.c"
require 'runtime ceiling 949' grep -q 'gpu_max_clock_limit = <949000>' "$dts"
require 'stock ceiling 858' grep -q 'gpu_stock_max_clock = <858000>' "$dts"
require 'thermal 949→858→767' grep -q 'gpu_temp_throttling = <949000 949000 949000 949000 858000 767000>' "$dts"
require 'GPU PM QoS table tem 10 linhas' test "$(sed -n '/gpu_cl_pmqos_table = </,/>;/p' "$dts" | grep -Ec '^[[:space:]]*[0-9]+[[:space:]]')" -eq 10
require 'interactive hispeed 676' grep -q 'interactive_info = <676000 60 0>' "$dts"
require 'GPU clamp sysfs preservado' grep -q 'gpu_clamp' "$source_root/drivers/gpu/arm/exynos/frontend/gpex_clock_sysfs.c"
require 'throttler protection preservada' grep -q 'throttlers_protection' "$source_root/kernel/ksysfs.c"
require 'UV Exynos preservado' grep -q 'CONFIG_SOC_EXYNOS2100_UNDERVOLT' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'KSUNext selecionado' grep -qx 'CONFIG_KSU_NEXT=y' "$source_root/arch/arm64/configs/ksu.config"
require 'SUSFS selecionado' grep -qx 'CONFIG_KSU_SUSFS=y' "$source_root/arch/arm64/configs/ksu.config"
require 'SUSFS v2.2.0' grep -qx '#define SUSFS_VERSION "v2.2.0"' "$source_root/include/linux/susfs.h"
for kmd in bv_r38p0 bv_r38p1 v_r38p1 v_r44p1; do
    if [[ -d "$source_root/drivers/gpu/arm/$kmd" ]]; then pass "Mali KMD $kmd"; else fail "Mali KMD $kmd"; fi
done

if grep -Eq '1091|1092' "$dts"; then
    printf 'FAIL  OPP ~1.09 GHz entrou sem remoção explícita deste bloqueio\n' >&2
    errors=$((errors + 1))
else
    printf 'BLOCKED  OPP 1092: ausente por falta de FVMAP/ASV/ACPM validado (decisão segura)\n'
fi

if [[ -f "$build_root/out/.config" ]]; then
    require 'config build KSU Next' grep -qx 'CONFIG_KSU_NEXT=y' "$build_root/out/.config"
    require 'config build SUSFS' grep -qx 'CONFIG_KSU_SUSFS=y' "$build_root/out/.config"
fi
if [[ -f "$build_root/out/arch/arm64/boot/dts/exynos/exynos2100.dtb" ]]; then
    pass 'DTB Exynos2100 materializado pela build'
fi
if [[ -f "$build_root/out/Module.symvers" ]]; then
    pass 'Module.symvers materializado (modpost passou até este ponto)'
fi

if ((errors)); then
    printf 'RESULT: FAIL (%d falhas estáticas)\n' "$errors" >&2
    exit 1
fi
printf 'RESULT: PASS com OPP 1092 explicitamente BLOCKED\n'
