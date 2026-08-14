# Erros e correções

## ERR-001 — corrida de Git no clone inicial

- Data: 2026-08-13T02:04:00-03:00.
- Fase: FASE 0.
- Sintoma: `index.lock` presente ao tentar validar checkout.
- Comandos envolvidos: clone parcial Floppy e, por tentativa de correção sem
  `set -e`, fetch adicional no mesmo repositório.
- Causa raiz: o invólucro de execução retornou antes dos subprocessos de Git
  terminarem; a sequência sem fail-fast permitiu uma interpretação incorreta de
  sucesso e iniciou fetch concorrente.
- Hipóteses: clone incompleto, ref ausente, lock stale.
- Diagnóstico: `ps` identificou os dois grupos de processo criados por esta
  missão; o fetch secundário mantinha `index-pack` e o clone original mantinha
  seu próprio fetch.
- Correção: apenas o grupo do fetch secundário (`PGID 21678`) recebeu `TERM`;
  nenhum processo do usuário foi tocado. Operações futuras usam `set -euo
  pipefail` e não concorrem no mesmo `.git`.
- Arquivos alterados: nenhum arquivo de kernel.
- Verificação: o clone terminou em `af9e70e`, `git status --short --branch`
  está limpo e a fonte forense não foi alterada.
- Estado: PASS.

## ERR-002 — invocação de `tc.sh` sob `set -u`

- Data: 2026-08-13T02:14:00-03:00.
- Fase: toolchain.
- Sintoma/comando: teste direto de `build/scripts/tc.sh` falhou em
  `CUST_DIR: unbound variable`.
- Causa raiz: o script oficial é chamado pelo `ckbuild.sh` sem `set -u`; o
  harness de inspeção adicionou essa opção e mudou a semântica.
- Hipóteses: toolchain indisponível, falha do downloader, variável ausente.
- Diagnóstico: repetição com ambiente equivalente ao pipeline e `CUST_DIR=""`
  usou o endpoint oficial e produziu clang r596125.
- Correção: não foi alterado o script Floppy; o wrapper exporta as variáveis
  necessárias e valida `clang --version`.
- Verificação: clang 22.0.2/r596125, LLVM `de03d430...` e SHA256 registrados.
- Estado: PASS.

## ERR-003 — Linux 5.4 rejeita o caminho canônico com espaço

- Data: 2026-08-13T02:26:00-03:00.
- Fase: build limpa, tentativa 1 e 2.
- Sintoma/comando: `make O=<PROJECT_ROOT>/.../out` falhou primeiro ao criar
  output e depois com `source directory cannot contain spaces or colons`.
- Causa raiz: o Makefile 5.4 usa `realpath` e rejeita espaço em `abs_srctree`;
  o caminho WorkspaceAI contém `Área de trabalho` por requisito do usuário.
- Hipóteses: quoting do wrapper, `O=` absoluto, bug do toolchain.
- Diagnóstico: a regra foi lida no Makefile; até symlink lógico falha porque
  `realpath` o resolve de volta ao caminho com espaço.
- Correção: Bubblewrap expõe o mesmo worktree como `/mnt` apenas no processo
  filho, preservando os caminhos absolutos originais que `ckbuild.sh` calcula
  a partir de `KDIR=/mnt`. Nenhum bind mount host, root, fonte forense ou dado
  sai do WorkspaceAI.
- Verificação: `bwrap ... /mnt make -s kernelversion` retornou `5.4.302`; a
  compilação prosseguiu por DTB, KMDs e Full LTO.
- Estado: PASS.

## ERR-007 — `MOD_OUTDIR` relativo muda o destino de `modules_install`

- Data: 2026-08-13T02:40:00-03:00.
- Fase: build limpa, tentativa 6 (empacotamento pós-link).
- Sintoma/comando: após `DEPMOD`, `build/scripts/post.sh` encerrou com
  `ERROR: No installed modules found in modules_out/lib/modules!`.
