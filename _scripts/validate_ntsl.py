"""
validate_ntsl.py — Validador e corretor automatico de sintaxe NTSL/NTFL
Uso:
  python _scripts/validate_ntsl.py              # valida todos os arquivos
  python _scripts/validate_ntsl.py --fix        # valida + corrige o que for seguro
  python _scripts/validate_ntsl.py --file x.ntsl  # valida arquivo especifico
"""

import os
import re
import sys
import glob
import argparse
from pathlib import Path

# ─────────────────────────────────────────────────────────────────────────────
# REGRAS DE ERROS
# Cada regra: (id, descricao, regex, tipo, auto_fix_fn ou None)
#   tipo: ERROR | WARNING
#   auto_fix_fn: funcao(linha_str) -> linha_corrigida  (None = nao corrigivel)
# ─────────────────────────────────────────────────────────────────────────────

def _fix_single_quotes(line):
    """Troca aspas simples por duplas em strings de codigo (nao em comentarios)."""
    code, _, comment = line.partition("//")
    if "'" in code:
        # Substitui pares de aspas simples por duplas
        fixed = re.sub(r"'([^']*)'", r'"\1"', code)
        return fixed + ("//" + comment if comment else "")
    return line

RULES = [
    # id, descricao, padrao regex, tipo, auto_fix
    (
        "E01",
        "Hour() nao existe — usar Time() >= H*10000+M*100",
        r"\bHour\s*\(",
        "ERROR",
        None,
    ),
    (
        "E02",
        "Minute() nao existe — usar Time() >= H*10000+M*100",
        r"\bMinute\s*\(",
        "ERROR",
        None,
    ),
    (
        "E03",
        "Exit; nao existe — usar bDeveOperar := false",
        r"\bExit\s*;",
        "ERROR",
        None,
    ),
    (
        "E04",
        "Operador 'div' nao existe em NTSL — Time() div 10000 FALHA",
        r"\bdiv\b",
        "ERROR",
        None,
    ),
    (
        "E05",
        "Operador 'mod' nao existe em NTSL",
        r"\bmod\b",
        "ERROR",
        None,
    ),
    (
        "E06",
        "Format() nao existe — usar IntToStr(Round(x))",
        r"\bFormat\s*\(",
        "ERROR",
        None,
    ),
    (
        "E07",
        "Floor() nao existe — usar divisao inteira manual",
        r"\bFloor\s*\(",
        "ERROR",
        None,
    ),
    (
        "E08",
        "DrawArrow() invalido — usar PlotText() + PaintBar() em .ntfl",
        r"\bDrawArrow\s*\(",
        "ERROR",
        None,
    ),
    (
        "E09",
        "String com aspas simples — NTSL exige aspas duplas \"\"",
        r"'[^']{0,80}'",
        "ERROR",
        _fix_single_quotes,
    ),
    (
        "E10",
        "IntToStr() como 1o arg de PlotText() — PlotText exige string literal",
        r'PlotText\s*\(\s*IntToStr\s*\(',
        "ERROR",
        None,
    ),
    (
        "E11",
        "PlotText() em .ntsl — so funciona em indicadores .ntfl",
        r"\bPlotText\s*\(",
        "ERROR",
        None,  # so aplica em .ntsl
        # filtrada por extensao abaixo
    ),
    (
        "E12",
        "Alert() em .ntsl — so funciona em indicadores .ntfl",
        r"\bAlert\s*\(",
        "ERROR",
        None,  # filtrada por extensao abaixo
    ),
    (
        "W01",
        "Condicao multi-linha: 'and' inicio de linha pode ser parser risk — verifique se ha paren externo no if",
        r"^\s{4,}and\s+(?!.*then\s*$)[^(]",
        "WARNING",
        None,
    ),
    (
        "W02",
        "Condicao multi-linha: 'or' inicio de linha pode ser parser risk — verifique se ha paren externo no if",
        r"^\s{4,}or\s+(?!.*then\s*$)[^(]",
        "WARNING",
        None,
    ),
    (
        "W03",
        "Variavel com espaco no nome (ex: bAcelerando Alta) — identificador invalido",
        r"\b[a-z][a-zA-Z0-9]+ [A-Z][a-zA-Z0-9]+\s*:=",
        "WARNING",
        None,
    ),
    (
        "W04",
        "ClosePosition() com parenteses — sintaxe correta e ClosePosition sem ()",
        r"\bClosePosition\s*\(\s*\)",
        "WARNING",
        lambda l: l.replace("ClosePosition()", "ClosePosition"),
    ),
]

# Regras que so se aplicam a .ntsl (nao a .ntfl)
NTSL_ONLY_RULES = {"E11", "E12"}

# ─────────────────────────────────────────────────────────────────────────────
# VALIDADOR
# ─────────────────────────────────────────────────────────────────────────────

def is_comment(line):
    return line.strip().startswith("//")

