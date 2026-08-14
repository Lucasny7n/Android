# Log de pesquisa externa

Entradas serão adicionadas cronologicamente com data/hora, pergunta, consulta,
ferramenta, URL, tipo, versão/commit, resumo técnico, confiança e impacto.

## R-001 — fontes primárias definidas

- Data: 2026-08-13.
- Objetivo: fixar fontes primárias iniciais.
- Consulta: URLs fornecidas pelo usuário e commits exatos.
- Ferramentas: Git local, GitHub via HTTPS; skill `github:github` para orientar
  o contexto de repositório.
- Fontes: repositórios Floppy e Proton listados em `docs/07-SOURCES.md`.
- Conclusão: fontes serão clonadas em `src/` e commits serão verificados por
  SHA completo, não por nome de branch.
- Confiança: alta.
- Impacto: nenhum código foi portado nesta fase.

## R-002 — toolchain oficial r596125

- Data/hora: 2026-08-13T02:15:00-03:00.
- Objetivo: obter o compilador exato, sem substituir por clang do host.
- Pergunta: o prebuilt Android 22.0.2 r596125 ainda é obtível pelo mecanismo
  oficial e qual é sua identidade verificável?
- Query/ferramenta: leitura de `build/scripts/tc.sh`, download HTTPS pelo
  endpoint AOSP definido pelo próprio Floppy, seguido de `clang --version` e
  SHA256 local.
- URL: `https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/mirror-goog-main-llvm-toolchain-source/clang-r596125.tar.gz`.
- Fonte/tipo: Android Open Source Project, prebuilt primário.
- Informação: clang reporta `Android (15682573, +pgo, +bolt, +lto, +mlgo,
  based on r596125) clang version 22.0.2`, LLVM revision
  `de03d430485c884861198b25459851f429cbdbad`.
- Evidência: SHA256 de `bin/clang` é
  `b50deb7c48633d03c02b15b6508d79768027e80422265d7a4a7f2f13d2f01d97`;
  `BUILD_INFO` identifica `llvm-r596125-release`.
- Confiança: alta.
- Impacto: build usa esse toolchain preservado em `tools/toolchains/`, não o
  compilador do host.

## R-003 — PLL G3D, CAL, FVMAP e ACPM do Floppy

- Data/hora: 2026-08-13T02:18:00-03:00.
- Objetivo: distinguir um OPP real de uma entrada apenas visual.
- Perguntas: 1091 é programável? Quem decide rate e tensão? É possível criar
  uma entrada FVMAP só pelo kernel?
- Ferramentas: `git show`, `rg` e leitura dos arquivos primários do commit
  Floppy alvo e da série 949.
- Fontes: `cmucal-node.c` Exynos2100/EVT0, `fvmap.c`, `acpm_dvfs.c`,
  `cal-if.c`, `gpexbe_clock.c`, DTS e commits Floppy listados em
  `docs/07-SOURCES.md`.
- Informação: G3D usa M/P/S e OSCCLK 26 MHz; 949 é 73/2 e 1092 seria 84/2.
  `cal_dfs_set_rate` envia `FREQ_REQ` ao ACPM. FVMAP copia `num_of_lv`, rates
  e tensões da SRAM firmware; a API de UV só percorre os níveis existentes.
- Conclusão: 1092 é candidato de PLL, não OPP validado. O fallback acima do
  topo reutiliza a tensão de 949 e é inadequado para este projeto.
- Confiança: alta para fluxo de código; alta para o bloqueio de implementação
  segura com o material disponível; não é uma alegação sobre capacidade física
  absoluta do SoC.
- Impacto: nenhuma edição de CMUCAL/DTS/FVMAP/thermal para 1092 foi feita.

## R-004 — implementação correlata Exynos2100

- Data/hora: 2026-08-13T02:24:00-03:00.
- Objetivo: procurar um caminho legítimo de extensão FVMAP/ACPM fora do
  Floppy/Proton.
- Query/ferramenta: `git ls-remote` e clone parcial do repositório público
  `xfwdrev/android_kernel_samsung_ex2100`, branch `rebased-11`, commit
  `09913b9ddf331512279872409db326b3827e234c`; busca de 1091/1092/G3D/FVMAP.
- URL: `https://github.com/xfwdrev/android_kernel_samsung_ex2100`.
- Tipo: código-fonte primário de kernel Exynos2100 correlato.
- Informação: mesmo modelo ACPM `FREQ_REQ`, cópia de FVMAP da SRAM e fallback
  de tensão acima do topo; nenhuma entrada/firmware G3D 1092 encontrada.
