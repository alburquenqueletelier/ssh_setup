#!/bin/bash
set -e

# --- Función para mostrar el uso correcto ---
function uso() {
    echo "Uso: sudo $0 <IP> <WIFI_PASSWORD>"
    echo "Ejemplo: sudo $0 192.168.0.10 miclave123"
    exit 1
}

# --- Validar cantidad de argumentos ---
if [ $# -ne 2 ]; then
    echo "Error: Debes proporcionar la IP a configurar y password del WIFI."
    uso
fi

# --- Validar formato de IPv4 ---
IPV4_ADDR="$1"
if [[ ! $IPV4_ADDR =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Error: La IP proporcionada no tiene un formato IPv4 válido."
    uso
fi

# Configuración de WiFi
IFACE=$(nmcli -t -f DEVICE,TYPE device | grep ':wifi' | grep -v 'p2p' | head -n1 | cut -d: -f1 | tr -d '\n')

if [ -z "$IFACE" ]; then
  echo "No se encontró interfaz Wi-Fi."
  exit 1
fi

echo "Usando interfaz Wi-Fi: $IFACE"

# --- Configuración fija ---
SSID="lab_soc"
WIFI_PASSWORD="$2"
IPV4_ADDR_WITH_MASK="${IPV4_ADDR}/24"
GATEWAY="192.168.0.1"
DNS="8.8.8.8 1.1.1.1"

# --- Eliminar conexión anterior si existe ---
if nmcli -t -f NAME connection show | grep -q "^${SSID}$"; then
  echo "Eliminando perfil anterior '$SSID' para evitar conflictos..."
  nmcli connection delete "$SSID"
fi

# --- Crear conexión con configuración completa, incluyendo seguridad WPA2 ---
echo "Creando nueva conexión WiFi '$SSID' con IP estática y WPA2..."
nmcli connection add type wifi ifname "$IFACE" con-name "$SSID" ssid "$SSID" \
  wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$WIFI_PASSWORD" \
  ipv4.addresses "$IPV4_ADDR_WITH_MASK" ipv4.gateway "$GATEWAY" \
  ipv4.dns "$DNS" ipv4.method manual connection.permissions ""

# --- Confirmación de configuración ---
echo "--- Configuración aplicada correctamente al perfil '$SSID' ---"
nmcli connection show "$SSID" | grep ipv4

# --- Reconectar ---
nmcli connection reload

# Si el SSID está visible, conectamos
if nmcli device wifi list ifname "$IFACE" | grep -q "$SSID"; then
  echo "SSID '$SSID' detectado. Intentando conectar..."
  nmcli device disconnect "$IFACE" || true
  sleep 1  # Delay corto para evitar conflictos de reconexión
  nmcli connection up "$SSID"
else
  echo "Nota: SSID '$SSID' no visible. La configuración queda almacenada para cuando esté disponible."
fi

# Mostrar la IP final de la interfaz
echo "--- IP actual en $IFACE ---"
ip -4 addr show "$IFACE" | grep inet || echo "No hay IP asignada aún."
