# Proton candidate audit

## Scope and method

- Floppy base: `af9e70e6af7aa7f66903d883cd677b9147424ed1` (`floppy-main`).
- Proton reference: `79d7da625ff3fbfa0c84cdedb07a4dcdc055baf4` (`testing`).
- The target-tree state, the individual Proton commits, and the final Floppy
  state were inspected. Direct patch identity was also checked where the
  Floppy import is a straight cherry-pick. A different file or a different
  commit title alone was never treated as a missing feature.

Status meanings: `ALREADY_PRESENT` is equivalent code already in Floppy;
`FLOPPY_BETTER` means Floppy has a later/more complete solution;
`PORT` requires a demonstrable net benefit and was not found in this audit;
`REJECT` is intentionally not ported because it is reverted upstream,
unvalidated, unsafe, or incompatible with Floppy policy.

## Candidates

| Proton commit | Purpose and affected files | Floppy equivalent / assessment | Status |
|---|---|---|---|
| `28f56e6354771c3c408b7678c65c46f9381fa066` | Make 949 MHz reachable through interactive DVFS; `arch/arm64/boot/dts/exynos/exynos2100.dts`. | Superseded by Floppy `4f5b021` plus `59fef87`, which add a runtime-toggleable 949 OPP and its thermal path. | FLOPPY_BETTER |
| `5a0ad7372355355c06c28ec0c991c816d9b9f9bf` | Add the 858 MHz thermal point before 767 MHz; Exynos2100 DTS. | Present in Floppy's `gpu_temp_throttling = <949000 949000 949000 949000 858000 767000>`. | ALREADY_PRESENT |
| `9184ab5e8f937d4e86321ca88f3db757b7c82ad8` | Honor a DT max GPU clock above CAL's stock limit; Exynos Mali clock code. | Included in Floppy as part of the 949 MHz runtime-unlock integration and guarded by the runtime ceiling. | FLOPPY_BETTER |
| `69acc1cf05cc79d1baed9e8f9c96a8ba943cf676` | Fix interactive hispeed floor; `drivers/gpu/arm/exynos/frontend/gpu_dvfs_governor.c`. | Direct import exists as `1118a016`; Floppy later tightened it in `a697340` so the governor can rise *above* hispeed rather than remain trapped. | FLOPPY_BETTER |
| `1b54584578d95319fd8c3fdb621565c5e87b9d5d` | Lower normal-profile ESG up-rate limit; Exynos2100 DTS. | Direct patch-equivalent import: Floppy `62a4e46` (stable patch-id `af1ab521`). | ALREADY_PRESENT |
| `1fa6059e4a5d4c2788af6eb16617ab509aceafa1` | Add foreground EMS wakeup/frequency boost; Exynos2100 DTS. | Direct import exists as Floppy `52ffa55`; final normal profile contains foreground frequency and wakeup boosts. | ALREADY_PRESENT |
| `1b4a964ee207eca5584b5ea0ad5aa73970b48f14` | Retune low GPU clocks and polling; Exynos2100 DTS. | Floppy's final 949-aware table polls at 12 ms (Proton target: 20 ms), preserves progressive thresholds, and does not force Proton's 949 sustained/Vulkan locks. | FLOPPY_BETTER |
| `4aa9e53bce8a10504791d58d7642caf376bca60` | Earlier aggressive GPU DTS tuning; Exynos2100 DTS. | Superseded by Floppy's later 949-aware DVFS, clamp, and thermal series. No independent runtime result establishes that the older tuning is better. | REJECT |
| `504463c99217654be681dfb9f873f1bf9480ba30` | Lower GPU interactive boost; Exynos2100 DTS. | Floppy uses a later balanced interactive policy together with the hispeed fix and runtime ceiling. Porting an isolated number would duplicate/conflict with that policy. | REJECT |
| `82781229f6e3c2f92c7cd675538f98d668b4849d` | RAM-aware watermark scaling; `mm/page_alloc.c`. | Direct patch-equivalent import: Floppy `dccc5f8` (stable patch-id `ea1282b4`), followed by Floppy-specific 6 GB floor/relaxation adjustments. | FLOPPY_BETTER |
| `aafb88bd9096d16b6b51dfead291090ff914d81e` | Reduce CFS wakeup/migration granularity; `kernel/sched/fair.c`. | Direct import exists as `9f598c0`; final Floppy subsequently uses 1.5 ms wakeup and 1 ms migration cost, versus this candidate's 2.5 ms and 2 ms. | FLOPPY_BETTER |
| `39f361f359314683ac413a034c3ecb62846fb572` | Later CFS tuning; `kernel/sched/fair.c`. | Floppy imported a related tuning (`b71c390`) and has a later, lower-latency final CFS policy. No benchmark demonstrates replacing it with Proton's intermediate values. | FLOPPY_BETTER |
| `bef9fdbe9dac678115187c32c591dedf9be9c812` | Faster EMS short-burst ramp; `kernel/sched/ems/energy_step.c`. | Floppy temporarily imported it (`09a64bf`) then explicitly reverted it (`aff16f2`). Reintroducing an explicitly reverted burst policy without device latency/power data is not justified. | REJECT |
| `4bb0f02622a200991859ad5f35681d264c442dd5` | Backport `support_uclamp` to EMSTune; EMS code and DTS policy. | Present in Floppy (`5b159ae`) with current uclamp support. | ALREADY_PRESENT |
| `b89d3cb7af75af1c7b0850b36090be23db9f3e0c` and `eea4e5e644c8118e8ac3915ae22d5858b6a74783` | Add fclamp infrastructure/policy; EMS code and DTS. | Proton's same series includes a later revert of `support_uclamp`; Floppy has its established uclamp policy. The unproven fclamp layer is not a safe additive port. | REJECT |
| `733ea96a20f36d9ad1326d94db480a8f89435666` | Enable EMS ontime for `foreground`; Exynos2100 DTS. | Floppy already provides the foreground wakeup/frequency boost from `52ffa55`. Stacking ontime without target measurements would alter placement policy twice. | REJECT |
| `649ad2d00d2b9d16dfd30c0b37355c747f4a1c8c` | Broad scheduler parameter retune; scheduler/EMS/DTS. | Superseded by the directly imported, then later adjusted Floppy CFS/EMS policy. Its broad scope prevents a safe isolated port. | REJECT |
| `930ad88fcf52ef5d9f8e648532888c8bad69106b` | Block userspace GPU max-clock clamps; `gpex_clock_sysfs.c`. | Direct patch-equivalent import: Floppy `d607896` (stable patch-id `2ab87364`), complemented by GPU clamp and runtime-ceiling handling. | FLOPPY_BETTER |
| `d97992ca6da244b518a5a1e435722f4f310291d1` | Block userspace CPU throttling daemons; treewide. | Present as Floppy `1aec9a7`, while retaining the existing safety mechanisms. | ALREADY_PRESENT |
| `4027b3455ed798ebcc50a92f73b830432bd0cb18` | Add async `kshrink_lruvecd`; vmscan/rmap/page-ext and staging driver. | Direct patch-equivalent import: Floppy `17076aa` (stable patch-id `ebcd7b71`). | ALREADY_PRESENT |
| `d07af448e8e6b0a133834a2ac2fa82c37e82081e` | Add async `kshrink_slabd`; reclaim and staging. | Not present, but it is a staging reclaim worker with no S21 runtime pressure/regression evidence in this run. | REJECT |
| `f70a46e0dbb81b12d9ab83187eff4ae8fb1e201a` | More aggressive MIF alt-DVFS; Exynos2100 DTS (and an unrelated `mi_grabacion.mp4`). | Floppy has a different later MIF curve. This candidate changes thresholds, hispeed, and an artifact in one commit; no target stutter/power data proves it better. | REJECT |
| `38a38753bce8a10504791d58d7642caf376bca60` | UFS small-burst performance thresholds; Exynos2100 DTS. | Absent: it adds `perf-count-l = <8>` and `perf-period-in-ms-l = <12>`. There is no S21 UFS latency, power, or error-recovery test here, so it is not a proven improvement. | REJECT |
| `754eac1cf1eaba1300a31f7c785d39bbadb7800e` and `3efcb9dd57ada62db9fa7c59334b97847410a3ff` | Protect I/O scheduler initialization/booster control; block layer. | Both are reverted by the Proton target's two immediate parents (`9190c40`, `79d7da6`). | REJECT |
| `b0f483c793b261fa17d0c512fc862ddb47faea31` and follow-up ADIOS commits | Add ADIOS I/O scheduler; block layer. | Proton target contains `[SQUASH] block: Revert ADIOS` (`dc2c0fa`). Do not reintroduce a reverted scheduler. | REJECT |
| `bbe08acea6a3f181e2fee09d67cbd300225f3caf` | Disable Samsung cooling `set_cur_state`; thermal cooling. | Proton itself reverted this (`812032a`). It weakens an essential thermal callback and violates the safety requirement. | REJECT |
| `40660660666fb6af24aded13138b110eca0ee34d` | Disable Samsung `mem_boost`; memory policy. | Removes vendor behavior rather than adding a demonstrated Exynos2100 improvement; no memory-pressure test supports it. | REJECT |

## Result

`PORT` candidates: **0**. The audited performance-oriented Proton work is
either already present, superseded by a later Floppy implementation, explicitly
reverted, or lacks the device-specific evidence needed to preserve Floppy
stability. No Proton code was ported.
