#!/data/data/com.termux/files/usr/bin/bash

BACKUP_DIR="$HOME/.shortcuts"
BACKUP_SCRIPT="$BACKUP_DIR/backup.sh"
BACKUP_FILE="$BACKUP_DIR/backup_termux.tar.gz"

OWNER="txurtxil"
REPO="ia"
TOKEN="<TOKEN>"
PASSWORD="<PASSWORD>"

# --- Opción 1: Backup ---
backup() {
    echo "[*] Creando lista de paquetes instalados..."
    pkg list-installed > "$BACKUP_DIR/installed_packages.txt"

    echo "[*] Creando backup completo de Termux y proot Debian..."
    tar -czf "$BACKUP_FILE" \
        -C "$HOME" .shortcuts \
        -C "$HOME" docs \
        -C /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs debian

    echo "[*] Backup creado en $BACKUP_FILE"

    # Subir backup a GitHub protegido
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_${fecha}.tar.gz"

    echo "[*] Encriptando backup con contraseña..."
    zip -P "$PASSWORD" "$BACKUP_DIR/${archivo}.zip" "$BACKUP_FILE"

    echo "[*] Subiendo backup a GitHub..."
    gh_api="https://api.github.com/repos/$OWNER/$REPO/contents/$archivo.zip"
    base64_content=$(base64 -w 0 "$BACKUP_DIR/${archivo}.zip")

    tmpjson=$(mktemp)
    echo "{\"message\": \"Backup Termux $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"

    curl -s -X PUT "$gh_api" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson"
    echo "[*] Backup subido a GitHub con contraseña."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# --- Opción 2: Restauración ---
restore() {
    echo "[*] Restaurando backup desde GitHub..."
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_${fecha}.tar.gz.zip"

    gh_api="https://api.github.com/repos/$OWNER/$REPO/contents/$archivo"
    curl -s -H "Authorization: token $TOKEN" "$gh_api" | jq -r '.content' | base64 -d > "$BACKUP_DIR/$archivo"

    echo "[*] Desencriptando backup..."
    unzip -P "$PASSWORD" "$BACKUP_DIR/$archivo" -d "$BACKUP_DIR/restore_temp"

    echo "[*] Restaurando archivos..."
    cp -r "$BACKUP_DIR/restore_temp/.shortcuts" "$HOME/"
    cp -r "$BACKUP_DIR/restore_temp/docs" "$HOME/"
    cp -r "$BACKUP_DIR/restore_temp/debian" /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/

    echo "[*] Restauración completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# --- Opción 3: Subir script backup.sh a GitHub ---
upload_script() {
    if [ ! -f "$BACKUP_SCRIPT" ]; then
        echo "No se encontró el script $BACKUP_SCRIPT"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi

    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="backup_${fecha}.sh"

    # Enmascarar token y contraseña
    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASSWORD/<PASSWORD>/g" "$BACKUP_SCRIPT" > "$BACKUP_DIR/$archivo"

    echo "[*] Subiendo $archivo a GitHub..."
    gh_api="https://api.github.com/repos/$OWNER/$REPO/contents/$archivo"
    base64_content=$(base64 -w 0 "$BACKUP_DIR/$archivo")

    tmpjson=$(mktemp)
    echo "{\"message\": \"Subida de script $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"

    curl -s -X PUT "$gh_api" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson"
    echo "[*] Script subido con token y contraseña enmascarados."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# --- Menú principal ---
while :; do
    clear
    echo "===== BACKUP TERMUX =====
1) Crear backup y subir a GitHub
2) Restaurar backup desde GitHub
3) Subir este script backup.sh a GitHub (token y contraseña enmascarados)
0) Salir
========================="
    read -rp "Elige opción: " opt
    case $opt in
        1) backup ;;
        2) restore ;;
        3) upload_script ;;
        0) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
