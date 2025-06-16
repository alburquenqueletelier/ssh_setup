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

# --- Configuración fija ---
SSID="lab_soc"
IFACE="wlan0"          # Ajusta esto si tu interfaz es distinta
WIFI_PASSWORD="$2"
IPV4_ADDR_WITH_MASK="${IPV4_ADDR}/24"
GATEWAY="192.168.0.1"
DNS="8.8.8.8 1.1.1.1"

# --- Detectar si ya existe la conexión ---
CON_NAME=$(nmcli -t -f NAME connection show | grep "^${SSID}$" || true)

if [ -z "$CON_NAME" ]; then
  echo "La conexión para SSID '$SSID' no existe. Creando nueva conexión WiFi..."
  nmcli connection add type wifi ifname "$IFACE" con-name "$SSID" ssid "$SSID" connection.permissions ""
  
  nmcli connection modify "$SSID" wifi-sec.key-mgmt wpa-psk
  nmcli connection modify "$SSID" wifi-sec.psk "$WIFI_PASSWORD"
else
  echo "La conexión '$SSID' ya existe. Modificando parámetros..."
fi

# --- Aplicar configuración IP estática SOLO a lab_soc ---
nmcli connection modify "$SSID" ipv4.addresses "$IPV4_ADDR_WITH_MASK"
nmcli connection modify "$SSID" ipv4.gateway "$GATEWAY"
nmcli connection modify "$SSID" ipv4.dns "$DNS"
nmcli connection modify "$SSID" ipv4.method manual

# --- Confirmación de configuración ---
echo "--- Configuración aplicada correctamente al perfil '$SSID' ---"
nmcli connection show "$SSID" | grep ipv4

# --- Reconectar ---
nmcli connection reload

# Si el SSID está visible, conectamos
if nmcli device wifi list ifname "$IFACE" | grep -q "$SSID"; then
  echo "SSID '$SSID' detectado. Intentando conectar..."
  nmcli device disconnect "$IFACE" || true
  nmcli device wifi connect "$SSID" password "$WIFI_PASSWORD" ifname "$IFACE"
else
  echo "Nota: SSID '$SSID' no visible. La configuración queda almacenada para cuando esté disponible."
fi

# Mostrar la IP final de la interfaz
echo "--- IP actual en $IFACE ---"
ip -4 addr show "$IFACE" | grep inet || echo "No hay IP asignada aún."