- Causa raiz: a primeira adaptação para o caminho com espaço trocou
  `MOD_OUTDIR="$KDIR/modules_out"` por `modules_out`. O Makefile com `O=out`
  instalou corretamente 320 módulos em `out/modules_out/...`, enquanto o
  empacotador oficial procurou `modules_out/...` na raiz do worktree.
- Hipóteses: compilação parcial, depmod falho, módulos não habilitados, destino
  relativo errado.
- Diagnóstico: `find out/modules_out/lib/modules -name '*.ko'` retornou 320 e
  os metadados `modules.dep`, `modules.symbols` e `modules.order`; a raiz
  `modules_out/` não existia.
- Correção: restauradas as três linhas originais de `ckbuild.sh` no worktree e
  removida a mutação automática do wrapper. Dentro do namespace, `KDIR=/mnt`
  não contém espaço, portanto o script oficial pode ser usado literalmente.
- Arquivos alterados: `scripts/build-ksunext-susfs.sh`; a alteração transitória
  de `build/floppy-build/build/ckbuild.sh` foi desfeita antes da repetição.
- Verificação: `git -C build/floppy-build diff -- build/ckbuild.sh` está vazio;
  uma nova compilação limpa `kclq` foi iniciada.
- Estado: PASS. A build repetida terminou em 7m25s; produziu 320 módulos
  compilados, `modules.load` com 280 módulos selecionados e todos os formatos
  de pacote esperados.

## WARN-002 — avisos de configuração KSU/SUSFS

- Fase: configuração da build final.
- Sintoma: `.config:7446:warning: unexpected data` e
  `.config:7460:warning: override: reassigning to symbol KSU_SUSFS`.
- Diagnóstico: vêm da composição dos fragmentos Floppy para a variante
  KSUNext-SUSFS; a configuração final contém `CONFIG_KSU_NEXT=y` e
  `CONFIG_KSU_SUSFS=y` e o `vmlinux` contém símbolos KSU/SUSFS.
- Correção: nenhuma atualização ou remoção de root/SUSFS foi aplicada.
- Verificação: config e `llvm-nm` registrados em
  `logs/tests/final-static-package-20260813T025209-0300.log`.
- Estado: non-fatal; STATIC PASS, runtime NOT TESTED.

## WARN-003 — metadados Git do submódulo mkbootimg no namespace

- Fase: build/package.
- Sintoma: três mensagens `fatal: not a git repository` ao consultar metadados
  de `build/mkbootimg` pelo caminho de worktree fora do namespace.
- Diagnóstico: o submódulo foi inicializado e as imagens OneUI, AOSP e vendor
  boot foram efetivamente criadas; as mensagens são de obtenção de metadados,
  não de compilação/link/empacotamento.
- Correção: nenhuma; não se alterou a procedência do submódulo para silenciar
  uma mensagem não bloqueante.
- Verificação: ZIP e todos os TARs passaram em integridade.
- Estado: non-fatal; PACKAGE PASS.

## WARN-004 — `depmod` no staging do vendor ramdisk

- Fase: geração de `vendor_boot`.
- Sintoma: `depmod` informou ausência de `modules.order`, `modules.builtin` e
  `modules.builtin.modinfo` no diretório reduzido `lib/modules/0.0`.
- Diagnóstico: o pipeline copia apenas os módulos selecionados para a imagem
  vendor e o `post.sh` não copia a árvore de metadados completa. Foram
  compilados 320 `.ko` e gerado `modules.load` com 280 entradas antes do
  empacotamento.
- Correção: nenhuma; mudar a semântica do ramdisk oficial não foi autorizado.
- Verificação: `vendor_boot.img` está no ZIP e TAR; `unzip -t`/SHA256 PASS.
- Estado: non-fatal; runtime NOT TESTED.

## WARN-005 — objetos sem símbolos durante arquivamento

