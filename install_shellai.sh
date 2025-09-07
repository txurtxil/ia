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

# Paso 5: Clonar el repositorio de ShellAI
echo "🔹 Paso 5: Descargando el proyecto ShellAI desde GitHub..."
cd "$HOME"
if [ -d "ShellAI" ]; then
    echo "⚠️  El directorio 'ShellAI' ya existe. Se hará un backup y se clonará de nuevo."
    mv "ShellAI" "ShellAI_backup_$(date +%Y%m%d_%H%M%S)"
fi

git clone https://github.com/txurtxil/ia.git ShellAI

if [ ! -d "ShellAI" ]; then
    echo "❌ Error: No se pudo clonar el repositorio."
    exit 1
fi

cd "ShellAI"

# Paso 6: Hacer el script principal ejecutable
chmod +x ShellAI.sh

# Paso 7: Ejecutar ShellAI.sh para completar la configuración (creará directorios, pedirá credenciales, etc.)
echo "🔹 Paso 7: Iniciando ShellAI.sh para configuración final..."
echo "Por favor, introduce tus credenciales cuando se te soliciten."
sleep 3
./ShellAI.sh

echo "🎉 ¡Instalación completada con éxito!"
echo "Puedes iniciar ShellAI.sh en cualquier momento con: ./ShellAI.sh"
