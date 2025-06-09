#!/bin/bash

# --- Comprobación de permisos ---
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse con privilegios de root (sudo)."
   echo "Usa: sudo ./setup.sh"
   exit 1
fi

echo "--- Iniciando configuración de SSH en el sistema ---"

# --- 1. Detectar la distribución de Linux y su gestor de paquetes ---
DISTRO=""
PACKAGE_MANAGER=""

if command -v apt &> /dev/null; then
    DISTRO="Debian/Ubuntu"
    PACKAGE_MANAGER="apt"
elif command -v dnf &> /dev/null; then
    DISTRO="Fedora/RHEL"
    PACKAGE_MANAGER="dnf"
elif command -v yum &> /dev/null; then
    DISTRO="CentOS/RHEL"
    PACKAGE_MANAGER="yum"
else
    echo "¡Error! Distribución de Linux no reconocida o gestor de paquetes no encontrado."
    echo "Este script soporta Debian/Ubuntu, Fedora/RHEL, y CentOS."
    exit 1
fi

echo "Detectada distribución: $DISTRO"
echo "Gestor de paquetes: $PACKAGE_MANAGER"

# --- 2. Instalar OpenSSH Server si no está presente ---
echo "--- Verificando e instalando OpenSSH Server ---"
if ! systemctl is-active --quiet ssh; then
    echo "OpenSSH Server no está activo o instalado. Procediendo con la instalación..."
    case "$PACKAGE_MANAGER" in
        "apt")
            apt update && apt install -y openssh-server
            ;;
        "dnf")
            dnf install -y openssh-server
            systemctl enable sshd # En RHEL/Fedora, el servicio se llama sshd
            systemctl start sshd
            ;;
        "yum")
            yum install -y openssh-server
            systemctl enable sshd
            systemctl start sshd
            ;;
    esac
    if [ $? -eq 0 ]; then
        echo "OpenSSH Server instalado y servicio iniciado."
    else
        echo "¡Error! No se pudo instalar OpenSSH Server. Abortando."
        exit 1
    fi
else
    echo "OpenSSH Server ya está instalado y activo."
fi

# --- 3. Asegurar que el servicio SSH inicie al arrancar ---
echo "--- Habilitando el servicio SSH al inicio del sistema ---"
if [ "$PACKAGE_MANAGER" == "apt" ]; then
    systemctl enable ssh
    systemctl start ssh # Asegurarse de que esté corriendo por si se deshabilitó
else # dnf/yum
    systemctl enable sshd
    systemctl start sshd
fi
echo "Servicio SSH habilitado para iniciar automáticamente."

# --- 4. Configurar el Firewall ---
echo "--- Configurando el firewall para permitir SSH (puerto 22) ---"
if command -v ufw &> /dev/null; then
    echo "Usando UFW (Uncomplicated Firewall)."
    ufw allow 22/tcp
    ufw --force enable # Habilita UFW y no pregunta si ya está activo
    echo "Regla para SSH (puerto 22) añadida a UFW. UFW habilitado."
elif command -v firewall-cmd &> /dev/null; then
    echo "Usando Firewalld."
    firewall-cmd --add-service=ssh --permanent
    firewall-cmd --reload
    firewall-cmd --add-port=22/tcp --permanent # Aunque ssh service ya lo cubre, es una buena práctica
    firewall-cmd --reload
    systemctl enable firewalld # Asegurarse que firewalld inicie con el sistema
    systemctl start firewalld
    echo "Regla para SSH (servicio 'ssh' y puerto 22) añadida a Firewalld. Firewalld habilitado."
else
    echo "Advertencia: Ni UFW ni Firewalld encontrados. Por favor, configura tu firewall manualmente."
    echo "Asegúrate de permitir el puerto 22/tcp para conexiones SSH."
fi

echo "--- Configuración de SSH completada. ---"
echo "Ahora puedes proceder a copiar tu llave pública desde tu PC principal a este equipo."