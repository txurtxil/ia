#!/data/data/com.termux/files/usr/bin/bash

HOME_DOCS="$HOME/docs"
DL="$HOME/storage/downloads"

OWNER="txurtxil"
REPO="ia"
TOKEN="<TOKEN>"

cd "$HOME_DOCS" || exit

accion() {
    echo "Preparando modelo.scad..."
    rm -f "$HOME/modelo.scad" "$DL"/modelo.stl
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

subir_github() {
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

subir_script() {
    SCRIPT_PATH="$HOME/.shortcuts/menu.sh"
    if [ ! -f "$SCRIPT_PATH" ]; then
        echo "No se encontró el script $SCRIPT_PATH"
        read -n1 -s -r -p "Pulsa cualquier tecla..."
        return
    fi
    fecha=$(date +%Y%m%d_%H%M%S)
    archivo="menu_${fecha}.sh"

    # Enmascarar token en el script
    sed "s/$TOKEN/<TOKEN>/g" "$SCRIPT_PATH" > "$DL/$archivo"

    echo "Subiendo $archivo a GitHub..."
    gh_api="https://api.github.com/repos/$OWNER/$REPO/contents/$archivo"
    base64_content=$(base64 -w 0 "$DL/$archivo")

    tmpjson=$(mktemp)
    echo "{\"message\": \"Subida de script $archivo\", \"content\": \"$base64_content\"}" > "$tmpjson"

    curl -s -X PUT "$gh_api" \
        -H "Authorization: token $TOKEN" \
        -H "Content-Type: application/json" \
        -d @"$tmpjson"

    rm "$tmpjson"
    echo "Script subido y token enmascarado."
    read -n1 -s -r -p "Pulsa cualquier tecla..."
}

while :; do
    clear
    echo "===== IA 3D =====
1) OpenSCAD
2) FreeCAD
3) Ver STL con app predeterminada
4) Subir STL a GitHub
5) Subir este script a GitHub (token enmascarado)
0) Salir
================="
    read -rp "Elige opción: " opt
    case $opt in
        1) accion ;;
        2) freecad_run ;;
        3) ver ;;
        4) subir_github ;;
        5) subir_script ;;
        0) exit ;;
        *) echo "Opción inválida"; sleep 1 ;;
    esac
done
