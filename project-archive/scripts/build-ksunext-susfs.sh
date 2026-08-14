#!/usr/bin/env bash
# Reproduce the official Floppy Testing KSUNext-SUSFS pipeline at reduced host priority.
# A disposable worktree protects src/floppy, which remains the clean forensic baseline.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$project_root/src/floppy"
build_root="$project_root/build/floppy-build"
toolchain="$project_root/tools/toolchains/aospclang"
target=af9e70e6af7aa7f66903d883cd677b9147424ed1
timestamp=$(date -Iseconds | tr ':+' '__')
log_dir="$project_root/logs/build"
mkdir -p "$log_dir"
log="$log_dir/build-${timestamp}.log"

[[ "$(git -C "$source_root" rev-parse HEAD)" == "$target" ]] || { printf 'BLOCKED: src/floppy não está em %s\n' "$target" >&2; exit 2; }
[[ -z "$(git -C "$source_root" status --porcelain)" ]] || { printf 'BLOCKED: src/floppy não está limpo.\n' >&2; exit 2; }
[[ -x "$toolchain/bin/clang" ]] || { printf 'BLOCKED: toolchain r596125 ausente.\n' >&2; exit 2; }
"$toolchain/bin/clang" --version | grep -q '22.0.2' || { printf 'BLOCKED: clang não reporta 22.0.2.\n' >&2; exit 2; }

if [[ ! -e "$build_root/.git" ]]; then
    git -C "$source_root" worktree add -b floppy-exynos2100-oc-build "$build_root" "$target"
fi
[[ "$(git -C "$build_root" rev-parse HEAD)" == "$target" ]] || { printf 'BLOCKED: worktree não corresponde à base.\n' >&2; exit 2; }
git -C "$build_root" submodule update --init --depth 1 build/mkbootimg
[[ -z "$(git -C "$build_root" diff -- build/ckbuild.sh)" ]] || {
    printf 'BLOCKED: build/ckbuild.sh no worktree de build foi alterado.\n' >&2
    exit 2
}

export PATH="$project_root/tools/build-bin:$PATH"
export CLANG_TYPE=custom
export CUST_DIR="$toolchain"
export WP=/mnt/build
printf 'Build log: %s\n' "$log"
printf 'Policy: nice=10 ionice=idle jobs=10 (nproc shim)\n' | tee "$log"

# Linux 5.4 resolves source paths before testing for spaces. Bubblewrap makes
# the existing WorkspaceAI worktree available as /mnt only inside this child
# mount namespace, so the unmodified official ckbuild.sh uses /mnt paths. All
# real source/output bytes stay under PROJECT_ROOT; no host mount, root
# permission, or GUI operation occurs.
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
printf 'PASS: build oficial concluída; use prepare-package.sh para materializar artefatos.\n'
