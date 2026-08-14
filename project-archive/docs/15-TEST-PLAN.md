# Plano de teste futuro

Nenhum flash é automático. Enquanto 1092 estiver bloqueado, o pacote é uma
build baseline KSUNext-SUSFS e não autoriza teste de OC novo. Após revisão
humana de imagem/partição e somente com S21 Exynos2100 confirmado:

| Fase | Ação CLI | PASS | Stop imediato |
|---|---|---|---|
| 1 — Boot | flash manual aprovado, coletar `uname`, KSU/SUSFS e dmesg | boot sem oops/panic e modelo correto | bootloop, panic, watchdog |
| 2 — Idle | `runtime-monitor.sh`, tela sem carga especial | clock/temperatura/locks coerentes | reset, temperatura anormal |
| 3 — UI | navegação humana comum, log passivo | subida e descida normais, sem stutter óbvio | artifact, freeze, fault |
| 4 — carga leve | workload gráfico curto conhecido | utilização/clock sem Mali/MMU fault | Mali/GPU/MMU fault |
| 5 — benchmark curto | mesmo benchmark em 858, 949 e futura 1092 | registrar FPS, 1% low se disponível e frametime | fault, reset, calor crítico |
| 6 — 3D sustentado | janela curta e monitorada | residência, throttling gradual e sem erro | qualquer critério de segurança |
| 7 — thermal | observar cooling/TMU/PI | transições graduais; shutdown crítico preservado | temperatura crítica ou proteção ausente |
| 8 — stability | suspensão/carga mista e regressão KSU/SUSFS/KMD | sem oops, root e selector íntegros | reboot inesperado, corrupção |

Para um futuro OPP 1092, exigir antes da Fase 3: presença real em
`available_frequencies`, FVMAP/voltagem correspondente, aceitação ACPM e log
sem fallback. Nunca inferir “ativo” porque um arquivo DTS mostra o número.

Interromper imediatamente em Mali/GPU/MMU fault, reset, artifact, corrupção,
oops, panic, watchdog, freeze, reboot ou temperatura crítica. Resultados serão
sempre separados em `STATIC PASS`, `BUILD PASS` e `RUNTIME PASS`.

## Plano progressivo específico para o ZIP GPU1092 experimental

Somente após revisão humana no OrangeFox. Não usar ADB para flash automático;
não tocar em userdata; manter o ZIP 949 rollback acessível antes de iniciar.

| Fase | Ação manual/read-only posterior | Critério PASS | STOP imediato |
|---|---|---|---|
| 1 — boot | iniciar com `gpu_oc1092=0`; coletar dmesg e status | boot completo, sem oops/watchdog; teto segue estágio selecionado | panic, loop, freeze, reboot |
| 2 — idle | executar `runtime-monitor.sh` por 60 s | 1092 pode constar da tabela, mas clock baixo e temperaturas normais | fault/reset/temperatura crítica |
| 3 — UI | navegação comum, sem habilitar topo se ainda não necessário | sem artefact, stutter novo ou erro Mali | qualquer corrupção/fault |
| 4 — GPU leve | habilitar unlock 949, depois `gpu_oc1092=1`; carga leve curta | FVMAP tem 11 pares, status não bloqueado, subida/descida normal | recusa ACPM, clock divergente, erro kernel |
| 5 — média/benchmark curto | monitorar em intervalos de 1–2 s | 1092 realmente aparece como clock atual sob carga e retorna abaixo dela | Mali/MMU/reset/fault/temperatura |
| 6 — sustentada | somente após fases anteriores; duração curta e supervisionada | thermal reduz gradualmente 1092→949→858, sem salto inválido | qualquer critério de segurança acima |
| 7 — estabilidade | regressão KSU Next, SUSFS, seletor KMD e ciclo standby | sem regressão e logs limpos | reboot, root/KMD quebrado, oops |

O comando de coleta recomendado é
`./tools/runtime-monitor.sh --serial SERIAL --interval 2 --samples 60 --require-1092`.
Ele apenas lê sysfs/dmesg, separa `TABLE_CONTAINS_1092` de
`CURRENT_CLOCK_1092` e falha se a tabela não contiver o OPP. Nenhum resultado
runtime foi produzido nesta missão.
