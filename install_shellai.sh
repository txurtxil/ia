#!/data/data/com.termux/files/usr/bin/bash
# install_shellai.sh - Script de instalación automática para ShellAI

LOG_FILE="$HOME/install_shellai.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=================================="
echo "INICIANDO INSTALACIÓN - $(date)"
echo "=================================="

# Paso 1: Instalar dependencias básicas de Termux
echo "Paso 1/7: Instalando dependencias de Termux..."
pkg update -y
pkg install -y proot-distro curl wget tar gzip openssl jq nano vim

# Paso 2: Instalar Debian
echo "Paso 2/7: Instalando Debian..."
if ! proot-distro list | grep -q '^debian'; then
    proot-distro install debian
fi

# Paso 3: Instalar herramientas en Debian
echo "Paso 3/7: Instalando OpenSCAD, FreeCAD y herramientas de red..."
proot-distro login debian -- bash -c "
    apt update -y &&
    apt upgrade -y &&
    apt install -y openscad freecad freecad-common freecad-python3 \\
                  iproute2 net-tools traceroute mtr whois dnsutils tcpdump nmap \\
                  python3 python3-pip"

# Paso 4: Acceso al almacenamiento
echo "Paso 4/7: Configurando acceso al almacenamiento..."
termux-setup-storage
sleep 2

# Paso 5: Descargar el backup más reciente
echo "Paso 5/7: Descargando el backup más reciente..."
cd "$HOME"
mkdir -p ShellAI ShellAI_backups
BACKUP_DIR="$HOME/ShellAI_backups"

# Obtener lista de backups
BACKUP_LIST=$(curl -s "https://api.github.com/repos/txurtxil/ia/contents/backups" | jq -r '.[] | select(.name | endswith(".tar.gz")) | .name' 2>/dev/null)
LATEST_BACKUP=$(echo "$BACKUP_LIST" | sort -r | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "Error: No se encontró ningún backup."
    exit 1
fi

BACKUP_URL="https://raw.githubusercontent.com/txurtxil/ia/main/backups/$LATEST_BACKUP"
curl -L -o "$BACKUP_DIR/$LATEST_BACKUP" "$BACKUP_URL"

# Paso 6: Restaurar el backup
echo "Paso 6/7: Restaurando archivos..."
tar -xzf "$BACKUP_DIR/$LATEST_BACKUP" -C "$HOME/ShellAI"

# Paso 7: Ejecutar ShellAI.sh
echo "Paso 7/7: Iniciando ShellAI.sh..."
cd "$HOME/ShellAI"
chmod +x ShellAI.sh
./ShellAI.sh

echo "¡Instalación completada con éxito!"
