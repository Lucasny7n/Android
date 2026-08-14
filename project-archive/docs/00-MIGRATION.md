# Migração do trabalho anterior

## Origem preservada

Em 2026-08-13 foi inspecionado, sem alteração, o worktree externo
`/home/lucas/kernel-sources/floppy-exynos2100-1091`:

- HEAD: `d69b0cd249f4e92692b32925aba91cb39c3ee350`.
- Base ancestral declarada: Floppy `af9e70e6af7aa7f66903d883cd677b9147424ed1`.
- Estado: branch `floppy-exynos2100-1091`, sem alterações não rastreadas.
- Submódulos não inicializados: `build/mkbootimg` em `d2bb0af...` e
  `build/nh/firmware` em `50f2c42...`.

O bare repository externo também foi somente lido: `floppy-main` apontava a
`af9e70e`, e `proton/testing` a `79d7da6`.

## Evidência migrada

| Origem | Destino | SHA256 | Resultado |
|---|---|---|---|
| `PROTON_CANDIDATES.md` | `evidence/baseline/PROTON_CANDIDATES.previous.md` | `86b3154abf930941af87f5aac1ffd4a8bcf273d49d4fbdbb6624978bddcf0fa5` | PASS |
| `GPU_1091_BLOCKER.md` | `evidence/baseline/GPU_1091_BLOCKER.previous.md` | `25d6b697d74656bd974dfbc21164af0a79be40d3e815c466eab50ac6ea047468` | PASS |

Os arquivos foram copiados preservando atributos. Seus hashes no destino são
idênticos aos da origem. Eles são histórico forense, não prova suficiente para
modificar o kernel: todas as conclusões serão comparadas novamente contra as
fontes oficiais em `src/`.

## Limite operacional

Após a migração, trabalho novo, fontes clonadas, scripts, evidências, builds e
documentos pertencem exclusivamente a este `PROJECT_ROOT`. Os caminhos externos
não serão apagados, modificados ou usados como local de build.
