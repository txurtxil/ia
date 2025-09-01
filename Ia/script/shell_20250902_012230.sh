#!/data/data/com.termux/files/usr/bin/bash

# ===================== CONFIGURACIÓN =====================
HOME_DOCS="$HOME/docs"
DL="$HOME/storage/downloads"
SHORTCUTS_DIR="$HOME/.shortcuts"
PROOT_DIR="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
DOCS_DIR="$HOME/storage/shared/Documents"
BACKUP_FILE="$DOCS_DIR/backup_latest.tar.gz"
ENCRYPTED_BACKUP="$DOCS_DIR/backup_latest.enc"
CONF_FILE="$HOME/.config/shell_conf"

OWNER="txurtxil"
REPO="ia"

mkdir -p "$SHORTCUTS_DIR/restore_temp"
mkdir -p "$HOME/.config"
mkdir -p "$HOME_DOCS"

# ===================== ACCESO AL ALMACENAMIENTO =====================
STORAGE_FLAG="$HOME/.config/storage_done"
if [ ! -f "$STORAGE_FLAG" ]; then
    echo "[*] Habilitando acceso al almacenamiento compartido..."
    termux-setup-storage
    touch "$STORAGE_FLAG"
fi

# ===================== CARGAR TOKEN/PASS =====================
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
fi

if [ -z "$TOKEN" ] || [ -z "$PASS" ]; then
    read -rp "Introduce TOKEN de GitHub: " TOKEN
    read -srp "Introduce contraseña de backup: " PASS
    echo
    echo "TOKEN=\"$TOKEN\"" > "$CONF_FILE"
    echo "PASS=\"$PASS\"" >> "$CONF_FILE"
    chmod 600 "$CONF_FILE"
fi

