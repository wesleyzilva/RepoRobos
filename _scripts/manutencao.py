"""
manutencao.py — Script mestre de manutenção e auditoria do repositório
=====================================================================
Roda TODOS os checks de saúde do projeto em sequência, exibe um relatório
consolidado e retorna exit code 0 (tudo ok) ou 1 (algum problema).

Uso:
    python _scripts/manutencao.py              # auditoria completa
    python _scripts/manutencao.py --fix        # auditoria + corrigir NTSL auto
    python _scripts/manutencao.py --git        # auditoria + push automático
    python _scripts/manutencao.py --all        # auditoria + fix + push

O que este script verifica:
  1. Sintaxe NTSL/NTFL (validate_ntsl.py)
  2. Contexto macro diário (contexto_diario.py)
  3. Git status — arquivos pendentes de commit
  4. Estrutura do repositório — pastas obrigatórias existem
  5. Skills — verificar se nenhuma skill está vazia ou truncada
  6. Backtest pendente — CSVs sem análise associada
"""

import subprocess
import sys
import os
import glob
from pathlib import Path
from datetime import datetime

# ── CONFIG ──────────────────────────────────────────────────────────────────
REPO_ROOT = Path(__file__).parent.parent
SCRIPTS   = REPO_ROOT / "_scripts"
PYTHON    = sys.executable  # usa o mesmo Python que está rodando este script

# Pastas obrigatórias do repositório
PASTAS_OBRIGATORIAS = [
    "skills", "templates", "robos", "scripts", "_scripts",
    "docs", "agents", ".github/prompts", "DadosCandlesBacktest",
    "backtest_resultados",
]

# Skills que devem existir
SKILLS_OBRIGATORIAS = [
    "skill_ntsl_syntax.md",
    "skill_gestao_risco.md",
    "skill_confluencia_geometrica.md",
    "skill_price_action.md",
    "skill_padroes_geometricos.md",
    "skill_probabilidade_operacional.md",
    "skill_contexto_longo_prazo.md",
    "skill_WIN_caracteristicas.md",
    "skill_WDO_caracteristicas.md",
    "skill_estatisticas_backtest.md",
]

# ── CORES ───────────────────────────────────────────────────────────────────
GREEN  = "\033[92m"
YELLOW = "\033[93m"
RED    = "\033[91m"
BOLD   = "\033[1m"
DIM    = "\033[2m"
RESET  = "\033[0m"

def ok(msg):   print(f"  {GREEN}✅ {msg}{RESET}")
def warn(msg): print(f"  {YELLOW}⚠️  {msg}{RESET}")
def fail(msg): print(f"  {RED}❌ {msg}{RESET}")
def head(msg): print(f"\n{BOLD}{'─'*60}{RESET}\n{BOLD}  {msg}{RESET}")
def dim(msg):  print(f"  {DIM}{msg}{RESET}")

# ── HELPERS ─────────────────────────────────────────────────────────────────

def run(cmd: str, cwd: Path = REPO_ROOT) -> tuple[int, str, str]:
    """Executa comando e retorna (returncode, stdout, stderr)."""
    result = subprocess.run(
        cmd, shell=True, capture_output=True, text=True, cwd=str(cwd)
    )
    return result.returncode, result.stdout.strip(), result.stderr.strip()


def run_script(script_name: str, extra_args: str = "") -> tuple[bool, str]:
    """Roda um script em _scripts/ e retorna (sucesso, output)."""
    script = SCRIPTS / script_name
    if not script.exists():
        return False, f"Script não encontrado: {script}"
    code, out, err = run(f'"{PYTHON}" "{script}" {extra_args}')
    return code == 0, (out + "\n" + err).strip()


# ── CHECKS ───────────────────────────────────────────────────────────────────

def check_ntsl(fix: bool = False) -> bool:
    """Valida todos os arquivos NTSL/NTFL do repositório."""
    head("1. VALIDAÇÃO NTSL/NTFL")
    args = "--fix" if fix else ""
    ok_result, output = run_script("validate_ntsl.py", args)

    # Extrai resumo das últimas linhas
    lines = output.splitlines()
    for line in lines[-8:]:
        if line.strip():
            dim(f"  {line}")

    if ok_result:
        ok("Todos os arquivos NTSL/NTFL passaram na validação")
    else:
        fail("Erros encontrados nos arquivos NTSL/NTFL — ver detalhes acima")
    return ok_result


def check_contexto() -> bool:
    """Exibe o contexto macro do dia."""
    head("2. CONTEXTO MACRO DO DIA")
    ok_result, output = run_script("contexto_diario.py", "--ativo WINFUT")

    lines = output.splitlines()
    for line in lines:
        if line.strip():
            dim(f"  {line}")

    return True  # contexto não falha — é informativo


def check_git() -> bool:
    """Verifica o status do Git."""
    head("3. STATUS GIT")
    code, out, err = run("git status --short")
    code_branch, branch, _ = run("git branch --show-current")
    code_log, last_commit, _ = run("git log --oneline -1")

    print(f"  Branch:       {BOLD}{branch}{RESET}")
    print(f"  Último commit: {last_commit}")

    if out:
        linhas = out.splitlines()
        warn(f"{len(linhas)} arquivo(s) com alterações não commitadas:")
        for l in linhas[:10]:
            dim(f"    {l}")
        if len(linhas) > 10:
            dim(f"    ... e mais {len(linhas)-10} arquivo(s)")
        return False
    else:
        ok("Working tree limpa — sem pendências de commit")
        return True


