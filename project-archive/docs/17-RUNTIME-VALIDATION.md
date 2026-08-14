# Validação runtime

Estado: **NOT TESTED**.

`adb devices -l` não identificou S21 Exynos2100: primeiro apareceu somente um
emulador e, na coleta posterior, a lista estava vazia. O
`tools/collect-s21-gpu-data.sh` foi executado sem efeitos no telefone e saiu
`BLOCKED` por zero aparelhos autorizados; log em `logs/commands/`.

Assim, todos os itens abaixo são **NOT TESTED**: boot, root real, SUSFS real,
Mali selector em execução, FVMAP G3D, UV, GPU clamp, throttler protection,
858/949 sob carga, temperatura, performance e estabilidade. A coleta e testes
futuros devem manter logs completos em `evidence/runtime/` e aplicar os
critérios de parada de `docs/15-TEST-PLAN.md`.

## Estado vigente após a coleta root e a build GPU1092

| Item | Estado | Evidência / limite |
|---|---|---|
| Integridade da coleta baseline | PASS | 12 SHA256 da coleta root passaram. |
| Curva baseline FVMAP e UV=0 | PASS | `g3d-fv-table.txt`, `exynos-uv.txt`. |
| 1092 listado/atingido fisicamente | NOT TESTED | build/estático não substitui boot e carga. |
| Aceitação ACPM/FREQ_REQ | NOT TESTED | firmware pode rejeitar rate novo. |
| tensão 925000 uV/thermal/estabilidade | NOT TESTED | primeiro teste controlado deve seguir `15-TEST-PLAN.md`. |
| KSU Next/SUSFS/Mali selector em execução | NOT TESTED | configs/símbolos são STATIC PASS apenas. |
| flash OrangeFox | NOT TESTED | ZIP foi preparado; nenhum dispositivo foi modificado. |
