#!/usr/bin/env bash
# Copy the official build artifact into packages/ and create checksums/metadata.
set -euo pipefail

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_root=$(CDPATH= cd -- "$script_dir/.." && pwd)
build_root="$project_root/build/floppy-build"
package_dir="$project_root/packages"
release_dir="$project_root/output/release"
mkdir -p "$package_dir"
mkdir -p "$release_dir"

mapfile -t zips < <(find "$build_root/build" -maxdepth 1 -type f -name '*.zip' -print 2>/dev/null | sort)
(( ${#zips[@]} == 1 )) || { printf 'BLOCKED: esperado exatamente um ZIP no worktree; encontrados: %d\n' "${#zips[@]}" >&2; exit 2; }
source_zip=${zips[0]}
dest="$package_dir/$(basename -- "$source_zip")"
cp -p -- "$source_zip" "$dest"
mapfile -t tars < <(find "$build_root/build" -maxdepth 1 -type f -name '*.tar' -print 2>/dev/null | sort)
for tarball in "${tars[@]}"; do
    cp -p -- "$tarball" "$package_dir/$(basename -- "$tarball")"
done

for artifact in \
    "$build_root/out/arch/arm64/boot/Image" \
    "$build_root/out/arch/arm64/boot/Image.gz" \
    "$build_root/out/arch/arm64/boot/dts/exynos/exynos2100.dtb"; do
    [[ -f "$artifact" ]] || { printf 'FAIL: artefato de kernel ausente: %s\n' "$artifact" >&2; exit 1; }
    cp -p -- "$artifact" "$release_dir/$(basename -- "$artifact")"
done
find "$build_root/build/images" -maxdepth 1 -type f -name '*.img' -exec cp -p -- {} "$release_dir/" \;

module_root=$(find "$build_root/modules_out/lib/modules" -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null || true)
{
    printf 'source_commit=%s\n' "$(git -C "$build_root" rev-parse HEAD)"
    if [[ -n "$module_root" ]]; then
        printf 'kernel_release=%s\n' "$(basename -- "$module_root")"
        printf 'module_count=%s\n' "$(find "$module_root" -type f -name '*.ko' | wc -l)"
        find "$module_root" -type f -name '*.ko' -printf '%P\n' | LC_ALL=C sort
    else
        # The official post.sh deliberately removes modules_out after embedding
        # selected modules in vendor_boot.  Preserve an auditable statement
        # rather than rerunning modules_install outside the official pipeline.
        printf 'kernel_release=not-materialized; official post.sh cleaned modules_out\n'
        printf 'module_count=not-materialized; see build log DEPMOD/modules.load\n'
        printf 'build_log=%s\n' "$(find "$project_root/logs/build" -maxdepth 1 -type f -name 'build-*.log' -printf '%p\n' | LC_ALL=C sort | tail -n 1)"
    fi
} > "$release_dir/MODULES-MANIFEST.txt"

(
    cd "$package_dir"
    find . -maxdepth 1 -type f \( -name '*.zip' -o -name '*.tar' \) -printf '%f\n' | LC_ALL=C sort | xargs -r sha256sum
) > "$package_dir/SHA256SUMS"
(
    cd "$package_dir"
    sha256sum -c SHA256SUMS
)
sha256sum "$dest" > "$dest.sha256"
md5sum "$dest" > "$dest.md5"
{
    printf 'source_zip=%s\n' "$source_zip"
    printf 'source_commit=%s\n' "$(git -C "$build_root" rev-parse HEAD)"
    printf 'created_at=%s\n' "$(date -Iseconds)"
    printf 'sha256=%s\n' "$(sha256sum "$dest" | awk '{print $1}')"
    printf 'oc_status=BLOCKED; package preserves the unmodified 949 MHz Floppy baseline\n'
    printf 'tar_count=%s\n' "${#tars[@]}"
    printf 'raw_release_dir=%s\n' "$release_dir"
} > "$dest.metadata"
"$project_root/tools/verify-package.sh" "$dest"
printf 'PASS: %s\n' "$dest"
