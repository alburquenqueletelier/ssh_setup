#!/bin/bash

# --- Función para mostrar el uso correcto ---
function uso() {
    echo "Uso: sudo $0 <IP>"
    echo "Ejemplo: sudo $0 192.168.0.10"
    exit 1
}

# --- Validar cantidad de argumentos ---
if [ $# -ne 1 ]; then
    echo "Error: Debes proporcionar la IP a configurar."
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
IPV4_ADDR="${IPV4_ADDR}/24"  # Agregamos la máscara automáticamente
GATEWAY="192.168.0.1"
DNS="8.8.8.8 1.1.1.1"

# --- Detectar si ya existe la conexión ---
CON_NAME=$(nmcli -t -f NAME connection show | grep "^${SSID}$")

if [ -z "$CON_NAME" ]; then
  echo "La conexión para SSID '$SSID' no existe. Creando nueva conexión WiFi..."
  nmcli connection add type wifi ifname "$IFACE" con-name "$SSID" ssid "$SSID" connection.permissions ""
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

# --- Reiniciar la conexión para aplicar cambios ---
nmcli connection down "$SSID"
nmcli connection up "$SSID"
