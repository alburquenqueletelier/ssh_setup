#!/bin/bash

if [ -z "$1" ]; then
  echo "Uso: $0 <INDICE_DEL_MENU>"
  exit 1
fi

INDEX="$1"

echo "[INFO] Configurando GRUB para arrancar en la entrada de índice: $INDEX"
sudo grub-reboot "$INDEX"

if [ $? -eq 0 ]; then
  echo "[INFO] grub-reboot ejecutado correctamente. Reiniciando..."
  sudo reboot
else
  echo "[ERROR] Fallo grub-reboot"
  exit 1
fi
