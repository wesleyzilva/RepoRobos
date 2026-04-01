#!/usr/bin/env bash
# =============================================================================
# git_push.sh — Fluxo completo: validar → add → commit → push
#
# Uso:
#   bash _scripts/git_push.sh "tipo(escopo): descricao"
#   bash _scripts/git_push.sh "tipo(escopo): descricao" arquivo1.ntsl arquivo2.ntsl
#
# Exemplos:
#   bash _scripts/git_push.sh "feat(SEMAFORO): nova logica multi-TF"
#   bash _scripts/git_push.sh "fix(OCO): corrige stop ATR" robos/PADROES/FORCA_SAIDA_OCO.ntsl
#
# Comportamento padrão (sem arquivos específicos):
#   - Valida TODOS os .ntsl e .ntfl modificados (git diff)
#   - Faz git add de todos os arquivos modificados (git add -A)
# =============================================================================

set -e

BRANCH=$(git rev-parse --abbrev-ref HEAD)
TIMESTAMP=$(date +"%d/%m %H:%M")
MSG="$1"

if [[ -z "$MSG" ]]; then
  echo "❌  Uso: bash _scripts/git_push.sh \"tipo(escopo): descricao\" [arquivo1 arquivo2 ...]"
  exit 1
fi

# --- Arquivos a validar ---
shift  # remove o MSG dos argumentos; restam os arquivos opcionais

if [[ $# -gt 0 ]]; then
  ARQUIVOS=("$@")
else
  # Pega todos os .ntsl/.ntfl modificados ou staged
  mapfile -t ARQUIVOS < <(git status --short | awk '{print $2}' | grep -E '\.(ntsl|ntfl)$' || true)
fi

# --- Validação ---
if [[ ${#ARQUIVOS[@]} -gt 0 ]]; then
  echo ""
  echo "🔍  Validando ${#ARQUIVOS[@]} arquivo(s)..."
  ERROS=0
  for f in "${ARQUIVOS[@]}"; do
    if [[ -f "$f" ]]; then
      python _scripts/validate_ntsl.py --file "$f" || ERROS=$((ERROS + 1))
    fi
  done
  if [[ $ERROS -gt 0 ]]; then
    echo ""
    echo "❌  $ERROS arquivo(s) com erro. Corrija antes de commitar."
    exit 1
  fi
  echo "✅  Validação OK"
else
  echo "ℹ️   Nenhum .ntsl/.ntfl modificado — pulando validação"
fi

# --- Add ---
echo ""
echo "📦  git add -A"
git add -A

# --- Commit ---
FULL_MSG="${MSG} [${TIMESTAMP}]"
echo "💬  Commitando: ${FULL_MSG}"
git commit -m "$FULL_MSG"

# --- Push com workaround SSL ---
echo ""
echo "🚀  Push → origin/${BRANCH}"
git config --local http.sslVerify false
git push origin "$BRANCH"

echo ""
echo "✅  Concluído: origin/${BRANCH} atualizado"
