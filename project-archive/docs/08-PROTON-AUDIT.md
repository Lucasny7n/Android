# Auditoria Proton

Estado: **PASS — 27 candidatos revalidados, 0 PORT**.

A evidência migrada foi tratada somente como hipótese. Foram clonados os dois
commits exatos, lidos os commits e o estado final, e reexecutado `git patch-id
--stable` nas equivalências diretas. Diferença textual não foi tratada como
ausência de recurso.

Classificações aceitas:

- `ALREADY_PRESENT`: equivalente efetivo existe no Floppy.
- `FLOPPY_BETTER`: solução posterior, mais completa ou mais segura no Floppy.
- `PORT`: somente com benefício técnico claro, integração mínima e risco
  conhecido.
- `REJECT`: revertido, inseguro, não comprovado ou fora do objetivo.

## Método e evidência

- Proton alvo confirmado: `79d7da6`, cujo commit é o revert de `3efcb9d`.
  Seu pai imediato `9190c40` também reverte `754eac1`.
- Floppy alvo confirmado: `af9e70e`, com o estado final de GPU/CFS/EMS/thermal
  lido, não só patches históricos.
- Patch-id igual foi verificado para oito imports diretos; a lista, arquivos,
  justificativas e classificação de todos os 27 grupos está em
  [`PROTON_CANDIDATES.md`](../PROTON_CANDIDATES.md).
- As alterações de GPU 949 foram comparadas também à série Floppy
  `4f5b021`, `59fef87`, `df719bb`, `274922`, `091c2c6` e `a697340`.

## Resultado por subsistema

| Área | Resultado |
|---|---|
| CFS / wakeup / migration | imports ou política Floppy posterior; nenhum port seguro. |
| EMS / energy_step / foreground | boost/uclamp já presentes; short-burst foi revertido pelo próprio Floppy. |
| GPU DVFS / interactive / hispeed / PM QoS | Floppy possui a integração 949 mais completa, clamp e ceiling runtime. |
| Thermal / cooling | manter callbacks e a tabela gradual 949→858→767; não importar desativações. |
| CPU throttlers / userspace clamps | Floppy cobre mais superfícies por `1aec9a7` e proteção runtime. |
| Memory / MGLRU / reclaim / ZRAM | lruvec já integrado; slabd/mem_boost não têm evidência device-specific. |
| UFS / I/O / MIF | mudanças agressivas ou revertidas, sem telemetria de S21. |
| Networking / idle / power | nenhum candidato Proton adicional demonstrou ganho específico sem regressão. |

Não houve port de Proton, logo não há commit `proton: port ...` e não há
duplicação de subsistemas existentes no Floppy.

## Revalidação na continuação GPU1092

A nova coleta root e a implementação experimental foram comparadas com a
matriz anterior. Nenhum dos 27 candidatos Proton passa a ser `PORT`: nenhum
oferece extensão FVMAP/ACPM G3D verificável e as mudanças de scheduler,
thermal, GPU governor, PM QoS, memória, I/O e rede continuam presentes,
equivalentes ou mais integradas no Floppy. Resultado: **0 PORT, 27
ALREADY_PRESENT/FLOPPY_BETTER/REJECT; auditoria PASS**.
