import os
import subprocess
import datetime
import sys
import socket
from pathlib import Path

def run_command(command, description):
    print(f"--- {description} ---")
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"Erro: {result.stderr}")
        return False, result.stderr
    print(result.stdout)
    return True, result.stdout

def get_ip():
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except: return "127.0.0.1"

def update_session_log(activity, timestamp, commit_hash="pending", ip="0.0.0.0"):
    log_path = Path("e:/repo/RepoRobos_AbrilTeoria/SESSION_LOG.md")
    if not log_path.exists():
        print("Erro: SESSION_LOG.md não encontrado.")
        return False

    with open(log_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    new_lines = []
    in_last_activity = False
    
    for line in lines:
        if "## 🚀 Última Atividade" in line:
            in_last_activity = True
            new_lines.append(line)
            new_lines.append(f"- **Data/Hora:** [{timestamp}]\n")
            new_lines.append(f"- **Status Git:** ✅ Sincronizado com `origin/abril_teoria`\n")
            new_lines.append(f"- **Onde parei:** {activity}\n")
            continue
        
        if in_last_activity and line.startswith("- "):
            continue
        elif in_last_activity and (line.startswith("---") or line.strip() == ""):
            in_last_activity = False
        
        if not in_last_activity:
            new_lines.append(line)

    # Adiciona ao histórico de sessões
    date_str, time_str = timestamp.split(' ')
    # Formato: | Data | Hora | Atividade | Commit | IP | Sync? |
    history_line = f"| {date_str} | {time_str} | {activity} | {commit_hash} | {ip} | Sim |\n"
    new_lines.append(history_line)

    with open(log_path, "w", encoding="utf-8") as f:
        f.writelines(new_lines)
    return True

def display_log_summary():
    """Lê o SESSION_LOG.md e exibe um resumo no terminal."""
    log_path = Path("e:/repo/RepoRobos_AbrilTeoria/SESSION_LOG.md")
    if not log_path.exists(): return
    
    print("\n" + "="*81)
    print("📑 RESUMO DO DIÁRIO DE BORDO (SESSION_LOG.md)")
    print("="*81)
    
    with open(log_path, "r", encoding="utf-8") as f:
        lines = f.readlines()
        
    # Exibe bloco de Última Atividade
    show_activity = False
    for line in lines:
        if "## 🚀 Última Atividade" in line:
            show_activity = True
            continue
        if show_activity and line.startswith("---"):
            break
        if show_activity and line.strip():
            print(line.strip())
    
    print("-" * 81)
    # Exibe as últimas 3 linhas do histórico (tabela)
    table_rows = [l.strip() for l in lines if "|" in l and not l.strip().startswith("| :---")]
    for row in table_rows[-4:]: # Cabeçalho + últimas 3 entradas
        print(row)
    print("="*81 + "\n")

def main():
    if len(sys.argv) < 2:
        print("Uso: python sync_session.py \"tipo(escopo): descricao da atividade\"")
        return

    full_msg = sys.argv[1]
    # Extrai apenas a parte da descrição para o SESSION_LOG
    activity = full_msg.split(":")[-1].strip() if ":" in full_msg else full_msg
    
    now = datetime.datetime.now()
    timestamp = now.strftime("%d/%m %H:%M")
    current_ip = get_ip()
    
    # Detectar branch atual
    _, branch_out = run_command("git branch --show-current", "Detectando Branch")
    current_branch = branch_out.strip()

    # 1. Validar NTSL
    success, _ = run_command("python e:/repo/RepoRobos_AbrilTeoria/_scripts/validate_ntsl.py", "Validando Sintaxe NTSL")
    if not success:
        print("Abortando: Erros de sintaxe detectados.")
        return

    # 2. Git Add inicial
    run_command("git add .", "Adicionando arquivos ao Git")

    # 3. Git Commit inicial (para gerar o Hash)
    commit_msg = f"{full_msg} [{timestamp}]"
    success, _ = run_command(f'git commit -m "{commit_msg}"', "Realizando Commit")
    if not success:
        print("Nada para commitar ou erro no processo.")
        return

    # 4. Capturar o Hash do commit realizado
    _, hash_out = run_command("git rev-parse --short HEAD", "Capturando Hash")
    commit_hash = hash_out.strip()

    # 5. Atualizar SESSION_LOG.md com o Hash e IP
    if update_session_log(activity, timestamp, commit_hash, current_ip):
        print(f"SESSION_LOG.md atualizado (Hash: {commit_hash}, IP: {current_ip}).")

    # 6. Amend do commit para incluir a atualização do log no mesmo commit
    run_command("git add e:/repo/RepoRobos_AbrilTeoria/SESSION_LOG.md", "Adicionando log atualizado")
    run_command("git commit --amend --no-edit", "Mesclando log ao commit")
    
    # 7. Recapturar hash (pois o amend muda o hash)
    _, final_hash_out = run_command("git rev-parse --short HEAD", "Capturando Hash Final")
    final_hash = final_hash_out.strip()
    print(f"Hash final do commit: {final_hash}")

    # 8. Git Push (SSL Bypass)
    success, _ = run_command(f"git -c http.sslVerify=false push origin {current_branch}", f"Subindo para {current_branch} (SSL Bypass)")
    
    if success:
        print(f"\n✅ Sessão finalizada e sincronizada às {timestamp}!")
        display_log_summary()
    else:
        print("\n❌ Falha ao subir para o remoto. Verifique a conexão/proxy.")

if __name__ == "__main__":
    main()