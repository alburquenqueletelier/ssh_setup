#!/bin/bash
set -e

# --- Función para mostrar el uso correcto ---
function uso() {
    echo "Uso: sudo $0 <IP> <WIFI_PASSWORD>"
    echo "Ejemplo: sudo $0 192.168.0.10 miclave123"
    exit 1
}

# --- Validar cantidad de argumentos ---
if [ $# -ne 1 ]; then
    echo "Error: Debes proporcionar la IP a configurar y passoword del WIFI."
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
IPV4_ADDR="${IPV4_ADDR}/24"  # Agregamos la máscara automáticamente
GATEWAY="192.168.0.1"
DNS="8.8.8.8 1.1.1.1"

# --- Detectar si ya existe la conexión ---
CON_NAME=$(nmcli -t -f NAME connection show | grep "^${SSID}$")

if [ -z "$CON_NAME" ]; then
  echo "La conexión para SSID '$SSID' no existe. Creando nueva conexión WiFi..."
  nmcli connection add type wifi ifname "$IFACE" con-name "$SSID" ssid "$SSID" connection.permissions ""

  nmcli connection modify "$SSID" wifi-sec.key-mgmt wpa-psk
  nmcli connection modify "$SSID" wifi-sec.psk "$WIFI_PASSWORD"
else
  echo "La conexión '$SSID' ya existe. Modificando parámetros..."
fi

# --- Aplicar configuración estática ---
nmcli connection modify "$SSID" ipv4.addresses "$IPV4_ADDR"
nmcli connection modify "$SSID" ipv4.gateway "$GATEWAY"
nmcli connection modify "$SSID" ipv4.dns "$DNS"
nmcli connection modify "$SSID" ipv4.method manual

# (Opcional) Desactivar IPv6 si quieres:
# nmcli connection modify "$SSID" ipv6.method ignore

echo "Configuración aplicada correctamente a la red '$SSID'."

# Verificar que el SSID está visible antes de intentar conectar
if nmcli device wifi list ifname "$IFACE" | grep -q "$SSID"; then
  echo "SSID '$SSID' detectado. Intentando conectar..."
  nmcli connection down "$SSID" 2>/dev/null
  nmcli connection up "$SSID"
else
  echo "Error: SSID '$SSID' no encontrado en el aire. No se puede levantar la conexión."
  exit 1
fi