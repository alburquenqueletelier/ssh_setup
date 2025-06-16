#!/bin/bash

echo "[INFO] Listando las entradas de GRUB:"

index=0
grep "^menuentry '" /boot/grub/grub.cfg | while read -r line
do
  title=$(echo "$line" | cut -d"'" -f2)
  echo "$index: $title"
  index=$((index + 1))
done
