# Decisões técnicas

| ID | Decisão | Estado | Justificativa |
|---|---|---|---|
| D-001 | Floppy permanece a base absoluta. | PASS | requisito explícito; Proton é somente referência. |
| D-002 | Não substituir 949 MHz por outro valor. | PASS | preserva OC existente e arquitetura Floppy. |
| D-003 | Tratar 1,09 GHz como frequência física a provar, não rótulo. | PASS | 1091 e 1092 não são equivalentes sem evidência PLL/CAL. |
| D-004 | Não inventar tensão para novo OPP. | PASS | FVMAP/ASV/ACPM pendentes de prova. |
| D-005 | Não flashar/reiniciar telefone automaticamente. | PASS | requisito explícito da missão. |
| D-006 | Build somente com toolchain comprovado, não clang host. | PASS | preserva pipeline e reprodutibilidade. |
| D-007 | Converter a meta nominal de 1091 para candidato PLL 1092, sem equivaler os dois nomes. | PASS | M/P/S 84/2 e oscilador 26 MHz produzem 1092, não 1091. |
| D-008 | Bloquear OPP 1092 até existir FVMAP/ASV/ACPM específico. | BLOCKED | DTS/PLL isolados não provam tensão por silício nem aceitação do firmware. |
| D-009 | Preservar 949 como topo OC integrado e 858 como stock ceiling. | PASS | tabelas, runtime ceiling e thermal Floppy já são coerentes. |
| D-010 | Usar worktree de build e namespace Bubblewrap `/mnt` para a limitação de espaços do Makefile 5.4. | PASS | dados reais permanecem no WorkspaceAI; fonte forense fica limpa e nenhum mount/host é alterado. |
| D-011 | Não instalar `bc`, `zip` ou `ccache` no host. | PASS | shims locais estritos cobrem apenas timeconst/ZIP; ccache é desativado. |

| D-012 | Reabrir o bloqueio somente após validar a coleta root FVMAP. | PASS | 12 hashes passaram; a curva do alvo tem 10 níveis e UV=0. |
| D-013 | Usar 1092 MHz (M=84, P=2, S=0), não chamar 1091 de 1092. | PASS estático | 26 MHz × 84 / 2; entrada incluída nas duas variantes PLL G3D. |
| D-014 | Tensão inicial 925000 uV. | PASS de desenho; runtime NOT TESTED | teto de 6250 uV acima da extrapolação local conservadora (923214 uV). |
| D-015 | Estender somente a região G3D com guarda de layout, sem deslocar domínios SRAM. | PASS estático | exige curvas e offsets exatos; falha fechada antes de escrever. |
| D-016 | Exigir confirmação física pós `FREQ_REQ`. | PASS estático | RA/PLL é relido; divergência retorna erro em vez de reportar sucesso. |
| D-017 | Estagiar teto: stock 858, unlock 949, `gpu_oc1092` 1092. | PASS estático | evita forçar OC e preserva o comportamento Floppy de 949. |
| D-018 | Não alterar proteção TMU/critical; adicionar 1092 apenas ao degrau cooling/DVFS. | PASS estático | thermal e hispeed existentes permanecem; runtime determina eficácia. |
