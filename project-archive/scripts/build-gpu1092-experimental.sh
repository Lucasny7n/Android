#!/usr/bin/env bash
# Build the isolated experimental G3D-1092 branch with Floppy's official pipeline.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
baseline_root="$project_root/src/floppy"
build_root="$project_root/build/floppy-gpu1092-source"
toolchain="$project_root/tools/toolchains/aospclang"
baseline=af9e70e6af7aa7f66903d883cd677b9147424ed1
branch=floppy-exynos2100-g3d-1092-test
timestamp=$(date -Iseconds | tr ':+' '__')
log_dir="$project_root/logs/build"
mkdir -p "$log_dir"
log="$log_dir/build-gpu1092-${timestamp}.log"

[[ -e "$build_root/.git" ]] || { printf 'BLOCKED: worktree experimental ausente.\n' >&2; exit 2; }
[[ "$(git -C "$build_root" branch --show-current)" == "$branch" ]] || {
    printf 'BLOCKED: branch experimental incorreta.\n' >&2; exit 2;
}
[[ "$(git -C "$build_root" merge-base HEAD "$baseline")" == "$baseline" ]] || {
    printf 'BLOCKED: worktree não descende da base Floppy exigida.\n' >&2; exit 2;
}
[[ -z "$(git -C "$build_root" status --porcelain)" ]] || {
    printf 'BLOCKED: worktree experimental não está limpo.\n' >&2; exit 2;
}
[[ -x "$toolchain/bin/clang" ]] || { printf 'BLOCKED: toolchain r596125 ausente.\n' >&2; exit 2; }
"$toolchain/bin/clang" --version | grep -q '22.0.2' || {
    printf 'BLOCKED: clang não reporta 22.0.2.\n' >&2; exit 2;
}

git -C "$build_root" submodule update --init --depth 1 build/mkbootimg
export PATH="$project_root/tools/build-bin:$PATH"
export CLANG_TYPE=custom
export CUST_DIR="$toolchain"
export WP=/mnt/build
printf 'Build log: %s\n' "$log"
printf 'Policy: nice=10 ionice=idle jobs=10 (nproc shim)\n' | tee "$log"

# The original build script cannot resolve a source path containing spaces.
# This private mount namespace exposes only this worktree as /mnt; it does not
# touch host mounts, desktop state, or the clean forensic baseline worktree.
bwrap --die-with-parent \
    --ro-bind / / \
    --bind "$build_root" /mnt \
    --ro-bind "$toolchain" /srv \
    --tmpfs /tmp \
    --proc /proc \
    --dev /dev \
    --chdir /mnt \
    --setenv PATH "$PATH" \
    --setenv CLANG_TYPE custom \
    --setenv CUST_DIR /srv \
    --setenv WP /mnt/build \
    --setenv USE_CCACHE 0 \
    -- nice -n 10 ionice -c 3 bash build/ckbuild.sh kclq 2>&1 | tee -a "$log"
printf 'PASS: build oficial experimental concluída.\n'
