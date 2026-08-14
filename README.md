# ⚡ FloppyOC

> Experimental kernel engineering for Samsung Galaxy S21 Exynos 2100.

**Platform:** Exynos 2100 · Mali-G78 MP14 · Linux 5.4

---

## 🚦 Project Dashboard

| Area | Status | Flash? |
|---|---|---|
| Floppy 949 baseline | ✅ KNOWN-GOOD | ✅ rollback |
| FloppyOC V1 1092 | ⚠️ BLOCKED | ❌ |
| Physical G3D telemetry | 🧪 IN DEVELOPMENT | ❌ |
| FloppyOC V2 1092 | ⏳ WAITING | ❌ |
| GPU DVFS / PM QoS | 📋 PLANNED | ❌ |
| MIF / DSU | 📋 PLANNED | ❌ |
| Scheduler / EMS | 📋 PLANNED | ❌ |
| Memory / ZRAM | 📋 PLANNED | ❌ |
| CPU OC | 🚫 NOT READY | ❌ |

---

## 🎯 Current Mission

Prove the physical G3D clock before increasing it.

`GPEX → CAL → ACPM → VCLK → PLL_G3D → physical clock`

**A sysfs frequency alone is not proof of physical overclock.**

---

## 🌿 Development lanes

- `main` — reviewed baseline
- `debug/g3d-telemetry` — physical clock instrumentation
- `gpu/1092-v2` — experimental GPU OC
- `perf/integration` — performance stack
- `extreme/experimental` — extreme OC experiments

---

## 📦 Before flashing

- `docs/STATUS.md`
- `docs/ARTIFACTS.md`
- `docs/PACKAGING.md`
- `docs/TEST-MATRIX.md`

A successful build is not automatically flashable.

---

## 🤖 AI development

Qwen/Codex/agents must read `AGENTS.md`.

**One technical concept per commit.**

Canonical imported source: \`cc6540be7336f866e02a39467fb63f990f2104a9\`
