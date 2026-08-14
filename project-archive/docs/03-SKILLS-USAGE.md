# Uso de skills

| Data | Skill | Etapa | Entrada | Saída / impacto | Estado |
|---|---|---|---|---|---|
| 2026-08-13 | `github:github` | descoberta de fontes | URLs Floppy e Proton fornecidas | A skill determinou que contexto local e Git são fallback adequado quando não há conector de repositório/PR exposto. Clones oficiais serão mantidos em `src/`. | PASS |

Nenhuma skill global foi criada, modificada, ativada ou instalada. Nenhuma skill
rejeitada influenciou decisões de kernel.

| 2026-08-13 | `github:github` | pesquisa FVMAP/ACPM/precedentes 1092 | consultas de commits e código público, com Git local como mecanismo de leitura | confirmou que não há precedente Exynos2100 confiável de expansão de FVMAP G3D; a implementação adotou guardas estritos e ficou marcada experimental. | PASS |

Não houve skill para substituir análise de kernel: a decisão de projeto foi
tomada a partir de `fvmap.c`, CAL, VCLK, DTS, driver Mali e da coleta root
versionada no próprio projeto.