- Conclusão: não há caminho alternativo corroborado para materializar o OPP.
- Confiança: média-alta; é confirmação independente de arquitetura, não
  documentação do firmware Samsung.
- Impacto: reforça o bloqueio técnico e evita uma alteração especulativa.

## R-005 — fontes web institucionais e AOSP

- Data/hora: 2026-08-13T02:20:00-03:00.
- Objetivo: validar disponibilidade do r596125 e verificar fonte institucional
  Samsung para firmware/caracterização pública.
- Queries: `site:opensource.samsung.com Exynos 2100 kernel source G3D FVMAP`,
  pesquisa AOSP de `r596125`, e consulta de fontes Google CAL/FVMAP.
- Ferramenta: pesquisa web headless.
- URLs: AOSP clang em `docs/07-SOURCES.md`; portal Samsung Open Source;
  referências Google CAL/FVMAP também listadas lá.
- Resultado: AOSP confirma o prebuilt r596125/22.0.2. O portal Samsung é
  institucional, mas não entregou firmware ACPM ou curva ASV G3D 1092 neste
  escopo.
- Confiança: alta para origem do toolchain; baixa para qualquer conclusão de
  OC baseada somente no portal (por isso não foi usada como prova de OPP).
- Impacto: fontes secundárias irrelevantes não influenciaram código.

## R-006 — coleta root real G3D/ASV

- Data/hora: 2026-08-13 03:28 BRT (coleta); verificação nesta continuação.
- Objetivo/pergunta: substituir a lacuna de tensão real do aparelho por
  evidência verificável e descobrir se o FVMAP G3D contém 1092 MHz.
- Ferramenta: `sha256sum -c SHA256SUMS`, leitura local headless.
- Fonte: `evidence/runtime/baseline-device/s21-exynos2100-RQCRA01QZ9J-2026-08-13T03_28_30-03_00/g3d-fv-table.txt`.
- Tipo: coleta root primária do SM-G991B/Exynos 2100; hash do arquivo
  `2faa02e24175e67585b8ece78db9ca8a2a72eca2085a08b6913001179dc8b81f`.
- Resultado: os 12 arquivos da coleta passaram em SHA256. A tabela contém
  exatamente dez níveis, topo 949000 kHz/825000 uV e UV GPU 0%. Não contém
  1092 MHz.
- Conclusão/confiança: alta para a curva baseline deste aparelho; ela resolve
  o bloqueio anterior de desconhecimento da curva, mas não prova a aceitação
  ACPM de uma taxa nova.
- Impacto: 925000 uV foi selecionado como tensão inicial conservadora e a
  extensão passa a ser explicitamente experimental e protegida por guardas.

## R-007 — caminho FVMAP/CAL/ACPM e precedentes

- Data/hora: 2026-08-13 BRT.
- Objetivo/pergunta: determinar quem lê/escreve FVMAP e se o IPC recebe índice
  ou frequência; pesquisar precedente de décimo-primeiro nível G3D.
- Ferramentas: `rg`, `git show`, `git log`, leitura de fontes Floppy e clone
  Exynos2100 de referência; pesquisa GitHub headless orientada por
  `github:github`.
- Consultas: `Exynos2100 1092000000 G3D`, `cal_dfs_get_rate_asv_table G3D
  custom`, `fvmap num_of_lv Exynos G3D`, `exynos_acpm_set_rate G3D`,
  `fvmap_set_raw_voltage_table`.
- Fontes: `drivers/soc/samsung/cal-if/{fvmap.c,fvmap.h,cal-if.c,vclk.c,ra.c}`;
  `drivers/gpu/arm/.../gpex_clock.c`; `4f5b021d9c23`; clone local
  `references/xfwdrev-ex2100` (`09913b9ddf33`). URLs em `07-SOURCES.md`.
- Resultado técnico: `fvmap_init()` copia SRAM ACPM para uma tabela local;
  CAL exige que LUT VCLK e FVMAP tenham a mesma contagem; `cal_dfs_set_rate()`
  envia a taxa em kHz em `FREQ_REQ`, não um índice; `vclk_recalc_rate()` lê a
  taxa física via RA/PLL. O código aberto não contém firmware ACPM nem
  precedente confiável de OC G3D 1092 no Exynos2100.
- Conclusão/confiança: alta para o caminho kernel-side; média para a aceitação
  final, que exige boot real. A solução escolhida não reloca SRAM: só atua se
  houver espaço antes do próximo offset declarado e se a tabela for a curva
  coletada exata.