- Fase: Full LTO/arquivamento.
- Sintoma: 24 linhas `no symbols`, incluindo objetos de debug Mali r38p0,
  r38p1 e r44p1.
- Diagnóstico: não houve `undefined reference`, falha modpost ou falha de
  link; todos os três KMDs foram compilados e o kernel/link final terminou.
  Não foi feita uma comparação com uma build histórica para chamá-las de
  preexistentes.
- Correção: nenhuma alteração especulativa em KMD.
- Verificação: 320 `.ko`, `Module.symvers`, DTB e pacote PASS.
- Estado: non-fatal; MALI STATIC PASS e runtime NOT TESTED.

## ERR-008 — validador de sintaxe aplicou Bash a um shim Python

- Data: 2026-08-13T02:55:00-03:00.
- Fase: revisão final de scripts.
- Sintoma/comando: uma verificação em lote com `bash -n tools/build-bin/*`
  acusou `syntax error near unexpected token '('` no shim `bc`.
- Causa raiz: `tools/build-bin/bc` é Python por projeto (shebang Python), não
  Bash; o erro foi do verificador, não do shim ou da build.
- Diagnóstico: a linha 1 identifica o interpretador Python e o shim já tinha
  sido executado com sucesso para gerar `timeconst.h` durante a build.
- Correção: separar validação de shell (`bash -n`) da validação Python por
  `ast.parse`, sem gerar bytecode.
- Arquivos alterados: somente esta documentação.
- Verificação: `ast.parse` do shim Python e `bash -n` de todos os scripts de
  shell passaram; `git diff --check` e o JSON de estado também passaram.
- Estado: PASS.

## ERR-004 — `/tmp` read-only dentro do namespace de build

- Data: 2026-08-13T02:29:00-03:00.
- Fase: build limpa, tentativa 3.
- Sintoma/comando: `make`/clang falharam ao criar `GMfifo` e arquivo temporário
  em `/tmp`.
- Causa raiz: o namespace inicial tinha root read-only para proteger o host e
  não montava `/tmp` gravável.
- Diagnóstico: log oficial mostrou ambos os erros de escrita em `/tmp`.
- Correção: acrescentado `--tmpfs /tmp` privado ao Bubblewrap.
- Verificação: geração do DTB, configuração e compilação posterior passaram.
- Estado: PASS.

## ERR-005 — caminho com espaço do toolchain fragmentou flags clang

- Data: 2026-08-13T02:30:00-03:00.
- Fase: build limpa, tentativa 4.
- Sintoma/comando: clang reportou `no such file or directory: 'de'` e partes
  de `Área de trabalho/.../aospclang`.
- Causa raiz: a build 5.4 insere `CUST_DIR` sem quoting em flags internas.
- Diagnóstico: log apontou include e prefixo cross-compile fragmentados.
- Correção: o mesmo toolchain oficial é exposto read-only como `/srv` dentro
  do namespace e `CUST_DIR=/srv`; bytes e hashes continuam em
  `tools/toolchains/aospclang`.
- Verificação: compilação avançou além de scripts, scheduler, UFS e Mali.
- Estado: PASS.

## ERR-006 — dependência host `bc` ausente

- Data: 2026-08-13T02:31:00-03:00.
- Fase: build limpa, tentativa 5.
- Sintoma/comando: `/bin/sh: bc: command not found` ao gerar
  `include/generated/timeconst.h`.
- Causa raiz: `bc` não está instalado; não foi usada instalação privilegiada.
- Hipóteses: instalar pacote, gerar header estático, implementar somente o
  contrato de `timeconst.bc`.
- Diagnóstico: a árvore invoca `bc -q kernel/time/timeconst.bc` para
  `CONFIG_HZ=250`.
- Correção: criado `tools/build-bin/bc`, wrapper Python estrito que só aceita
  essa invocação e reproduz as funções inteiras `gcd`, `fmul`, `fadj` e
  `fmuls` do arquivo fonte. Ele recusa uso genérico.
