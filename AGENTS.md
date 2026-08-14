# 🤖 AGENTS.md

## Mandatory rules

1. Never develop directly on main.
2. One technical concept per commit.
3. Inspect complete diff before commit.
4. Never fabricate tests.
5. Never claim hardware testing unless actually performed.
6. Never fabricate Signed-off-by.
7. Preserve upstream attribution.
8. Experimental OC stays disabled by default.
9. Never remove thermal protections.
10. Do not combine Mali KMD updates with OC.
11. Keep scheduler/MM/display/GPU experiments separate.
12. Performance changes require A/B tests.
13. Flashable builds require rollback documentation.
14. Update STATUS.md only from real results.
15. STOP after each meaningful commit for external review.

## Commit style

`gpu: exynos: add physical G3D clock telemetry`

`soc: samsung: expose ACPM G3D rate readback`

`arm64: dts: exynos2100: prepare experimental 1092 MHz level`

Commit body must include problem, mechanism, source, tests, risk and rollback.
