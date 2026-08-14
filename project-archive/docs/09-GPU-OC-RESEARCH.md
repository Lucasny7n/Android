# Pesquisa de OC G3D

Estado: **BLOCKED — nenhuma alteração de código foi autorizada**.

A hipótese anterior, ainda a revalidar, é que a PLL G3D use M/P/S inteiros com
referência de 26 MHz: 949 MHz seria `26 × 73 / 2`, enquanto `26 × 84 / 2`
produziria 1092 MHz. Isso não prova que 1092 MHz seja programável, aceito pelo
ACPM ou sustentado por tensão/ASV.

Questões de bloqueio:

1. Quais registros e limites da PLL G3D existem no CMUCAL real?
2. Como CAL recebe e valida uma frequência acima do topo FVMAP?
3. A FVMAP em SRAM, gerida por ACPM, pode ser ampliada corretamente pelo
   kernel, ou exige firmware/BL?
4. Como obter tensão ASV por dispositivo sem inventar um valor?
5. Como o Mali KMD e thermal/cooling representam um OPP adicional?

## Evidência de PLL e frequência

O CMUCAL Exynos2100 e o equivalente EVT0 contêm a mesma tabela `pll_g3d`:

| Frequência | M | P | S |
|---:|---:|---:|---:|
| 949 MHz | 73 | 2 | 0 |
| 858 MHz | 66 | 2 | 0 |
| 767 MHz | 59 | 2 | 0 |
| 676 MHz | 52 | 2 | 0 |
| 585 MHz | 90 | 2 | 1 |
| 494 MHz | 76 | 2 | 1 |
| 403 MHz | 62 | 2 | 1 |
| 312 MHz | 48 | 2 | 1 |
| 221 MHz | 68 | 2 | 2 |
| 130 MHz | 80 | 2 | 3 |

`OSCCLK_CMU` é explicitamente 26.000.000 Hz. Com o formato M/P/S usado por
essa tabela, 949 MHz é exatamente `26 × 73 / 2`; o ponto inteiro imediatamente
compatível com a meta é **1092 MHz** (`26 × 84 / 2`). Não existe 1091 MHz na
tabela G3D. Portanto, 1091 MHz não é um nome tecnicamente honesto para este
PLL; 1092 MHz é apenas uma taxa de PLL candidata, ainda não um OPP válido.

## Cadeia real de DVFS

1. A tabela de 949 no DTS registra política (thresholds, PM QoS, limites,
   cooling), mas não cria a tensão ASV.
2. `gpexbe_clock` obtém níveis e rate/voltage do CAL/FVMAP; cada frequência
   precisa corresponder à tabela que o driver constrói.
3. `cal_dfs_set_rate()` envia `FREQ_REQ` com a taxa ao ACPM por
   `exynos_acpm_set_rate()` e só atualiza o rate cache se a chamada retornar
   sucesso.
4. Na inicialização, `fvmap_copy_from_sram()` copia `num_of_lv`, rates e
   tensões da SRAM fornecida pelo firmware ACPM.

Consequência: acrescentar somente CMUCAL/DTS/locks faria sysfs e o governor
verem um número, mas não prova que ACPM aceite 1092 nem que ele selecione uma
tensão por chip. Isto seria precisamente um clock falso.

## FVMAP/ASV/UV

- `fvmap_set_raw_voltage_table()` percorre os `num_of_lv` existentes e aplica
  margem; não aloca nem anexa um nível.
- `fvmap_get_freq_volt_table()` interpola dentro da tabela. Acima do topo, o
  fallback usa a tensão do primeiro nível (949 MHz), não uma caracterização
  ASV nova. Esse comportamento foi identificado e **rejeitado** como base
  para 1092 MHz.
- `/sys/kernel/exynos_uv` usa a infraestrutura de margem existente. Ela deve
  permanecer intacta, mas não é mecanismo de criação de OPP.
- Sem aparelho físico conectado, não há leitura de
  `g3d_fv_table`; logo, não há valor de tensão real de 949 por bin ASV, muito
  menos uma tensão 1092 validada.

## Pesquisa de implementações correlatas

- Floppy `4f5b021` mostra o padrão completo de 949: PLL G3D nas duas variantes
  CMUCAL, entrada DTS, limites e integração de driver. `59fef87` acrescenta o
  caminho thermal; `df719bb`, `274922`, `091c2c6` e `a697340` completam os
  limites, proteção de throttlers, clamp e hispeed.
