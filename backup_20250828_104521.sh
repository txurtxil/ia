#!/data/data/com.termux/files/usr/bin/bash

SHORTCUTS_DIR="$HOME/.shortcuts"
HOME_DOCS="$HOME/docs"
PROOT_DIR="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"

# Ruta a Documentos (requiere termux-setup-storage)
DOCS_DIR="$HOME/storage/shared/Documents"
BACKUP_FILE="$DOCS_DIR/backup_latest.tar.gz"
ENCRYPTED_BACKUP="$DOCS_DIR/backup_latest.enc"

OWNER="txurtxil"
REPO="ia"
TOKEN="<TOKEN>"
PASS="<PASS>"

mkdir -p "$SHORTCUTS_DIR/restore_temp"

backup() {
    echo "[*] Creando lista de paquetes instalados..."
    dpkg --get-selections > "$DOCS_DIR/packages.list"

    echo "[*] Creando backup en $BACKUP_FILE ..."
    tar --ignore-failed-read -czf "$BACKUP_FILE" \
        "$SHORTCUTS_DIR/menu.sh" \
        "$HOME_DOCS" \
        "$PROOT_DIR" \
        "$DOCS_DIR/packages.list"
    TAR_STATUS=$?

    if [ -f "$BACKUP_FILE" ]; then
        echo "[+] Backup creado en $BACKUP_FILE"
        if [ $TAR_STATUS -ne 0 ]; then
            echo "[!] Aviso: algunos ficheros no se pudieron incluir por permisos"
        fi
    else
        echo "[!] Error: backup no se creó"
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

restore() {
    echo "[*] Antes de restaurar, es necesario habilitar el acceso al almacenamiento compartido."
    echo "Pulsa una tecla para ejecutar termux-setup-storage..."
    read -n1 -s
    termux-setup-storage

    if [ ! -f "$ENCRYPTED_BACKUP" ]; then
        echo "[!] No se encontró ningún backup en $DOCS_DIR"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi

    echo "[*] Desencriptando backup..."
    openssl enc -d -aes-256-cbc -in "$ENCRYPTED_BACKUP" -out "$BACKUP_FILE" -k "$PASS"

    echo "[*] Extrayendo archivos..."
    mkdir -p "$SHORTCUTS_DIR/restore_temp"
    tar xzf "$BACKUP_FILE" -C "$SHORTCUTS_DIR/restore_temp"

    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $SHORTCUTS_DIR)" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/docs" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $PROOT_DIR)" "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/" 2>/dev/null

    echo "[*] Restauración completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

install_clean() {
    echo "[*] Habilitando almacenamiento compartido..."
    termux-setup-storage

    echo "[*] Instalando proot-distro..."
    pkg update -y && pkg upgrade -y
    pkg install -y proot-distro

    echo "[*] Instalando Debian..."
    proot-distro install debian

    echo "[*] Iniciando Debian..."
    proot-distro login debian -- bash -c "
        apt update -y &&
        apt upgrade -y &&
        apt install -y openscad freecad
    "

    echo "[*] Instalación limpia completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

upload_script() {
    echo "[*] Subiendo backup.sh a GitHub..."
    SCRIPT_PATH="$SHORTCUTS_DIR/backup.sh"
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_$fecha.sh"

    # Enmascarar token y contraseña
    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASS/<PASS>/g" "$SCRIPT_PATH" > "$DOCS_DIR/$archivo"

    base64_content=$(base64 -w 0 "$DOCS_DIR/$archivo")
    tmpjson=$(mktemp)
    echo "{\"message\": \"Script $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"

    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$archivo" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson"
    echo "[*] Script subido."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

while :; do
    clear
    echo "===== BACKUP TERMUX =====
1) Crear backup en Documentos
2) Restaurar backup desde Documentos
3) Instalación limpia (proot + Debian + OpenSCAD + FreeCAD)
4) Subir este script a GitHub (token y password enmascarados)
0) Salir
=========================="
    read -rp "Elige opción: " opt
    case $opt in
        1) backup ;;
        2) restore ;;
        3) install_clean ;;
        4) upload_script ;;
        0) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