# ===================== FUNCIONES IA 3D =====================
accion() {
    echo "Preparando modelo.scad..."
    touch "$HOME/modelo.scad"
    ${EDITOR:-nano} "$HOME/modelo.scad"
    echo "Ejecutando modelo.scad con OpenSCAD..."
    proot-distro login debian -- /usr/bin/openscad -o "$DL/modelo.stl" "$HOME/modelo.scad"
    if [ -f "$DL/modelo.stl" ]; then
        echo "STL actualizado en Descargas."
    else
        echo "No se encontró modelo.stl tras ejecutar OpenSCAD."
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

freecad_run() {
    echo "Preparando modelo.py..."
    touch "$HOME/modelo.py"
    ${EDITOR:-nano} "$HOME/modelo.py"
    echo "Ejecutando modelo.py con FreeCAD..."
    proot-distro login debian -- /usr/bin/freecadcmd "$HOME/modelo.py"
    if [ -f "$DL/modelo.stl" ]; then
        echo "STL actualizado en Descargas."
    else
        echo "No se encontró modelo.stl tras ejecutar FreeCAD."
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

ver() {
    if [ -f "$DL/modelo.stl" ]; then
        termux-open "$DL/modelo.stl"
    else
        echo "No existe $DL/modelo.stl"
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

subir_stl() {
    if [ ! -f "$DL/modelo.stl" ]; then
        echo "No existe modelo.stl para subir."
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi

    read -rp "Nombre del proyecto: " PROYECTO
    fecha=$(date +%Y%m%d_%H%M%S)
    STL_FILE="$DL/modelo.stl"
    CODE_FILE="$HOME/modelo.scad"

    STL_GH="${PROYECTO}/modelo_${fecha}.stl"
    CODE_GH="${PROYECTO}/modelo_${fecha}.scad"

    # Subir STL
    base64_stl=$(base64 -w 0 "$STL_FILE")
    tmpjson=$(mktemp)
    printf '{"message": "Subida STL %s", "content": "%s"}' "$STL_GH" "$base64_stl" > "$tmpjson"
    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$STL_GH" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"
    rm "$tmpjson"

    # Subir código
    if [ -f "$CODE_FILE" ]; then
        base64_code=$(base64 -w 0 "$CODE_FILE")
        tmpjson=$(mktemp)
        printf '{"message": "Subida código %s", "content": "%s"}' "$CODE_GH" "$base64_code" > "$tmpjson"
        curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$CODE_GH" \
            -H "Authorization: token $TOKEN" \
            -H "Content-Type: application/json" \
            -d @"$tmpjson"
        rm "$tmpjson"
    fi

    REF_FILE="$DL/${PROYECTO}_info.txt"
    echo "Proyecto: $PROYECTO" > "$REF_FILE"
    echo "STL: $STL_GH" >> "$REF_FILE"
    echo "Código: $CODE_GH" >> "$REF_FILE"
    echo "Fecha: $fecha" >> "$REF_FILE"

    echo "Subida completada y referencia guardada en $REF_FILE"
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

debian_shell() {
    proot-distro login debian
}

# ===================== FUNCIONES INSTALAR-REST. ENTORNO =====================
backup() {
    echo "[*] Creando lista de paquetes instalados..."
    dpkg --get-selections > "$DOCS_DIR/packages.list"

    echo "[*] Creando backup en $BACKUP_FILE ..."
    tar --ignore-failed-read -czf "$BACKUP_FILE" \
        "$SHORTCUTS_DIR/menu.sh" \
        "$HOME_DOCS" \
        "$PROOT_DIR" \
        "$DOCS_DIR/packages.list"
    if [ -f "$BACKUP_FILE" ]; then
        echo "[+] Backup creado en $BACKUP_FILE"
        echo "[*] Encriptando..."
        openssl enc -aes-256-cbc -pbkdf2 -salt -in "$BACKUP_FILE" -out "$ENCRYPTED_BACKUP" -k "$PASS"
        echo "[+] Backup encriptado en $ENCRYPTED_BACKUP"
    else
        echo "[!] Error: backup no se creó"
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

restore() {
    echo "[*] Antes de restaurar, habilita el almacenamiento compartido..."
    read -n1 -s
    termux-setup-storage

    if [ ! -f "$ENCRYPTED_BACKUP" ]; then
        echo "[!] No se encontró ningún backup en $DOCS_DIR"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi

    echo "[*] Desencriptando backup..."
    openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENCRYPTED_BACKUP" -out "$BACKUP_FILE" -k "$PASS"

    echo "[*] Extrayendo archivos..."
    mkdir -p "$SHORTCUTS_DIR/restore_temp"
    tar xzf "$BACKUP_FILE" -C "$SHORTCUTS_DIR/restore_temp"

    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $SHORTCUTS_DIR)" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/docs" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $PROOT_DIR)" "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/" 2>/dev/null

    echo "[*] Restauración completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

instalacion_limpia() {
    echo "[*] Instalando proot-distro si no está..."
    pkg update -y
    pkg install -y proot-distro

    echo "[*] Instalando Debian..."
    if ! proot-distro list | grep -q '^debian'; then
        proot-distro install debian
    fi

    echo "[*] Actualizando paquetes en Debian e instalando OpenSCAD y FreeCAD..."
    proot-distro login debian -- bash -c "apt update && apt upgrade -y && apt install -y openscad freecad"

    echo "[*] Habilitando acceso a almacenamiento compartido..."
    termux-setup-storage

    echo "[*] Instalación limpia completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

upload_shell_script() {
    echo "[*] Subiendo shell.sh a GitHub..."
    SCRIPT_PATH="$HOME/shell.sh"
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="Ia/script/shell_${fecha}.sh"

    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASS/<PASS>/g" "$SCRIPT_PATH" > "$DOCS_DIR/shell_tmp.sh"

    base64_content=$(base64 -w 0 "$DOCS_DIR/shell_tmp.sh")
    tmpjson=$(mktemp)
    printf '{"message": "Script %s", "content": "%s"}' "$archivo" "$base64_content" > "$tmpjson"

    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$archivo" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson" "$DOCS_DIR/shell_tmp.sh"
    echo "[*] Script subido a Ia/script."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# ===================== MENÚ PRINCIPAL =====================
while :; do
    clear
    echo "===== SHELL.SH ====="
    echo "1) IA 3D"
    echo "2) Instalar-Restaurar entorno"
    echo "3) Backup GitHub del script shell.sh"
    echo "4) Salir"
    echo "=========================="
    read -rp "Elige opción: " opt
    case $opt in
        1)
            while :; do
                clear
                echo "===== IA 3D ====="
                echo "1) OpenSCAD"
                echo "2) FreeCAD"
                echo "3) Ver STL con app predeterminada"
                echo "4) Subir STL a GitHub"
                echo "5) Iniciar shell Debian"
                echo "0) Volver"
                echo "=================="
                read -rp "Elige opción: " subopt
                case $subopt in
                    1) accion ;;
                    2) freecad_run ;;
                    3) ver ;;
                    4) subir_stl ;;
                    5) debian_shell ;;
                    0) break ;;
                    *) echo "Opción inválida"; sleep 1 ;;
                esac
            done
            ;;
        2)
            while :; do
                clear
                echo "===== INSTALAR/RESTAURAR ENTORNO ====="
                echo "1) Crear backup en Documentos"
                echo "2) Restaurar backup desde Documentos"
                echo "3) Instalación limpia automática"
                echo "0) Volver"
                echo "============================="
                read -rp "Elige opción: " subopt
                case $subopt in
                    1) backup ;;
                    2) restore ;;
                    3) instalacion_limpia ;;
                    0) break ;;
                    *) echo "Opción inválida"; sleep 1 ;;
                esac
            done
            ;;
        3) upload_shell_script ;;
        4) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