- Verificação: saída contém HZ 250 e todas as constantes; compilação prosseguiu
  para Full LTO.
- Estado: PASS.

## WARN-001 — avisos de fragmento e identidade Git do KernelSU Next

- Data: 2026-08-13T02:30:00-03:00.
- Fase: configuração/compilação.
- Sintomas: `CONFIG_KSU_SUSFS` duplicado no fragmento gera warning de override;
  Kbuild usa fallback `33214`/`v3.3.0-legacy-unofficial`; Git do submódulo
  mkbootimg não resolve através do namespace.
- Diagnóstico: os dois primeiros já pertencem ao conteúdo Floppy; a identidade
  fallback é deliberada no Kbuild de uma integração em árvore, não erro de
  link. O aviso Git não interrompeu DTB/KMD/KSU/SUSFS.
- Correção: nenhuma alteração de root/SUSFS nem supressão enganosa. Avaliação
  final será baseada no resultado do link e `modpost`; runtime permanece
  NOT TESTED.
- Estado: OPEN até o término da build.

Todos os novos erros relevantes serão incluídos nesta tabela com causa e
verificação explícitas.

## ERR-007 — identidade Git ausente no worktree experimental

- Data/hora/fase: 2026-08-13, implementação.
- Sintoma/comando: o primeiro `git commit` no worktree rejeitou a autoria.
- Causa raiz: o repositório não tinha `user.name`/`user.email` locais
configurados para esta sessão.
- Hipóteses/diagnóstico: não era erro de patch, índice ou branch; `git config
--local --get` confirmou ausência de identidade local.
- Correção: configurados somente no repositório experimental `Codex
WorkspaceAI <codex-workspaceai@local.invalid>`; nenhuma configuração global do
usuário foi alterada.
- Arquivos alterados: `.git/config` do repositório compartilhado pelos
worktrees, não código de kernel.
- Verificação/estado: commits `78ba9c7..cc6540b` criados; **PASS**.

## ERR-008 — script de build confundia arquivo `.git` de worktree com diretório

- Data/hora/fase: 2026-08-13, pré-build.
- Sintoma/comando: verificação inicial do wrapper rejeitou worktree válido.
- Causa raiz: teste `-d .git` não é válido em `git worktree`, onde `.git` é um
arquivo apontando ao gitdir comum.
- Correção: guard atualizado para `-e .git`; ele ainda exige repositório
existente e árvore limpa.
- Verificação/estado: build oficial completou em 7m53s; **PASS**.

## WARN-002 — mensagens não fatais de `sudo` e `depmod` no namespace de build

- Data/hora/fase: build experimental.
- Sintoma: `sudo.conf` aparece com UID mapeado e `depmod` não encontra
`modules.order`/`modules.builtin*` em um subdiretório vendor-ramdisk reduzido.
- Diagnóstico: o build ocorre em Bubblewrap sem privilégios e o pacote oficial
contém os módulos produzidos; não houve `undefined reference`, modpost falho
ou ausência dos três KMDs.
- Correção: nenhuma supressão enganosa; avisos preservados no log e módulos,
DTB, Image e ZIP foram auditados separadamente.
- Estado: **PASS com warning pré-existente/pipeline**, runtime continua
**NOT TESTED**.

## ERR-009 — manifesto SHA256 executado do diretório errado

- Data/hora/fase: 2026-08-13, verificação final de pacote.
- Sintoma/comando: `sha256sum -c packages/SHA256SUMS` procurou nomes relativos
na raiz do projeto e marcou nove artefatos como ausentes.
- Causa raiz: o manifesto oficial contém basenames, portanto o diretório de
trabalho deve ser `packages/`; não era hash divergente ou arquivo perdido.
- Correção: verificação reproduzível corrigida para
`(cd packages && sha256sum -c SHA256SUMS)`.
- Verificação/estado: repetida com todos os artefatos `OK`; **PASS**.
