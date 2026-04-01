# Guia de Commits — RepoRobos

## Formato Padrão

```
<tipo>(<escopo>): <descrição breve> [DD/MM HH:MM]
```

O **timestamp** é obrigatório no final — facilita rastreamento no log e nos prompts de sessão.

### Comando para commitar com timestamp (bash / MINGW64):

```bash
git commit -m "Descrição da mudança [$(date +%d/%m\ %H:%M)]"
```

---

## Tipos de Commit

| Tipo | Uso |
|------|-----|
| `feat` | Nova funcionalidade, novo robô, nova lógica |
| `fix` | Correção de bug ou erro de compilação |
| `docs` | Alterações em arquivos `.md` |
| `style` | Formatação, cores, comentários (sem mudança de lógica) |
| `refactor` | Refatoração sem mudança de comportamento |
| `perf` | Melhoria de performance (ex: ajuste de parâmetros ATR) |
| `chore` | Tarefas gerais: organização de pastas, renomeação |
| `visual` | Mudança de esquema de cores / PaintBar |

---

## Escopos Comuns

| Escopo | Descrição |
|--------|-----------|
| `robo` | Robôs `.ntsl` |
| `indicador` | Indicadores / colorações `.ntfl` |
| `docs` | Documentação `.md` |
| `skills` | Arquivos em `skills/` |
| `config` | Scripts, validador, configuração |
| `git` | Workarounds e configurações de git |

---

## Exemplos

```
feat(robo): adicionar FORCA_SAIDA_TRAILING_60MIN com ATR [01/04 10:15]
fix(indicador): corrigir parse error missing ; em if/else chain [01/04 11:30]
visual(robo): novo esquema de cores branco/cinza/laranja [01/04 14:32]
docs(skills): consolidar EstrategiasStop com tabelas por TF [01/04 16:00]
chore: mover exemplos Profit para skills/exemplos_profit [31/03 09:45]
```

---

## Subir para o remoto (workaround SSL proxy corporativo)

```bash
git -c http.sslVerify=false push origin abril_teoria
```

> Não altera configuração global — apenas para o comando atual.
> Documentação completa: `devThings/git_ssl_proxy_workaround.md`
