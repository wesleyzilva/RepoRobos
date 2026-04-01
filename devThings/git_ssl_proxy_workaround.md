# Git SSL / Proxy Corporativo — Workaround para Push

## Problema

Ao tentar `git push origin <branch>` o Git retorna:

```
fatal: unable to access 'https://github.com/wesleyzilva/RepoRobos.git/':
schannel: SEC_E_UNTRUSTED_ROOT (0x80090325) -
A cadeia de certificação foi emitida por uma autoridade que não é de confiança.
```

Ou via OpenSSL:

```
SSL certificate OpenSSL verify result: self-signed certificate in certificate chain (19)
```

## Causa

Proxy/VPN corporativo intercepta conexões HTTPS (MITM).
Ele substitui o certificado do GitHub pelo certificado interno da empresa,
que o Git não reconhece como autoridade confiável.

Porta 22 (SSH) também fica bloqueada: `Connection timed out`.

## Soluções

### Opção A — Push pontual (mais seguro, use quando necessário)

Desabilita SSL apenas para o comando, sem alterar configuração global:

```bash
git -c http.sslVerify=false push origin <branch>
```

### Opção B — Desabilitar SSL globalmente e restaurar (o que foi feito na sessão)

```bash
# Desabilitar (para fazer o push passar)
git config --global http.sslVerify false
git push origin <branch>

# Restaurar imediatamente depois
git config --global http.sslVerify true
```

> ⚠ Nunca deixe `sslVerify false` permanente. Restaure sempre após o push.

### Opção C — Solução definitiva (adicionar certificado do proxy)

1. Exportar o certificado da empresa (Chrome → cadeado → Certificado → exportar como `.crt`)
2. Registrar no Git:

```bash
git config --global http.sslCAInfo "C:/caminho/certificado_empresa.crt"
```

A partir daí, push HTTPS funciona normalmente sem desabilitar nada.

### Opção D — SSH via porta 443 (alternativa se porta 22 liberada)

Editar (ou criar) `~/.ssh/config`:

```
Host github.com
  Hostname ssh.github.com
  Port 443
  User git
```

Depois trocar o remote:

```bash
git remote set-url origin git@github.com:wesleyzilva/RepoRobos.git
```

## Diagnóstico rápido

| Protocolo | Resultado |
|-----------|-----------|
| HTTPS Schannel | ❌ `SEC_E_UNTRUSTED_ROOT` |
| HTTPS OpenSSL | ❌ `self-signed certificate` |
| SSH porta 22 | ❌ `Connection timed out` |
| HTTPS `sslVerify=false` | ✅ Funciona |

## Verificar configuração atual

```bash
git config --global http.sslVerify
git config --global http.sslBackend
git config --global http.sslCAInfo
git remote -v
```

## Outros repositórios nesta máquina

- `C:/repositorio_wes/RepoRobos` → `wesleyzilva/RepoRobos`
- `C:/repositorio_wes/PriceAction_Fisica` → `wesleyzilva/PriceAction_Fisica`