- Proton na revisão solicitada não contém OPP G3D 1091/1092.
- O kernel Exynos2100 independente de `xfwdrev` (`rebased-11`,
  `09913b9`) possui o mesmo modelo ACPM/FVMAP: cópia de `num_of_lv` da SRAM,
  fallback de tensão acima do topo e `FREQ_REQ` para ACPM. Não forneceu um
  caminho alternativo validado para acrescentar OPP.
- Não foi encontrada uma fonte primária que forneça firmware ACPM/FVMAP G3D
  Exynos2100 com 1092 MHz ou uma curva ASV oficial para esse ponto. A página
  Samsung Open Source foi consultada como fonte institucional, mas não oferece
  esse firmware/caracterização neste material.

## Decisão da Fase 5

**BLOCKED para implementação de 1092 MHz.** A frequência PLL é derivável,
mas o OPP seguro não: falta firmware/ACPM que aceite a taxa e gere/adote uma
entrada FVMAP/ASV 1092 específica do silício. Não foi introduzido código de
OC, tensão copiada, thermal fictício ou lock que anuncie 1092.

Para reabrir a decisão, é necessário no mínimo: (a) imagem ACPM/bootloader
com FVMAP G3D 1092 documentada, ou código-fonte confiável que estenda essa
estrutura e seu protocolo; (b) leitura real do `g3d_fv_table` do S21 alvo;
(c) confirmação runtime de aceitação ACPM e medição com os critérios de parada
do plano. Até lá, 949 MHz continua sendo o único OC integrado.

## Continuação — desenho experimental 1092 MHz (substitui o bloqueio de dados)

A coleta root válida agora resolve a ausência de curva real. Ela confirma dez
pares FVMAP sem UV: 130/543750, 221/562500, 312/581250, 403/593750,
494/612500, 585/631250, 676/656250, 767/706250, 858/762500 e 949/825000
(kHz/uV). `gpu_uv_percent=0`, portanto 825000 uV é a tensão baseline real de
949 MHz neste aparelho, não valor teórico.

O último intervalo mede 62500 uV/91 MHz = 686,813 uV/MHz. Extrapolado para
1092 MHz produz 923214 uV. Regressão linear dos três pontos superiores produz
917262 uV; quatro pontos, 910268 uV. A escolha é o próximo degrau FVMAP de
6250 uV acima da extrapolação local mais conservadora: **925000 uV**. É uma
tensão inicial de teste, não ASV de fábrica, não overvolt automático e não
declaração de estabilidade. A razão dinâmica aproximada contra 949 é 1,447x
(`1092/949 * (925/825)^2`), usada somente para explicar por que o topo deve
ser reservado a carga alta.

### Arquitetura implementada

`fvmap_init()` primeiro copia a FVMAP SRAM do ACPM. A extensão G3D do projeto
aceita exclusivamente a tabela coletada de dez níveis, testa local e SRAM,
calcula o próximo offset declarado por todos os cabeçalhos e só insere quatro
bytes se o intervalo for realmente livre. Ela desloca apenas os dez entries
G3D dentro desse intervalo, preserva offsets de todos os domínios seguintes,
insere 1092000/925000 no topo e atualiza `num_of_lv`/`max_rate` para 11/1092.
Se qualquer guarda, alocação ou layout falhar, não escreve e a sonda GPU falha
em vez de expor um OPP parcial.

Para manter CAL coerente, a LUT VCLK G3D recebe uma cópia shadow de 11 taxas;
assim `cal_dfs_get_rate_asv_table()` não encontra contagens divergentes. O
driver envia 1092000 por `FREQ_REQ`; após cada mudança `gpex_clock_set()`
recalcula a taxa física RA/PLL e devolve erro se não for a taxa solicitada.
Logo uma tabela/sysfs isolada não é tratada como prova de clock real.

O risco que resta é firmware: o ACPM pode ainda rejeitar uma taxa ausente de
sua lógica interna. Não há firmware-fonte para provar isso offline. A validação
runtime deve confirmar `g3d_oc1092_status`, FVMAP de 11 linhas e clock físico;
até então **RUNTIME NOT TESTED**.
