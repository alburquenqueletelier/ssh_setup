#!/bin/bash
set -e

echo "--- Actualizando la lista de paquetes e instalando Docker ---"
apt update
apt install -y docker.io

echo "--- Habilitando y iniciando el servicio Docker ---"
systemctl enable docker --now
systemctl start docker

# Verificación opcional de que Docker está corriendo
if systemctl is-active --quiet docker; then
    echo "Docker se ha iniciado correctamente."
else
    echo "¡Error: Docker no se pudo iniciar! Por favor, verifica los logs."
    exit 1
fi

echo "--- Instalando Docker Compose (como plugin de Docker CLI) ---"
# Esta es la forma recomendada para la mayoría de las instalaciones modernas de Docker
# Se asegura de que docker compose esté integrado con la CLI principal de Docker
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Si prefieres la versión del paquete de apt (a menudo más antigua):
# echo "--- Instalando Docker Compose (desde paquete apt) ---"
# apt install -y docker-compose

echo "--- Verificando versiones de Docker y Docker Compose ---"
docker -v
docker compose version

echo "--- Agregando al usuario 'soclab' al grupo 'docker' ---"
# Verifica si el usuario existe antes de intentar agregarlo
if id -u "soclab" >/dev/null 2>&1; then
    usermod -aG docker soclab
    echo "El usuario 'soclab' ha sido añadido al grupo 'docker'."

    # Asegura que los permisos del directorio .docker sean correctos
    if [ -d "/home/soclab/.docker" ]; then
        echo "Ajustando permisos para /home/soclab/.docker"
        chown soclab:soclab /home/soclab/.docker -R
        chmod g+rwx /home/soclab/.docker -R
    fi
else
    echo "Advertencia: El usuario 'soclab' no existe. No se pudo agregar al grupo 'docker'."
fi

echo "--- Proceso de instalación finalizado ---"
echo "¡IMPORTANTE! Para que los cambios surtan efecto, el usuario 'soclab' DEBE cerrar su sesión actual y volver a iniciarla."
echo "Después de reiniciar la sesión, 'soclab' podrá ejecutar comandos Docker sin 'sudo'."
echo "Puedes probarlo con: docker run hello-world"