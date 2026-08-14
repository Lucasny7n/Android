# Validação estática e revisão adversarial

## Resultado

**STATIC PASS para a baseline Floppy; 1092 MHz BLOCKED por design.**

Foram executados `tools/preflight-check.sh`, `tools/static-validate.sh`,
`tools/verify-package.sh`, `llvm-nm`, `dtc -I dtb -O dts`, contagem de módulos,
`git diff --check` e testes de arquivo ZIP/TAR. O log consolidado é
`logs/tests/final-static-package-20260813T025209-0300.log`.

## Revisão adversarial

| Hipótese adversarial | Verificação | Resultado |
|---|---|---|
| Fonte Floppy modificada/dirty | `git status`, `git diff --check`, SHA alvo | PASS: limpa em `af9e70e` |
| Proton misturado à base | auditoria patch-id/histórico e diff de fontes | PASS: 0 ports, Floppy preservado |
| 1092 falso exibido em sysfs/DTS | pesquisa no DTS, CMUCAL e FVMAP | PASS seguro: 1092 ausente e BLOCKED |
| 949 removido/regredido | 10 linhas DVFS, PLL nas duas variantes, limits | PASS: 130–949; stock 858, ceiling 949 |
| térmica/PM QoS/locks omitidos | `gpu_temp_throttling`, PM QoS, clamp e hispeed | PASS para tabela Floppy existente |
| UV/clamp/throttler perdido | busca de `CONFIG_SOC_EXYNOS2100_UNDERVOLT`, `gpu_clamp`, `throttlers_protection` | PASS estático |
| KSU/SUSFS apenas no config | config final e símbolos de `vmlinux` | STATIC PASS |
| Mali selector reduzido | diretórios KMD e objetos compilados | STATIC PASS |
| modpost/símbolo não resolvido | `Module.symvers`, busca de `undefined` | PASS |
| DT inválido | DTB materializado/decompilado com dtc | PASS |
| pacote incompleto/corrompido | `unzip -t`, SHA256, inventário, `tar -tf` | PASS |
| build marcada como OC sem provar hardware | metadata do pacote e relatório | PASS: explicitamente baseline, OC BLOCKED |

## Frequências e integração real

A tabela entregue continua com 10 degraus: `130, 221, 312, 403, 494, 585,
676, 767, 858, 949 MHz`. A linha de política/thermal existente manteve
`949 → 858 → 767`, `gpu_stock_max_clock=858000`,
`gpu_max_clock_limit=949000` e `interactive_info=<676000 60 0>`.

Não há 1091 ou 1092 no DTB/DTS. Isso não é omissão: CMUCAL permite derivar um
candidato PLL 1092 (26 MHz × 84 / 2), mas FVMAP vem de SRAM/ACPM e não contém
um nível ASV 1092 comprovado. Colocar somente o número em DTS/CMUCAL teria
produzido a hipótese adversarial de *clock fake*. A recusa é a validação de
segurança relevante.

## Limites da validação

Static/build PASS não prova boot, frequência física, tensão, aceitação ACPM,
thermal runtime, KSU/SUSFS real, Mali selector real, frame pacing ou
estabilidade. Não havia S21 Exynos2100 conectado e não houve flash. Todos
esses itens continuam **NOT TESTED**.

## Revisão adversarial GPU1092 — resultado vigente

| Hipótese de falha | Evidência/contramedida | Estado |
|---|---|---|
| 1092 só existe em texto/DTS | PLL normal+EVT, DTS, DTB e driver usam 1092000; frequência física é relida por RA/PLL após set. | STATIC PASS |
| FVMAP de 10 níveis sofre overwrite | extensão exige as dez taxas/tensões exatas, calcula próximo offset e recusa ausência de quatro bytes livres; não desloca domínios. | STATIC PASS |
| CAL recebe 10×11 divergente | LUT VCLK shadow de 11 entries acompanha a FVMAP antes de `cal_dfs_get_rate_asv_table`. | STATIC PASS |
| ACPM aceita cache mas não hardware | IPC envia kHz; diferença entre set/recalc retorna `-EREMOTEIO`. | STATIC PASS; firmware runtime NOT TESTED |
| locks/ceiling truncam 1092 | novo topo, PM QoS, max/stock/unlock, `gpu_oc1092`, table count e DTB foram inspecionados. | STATIC PASS |
| ping-pong/hispeed força topo | 1092 é faixa 82–100, 949 conserva 78–95, stay 6; hispeed fica 676. | STATIC PASS de política |
| thermal trata 1092 como 949 | cooling/DVFS começa 1092→949→858→767; proteção TMU/critical não foi removida. | STATIC PASS |
| UV/KSU/SUSFS/Mali selector regrediram | 11 níveis são instalados antes de UV; configs, símbolos e KMDs r38p0/r38p1/r44p1 foram verificados. | STATIC PASS |
| ZIP não é o pipeline Floppy | ZIP oficial AnyKernel foi copiado sem reinvenção e passou inventário/`unzip -t`. | PACKAGE PASS |

`tools/static-validate-gpu1092.sh` executa essas verificações reproduzíveis.
Ele não consegue demonstrar que o firmware ACPM do aparelho aceitará o novo
rate, que 925000 uV é estável, nem que boot/root/thermal funcionarão: todos
esses pontos são **RUNTIME NOT TESTED**.

### Revisão pós-build de ownership da LUT

Foi verificado adversarialmente que `vclk_get_dfs_info()` cria a LUT ACPM com
`kzalloc()` e os parâmetros de cada nível com `kcalloc()`. Portanto substituir
somente o array LUT por cópia de 11 entradas e manter os ponteiros dos dez
níveis originais não libera armazenamento estático nem invalida parâmetros;
o novo topo recebe cópia independente dos parâmetros de 949. Isto resolve a
hipótese de `kfree()` sobre dados estáticos. A ausência de unload nesse caminho
de boot não cria uma liberação posterior adicional. **STATIC PASS**.
