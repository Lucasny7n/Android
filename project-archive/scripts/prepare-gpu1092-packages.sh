#!/usr/bin/env bash
# Materialize the official AnyKernel artifact and the verified 949 MHz rollback.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
source_root="$project_root/build/floppy-gpu1092-source"
build_dir="$source_root/build"
package_dir="$project_root/packages"
release_dir="$project_root/output/release/gpu1092-20260813-0406"
baseline="$package_dir/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-20260813-0242.zip"
experimental="$package_dir/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-GPU1092-EXPERIMENTAL-20260813-0406.zip"
rollback="$package_dir/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip"
expected_commit=cc6540be7336

[[ "$(git -C "$source_root" rev-parse --short=12 HEAD)" == "$expected_commit" ]] || {
    printf 'BLOCKED: HEAD experimental inesperado.\n' >&2; exit 2;
}
[[ -z "$(git -C "$source_root" status --porcelain)" ]] || {
    printf 'BLOCKED: worktree experimental não está limpo.\n' >&2; exit 2;
}
source_zip="$build_dir/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-20260813-0406.zip"
[[ -s "$source_zip" ]] || { printf 'FAIL: ZIP oficial experimental ausente.\n' >&2; exit 1; }
[[ -s "$baseline" ]] || { printf 'FAIL: ZIP baseline 949 ausente.\n' >&2; exit 1; }

mkdir -p "$package_dir" "$release_dir"
cp -p -- "$source_zip" "$experimental"
cp -p -- "$baseline" "$rollback"

for artifact in \
    "$source_root/out/arch/arm64/boot/Image" \
    "$source_root/out/arch/arm64/boot/Image.gz" \
    "$source_root/out/arch/arm64/boot/dts/exynos/exynos2100.dtb"; do
    [[ -s "$artifact" ]] || { printf 'FAIL: artefato ausente: %s\n' "$artifact" >&2; exit 1; }
    cp -p -- "$artifact" "$release_dir/$(basename -- "$artifact")"
done
find "$build_dir/images" -maxdepth 1 -type f -name '*.img' -exec cp -p -- {} "$release_dir/" \;
find "$source_root/out/drivers/gpu/arm" -type f -name 'mali_kbase*.ko' -exec cp -p -- {} "$release_dir/" \;

{
    printf 'kind=EXPERIMENTAL GPU1092 AnyKernel/OrangeFox manual-test package\n'
    printf 'source_zip=%s\n' "$source_zip"
    printf 'source_commit=%s\n' "$(git -C "$source_root" rev-parse HEAD)"
    printf 'base_commit=af9e70e6af7aa7f66903d883cd677b9147424ed1\n'
    printf 'build_log=%s\n' "$project_root/logs/build/build-gpu1092-2026-08-13T04_06_32-03_00.log"
    printf 'runtime_status=NOT TESTED; do not claim stability or ACPM acceptance before manual test\n'
    printf 'rollback=%s\n' "$rollback"
} > "$experimental.metadata"
{
    printf 'kind=VERIFIED baseline 949 MHz rollback AnyKernel/OrangeFox package\n'
    printf 'source_package=%s\n' "$baseline"
    printf 'source_sha256=3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4\n'
    printf 'base_commit=af9e70e6af7aa7f66903d883cd677b9147424ed1\n'
    printf 'runtime_status=baseline artifact; not reflashed in this mission\n'
} > "$rollback.metadata"

for artifact in "$experimental" "$rollback"; do
    unzip -t "$artifact" >/dev/null
    sha256sum "$artifact" > "$artifact.sha256"
    md5sum "$artifact" > "$artifact.md5"
done
(
    cd "$package_dir"
    find . -maxdepth 1 -type f \( -name '*.zip' -o -name '*.tar' \) -printf '%f\n' |
        LC_ALL=C sort | xargs -r sha256sum
) > "$package_dir/SHA256SUMS"
(
    cd "$package_dir"
    sha256sum -c SHA256SUMS
)
"$project_root/tools/verify-package.sh" "$experimental"
"$project_root/tools/verify-package.sh" "$rollback"
printf 'PASS: experimental=%s\nPASS: rollback=%s\n' "$experimental" "$rollback"
