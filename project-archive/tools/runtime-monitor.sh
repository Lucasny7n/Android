#!/usr/bin/env bash
# Read-only GPU1092 runtime monitor. It never flashes, reboots, or changes clocks.
set -euo pipefail

usage() {
    printf 'Uso: %s --serial SERIAL [--interval SEGUNDOS] [--samples N] [--require-1092]\n' "$0" >&2
    exit 2
}

serial=
interval=2
samples=60
require_1092=0
while (($#)); do
    case $1 in
        --serial) serial=${2:-}; shift 2 ;;
        --interval) interval=${2:-}; shift 2 ;;
        --samples) samples=${2:-}; shift 2 ;;
        --require-1092) require_1092=1; shift ;;
        *) usage ;;
    esac
done
[[ -n "$serial" ]] || usage
[[ "$serial" != emulator-* ]] || { printf 'BLOCKED: emulador não é alvo.\n' >&2; exit 2; }
command -v adb >/dev/null 2>&1 || { printf 'BLOCKED: adb ausente.\n' >&2; exit 2; }
[[ "$interval" =~ ^[1-9][0-9]*$ && "$samples" =~ ^[1-9][0-9]*$ ]] || usage

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
out="$project_root/evidence/runtime/monitor-${serial//[^A-Za-z0-9._-]/_}-$(date -Iseconds | tr ':+' '__').log"
mkdir -p "$(dirname -- "$out")"

adb -s "$serial" get-state 2>/dev/null | grep -qx device || {
    printf 'BLOCKED: serial não está em estado device.\n' >&2; exit 2;
}

{
    printf '# GPU1092 read-only monitor\n'
    printf '# serial=%s started=%s interval=%s samples=%s require_1092=%s\n' \
        "$serial" "$(date -Iseconds)" "$interval" "$samples" "$require_1092"
    adb -s "$serial" shell '
        getprop ro.product.model
        getprop ro.soc.model
        uname -a
        for p in /sys/kernel/fvmap/fv_tables/g3d_fv_table \
                 /sys/kernel/fvmap/fv_tables/g3d_oc1092_status \
                 /sys/kernel/exynos_uv/gpu_uv_percent \
                 /sys/kernel/gpu/gpu_unlock /sys/kernel/gpu/gpu_oc1092 \
                 /sys/kernel/gpu/gpu_freq_table /sys/kernel/gpu/gpu_clock \
                 /sys/devices/platform/18500000.mali/asv_table \
                 /sys/devices/platform/18500000.mali/time_in_state; do
            [ -r "$p" ] || continue
            echo "### $p"; cat "$p" 2>&1
        done
    ' 2>&1
} > "$out"

for ((i = 1; i <= samples; i++)); do
    {
        printf '\n===== sample=%d time=%s =====\n' "$i" "$(date -Iseconds)"
        adb -s "$serial" shell '
            for p in /sys/kernel/fvmap/fv_tables/g3d_fv_table \
                     /sys/kernel/fvmap/fv_tables/g3d_oc1092_status \
                     /sys/kernel/gpu/gpu_clock /sys/kernel/gpu/gpu_freq_table \
                     /sys/kernel/gpu/gpu_unlock /sys/kernel/gpu/gpu_oc1092 \
                     /sys/devices/platform/18500000.mali/clock \
                     /sys/devices/platform/18500000.mali/utilization \
                     /sys/devices/platform/18500000.mali/time_in_state; do
                [ -r "$p" ] || continue
                echo "### $p"; cat "$p" 2>&1
            done
            for p in /sys/class/thermal/thermal_zone*/type; do
                base=${p%/type}; [ -r "$base/temp" ] || continue
                echo "### $base"; cat "$p" "$base/temp" 2>&1
            done
        ' 2>&1 || true
        adb -s "$serial" shell 'dmesg | grep -Ei "mali|g3d|gpu|fault|reset|mmu|oops|panic|watchdog|thermal|acpm" | tail -n 160' 2>&1 || true
    } >> "$out"
    sleep "$interval"
done
if awk '
    /^### \/sys\/kernel\/fvmap\/fv_tables\/g3d_fv_table$/ { table=1; next }
    /^### / { table=0 }
    table && /^[[:space:]]*1092000([[:space:]]|$)/ { found=1 }
    END { exit !found }
' "$out"; then
    printf 'TABLE_CONTAINS_1092=YES\n' | tee -a "$out"
else
    printf 'TABLE_CONTAINS_1092=NO\n' | tee -a "$out"
fi
if awk '
    /^### \/sys\/kernel\/gpu\/gpu_clock$/ ||
    /^### \/sys\/devices\/platform\/18500000\.mali\/clock$/ { clock=1; next }
    /^### / { clock=0 }
    clock && /^[[:space:]]*1092000[[:space:]]*$/ { found=1 }
    END { exit !found }
' "$out"; then
    printf 'CURRENT_CLOCK_1092=YES\n' | tee -a "$out"
    observed=1
else
    printf 'CURRENT_CLOCK_1092=NO\n' | tee -a "$out"
    observed=0
fi
sha256sum "$out" > "$out.sha256"
if ((require_1092 && !observed)); then
    printf 'FAIL: 1092 MHz não foi observado; log read-only salvo em %s\n' "$out" >&2
    exit 1
fi
printf 'PASS: monitoramento read-only salvo em %s (current_clock_1092=%s)\n' "$out" "$observed"
