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
        
        response=$(curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_KEY" \
        -H 'Content-Type: application/json' \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"$query\"}]}]}" | jq -r '.candidates[0].content.parts[0].text')

        echo "$response"
        echo
    done
}

# Función para generar código OpenSCAD con IA
generate_openscad_code() {
    clear
    echo "===== Generar código OpenSCAD con IA ====="
    echo "Escribe el prompt para generar el modelo. Guarda y sal del editor para continuar."
    tmp_prompt=$(mktemp)
    ${EDITOR:-nano} "$tmp_prompt"
    prompt_content=$(cat "$tmp_prompt")
    
    if [ -z "$prompt_content" ]; then
        echo "No se ha introducido ningún prompt. Volviendo al menú."
        rm "$tmp_prompt"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi
    
    echo "Generando código OpenSCAD..."
    
    # Pedimos a la IA que devuelva solo el código.
    FULL_PROMPT="Genera un script de OpenSCAD para la siguiente descripción. No incluyas texto extra, explicaciones ni bloques de código markdown. Solo devuelve el código.
    $prompt_content"
    
    # Hacemos la llamada a la API y guardamos la respuesta en un archivo temporal.
    tmp_response=$(mktemp)
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_KEY" \
        -H 'Content-Type: application/json' \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"$FULL_PROMPT\"}]}]}" > "$tmp_response"

    # Procesamos la respuesta.
    code_content=$(jq -r '.candidates[0].content.parts[0].text' "$tmp_response")

    # Verificamos si la extracción fue exitosa.
    if [ -z "$code_content" ] || [ "$code_content" == "null" ]; then
        echo "ERROR: La IA no pudo generar un código válido."
        echo "El prompt de la IA fue: "
        cat "$tmp_prompt"
        echo "La respuesta de la IA fue:"
        cat "$tmp_response"
        rm "$tmp_prompt" "$tmp_response"
        read -n1 -s -r -p "Revisa tu prompt o inténtalo de nuevo. Pulsa cualquier tecla..."
        return
    fi
        
    echo "$code_content" > "$HOME/modelo.scad"
    rm "$tmp_prompt" "$tmp_response"
    
    echo "Código generado y guardado en $HOME/modelo.scad"
    
    # Se ha añadido la compilación automática aquí
    echo "Compilando el archivo para generar el STL..."
    proot-distro login debian -- /usr/bin/openscad -o "$DL/modelo.stl" "$HOME/modelo.scad"
    
    if [ -f "$DL/modelo.stl" ]; then
        echo "STL actualizado en Descargas."
    else
        echo "No se encontró modelo.stl tras la compilación."
    fi
    
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# Función para generar código FreeCAD con IA
generate_freecad_code() {
    clear
    echo "===== Generar código FreeCAD (Python) con IA ====="
    echo "Escribe el prompt para generar el script. Guarda y sal del editor para continuar."
    tmp_prompt=$(mktemp)
    ${EDITOR:-nano} "$tmp_prompt"
    prompt_content=$(cat "$tmp_prompt")
    
    if [ -z "$prompt_content" ]; then
        echo "No se ha introducido ningún prompt. Volviendo al menú."
        rm "$tmp_prompt"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi
    
    echo "Generando código FreeCAD (Python)..."
    
    # Pedimos a la IA que devuelva solo el código.
    FULL_PROMPT="Genera un script de Python completo y válido para FreeCAD basado en la siguiente descripción. El script debe ser totalmente funcional y guardar el resultado como un archivo STL con la ruta completa '$DL/modelo.stl'. Utiliza solo operaciones booleanas y formas básicas (cajas, cilindros) para construir geometrías complejas. Asegúrate de que todas las operaciones booleanas sean entre dos formas sólidas para evitar el error 'Part.Compound'. No incluyas texto extra, explicaciones, JSON ni bloques de código markdown. Solo devuelve el código.
    $prompt_content"
    
    # Hacemos la llamada a la API y guardamos la respuesta en un archivo temporal.
    tmp_response=$(mktemp)
    curl -s -X POST "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_KEY" \
        -H 'Content-Type: application/json' \
        -d "{\"contents\":[{\"parts\":[{\"text\":\"$FULL_PROMPT\"}]}]}" > "$tmp_response"

    # Extraemos el contenido del campo 'text' de la respuesta JSON.
    code_content=$(jq -r '.candidates[0].content.parts[0].text' "$tmp_response")
    
    if [ -z "$code_content" ] || [ "$code_content" == "null" ]; then
        # Si la extracción falla, el archivo queda vacío. Muestra el error y sale.
        echo "ERROR: La IA no pudo generar un código válido."
        echo "El prompt de la IA fue: "
        cat "$tmp_prompt"
        echo "La respuesta de la IA fue:"
        cat "$tmp_response"
        rm "$tmp_prompt" "$tmp_response"
        read -n1 -s -r -p "Revisa tu prompt o inténtalo de nuevo. Pulsa cualquier tecla..."
        return
    fi

    # Elimina los bloques de código Markdown que a veces la IA añade.
    cleaned_code=$(echo "$code_content" | sed -e '/^```\(python\|json\)\?$/d' -e '/^```$/d')

    if [ -z "$cleaned_code" ]; then
        echo "ERROR: La respuesta de la IA está vacía después de la limpieza."
        echo "El prompt de la IA fue: "
        cat "$tmp_prompt"
        echo "La respuesta de la IA fue:"
        cat "$tmp_response"
        rm "$tmp_prompt" "$tmp_response"
        read -n1 -s -r -p "Revisa tu prompt o inténtalo de nuevo. Pulsa cualquier tecla..."
        return
    fi
    
    echo "$cleaned_code" > "$HOME/modelo.py"
    rm "$tmp_prompt" "$tmp_response"
    
    echo "Código generado y guardado en $HOME/modelo.py"
    
    # Se ha añadido la compilación automática aquí
    echo "Compilando el script para generar el STL..."
    proot-distro login debian -- /usr/bin/freecadcmd "$HOME/modelo.py"
    
    if [ -f "$DL/modelo.stl" ]; then
        echo "STL actualizado en Descargas."
    else
        echo "No se encontró modelo.stl tras la compilación."
    fi
    
    read -n1 -s -r -p "Pulsa cualquier tecla..."
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

# --- Estilos y Comandos para Networking ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # Sin Color
PROOT_CMD="proot-distro login debian -- /bin/bash -c"
TERMUX_CMD="/data/data/com.termux/files/usr/bin/bash -c"

# --- Funciones de Networking ---
show_banner() {
    echo -e "${GREEN}"
    echo "================================================"
    echo "   Analizador de Red con Debian (Proot) v2.0    "
    echo "================================================"
    echo -e "${NC}"
}

check_dependencies() {
    echo -e "\n${YELLOW}--- Verificando Dependencias ---${NC}"
    local termux_deps=("iproute2" "net-tools" "curl")
    local debian_deps=("iproute2" "net-tools" "traceroute" "mtr" "whois" "dnsutils" "tcpdump")
    local missing_termux=()
    local missing_debian=()

    # Verificar en Termux
    for dep in "${termux_deps[@]}"; do
        if ! $TERMUX_CMD "command -v $dep &> /dev/null"; then
            missing_termux+=("$dep")
        fi
    done

    # Verificar en Debian
    for dep in "${debian_deps[@]}"; do
        if ! $PROOT_CMD "command -v $dep &> /dev/null"; then
            missing_debian+=("$dep")
        fi
    done

    if [ ${#missing_termux[@]} -gt 0 ]; then
        echo -e "${RED}Faltan herramientas en Termux:${NC} ${missing_termux[*]}"
        echo -e "${YELLOW}Para instalarlas, ejecuta: ${NC}pkg install ${missing_termux[*]}"
    else
        echo -e "${GREEN}Todas las dependencias de Termux están instaladas.${NC}"
    fi

    if [ ${#missing_debian[@]} -gt 0 ]; then
        echo -e "${RED}Faltan herramientas en el contenedor Debian:${NC} ${missing_debian[*]}"
        echo -e "${YELLOW}Para instalarlas, ejecuta: ${NC}${PROOT_CMD} 'apt-get update && apt-get install -y ${missing_debian[*]}'"
    else
        echo -e "${GREEN}Todas las dependencias de Debian están instaladas.${NC}"
    fi

    echo -e "\n${GREEN}Presiona Enter para volver al menú...${NC}"
    read
}

get_ips() {
    echo -e "${YELLOW}--- Tus Direcciones IP (vistas desde Termux) ---${NC}"
    echo -n "IP Local del Dispositivo: "
    if $TERMUX_CMD "command -v ip &> /dev/null"; then
        $TERMUX_CMD "ip a | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1"
    elif $TERMUX_CMD "command -v ifconfig &> /dev/null"; then
        $TERMUX_CMD "ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}' | cut -d/ -f1"
    else
        echo -e "${RED}Error: Herramienta 'ip' o 'ifconfig' no encontrada en Termux.${NC}"
        echo -e "${YELLOW}Ejecuta 'opción 7' para instalar las dependencias faltantes.${NC}"
    fi
    
    echo -n "IP Pública (puede tardar): "
    if $TERMUX_CMD "command -v curl &> /dev/null"; then
        $TERMUX_CMD "curl -s ifconfig.me"
    else
        echo -e "${RED}Error: Herramienta 'curl' no encontrada en Termux.${NC}"
        echo -e "${YELLOW}Ejecuta 'opción 7' para instalar las dependencias faltantes.${NC}"
    fi
    echo ""
}

show_connections() {
    echo -e "\n${YELLOW}--- Conexiones de Red Activas (desde Termux) ---${NC}"
    if $TERMUX_CMD "command -v ss &> /dev/null"; then
        $TERMUX_CMD "ss -tulnp"
    elif $TERMUX_CMD "command -v netstat &> /dev/null"; then
        $TERMUX_CMD "netstat -tulnp"
    else
        echo -e "${RED}Error: Herramienta 'ss' o 'netstat' no encontrada en Termux.${NC}"
        echo -e "${YELLOW}Ejecuta 'opción 7' para instalar las dependencias faltantes.${NC}"
    fi
}

trace_route() {
    read -p "Introduce el dominio o IP para Traceroute (ej: 1.1.1.1): " target
    if [[ ! -z "$target" ]]; then
        echo -e "\n${YELLOW}--- Trazando la ruta a $target ---${NC}"
        ${PROOT_CMD} "traceroute $target"
    else
        echo -e "${RED}No se introdujo un destino.${NC}"
    fi
}

mtr_route() {
    read -p "Introduce el dominio o IP para MTR (ej: google.com): " target
    if [[ ! -z "$target" ]]; then
        echo -e "\n${YELLOW}--- Ejecutando MTR hacia $target ---${NC}"
        ${PROOT_CMD} "mtr -r -c 10 $target"
    else
        echo -e "${RED}No se introdujo un destino.${NC}"
    fi
}

capture_packets() {
    echo -e "\n${YELLOW}--- Captura de Paquetes con tcpdump ---${NC}"
    echo -e "${RED}AVISO: Debido a las limitaciones de proot, es probable que solo veas el tráfico generado DENTRO de Debian.${NC}"
    read -p "Introduce la interfaz de red (ej: eth0, any) o deja en blanco para 'any': " interface
    interface=${interface:-any}
    read -p "Introduce un filtro (ej: 'port 80' o 'host 1.1.1.1') o deja en blanco: " filter
    echo -e "\n${YELLOW}Iniciando tcpdump... (Presiona Ctrl+C para detener la captura)${NC}"
    ${PROOT_CMD} "tcpdump -i ${interface} -n ${filter}"
}

get_domain_info() {
    read -p "Introduce el dominio o IP a consultar (ej: wikipedia.org): " target
    if [[ ! -z "$target" ]]; then
        echo -e "\n${YELLOW}--- Información WHOIS de $target ---${NC}"
        ${PROOT_CMD} "whois $target"
        echo -e "\n${YELLOW}--- Registros DNS (A, AAAA, MX) de $target ---${NC}"
        ${PROOT_CMD} "dig $target A +short; dig $target AAAA +short; dig $target MX +short"
    else
        echo -e "${RED}No se introdujo un destino.${NC}"
    fi
}

# --- Menú de Utilidades de Networking ---
networking_utilities_menu() {
    while true; do
        clear
        show_banner
        get_ips
        echo -e "\nElige una herramienta de análisis:"
        echo "1. Ver conexiones activas (netstat)"
        echo "2. Traceroute clásico"
        echo -e "3. ${GREEN}MTR (Traceroute + Ping avanzado)${NC}"
        echo "4. Obtener información de Dominio/IP (Whois & DNS)"
        echo -e "5. ${RED}Capturar paquetes (tcpdump)${NC}"
        echo "6. Volver"
        echo -e "7. ${YELLOW}Verificar e Instalar Dependencias${NC}"
        read -p "Opción: " choice

        case $choice in
            1) show_connections ;;
            2) trace_route ;;
            3) mtr_route ;;
            4) get_domain_info ;;
            5) capture_packets ;;
            6) break ;;
            7) check_dependencies ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        
        # Este mensaje está dentro del bucle del submenú
        [ "$choice" -ne 6 ] && echo -e "\n${GREEN}Presiona Enter para volver al menú...${NC}" && read
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
    echo "===== SHELL.SH ====="
    echo "1) IA 3D"
    echo "2) Instalar-Restaurar entorno"
    echo "3) Usar Gemini CLI"
    echo "4) Backup GitHub del script shell.sh"
    echo "5) Iniciar shell Debian"
    echo "6) Utilidades Networking"
    echo "7) Salir"
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
                echo "5) Generar OpenSCAD con IA"
                echo "6) Generar FreeCAD con IA"
                echo "0) Volver"
                echo "=================="
                read -rp "Elige opción: " subopt
                case $subopt in
                    1) accion ;;
                    2) freecad_run ;;
                    3) ver ;;
                    4) subir_stl ;;
                    5) generate_openscad_code ;;
                    6) generate_freecad_code ;;
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
                echo "3) Instalación limpia (proot + Debian + OpenSCAD + FreeCAD)"
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
        3) gemini_cli_chat ;;
        4) upload_shell_script ;;
        5) debian_shell ;;
        6) networking_utilities_menu ;;
        7) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
