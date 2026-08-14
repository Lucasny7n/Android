# Triagem de skills

Data: 2026-08-13. A busca de manifests `SKILL.md` confirmou que não há skill
instalada específica para Linux kernel, Android kernel, Exynos, Mali, ADB,
toolchain Android ou build de kernel. Não foram carregadas skills em massa.

| Skill candidata | Caminho | Finalidade | Decisão |
|---|---|---|---|
| `github:github` | cache do plugin GitHub | orientar contexto de repositórios GitHub | USADA para definir a consulta de fontes com Git local; o conector GitHub não está exposto nesta sessão. |
| `github:gh-fix-ci` | cache do plugin GitHub | CI de pull request | REJEITADA: não há PR/Actions da missão. |
| `github:gh-address-comments` | cache do plugin GitHub | comentários de PR | REJEITADA: não há PR ou comentários. |
| `github:yeet` | cache do plugin GitHub | publicar PR | REJEITADA: sem autorização para publicar. |
| `openai-docs` | `/home/lucas/.codex/skills/.system/openai-docs` | documentação de produtos OpenAI | REJEITADA: não é necessária para código de kernel. |
| `skill-creator` | `/home/lucas/.codex/skills/.system/skill-creator` | criar skills Codex | REJEITADA: criar uma skill global ou artificial não melhora esta missão; scripts locais serão usados se necessários. |
| `plugin-creator` / `skill-installer` | system skills | plugins/instalação de skills | REJEITADAS: não instalar nem alterar capacidades globais. |
| `imagegen` | system skill | imagens raster | REJEITADA: artefatos são código, texto e logs. |
| Google Drive / Docs / Sheets / Slides | plugins | documentos remotos | REJEITADAS: a política requer documentos locais no WorkspaceAI. |

Skills fora desta tabela foram agrupadas na busca por terem escopo claramente
alheio (web, iOS, CRM, finanças, design, vídeo, nuvem, e-mail etc.). Nenhuma
foi carregada ou ativada.

## Reavaliação — continuação GPU1092 (2026-08-13)

A triagem foi refeita antes da implementação experimental. O inventário ainda
não oferece skill específica para kernel Linux/Android, Exynos, Mali, CAL,
FVMAP, ACPM, ADB ou análise estática de device tree. `github:github` continua
sendo a única skill pertinente: foi usada apenas para orientar a busca de
fontes GitHub; a leitura e a implementação foram feitas em clones locais e
fontes primárias. As skills de CI/PR, criação/instalação de skills, imagem e
Google Drive permanecem rejeitadas pelo mesmo motivo já registrado acima.
