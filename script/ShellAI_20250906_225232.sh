#!/data/data/com.termux/files/usr/bin/bash
# modules/upload_script.sh - Módulo para subir el script principal a GitHub

# Importar configuración
source "$(dirname "$0")/../config.sh"

# --- FUNCIONES DE SUBIDA ---
upload_shell_script() {
    # $0 es el nombre del script que se está ejecutando (ShellAI.sh)
    SCRIPT_PATH="$0"
    fecha=$(date +%Y%m%d_%H%M%S)
    # Creamos la carpeta 'script' en el repo si no existe
    archivo="script/ShellAI_${fecha}.sh"
    # Creamos un archivo temporal sin las claves sensibles
    sed -e "s/$TOKEN/<TOKEN>/g" -e "s/$PASS/<PASS>/g" -e "s/$GEMINI_KEY/<GEMINI_KEY>/g" "$SCRIPT_PATH" > "$DOCS_DIR/shell_tmp.sh"
    # Convertimos el archivo a base64 para la API de GitHub
    base64_content=$(base64 -w 0 "$DOCS_DIR/shell_tmp.sh")
    tmpjson=$(mktemp)
    # Creamos el JSON para la API
    cat > "$tmpjson" <<EOF
{
  "message": "Backup automático: $archivo",
  "content": "$base64_content"
}
EOF
    # Hacemos la llamada a la API de GitHub
    response=$(curl -s -X PUT "https://api.github.com/repos/$OWNER/$REPO/contents/$archivo" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson")
    # Limpiamos archivos temporales
    rm "$tmpjson" "$DOCS_DIR/shell_tmp.sh"
    # Comprobamos si la subida fue exitosa
    if echo "$response" | grep -q '"sha"'; then
        echo "✅ ¡Script subido correctamente como: $archivo"
    else
        echo "❌ Error al subir el script."
        echo "Respuesta de GitHub:"
        echo "$response" | jq .
    fi
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

# Ejecutar la función de subida
upload_shell_script
