#!/data/data/com.termux/files/usr/bin/bash

# ===================== CONFIGURACIÓN =====================
HOME_DOCS="$HOME/docs"
DL="$HOME/storage/downloads"
SHORTCUTS_DIR="$HOME/.shortcuts"
PROOT_DIR="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
DOCS_DIR="$HOME/storage/shared/Documents"
BACKUP_FILE="$DOCS_DIR/backup_latest.tar.gz"
ENCRYPTED_BACKUP="$DOCS_DIR/backup_latest.enc"

OWNER="txurtxil"
REPO="ia"
TOKEN="<TOKEN>"
PASS="<PASS>"

mkdir -p "$SHORTCUTS_DIR/restore_temp"

# ===================== FUNCIONES IA 3D =====================
accion() {
    echo "Preparando modelo.scad..."
    rm -f "$HOME/modelo.scad" "$DL/modelo.stl"
    touch "$HOME/modelo.scad"
    nano "$HOME/modelo.scad"
    echo "Ejecutando modelo.scad con OpenSCAD..."
    proot-distro login debian -- /usr/bin/openscad -o "$HOME_DOCS/modelo.stl" "$HOME/modelo.scad"
    if [ -f "$HOME_DOCS/modelo.stl" ]; then
        cp "$HOME_DOCS/modelo.stl" "$DL"
        echo "STL generado con OpenSCAD y movido a Descargas."
    else
        echo "No se encontró modelo.stl tras ejecutar OpenSCAD."
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

ver() {
    termux-open "$DL/modelo.stl"
}

freecad_run() {
    echo "Preparando modelo.py..."
    rm -f "$HOME/modelo.py"
    touch "$HOME/modelo.py"
    nano "$HOME/modelo.py"
    echo "Ejecutando modelo.py con FreeCAD..."
    proot-distro login debian -- /usr/bin/freecadcmd "$HOME/modelo.py"
    if [ -f "$HOME_DOCS/modelo.stl" ]; then
        cp "$HOME_DOCS/modelo.stl" "$DL"
        echo "STL generado con FreeCAD y movido a Descargas."
    else
        echo "No se encontró modelo.stl tras ejecutar FreeCAD."
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

subir_stl() {
    if [ ! -f "$DL/modelo.stl" ]; then
        echo "No existe modelo.stl en Descargas para subir."
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="modelo_${fecha}.stl"
    cp "$DL/modelo.stl" "$DL/$archivo"

    echo "Subiendo $archivo a GitHub..."
    gh_api="https://api.github.com/repos/$OWNER/$REPO/contents/$archivo"
    base64_content=$(base64 -w 0 "$DL/$archivo")
    tmpjson=$(mktemp)
    echo "{\"message\": \"Subida de STL $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"
    curl -s -X PUT "$gh_api" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"
    rm "$tmpjson"
    echo "Subida completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
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

instalacion_limpia() {
    echo "[*] Habilitando acceso a almacenamiento..."
    termux-setup-storage

    echo "[*] Instalando proot-distro..."
    pkg update -y
    pkg install -y proot-distro

    echo "[*] Instalando Debian..."
    proot-distro install debian

    echo "[*] Instalando OpenSCAD y FreeCAD en Debian..."
    proot-distro login debian -- bash -c "apt update && apt install -y openscad freecad"

    echo "[*] Instalación limpia completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

upload_shell_script() {
    echo "[*] Subiendo shell.sh a GitHub..."
    SCRIPT_PATH="/data/data/com.termux/files/home/shell.sh"
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="shell_${fecha}.sh"
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

# ===================== MENÚ PRINCIPAL =====================
while :; do
    clear
    echo "===== SHELL.SH =====
1) IA 3D
2) Instalar-Restaurar entorno
3) Backup GitHub del script shell.sh
4) Salir
=========================="
    read -rp "Elige opción: " opt
    case $opt in
        1)
            while :; do
                clear
                echo "===== IA 3D =====
1) OpenSCAD
2) FreeCAD
3) Ver STL con app predeterminada
4) Subir STL a GitHub
0) Volver
=================="
                read -rp "Elige opción: " subopt
                case $subopt in
                    1) accion ;;
                    2) freecad_run ;;
                    3) ver ;;
                    4) subir_stl ;;
                    0) break ;;
                    *) echo "Opción inválida"; sleep 1 ;;
                esac
            done
            ;;
        2)
            while :; do
                clear
                echo "===== INSTALAR/RESTAURAR ENTORNO =====
1) Crear backup en Documentos
2) Restaurar backup desde Documentos
3) Instalación limpia (proot + Debian + OpenSCAD + FreeCAD)
0) Volver
============================="
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
