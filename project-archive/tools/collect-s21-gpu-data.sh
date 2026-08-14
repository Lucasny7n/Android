#!/usr/bin/env bash
# Read-only evidence collection for a physical Galaxy S21 Exynos 2100.
# It never writes to the device, changes clocks, invokes reboot, or uses flash.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
evidence_root="$project_root/evidence/runtime/baseline-device"
timestamp=$(date -Iseconds | tr ':+' '__')

fail() {
    printf 'BLOCKED: %s\n' "$*" >&2
    exit 2
}

command -v adb >/dev/null 2>&1 || fail "adb não está disponível no PATH"
mkdir -p "$evidence_root"
mapfile -t devices < <(adb devices -l | awk 'NR > 1 && $2 == "device" { print $1 }')
(( ${#devices[@]} == 1 )) || fail "é necessário exatamente um aparelho autorizado em estado device; encontrados: ${#devices[@]}"
serial=${devices[0]}
[[ "$serial" != emulator-* ]] || fail "emulador detectado; nenhum S21 físico será coletado"

run_shell() {
    adb -s "$serial" shell "$1" 2>&1 || true
}

props=$(run_shell getprop)
if ! printf '%s\n' "$props" | grep -Eqi 'exynos.?2100|s5e9840'; then
    printf '%s\n' "$props" > "$evidence_root/rejected-${timestamp}-getprop.txt"
    fail "o aparelho não se identificou como Exynos 2100/S5E9840; evidência salva sem alterar o aparelho"
fi

out="$evidence_root/s21-exynos2100-${serial//[^A-Za-z0-9._-]/_}-${timestamp}"
mkdir -p "$out"
printf '%s\n' "$serial" > "$out/serial.txt"
printf '%s\n' "$props" > "$out/getprop.txt"
run_shell 'uname -a; id; getconf LONG_BIT 2>/dev/null || true' > "$out/system.txt"
adb devices -l > "$out/adb-devices-l.txt"

collect_path() {
    local label=$1 path=$2
    {
        printf '%s\n' "# path: $path"
        run_shell "if [ -r '$path' ]; then cat '$path'; else echo '__UNREADABLE_OR_ABSENT__'; fi"
    } > "$out/$label.txt"
}

collect_tree() {
    local label=$1 root=$2
    {
        printf '%s\n' "# tree: $root"
        run_shell "if [ -d '$root' ]; then find '$root' -maxdepth 3 -type f 2>/dev/null | sort | while IFS= read -r f; do echo \"### \$f\"; cat \"\$f\" 2>&1; done; else echo '__ABSENT__'; fi"
    } > "$out/$label.txt"
}

collect_path g3d-fv-table /sys/kernel/fvmap/fv_tables/g3d_fv_table
collect_tree exynos-uv /sys/kernel/exynos_uv
collect_tree kernel-gpu /sys/kernel/gpu
collect_tree mali-platform /sys/devices/platform/18500000.mali
collect_tree gpu-devfreq /sys/class/devfreq
collect_tree thermal-zones /sys/class/thermal
collect_tree cooling-devices /sys/class/thermal
run_shell 'dmesg | grep -Ei "mali|g3d|gpu|acpm|fvmap|asv|thermal|tmu|fault|reset|mmu"' > "$out/dmesg-relevant.txt"

(
    cd "$out"
    sha256sum ./* > SHA256SUMS
)
archive="$evidence_root/$(basename -- "$out").tar.gz"
tar -C "$evidence_root" -czf "$archive" "$(basename -- "$out")"
sha256sum "$archive" > "$archive.sha256"
printf 'PASS: %s\nARCHIVE: %s\n' "$out" "$archive"
