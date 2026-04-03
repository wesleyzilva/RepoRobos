# Guia de Commits — RepoRobos

## 🚀 Fluxo Automatizado (RECOMENDADO)

Para evitar erros de SSL, formatação de data no PowerShell e esquecimento de logs, use o script Python. Ele valida o código, atualiza o `SESSION_LOG.md` e sobe para o GitHub.

**No Terminal (PowerShell):**
```powershell
# Tente primeiro com 'python'
python _scripts/sync_session.py "feat(robo): descricao da logica"

# Se 'python' abrir a Windows Store, use 'py'
py _scripts/sync_session.py "feat(robo): descricao da logica"
```

---

## 🛠️ Sincronizar Manualmente (Fallback)

Antes de iniciar qualquer alteração, garanta que seu repositório local está atualizado com o remoto:

```bash
git fetch --all   # Busca todas as atualizações do remoto
git pull          # Atualiza sua branch local com as mudanças do remoto
```

> Sempre execute esses comandos antes de editar, commitar ou criar novos arquivos, para evitar conflitos e garantir que está trabalhando na versão mais recente.

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

## Fluxo via script (RECOMENDADO — um único comando)

```bash
# Commita e sobe tudo de uma vez (valida automaticamente os .ntsl/.ntfl modificados)
bash _scripts/git_push.sh "tipo(escopo): descricao"

# Exemplo com arquivos específicos
bash _scripts/git_push.sh "feat(SEMAFORO): nova logica" robos/PADROES/FORCA_SEMAFORO_CORES_SOM.ntfl
```

O script executa na ordem:
1. `validate_ntsl.py` em todos os `.ntsl`/`.ntfl` modificados — aborta se houver erro
2. `git add -A`
3. `git commit` com timestamp automático `[DD/MM HH:MM]`
4. `git config --local http.sslVerify false; git push origin <branch>`

---

## Fluxo manual completo antes do push (fallback)

```bash
# 1. Validar sintaxe (ANTES do commit)
python _scripts/validate_ntsl.py --file <arquivo.ntsl>

# 2. Commitar apenas após "TUDO LIMPO"
git add <arquivo>
git commit -m "tipo(escopo): descrição [$(date +%d/%m\ %H:%M)]"

# 3. Push com workaround SSL
git config --local http.sslVerify false; git push origin <branch>
```

---

## Workaround SSL proxy corporativo — comando correto

```bash
git config --local http.sslVerify false; git push origin abril_teoria
```

> ⚠️ **Evidência de terminal (01/04/2026):**
>
> | Comando | Resultado |
> |---|---|
> | `git -c http.sslVerify=false push` | ❌ `remote helper 'https' aborted session` (EXIT:130) |
> | `git config http.sslVerify false && git push` | ❌ `remote helper 'https' aborted session` (EXIT:130) |
> | `git -C /path push` (sem ssl config) | ❌ sem output, EXIT:130 |
> | `git config --local http.sslVerify false; git push` | ✅ **funciona sempre** |
>
> **Motivo:** o `;` executa os dois comandos no mesmo processo de shell.
> O `&&` em alguns contextos interrompe a sessão antes do push ser iniciado.
> O `-c` inline não persiste corretamente com o backend `schannel`.
