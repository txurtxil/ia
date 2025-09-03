#!/data/data/com.termux/files/usr/bin/bash

# Este script actualizado incluye una nueva opción para usar la API de Gemini CLI.
# ===================== CONFIGURACIÓN =====================
HOME_DOCS="$HOME/docs"
DL="$HOME/storage/downloads"
SHORTCUTS_DIR="$HOME/.shortcuts"
PROOT_DIR="/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"
DOCS_DIR="$HOME/storage/shared/Documents"
BACKUP_FILE="$DOCS_DIR/backup_latest.tar.gz"
ENCRYPTED_BACKUP="$DOCS_DIR/backup_latest.enc"
CONF_FILE="$HOME/.config/shell_conf"

# Añadimos la variable para la clave de la API de Gemini
GEMINI_KEY=""

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

# ===================== CARGAR TOKEN/PASS/KEY =====================
if [ -f "$CONF_FILE" ]; then
    source "$CONF_FILE"
fi

# Solicitamos la clave de Gemini si no está guardada, además del token y la contraseña de GitHub
if [ -z "$TOKEN" ] || [ -z "$PASS" ] || [ -z "$GEMINI_KEY" ]; then
    echo "¡Configuración inicial necesaria!"
    [ -z "$TOKEN" ] && read -rp "Introduce TOKEN de GitHub: " TOKEN
    [ -z "$PASS" ] && read -srp "Introduce contraseña de backup: " PASS
    [ -z "$GEMINI_KEY" ] && read -srp "Introduce tu clave de la API de Gemini: " GEMINI_KEY
    echo
    echo "TOKEN=\"$TOKEN\"" > "$CONF_FILE"
    echo "PASS=\"$PASS\"" >> "$CONF_FILE"
    echo "GEMINI_KEY=\"$GEMINI_KEY\"" >> "$CONF_FILE"
    chmod 600 "$CONF_FILE"
    echo "Configuración guardada en $CONF_FILE."
    read -n1 -s -r -p "Pulsa cualquier tecla para continuar..."
fi

# ===================== FUNCIONES IA 3D =====================
accion() {
    echo "Preparando modelo.scad vacío..."
    > "$HOME/modelo.scad"
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

    base64_stl=$(base64 -w 0 "$STL_FILE")
    tmpjson=$(mktemp)
    cat > "$tmpjson" <<EOF
{
  "message": "Subida STL $STL_GH",
  "content": "$base64_stl"
}
EOF
    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$STL_GH" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"
    rm "$tmpjson"

    if [ -f "$CODE_FILE" ]; then
        base64_code=$(base64 -w 0 "$CODE_FILE")
        tmpjson=$(mktemp)
        cat > "$tmpjson" <<EOF
{
  "message": "Subida código $CODE_GH",
  "content": "$base64_code"
}
EOF
        curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$CODE_GH" \
            -H "Authorization: token $TOKEN" \
            -H "Content-Type: application/json" \
            -d @"$tmpjson"
        rm "$tmpjson"
    fi

    echo "Subida completada."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

debian_shell() {
    proot-distro login debian
}

# ===================== FUNCIONES DE GEMINI CLI =====================
gemini_cli_chat() {
    clear
    echo "===== Gemini CLI Chat ====="
    echo "Escribe tu consulta. Escribe 'salir' para volver al menú principal."
    echo "--------------------------"
    
    while true; do
        read -rp "Tú: " query
        if [ "$query" == "salir" ]; then
            break
        fi
        
        if [ -z "$query" ]; then
            echo "No has introducido ninguna consulta."
            continue
        fi

        echo "Gemini: "
        
        # Se ha corregido el endpoint para usar gemini-2.0-flash en lugar de gemini-pro
        response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_KEY" \
        -H 'Content-Type: application/json' \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"$query\"}]}]}" | jq -r '.candidates[0].content.parts[0].text')

        echo "$response"
        echo
    done
}

# ===================== FUNCIONES INSTALAR/REST. ENTORNO =====================
backup() {
    dpkg --get-selections > "$DOCS_DIR/packages.list"
    tar --ignore-failed-read -czf "$BACKUP_FILE" \
        "$SHORTCUTS_DIR/menu.sh" \
        "$HOME_DOCS" \
        "$PROOT_DIR" \
        "$DOCS_DIR/packages.list"
    openssl enc -aes-256-cbc -pbkdf2 -salt -in "$BACKUP_FILE" -out "$ENCRYPTED_BACKUP" -k "$PASS"
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

restore() {
    termux-setup-storage
    openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENCRYPTED_BACKUP" -out "$BACKUP_FILE" -k "$PASS"
    mkdir -p "$SHORTCUTS_DIR/restore_temp"
    tar xzf "$BACKUP_FILE" -C "$SHORTCUTS_DIR/restore_temp"
    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $SHORTCUTS_DIR)" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/docs" "$HOME/" 2>/dev/null
    cp -r "$SHORTCUTS_DIR/restore_temp/$(basename $PROOT_DIR)" "/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/" 2>/dev/null
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

instalacion_limpia() {
    pkg update -y
    pkg install -y proot-distro
    if ! proot-distro list | grep -q '^debian'; then
        proot-distro install debian
    fi
    proot-distro login debian -- bash -c "apt update && apt upgrade -y && apt install -y openscad freecad"
    termux-setup-storage
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

upload_shell_script() {
    SCRIPT_PATH="$HOME/ShellGemini.sh"
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="script/shell_${fecha}.sh"
    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASS/<PASS>/g" -e "s/$GEMINI_KEY/<GEMINI_KEY>/g" "$SCRIPT_PATH" > "$DOCS_DIR/shell_tmp.sh"
    base64_content=$(base64 -w 0 "$DOCS_DIR/shell_tmp.sh")
    tmpjson=$(mktemp)
    cat > "$tmpjson" <<EOF
{
  "message": "Script $archivo",
  "content": "$base64_content"
}
EOF
    curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$archivo" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"
    rm "$tmpjson" "$DOCS_DIR/shell_tmp.sh"
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# ===================== MENÚ PRINCIPAL =====================
while :; do
    clear
    echo "===== SHELL.SH =====
1) IA 3D
2) Instalar-Restaurar entorno
3) Usar Gemini CLI
4) Backup GitHub del script shell.sh
5) Iniciar shell Debian
6) Salir
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
        3) gemini_cli_chat ;;
        4) upload_shell_script ;;
        5) debian_shell ;;
        6) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