def validate_file(filepath, fix=False):
    ext = Path(filepath).suffix.lower()
    issues = []
    lines_fixed = []
    fixed_count = 0

    with open(filepath, "r", encoding="utf-8") as f:
        lines = f.readlines()

    begin_count = sum(1 for l in lines if re.search(r'\bbegin\b', l) and not is_comment(l))
    end_count   = sum(1 for l in lines if re.search(r'\bend\b',   l) and not is_comment(l))
    if begin_count != end_count:
        issues.append({
            "line": 0,
            "rule": "E13",
            "type": "ERROR",
            "desc": f"begin/end desbalanceados: {begin_count} begin vs {end_count} end",
            "content": "",
        })

    for i, line in enumerate(lines, 1):
        stripped = line.rstrip("\n")
        new_line = stripped

        if is_comment(stripped):
            lines_fixed.append(line)
            continue

        for (rule_id, desc, pattern, rtype, fix_fn) in RULES:
            # Filtrar regras que so se aplicam a .ntsl
            if rule_id in NTSL_ONLY_RULES and ext != ".ntsl":
                continue
            # Suprimir regra se linha tem comentario // noqa:RuleId
            if f"// noqa:{rule_id}" in stripped:
                continue

            if re.search(pattern, stripped):
                issues.append({
                    "line": i,
                    "rule": rule_id,
                    "type": rtype,
                    "desc": desc,
                    "content": stripped.strip(),
                })
                if fix and fix_fn:
                    new_line = fix_fn(new_line)
                    fixed_count += 1

        lines_fixed.append(new_line + "\n")

    if fix and fixed_count > 0:
        with open(filepath, "w", encoding="utf-8") as f:
            f.writelines(lines_fixed)

    return issues, fixed_count

# ─────────────────────────────────────────────────────────────────────────────
# RELATORIO
# ─────────────────────────────────────────────────────────────────────────────

COLORS = {
    "ERROR":   "\033[91m",  # vermelho
    "WARNING": "\033[93m",  # amarelo
    "OK":      "\033[92m",  # verde
    "RESET":   "\033[0m",
    "BOLD":    "\033[1m",
    "DIM":     "\033[2m",
}

def color(text, key):
    return COLORS.get(key, "") + text + COLORS["RESET"]

def print_report(results):
    total_errors = 0
    total_warnings = 0
    total_fixed = 0
    files_with_issues = 0

    print()
    print(color("=" * 70, "BOLD"))
    print(color("  VALIDADOR NTSL/NTFL", "BOLD"))
    print(color("=" * 70, "BOLD"))

    for filepath, issues, fixed in results:
        rel = os.path.relpath(filepath, start=os.path.dirname(os.path.dirname(__file__)))
        errors   = [i for i in issues if i["type"] == "ERROR"]
        warnings = [i for i in issues if i["type"] == "WARNING"]

        if not issues:
            print(color(f"  OK  {rel}", "OK"))
        else:
            files_with_issues += 1
            print()
            print(color(f"  {rel}", "BOLD"))
            for issue in sorted(issues, key=lambda x: x["line"]):
                tag = color(f"[{issue['type']}]", issue["type"])
                loc = color(f"linha {issue['line']:>3}", "DIM") if issue["line"] else color("      ", "DIM")
                print(f"    {tag} {loc}  {issue['rule']}  {issue['desc']}")
                if issue["content"]:
                    print(color(f"           → {issue['content'][:80]}", "DIM"))

        if fixed > 0:
            print(color(f"    ✓ {fixed} correção(ões) aplicada(s)", "OK"))
            total_fixed += fixed

        total_errors   += len(errors)
        total_warnings += len(warnings)

    print()
    print(color("─" * 70, "DIM"))
    print(f"  Arquivos: {len(results)}   "
          + color(f"Erros: {total_errors}", "ERROR" if total_errors else "OK")
          + "   "
          + color(f"Avisos: {total_warnings}", "WARNING" if total_warnings else "OK")
          + (color(f"   Corrigidos: {total_fixed}", "OK") if total_fixed else ""))
    print(color("─" * 70, "DIM"))

    if total_errors == 0 and total_warnings == 0:
        print(color("  TUDO LIMPO — pronto para compilar no Profit!", "OK"))
    elif total_errors > 0:
        print(color(f"  {total_errors} ERRO(S) encontrado(s) — corrigir antes de compilar", "ERROR"))
    else:
        print(color(f"  {total_warnings} AVISO(S) — revisar antes de compilar", "WARNING"))
    print()

# ─────────────────────────────────────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description="Validador NTSL/NTFL")
    parser.add_argument("--fix",  action="store_true", help="Aplicar correcoes automaticas seguras")
    parser.add_argument("--file", type=str, default=None, help="Validar arquivo especifico")
    args = parser.parse_args()

    repo_root = Path(__file__).parent.parent

    if args.file:
        files = [args.file]
    else:
        files = sorted(
            glob.glob(str(repo_root / "**" / "*.ntsl"), recursive=True) +
            glob.glob(str(repo_root / "**" / "*.ntfl"), recursive=True)
        )

    if not files:
        print("Nenhum arquivo .ntsl ou .ntfl encontrado.")
        sys.exit(0)

    results = []
    for f in files:
        issues, fixed = validate_file(f, fix=args.fix)
        results.append((f, issues, fixed))

    print_report(results)

    has_errors = any(
        i["type"] == "ERROR"
        for _, issues, _ in results
        for i in issues
    )
    sys.exit(1 if has_errors else 0)

if __name__ == "__main__":
    main()
