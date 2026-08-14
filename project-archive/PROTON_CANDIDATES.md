# Proton candidates — revalidated ledger

Scope: Proton `79d7da625ff3fbfa0c84cdedb07a4dcdc055baf4` versus Floppy
`af9e70e6af7aa7f66903d883cd677b9147424ed1`. This file is a decision ledger,
not a patch queue. A `PORT` needs target-specific benefit evidence; none met
that bar.

| # | Proton commit(s) | Finalidade / arquivos | Equivalente Floppy e decisão | Status |
|---:|---|---|---|---|
| 1 | `28f56e6` | 949 MHz alcançável pelo interactive DVFS; DTS | `4f5b021` + `59fef87` implementam OPP 949 runtime e thermal-aware. | FLOPPY_BETTER |
| 2 | `5a0ad73` | inserir 858 entre 949 e 767 no thermal; DTS | Tabela final é `949,949,949,949,858,767`. | ALREADY_PRESENT |
| 3 | `9184ab5` | respeitar max clock DTS acima de CAL; Mali | Integrado no caminho 949 e completado pelo ceiling runtime `df719bb`. | FLOPPY_BETTER |
| 4 | `69acc1c` | corrigir piso hispeed interativo; GPU governor | Patch-id de `1118a016` é idêntico; `a697340` corrige o bloqueio acima do hispeed. | FLOPPY_BETTER |
| 5 | `1b54584` | ESG up-rate normal; DTS | Patch-id idêntico a `62a4e46`. | ALREADY_PRESENT |
| 6 | `1fa6059` | boost EMS foreground; DTS | Patch-id idêntico a `52ffa55`. | ALREADY_PRESENT |
| 7 | `1b4a964` | thresholds/polling GPU; DTS | Floppy final tem polling 12 ms, curva 949-aware e não força locks sustentados Proton. | FLOPPY_BETTER |
| 8 | `4aa9e53` | GPU tuning antigo | Antecedido pela série Floppy 949/clamp/thermal; sem dado runtime que prove ganho. | REJECT |
| 9 | `504463c` | reduzir boost interactive GPU | Número isolado conflita com política posterior e a correção hispeed. | REJECT |
| 10 | `8278122` | watermarks dependentes de RAM; `mm/page_alloc.c` | Patch-id idêntico a `dccc5f8`; Floppy ajusta o comportamento posterior. | FLOPPY_BETTER |
| 11 | `aafb88b` | granularidade wakeup/migration CFS; `fair.c` | Patch-id idêntico a `9f598c0`; política final Floppy é posterior. | FLOPPY_BETTER |
| 12 | `39f361f` | CFS Exynos responsiveness; `fair.c` | `b71c390` registra ajuste Floppy específico posterior; não há benchmark para substituir. | FLOPPY_BETTER |
| 13 | `bef9fdb` | EMS short-burst; `energy_step.c` | Floppy importou (`09a64bf`) e reverteu explicitamente (`aff16f2`). | REJECT |
| 14 | `4bb0f02` | `support_uclamp` EMSTune | Patch-id idêntico a `5b159ae`. | ALREADY_PRESENT |
| 15 | `eea4e5e`, `b89d3cb` | infraestrutura/política fclamp | Camada adicional sem teste no S21; o alvo Proton reverteu a série uclamp correlata. | REJECT |
| 16 | `733ea96` | EMS ontime no foreground | Floppy já usa boost foreground; empilhar placement sem medição é duplicação. | REJECT |
| 17 | `649ad2d` | retune amplo scheduler/EMS | Escopo sobreposto a CFS/EMS posterior Floppy, sem ganho isolável. | REJECT |
| 18 | `930ad88` | impedir max clamp GPU de userspace | Patch-id idêntico a `d607896`; Floppy ainda tem GPU clamp e ceiling. | FLOPPY_BETTER |
| 19 | `d97992c` | bloquear throttlers CPU | Floppy `1aec9a7` cobre cpufreq, PM QoS, UFCC e GPU QoS; implementação mais ampla, patch-id não literal. | FLOPPY_BETTER |
| 20 | `4027b34` | `kshrink_lruvecd` async reclaim | Patch-id idêntico a `17076aa`. | ALREADY_PRESENT |
| 21 | `d07af44` | `kshrink_slabd` async | Worker de staging sem medição de pressure, latency ou regressão no S21. | REJECT |
| 22 | `f70a46e` | MIF alt-DVFS agressivo | Muda vários knobs; não há evidência target de stutter/power/recovery. | REJECT |
| 23 | `38a3875` | UFS small-burst | Sem telemetria UFS/alimentação/erros no aparelho alvo. | REJECT |
| 24 | `754eac1`, `3efcb9d` | proteção de I/O scheduler/booster | Ambos são revertidos pelos pais imediatos de `79d7da6`. | REJECT |
| 25 | `b0f483c` e série ADIOS | scheduler ADIOS | Proton `dc2c0fa` reverte ADIOS após relatos de travamento de I/O. | REJECT |
| 26 | `bbe08ac` | desabilitar callback Samsung cooling | É revert de uma desativação anterior; preservá-lo mantém a callback de segurança. | REJECT |
| 27 | `4066066` | desabilitar Samsung mem_boost | Remove política vendor sem teste de memória no S21. | REJECT |

## Resultado

- Candidatos lógicos: **27**.
- `ALREADY_PRESENT`: **5**.
- `FLOPPY_BETTER`: **8**.
- `REJECT`: **14**.
- `PORT`: **0**.

Patch-ids reexecutados e idênticos: `1b54584→62a4e46`,
`1fa6059→52ffa55`, `8278122→dccc5f8`, `aafb88b→9f598c0`,
`4bb0f02→5b159ae`, `930ad88→d607896`, `4027b34→17076aa` e
`69acc1c→1118a016`. A auditoria não adiciona código Proton.
