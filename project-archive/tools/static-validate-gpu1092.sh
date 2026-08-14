#!/usr/bin/env bash
# Static-only validation for the isolated G3D 1092 MHz experimental branch.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$project_root/build/floppy-gpu1092-source"
dts="$source_root/arch/arm64/boot/dts/exynos/exynos2100.dts"
dtb="$source_root/out/arch/arm64/boot/dts/exynos/exynos2100.dtb"
errors=0

pass() { printf 'PASS  %s\n' "$1"; }
fail() { printf 'FAIL  %s\n' "$1" >&2; errors=$((errors + 1)); }
require() {
    local label=$1
    shift
    if "$@"; then pass "$label"; else fail "$label"; fi
}
count_rows() { sed -n "/$1 = </,/>;/p" "$dts" | grep -Ec '^[[:space:]]*[0-9]+[[:space:]]'; }
freqs_in_order() { sed -n '/gpu_dvfs_table = </,/>;/p' "$dts" | awk '/^[[:space:]]*[0-9]+[[:space:]]/ { print $1 }' | tr '\n' ' '; }

[[ -e "$source_root/.git" ]] || { printf 'BLOCKED: worktree experimental ausente.\n' >&2; exit 2; }
require 'branch experimental selecionada' test "$(git -C "$source_root" branch --show-current)" = floppy-exynos2100-g3d-1092-test
require 'worktree experimental limpo' test -z "$(git -C "$source_root" status --porcelain)"
require 'git diff --check limpo' git -C "$source_root" diff --check
require 'DTS possui 11 linhas DVFS' test "$(count_rows gpu_dvfs_table)" -eq 11
require 'DTS possui 11 linhas PM QoS' test "$(count_rows gpu_cl_pmqos_table)" -eq 11
require 'sequência DVFS integral' test "$(freqs_in_order)" = '1092000 949000 858000 767000 676000 585000 494000 403000 312000 221000 130000 '
require 'PLL G3D 1092 normal M84/P2/S0' grep -q 'PLL_RATE_MPS(1092000000, 84, 2, 0)' "$source_root/drivers/soc/samsung/cal-if/exynos2100/cmucal-node.c"
require 'PLL G3D 1092 EVT0 M84/P2/S0' grep -q 'PLL_RATE_MPS(1092000000, 84, 2, 0)' "$source_root/drivers/soc/samsung/cal-if/exynos2100_evt0/cmucal-node.c"
require 'FVMAP usa 925000 uV' grep -q '#define G3D_OC1092_VOLT.*925000U' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'FVMAP requer 10 níveis conhecidos antes da extensão' grep -q 'G3D_BASE_LEVELS.*(10U)' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'FVMAP publica 11 níveis somente após escrever as entradas' grep -q 'num_of_lv = G3D_OC1092_LEVELS' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'FVMAP atualiza máximo compartilhado' grep -q 'max_rate = G3D_OC1092_RATE' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'FVMAP recusa falta de espaço antes do próximo objeto' grep -q 'next_offset < table_end + sizeof' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'ACPM recebe frequência kHz via FREQ_REQ' grep -q 'config.cmd\[1\] = (unsigned int)rate' "$source_root/drivers/soc/samsung/cal-if/acpm_dvfs.c"
require 'runtime só aceita OPP exposto pelo CAL' grep -q 'CAL is the authority for usable OPPs' "$source_root/drivers/gpu/arm/exynos/frontend/gpex_clock.c"
require 'pedido de clock confere rate físico' grep -q 'hardware reports %d kHz' "$source_root/drivers/gpu/arm/exynos/frontend/gpex_clock.c"
require 'OC de terceiro estágio existe' grep -q 'gpu_oc1092' "$source_root/drivers/gpu/arm/exynos/frontend/gpex_clock_sysfs.c"
require 'unlock preserva teto 949' grep -q 'gpu_unlock_max_clock = <949000>' "$dts"
require 'teto de hardware 1092 no DTS' grep -q 'gpu_max_clock = <1092000>' "$dts"
require 'thermal inicia em 1092 e reduz para 949' grep -q 'gpu_temp_throttling = <1092000 949000 949000 949000 858000 767000>' "$dts"
require 'hispeed interativo permanece 676' grep -q 'interactive_info = <676000 60 0>' "$dts"
require 'UV Exynos preservado' grep -q 'CONFIG_SOC_EXYNOS2100_UNDERVOLT' "$source_root/drivers/soc/samsung/cal-if/fvmap.c"
require 'KSU Next selecionado' grep -qx 'CONFIG_KSU_NEXT=y' "$source_root/arch/arm64/configs/ksu.config"
require 'SUSFS selecionado' grep -qx 'CONFIG_KSU_SUSFS=y' "$source_root/arch/arm64/configs/ksu.config"
require 'SUSFS v2.2.0' grep -qx '#define SUSFS_VERSION "v2.2.0"' "$source_root/include/linux/susfs.h"
for kmd in bv_r38p0 v_r38p1 v_r44p1; do
    require "Mali KMD ${kmd}" test -d "$source_root/drivers/gpu/arm/$kmd"
done
require 'Kbuild comum usa clock frontend' grep -q 'gpex_clock.o' "$source_root/drivers/gpu/arm/exynos/Kbuild"
require 'Kbuild comum usa DVFS externo' grep -q 'gpex_dvfs_external.o' "$source_root/drivers/gpu/arm/exynos/Kbuild"
require 'DTB experimental materializado' test -s "$dtb"
if [[ -s "$dtb" ]]; then
    require 'DTB contém propriedade gpu_unlock_max_clock' grep -aq 'gpu_unlock_max_clock' "$dtb"
    require 'DTB contém 1092000 em big-endian' bash -c "xxd -p '$dtb' | tr -d '\\n' | grep -q 0010a9a0"
fi
require 'Module.symvers materializado' test -s "$source_root/out/Module.symvers"
for kmod in mali_kbase_r38p0.ko mali_kbase_r38p1.ko mali_kbase_r44p1.ko; do
    require "módulo ${kmod} materializado" test -s "$(find "$source_root/out/drivers/gpu/arm" -name "$kmod" -print -quit)"
done
require 'config final KSU Next' grep -qx 'CONFIG_KSU_NEXT=y' "$source_root/out/.config"
require 'config final SUSFS' grep -qx 'CONFIG_KSU_SUSFS=y' "$source_root/out/.config"

if ((errors)); then
    printf 'RESULT: FAIL (%d falhas estáticas)\n' "$errors" >&2
    exit 1
fi
printf 'RESULT: PASS (static only; runtime hardware/ACPM acceptance remains NOT TESTED)\n'
