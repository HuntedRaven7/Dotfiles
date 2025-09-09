#!

FLAG_FILE="/tmp/workspaces_flag"
WIDGET_NAME="workspaces"

watch_for_inactivity() {
    while true; do
        if [ -f "$FLAG_FILE" ]; then
            last_mod=$(stat -c %Y "$FLAG_FILE")
            now=$(date +%s)
            diff=$((now - last_mod))
            if [ "$diff" -ge 3 ]; then
                eww update workspaces-rev=false
                sleep 0.3
                eww close "$WIDGET_NAME"
                rm -f "$FLAG_FILE"
                break
            fi
        else
            break
        fi
        sleep 1
    done
}

# Si se ejecuta en modo watcher, solo corre el watcher
if [ "$1" = "watch" ]; then
    watch_for_inactivity
    exit 0
fi

# Verifica si se pasó un número de workspace
if [[ "$1" =~ ^[1-9]$|^10$ ]]; then
    workspace_num="$1"

    # Cambia al workspace especificado
    hyprctl dispatch workspace "$workspace_num"

    # Fuerza actualización del workspace actual en eww
    eww update selected-ws="$workspace_num"

    # Lee el estado del flag
    flag_content=$(cat "$FLAG_FILE" 2>/dev/null || echo "off")

    # Si el flag está en "on", solo ejecuta el comando y sale
    if [ "$flag_content" = "on" ]; then
        exit 0
    fi

    # Actualiza el flag de actividad
    touch "$FLAG_FILE"

    # Obtiene ventanas activas
    active_windows=$(eww active-windows)

    # Si no está abierto, lo abre
    if [[ "$active_windows" != *"$WIDGET_NAME"* ]]; then
        eww close "$WIDGET_NAME" 2>/dev/null
        sleep 0.2
        eww open "$WIDGET_NAME"
    fi

    # Lanza el watcher si no está corriendo
    if ! pgrep -f "$0 watch" > /dev/null; then
        "$0" watch &
    fi

else
    echo "Uso: $0 [1-10]"
    echo "Ejemplo: $0 3  # Cambia al workspace 3 y muestra el selector"
    exit 1
fi
