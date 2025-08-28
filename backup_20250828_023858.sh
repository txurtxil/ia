#!/data/data/com.termux/files/usr/bin/bash

SHORTCUTS_DIR="$HOME/.shortcuts"
HOME_DOCS="$HOME/docs"
PROOT_DIR="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
BACKUP_FILE="$SHORTCUTS_DIR/backup_latest.tar.gz"
ENCRYPTED_BACKUP="$SHORTCUTS_DIR/backup_latest.enc"

OWNER="txurtxil"
REPO="ia"
TOKEN="<TOKEN>"
PASS="<PASS>"

mkdir -p "$SHORTCUTS_DIR/restore_temp"

backup() {
    echo "[*] Creando lista de paquetes instalados..."
    dpkg --get-selections > "$SHORTCUTS_DIR/packages.list"

    echo "[*] Creando backup en $BACKUP_FILE ..."
    tar czf "$BACKUP_FILE" \
        "$SHORTCUTS_DIR/menu.sh" \
        "$HOME_DOCS" \
        "$PROOT_DIR" \
        "$SHORTCUTS_DIR/packages.list"

    echo "[*] Protegiendo backup con contraseña..."
    openssl enc -aes-256-cbc -salt -in "$BACKUP_FILE" -out "$ENCRYPTED_BACKUP" -k "$PASS"

    echo "[*] Subiendo backup a GitHub..."
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_$fecha.enc"
    cp "$ENCRYPTED_BACKUP" "$SHORTCUTS_DIR/$archivo"

    base64_content=$(base64 -w 0 "$SHORTCUTS_DIR/$archivo")
    tmpjson=$(mktemp)
    echo "{\"message\": \"Backup $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"

    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$archivo" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson"
    echo "[*] Backup completado."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

restore() {
    echo "[*] Restaurando backup desde GitHub..."
    # Obtener último backup
    latest_url=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$OWNER/$REPO/contents/" | jq -r '.[] | select(.name|test("backup_.*\\.enc")) | .download_url' | sort | tail -n1)

    if [ -z "$latest_url" ]; then
        echo "[!] No se encontró ningún backup en GitHub."
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi

    echo "[*] Descargando $latest_url..."
    curl -sL "$latest_url" -o "$SHORTCUTS_DIR/backup_latest.enc"

    echo "[*] Desencriptando backup..."
    openssl enc -d -aes-256-cbc -in "$SHORTCUTS_DIR/backup_latest.enc" -out "$BACKUP_FILE" -k "$PASS"

    echo "[*] Extrayendo archivos..."
    mkdir -p "$SHORTCUTS_DIR/restore_temp"
    tar xzf "$BACKUP_FILE" -C "$SHORTCUTS_DIR/restore_temp"

    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $SHORTCUTS_DIR)" "$HOME/"
    cp -r "$SHORTCUTS_DIR/restore_temp/docs" "$HOME/"
    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $PROOT_DIR)" "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/"

    echo "[*] Restauración completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

upload_script() {
    echo "[*] Subiendo backup.sh a GitHub..."
    SCRIPT_PATH="$SHORTCUTS_DIR/backup.sh"
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_$fecha.sh"

    # Enmascarar token y contraseña
    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASS/<PASS>/g" "$SCRIPT_PATH" > "$SHORTCUTS_DIR/$archivo"

    base64_content=$(base64 -w 0 "$SHORTCUTS_DIR/$archivo")
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
1) Crear backup y subir a GitHub
2) Restaurar backup desde GitHub
3) Subir este script a GitHub (token y password enmascarados)
0) Salir
=========================="
    read -rp "Elige opción: " opt
    case $opt in
        1) backup ;;
        2) restore ;;
        3) upload_script ;;
        0) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
