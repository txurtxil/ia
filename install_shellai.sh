#!/data/data/com.termux/files/usr/bin/bash
# install_shellai.sh - Script de instalación automática para ShellAI

echo "🚀 Iniciando instalación automática de ShellAI..."
echo "=================================================="

# Paso 1: Actualizar repositorios e instalar dependencias básicas de Termux
echo "🔹 Paso 1: Instalando dependencias de Termux..."
pkg update -y
pkg install -y proot-distro git curl wget nano vim jq tar gzip openssl

# Paso 2: Instalar y configurar Debian
echo "🔹 Paso 2: Instalando y configurando Debian..."
if ! proot-distro list | grep -q '^debian'; then
    proot-distro install debian
fi

# Instalar paquetes dentro de Debian
echo "🔹 Paso 3: Instalando OpenSCAD, FreeCAD y herramientas de red en Debian..."
proot-distro login debian -- bash -c "
    apt update && apt upgrade -y &&
    apt install -y openscad freecad freecad-common freecad-python3 \\
                  iproute2 net-tools traceroute mtr whois dnsutils tcpdump nmap \\
                  python3 python3-pip
"

# Paso 4: Solicitar acceso al almacenamiento
echo "🔹 Paso 4: Configurando acceso al almacenamiento..."
termux-setup-storage
sleep 2 # Dar tiempo al usuario para aceptar el permiso

# Paso 5: Descargar y restaurar el backup más reciente desde GitHub
echo "🔹 Paso 5: Descargando el backup más reciente de ShellAI desde GitHub..."

# Crear directorio del proyecto
cd "$HOME"
PROJECT_DIR="$HOME/ShellAI"
BACKUP_DIR="$HOME/ShellAI_backups"

mkdir -p "$PROJECT_DIR"
mkdir -p "$BACKUP_DIR"

# Obtener la lista de backups desde la API de GitHub
echo "   Obteniendo lista de backups disponibles..."
BACKUP_LIST=$(curl -s "https://api.github.com/repos/txurtxil/ia/contents/backups" | jq -r '.[] | select(.name | endswith(".tar.gz")) | .name')

if [ -z "$BACKUP_LIST" ]; then
    echo "❌ Error: No se encontraron archivos de backup (.tar.gz) en el repositorio."
    echo "   Asegúrate de haber ejecutado la opción 4 ('Backup COMPLETO del Proyecto a GitHub') al menos una vez."
    exit 1
fi

# Encontrar el backup más reciente (por nombre, asumiendo que incluye la fecha)
LATEST_BACKUP=$(echo "$BACKUP_LIST" | sort -r | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ Error: No se pudo determinar el backup más reciente."
    exit 1
fi

echo "   Backup más reciente encontrado: $LATEST_BACKUP"

# Descargar el backup
BACKUP_URL="https://raw.githubusercontent.com/txurtxil/ia/main/backups/$LATEST_BACKUP"
LOCAL_BACKUP_PATH="$BACKUP_DIR/$LATEST_BACKUP"

echo "   Descargando: $BACKUP_URL"
curl -L -o "$LOCAL_BACKUP_PATH" "$BACKUP_URL"

if [ ! -f "$LOCAL_BACKUP_PATH" ]; then
    echo "❌ Error: No se pudo descargar el archivo de backup."
    exit 1
fi

# Descomprimir el backup en el directorio del proyecto
echo "   Descomprimiendo el backup en $PROJECT_DIR..."
tar -xzf "$LOCAL_BACKUP_PATH" -C "$PROJECT_DIR"

# Verificar que los archivos esenciales están presentes
if [ ! -f "$PROJECT_DIR/ShellAI.sh" ] || [ ! -d "$PROJECT_DIR/modules" ]; then
    echo "❌ Error: El backup no contiene los archivos esenciales del proyecto."
    echo "   Contenido del directorio:"
    ls -la "$PROJECT_DIR"
    exit 1
fi

# Paso 6: Hacer el script principal ejecutable
chmod +x "$PROJECT_DIR/ShellAI.sh"

# Paso 7: Ejecutar ShellAI.sh para completar la configuración (creará directorios, pedirá credenciales, etc.)
echo "🔹 Paso 7: Iniciando ShellAI.sh para configuración final..."
echo "Por favor, introduce tus credenciales cuando se te soliciten."
sleep 3
cd "$PROJECT_DIR"
./ShellAI.sh

echo "🎉 ¡Instalación completada con éxito!"
echo "Puedes iniciar ShellAI.sh en cualquier momento con: cd ~/ShellAI && ./ShellAI.sh"
