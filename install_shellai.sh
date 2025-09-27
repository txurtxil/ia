#!/data/data/com.termux/files/usr/bin/bash
# install_shellai.sh - Instalación automática de ShellAI (5 pasos)
# Compatible con: ./install.sh  Y  curl -s URL | bash

# --- AUTO-RELOCATE si se ejecuta desde tubería (stdin no es terminal) ---
if [ ! -t 0 ]; then
    echo "⚠️  Detectada ejecución desde tubería (curl | bash)."
    echo "    Descargando script localmente para modo interactivo..."
    SCRIPT_PATH="$HOME/install_shellai.sh"
    curl -s -o "$SCRIPT_PATH" "https://raw.githubusercontent.com/txurtxil/ia/main/install_shellai.sh"
    chmod +x "$SCRIPT_PATH"
    echo "    Reejecutando desde archivo local..."
    exec "$SCRIPT_PATH"
fi

set -e

echo "=================================="
echo "INICIANDO INSTALACIÓN - $(date)"
echo "=================================="

check_storage() {
    [ -d "$HOME/storage/shared" ]
}

# Paso 1/5: Dependencias
echo "🔹 Paso 1/5: Instalando dependencias de Termux..."
pkg update -y
pkg install -y proot-distro curl wget tar gzip openssl jq nano vim
echo "✅ Paso 1/5 completado."

# Paso 2/5: Debian
echo "🔹 Paso 2/5: Instalando Debian..."
if ! proot-distro list | grep -q '^debian'; then
    proot-distro install debian
fi
echo "✅ Paso 2/5 completado."

# Paso 3/5: Herramientas en Debian
echo "🔹 Paso 3/5: Instalando OpenSCAD, FreeCAD y herramientas de red (unos 10 minutos)..."
proot-distro login debian -- bash -c "
    apt update -y &&
    apt upgrade -y &&
    apt install -y openscad freecad freecad-common freecad-python3 \\
                  iproute2 net-tools traceroute mtr whois dnsutils tcpdump nmap \\
                  python3 python3-pip" >/dev/null 2>&1
echo "✅ Paso 3/5 completado."

# Paso 4/5: Acceso al almacenamiento
echo "🔹 Paso 4/5: Configurando acceso al almacenamiento..."

if check_storage; then
    echo "  ✅ Almacenamiento ya accesible."
else
    echo
    echo "  📱 Por favor, en otra pestaña de Termux ejecute:"
    echo "        termux-setup-storage"
    echo "  Conceda el permiso de 'Archivos y multimedia' cuando Android lo solicite."
    echo "  Una vez hecho, vuelva aquí y presione ENTER para continuar."
    echo
    read -p "  Presione ENTER cuando haya completado este paso... " _
    
    if ! check_storage; then
        echo "❌ Error: El almacenamiento sigue sin estar accesible."
        echo "    Asegúrese de haber ejecutado 'termux-setup-storage' y concedido el permiso."
        exit 1
    fi
fi
echo "✅ Paso 4/5 completado."

# Paso 5/5: Descargar y restaurar desde backup
echo "🔹 Paso 5/5: Descargando y restaurando ShellAI desde backup..."
cd "$HOME"
mkdir -p ShellAI ShellAI_backups
BACKUP_DIR="$HOME/ShellAI_backups"

# 🔴 CORREGIDO: eliminar espacios en las URLs
BACKUP_LIST=$(curl -s "https://api.github.com/repos/txurtxil/ia/contents/backups" | jq -r '.[] | select(.name | endswith(".tar.gz")) | .name' 2>/dev/null)

if [ -z "$BACKUP_LIST" ]; then
    echo "❌ Error: No se encontraron backups en el repositorio."
    exit 1
fi

LATEST_BACKUP=$(echo "$BACKUP_LIST" | sort -r | head -n 1)
# 🔴 CORREGIDO: URL sin espacio
BACKUP_URL="https://raw.githubusercontent.com/txurtxil/ia/main/backups/$LATEST_BACKUP"

curl -L -o "$BACKUP_DIR/$LATEST_BACKUP" "$BACKUP_URL"
tar -xzf "$BACKUP_DIR/$LATEST_BACKUP" -C "$HOME/ShellAI"

if [ ! -f "$HOME/ShellAI/ShellAI.sh" ]; then
    echo "❌ Error: ShellAI.sh no encontrado en el backup."
    exit 1
fi

# Habilitar allow-external-apps
TERMUX_PROP_DIR="$HOME/.termux"
TERMUX_PROP_FILE="$TERMUX_PROP_DIR/termux.properties"
mkdir -p "$TERMUX_PROP_DIR"
touch "$TERMUX_PROP_FILE"

if ! grep -q "^allow-external-apps\s*=\s*true" "$TERMUX_PROP_FILE" 2>/dev/null; then
    if grep -q "^allow-external-apps" "$TERMUX_PROP_FILE"; then
        sed -i 's/^allow-external-apps\s*=.*/allow-external-apps = true/' "$TERMUX_PROP_FILE"
    else
        echo "allow-external-apps = true" >> "$TERMUX_PROP_FILE"
    fi
    termux-reload-settings
fi

chmod +x "$HOME/ShellAI/ShellAI.sh"
cd "$HOME/ShellAI"
echo "✅ Iniciando ShellAI.sh..."
./ShellAI.sh

echo
echo "🎉 ¡Instalación completada con éxito!"
read -p "Presione ENTER para finalizar instalación... " _
