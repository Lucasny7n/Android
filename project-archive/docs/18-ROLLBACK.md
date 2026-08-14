# Rollback

## Limite desta missão

Nenhum telefone foi alterado, reiniciado, flasheado, apagado ou teve userdata
tocado. Portanto não há rollback de dispositivo a executar nesta entrega. O
ZIP produzido é baseline 949 MHz e não autoriza flash automático.

## Restaurar a fonte Floppy exata

No `PROJECT_ROOT`:

```bash
git -C src/floppy switch --detach af9e70e6af7aa7f66903d883cd677b9147424ed1
git -C src/floppy status --short --branch
git -C src/floppy rev-parse HEAD
```

O último comando deve imprimir
`af9e70e6af7aa7f66903d883cd677b9147424ed1` e o status deve ficar vazio após a
linha de branch. Não use `reset --hard`.

## Remover somente o worktree de build descartável

Somente se todos os artefatos de interesse em `packages/` e `output/release/`
já tiverem sido preservados, execute:

```bash
git -C src/floppy worktree remove --force \
  '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC/build/floppy-build'
git -C src/floppy branch -D floppy-exynos2100-oc-build
git -C src/floppy worktree list
```

Esse alvo é explícito e criado por esta missão. O comando não toca o clone
forense `src/floppy`, os diretórios legados em `/home/lucas/kernel-sources`,
o WorkspaceAI externo ao projeto ou dados do usuário.

## Desfazer mudanças do projeto de documentação/scripts

Os commits do projeto são independentes da fonte Floppy. Para revisar ou
reverter uma mudança específica sem apagar histórico:

```bash
git -C '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC' log --oneline --decorate
git -C '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC' revert COMMIT
```

Use o SHA exibido pelo primeiro comando para `COMMIT`. Isso cria um novo
commit reversível; não reescreve histórico e não altera `src/floppy`.

## Confirmar artefatos antes de usar ou arquivar

```bash
cd '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
(cd packages && sha256sum -c SHA256SUMS)
./tools/verify-package.sh packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip
```

O SHA256 do ZIP principal é
`3db0228e2329239126d8201e8068de76c8834d74eb38fc7ceafd483d95e27ef4`.
Se um futuro flash for feito sob revisão humana e for necessário retornar, use
apenas um pacote Floppy anterior cujo modelo/layout/partição tenham sido
confirmados pelo usuário. Esta missão não inventa um comando de flash ou
partição, porque nenhum S21 físico foi identificado.

## Rollback da continuação GPU1092

O ZIP de rollback confirmado é:

```bash
cd '/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
sha256sum -c packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip.sha256
./tools/verify-package.sh packages/Floppy_v1.1.2-KSUNext-SUSFS-exynos2100-949-ROLLBACK-20260813-0242.zip
```

Depois de um teste manual GPU1092, o retorno no recovery deve usar **esse ZIP
949**, somente se o modelo/layout tiver sido conferido no próprio recovery. Não
há comando de flash automatizado neste projeto.

Para remover apenas o worktree experimental local (não execute se quiser
preservar fonte de diagnóstico), primeiro preserve os ZIPs e confirme que não
há alterações:

```bash
project='/home/lucas/Área de trabalho/WorkspaceAI/Codex/02-Projects/Floppy-Exynos2100-OC'
git -C "$project/build/floppy-gpu1092-source" status --short
git -C "$project/src/floppy" worktree remove "$project/build/floppy-gpu1092-source"
git -C "$project/src/floppy" branch -D floppy-exynos2100-g3d-1092-test
git -C "$project/src/floppy" status --short
git -C "$project/src/floppy" rev-parse HEAD
```

O último hash deve ser `af9e70e6af7aa7f66903d883cd677b9147424ed1`. Esses
comandos só removem o worktree identificado, nunca a baseline nem os pacotes.