def check_estrutura() -> bool:
    """Verifica se as pastas obrigatórias existem."""
    head("4. ESTRUTURA DO REPOSITÓRIO")
    tudo_ok = True
    for pasta in PASTAS_OBRIGATORIAS:
        p = REPO_ROOT / pasta
        if p.exists():
            ok(pasta)
        else:
            fail(f"{pasta}  ← PASTA AUSENTE")
            tudo_ok = False
    return tudo_ok


def check_skills() -> bool:
    """Verifica se todas as skills obrigatórias existem e têm conteúdo."""
    head("5. SKILLS OBRIGATÓRIAS")
    tudo_ok = True
    skills_dir = REPO_ROOT / "skills"
    for skill in SKILLS_OBRIGATORIAS:
        p = skills_dir / skill
        if not p.exists():
            fail(f"{skill}  ← AUSENTE")
            tudo_ok = False
        else:
            size = p.stat().st_size
            if size < 500:
                warn(f"{skill}  ({size} bytes — provavelmente vazia)")
                tudo_ok = False
            else:
                ok(f"{skill}  ({size:,} bytes)")
    return tudo_ok


def check_backtests() -> bool:
    """Lista CSVs de backtest e verifica se há análises associadas."""
    head("6. BACKTESTS PENDENTES DE ANÁLISE")
    bt_dir = REPO_ROOT / "backtest_resultados"
    csvs = [f for f in glob.glob(str(bt_dir / "**" / "*.csv"), recursive=True)
            if "EXEMPLO" not in f.upper()]

    if not csvs:
        warn("Nenhum CSV de backtest encontrado em backtest_resultados/")
        return True

    pendentes = []
    for csv_path in csvs:
        nome = Path(csv_path).stem
        # Verificar se existe um .md de análise correspondente
        md_path = Path(csv_path).with_suffix(".md")
        anotacoes = REPO_ROOT / "anotacoes"
        tem_analise = md_path.exists() or any(
            nome.lower() in f.name.lower()
            for f in anotacoes.glob("*.md")
        ) if anotacoes.exists() else False

        if tem_analise:
            ok(f"{Path(csv_path).relative_to(bt_dir)}")
        else:
            pendentes.append(Path(csv_path).relative_to(bt_dir))

    if pendentes:
        warn(f"{len(pendentes)} backtest(s) sem análise documentada:")
        for p in pendentes:
            dim(f"    {p}")
        dim("  → Rodar: python scripts/analisa_backtest_profit.py backtest_resultados/<arquivo>")
    else:
        ok("Todos os backtests têm análise associada")

    return len(pendentes) == 0


def git_push() -> bool:
    """Executa add + commit + push automático."""
    head("🚀 GIT PUSH AUTOMÁTICO")
    code, out, _ = run("git status --short")
    if not out:
        ok("Nada para commitar")
        return True

    timestamp = datetime.now().strftime("%d/%m %H:%M")
    msg = f"chore: manutencao automatica [{timestamp}]"

    print(f"  Commitando com: {msg}")
    run("git add .")
    c, o, e = run(f'git commit -m "{msg}"')
    if c != 0:
        fail(f"Erro no commit: {e}")
        return False

    # SSL workaround (proxy corporativo)
    run("git config --local http.sslVerify false")
    c2, o2, e2 = run("git push origin abril_teoria")
    if c2 == 0:
        ok("Push realizado com sucesso")
        return True
    else:
        fail(f"Erro no push: {e2}")
        return False


# ── MAIN ─────────────────────────────────────────────────────────────────────

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Auditoria e manutenção do RepoRobos")
    parser.add_argument("--fix", action="store_true", help="Corrigir erros NTSL automaticamente")
    parser.add_argument("--git", action="store_true", help="Fazer push após auditoria")
    parser.add_argument("--all", action="store_true", help="Fix + push (equivalente a --fix --git)")
    args = parser.parse_args()

    if args.all:
        args.fix = True
        args.git = True

    print()
    print(f"{BOLD}{'='*60}{RESET}")
    print(f"{BOLD}  AUDITORIA REPOROBOS — {datetime.now().strftime('%d/%m/%Y %H:%M')}{RESET}")
    print(f"{BOLD}{'='*60}{RESET}")

    resultados = {}
    resultados["NTSL"]       = check_ntsl(fix=args.fix)
    resultados["Contexto"]   = check_contexto()
    resultados["Git"]        = check_git()
    resultados["Estrutura"]  = check_estrutura()
    resultados["Skills"]     = check_skills()
    resultados["Backtests"]  = check_backtests()

    if args.git:
        resultados["Push"] = git_push()

    # ── SUMÁRIO FINAL ────────────────────────────────────────────────────────
    print()
    print(f"{BOLD}{'─'*60}{RESET}")
    print(f"{BOLD}  SUMÁRIO FINAL{RESET}")
    print(f"{BOLD}{'─'*60}{RESET}")

    tudo_ok = True
    for check, passou in resultados.items():
        if passou:
            ok(check)
        else:
            fail(check)
            if check != "Contexto":  # contexto é sempre informativo
                tudo_ok = False

    print()
    if tudo_ok:
        print(f"{GREEN}{BOLD}  ✅ REPOSITÓRIO EM BOA SAÚDE — pronto para operar{RESET}")
    else:
        print(f"{YELLOW}{BOLD}  ⚠️  ATENÇÃO: há itens que requerem revisão{RESET}")
        print(f"{DIM}  Rodar com --fix para corrigir o que for automático{RESET}")
    print()

    sys.exit(0 if tudo_ok else 1)


if __name__ == "__main__":
    main()
