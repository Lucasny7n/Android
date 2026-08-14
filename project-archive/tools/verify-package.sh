#!/usr/bin/env bash
# Verify a package produced inside this project. It never flashes a device.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
package_dir="$project_root/packages"
package=${1:-}

if [[ -z "$package" ]]; then
    mapfile -t candidates < <(find "$package_dir" -maxdepth 1 -type f -name '*.zip' -print 2>/dev/null | sort)
    (( ${#candidates[@]} == 1 )) || { printf 'BLOCKED: informe um ZIP ou deixe exatamente um em packages/.\n' >&2; exit 2; }
    package=${candidates[0]}
fi
[[ -f "$package" ]] || { printf 'FAIL: pacote inexistente: %s\n' "$package" >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { printf 'BLOCKED: unzip ausente.\n' >&2; exit 2; }

printf 'PACKAGE: %s\n' "$package"
sha256sum "$package"
unzip -t "$package"
if [[ -f "$package.sha256" ]]; then
    (cd "$(dirname -- "$package")" && sha256sum -c "$(basename -- "$package").sha256")
else
    printf 'INFO: arquivo .sha256 ao lado do pacote não encontrado.\n'
fi
printf 'RESULT: PASS\n'
