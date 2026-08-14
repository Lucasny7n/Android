# 1091 MHz G3D feasibility audit

## Result

**BLOCKED: no 1091 MHz OPP was added.** This is a deliberate safety result,
not an incomplete string replacement. The exact 1091 MHz request cannot be
implemented as a valid, voltage-backed Exynos2100 G3D OPP from the kernel
source alone.

## Evidence in Floppy `af9e70e`

1. `drivers/soc/samsung/cal-if/exynos2100/cmucal-node.c` has the G3D PLL
   table `949, 858, 767, 676, 585, 494, 403, 312, 221, 130, 100 MHz`.
   The 949 entry is `PLL_RATE_MPS(949000000, 73, 2, 0)`.
2. The Exynos2100 G3D PLL register description exports only `DIV_P`, `DIV_M`,
   and `DIV_S`. Unlike PLLs with fractional support, there is no G3D `DIV_F`
   field. The existing table therefore uses integer M/P/S rates: with the
   26 MHz reference, `M=73,P=2,S=0` yields 949 MHz and the next simple
   integer point `M=84,P=2,S=0` is **1092 MHz**, not 1091 MHz.
3. The active GPU DTS table has ten rows up to 949 MHz, max-clock and
   max-clock-limit are 949000, and thermal cooling has the explicit 949/858/
   767 progression. The 949 implementation correctly touches all of these
   paths, including runtime unlock and max-lock reporting.
4. Mali platform initialization calls `cal_dfs_get_rate_asv_table()` and only
   initializes a DTS DVFS row when `cal_freq == dts_row_frequency`. It does
   not synthesize a voltage for a DTS-only row.
5. `drivers/soc/samsung/cal-if/fvmap.c` copies the frequency/voltage map from
   ACPM-owned SRAM at boot. The actual G3D ASV/FVMAP curve, including the
   per-device voltage for 949 MHz, is consequently not encoded in this git
   tree and cannot be inferred safely here.

## What was not fabricated

- No `949000` value was replaced.
- No nominal 1091/1092 voltage was invented or copied from 949 MHz.
- No FVMAP row, ACPM protocol, CAL table, PM QoS limit, GPU lock, cooling
  state, thermal state, or UV interface was altered to pretend that firmware
  accepts an unknown level.
- `/sys/kernel/exynos_uv`, KernelSU Next, SUSFS, the Mali selector, GPU clamp,
  and all existing Floppy controls remain untouched in the clean worktree.

## Runtime evidence availability

`adb devices -l` reported only `emulator-5556` (`sdk_gphone64_x86_64`), not a
Galaxy S21 / Exynos2100. Therefore `/sys/kernel/fvmap/fv_tables/g3d_fv_table`,
actual 949 MHz voltage, actual supported levels, GPU lock behavior, and all
1091 MHz runtime/thermal/benchmark stages are **NOT TESTED**.

## Required evidence before a safe implementation can continue

1. A connected, identified Galaxy S21-series Exynos2100 booted on this exact
   base, with a saved read-only capture of its G3D FVMAP table and GPU sysfs.
2. Evidence that ACPM/FVMAP accepts an additional G3D level and the exact
   frequency it represents. If the hardware only supports integer M/P/S,
   the requested label must be reconciled with actual 1092 MHz clocking.
3. A per-device conservative voltage derivation validated against the captured
   949 MHz ASV point; an unsupported FVMAP/firmware level cannot be supplied
   safely by a DTS voltage literal.
4. CLI-only staged testing on the phone: boot, available frequencies, locks,
   thermal/cooling states, idle/UI, short graphics load, benchmark, and
   sustained 3D monitoring with an immediate stop on GPU fault/reset/oops.

Until all four conditions are satisfied, producing a flashable "1091 MHz"
package would be misleading and could damage or destabilize the device.
