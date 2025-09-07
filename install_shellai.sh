#!/data/data/com.termux/files/usr/bin/bash
# install_shellai.sh - Script de instalación automática para ShellAI

# --- Función para mostrar una barra de progreso simple ---
show_progress() {
    local current=$1
    local total=$2
    local task_name=$3
    local width=40
    local percent=$((current * 100 / total))
    local filled=$((percent * width / 100))
    local remaining=$((width - filled))
    local bar=$(printf "%${filled}s" | tr ' ' '#')
    local space=$(printf "%${remaining}s" | tr ' ' '-')
    echo -ne "\r[$bar$space] $percent% - $task_name"
}

echo "🚀 Iniciando instalación automática de ShellAI..."
echo "=================================================="

local total_steps=7
local current_step=0

# Paso 1: Actualizar repositorios e instalar dependencias básicas de Termux
((current_step++))
show_progress $current_step $total_steps "Instalando dependencias de Termux..."
pkg update -y >/dev/null 2>&1
pkg install -y proot-distro git curl wget nano vim jq tar gzip openssl >/dev/null 2>&1
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 2: Instalar y configurar Debian
((current_step++))
show_progress $current_step $total_steps "Instalando y configurando Debian..."
if ! proot-distro list | grep -q '^debian'; then
    proot-distro install debian >/dev/null 2>&1
fi
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 3: Instalar paquetes dentro de Debian
((current_step++))
show_progress $current_step $total_steps "Instalando OpenSCAD, FreeCAD y herramientas de red..."
proot-distro login debian -- bash -c "
    apt update >/dev/null 2>&1 &&
    apt upgrade -y >/dev/null 2>&1 &&
    apt install -y --no-install-recommends openscad freecad freecad-common freecad-python3 \\
                  iproute2 net-tools traceroute mtr whois dnsutils tcpdump nmap \\
                  python3 python3-pip" >/dev/null 2>&1
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 4: Solicitar acceso al almacenamiento
((current_step++))
show_progress $current_step $total_steps "Configurando acceso al almacenamiento..."
termux-setup-storage
sleep 2
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 5: Descargar y restaurar el backup más reciente desde GitHub
((current_step++))
show_progress $current_step $total_steps "Descargando el backup más reciente..."
cd "$HOME"
PROJECT_DIR="$HOME/ShellAI"
BACKUP_DIR="$HOME/ShellAI_backups"
mkdir -p "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"

BACKUP_LIST=$(curl -s "https://api.github.com/repos/txurtxil/ia/contents/backups" | jq -r '.[] | select(.name | endswith(".tar.gz")) | .name')
LATEST_BACKUP=$(echo "$BACKUP_LIST" | sort -r | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo -e "\n❌ Error: No se encontró ningún backup."
    exit 1
fi

BACKUP_URL="https://raw.githubusercontent.com/txurtxil/ia/main/backups/$LATEST_BACKUP"
LOCAL_BACKUP_PATH="$BACKUP_DIR/$LATEST_BACKUP"
curl -L -o "$LOCAL_BACKUP_PATH" "$BACKUP_URL" >/dev/null 2>&1
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 6: Descomprimir el backup
((current_step++))
show_progress $current_step $total_steps "Restaurando archivos del proyecto..."
tar -xzf "$LOCAL_BACKUP_PATH" -C "$PROJECT_DIR" >/dev/null 2>&1
chmod +x "$PROJECT_DIR/ShellAI.sh"
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

# Paso 7: Ejecutar ShellAI.sh para configuración final
((current_step++))
show_progress $current_step $total_steps "Iniciando configuración final..."
cd "$PROJECT_DIR"
./ShellAI.sh
echo -e "\r$(printf '%*s' 80)"
echo -e "[✓] Paso $current_step/$total_steps completado."

echo -e "\n🎉 ¡Instalación completada con éxito!"
echo "Puedes iniciar ShellAI.sh en cualquier momento con: cd ~/ShellAI && ./ShellAI.sh"
