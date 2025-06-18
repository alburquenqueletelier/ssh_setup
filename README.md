# Setup para configurar SSH en entornos linux

## Requerimientos

- Ubuntu 24.04
- Kali Linux 2025.1

## Ejecución

### Paso 1
Clonar el repositorio en el pc servidor `git clone https://github.com/alburquenqueletelier/ssh_setup.git`

### Paso 2
Entrar a setup `cd SSH_SETUP/setup`
Levanta el servidor ssh `sudo ./ssh_server_setup.sh`

### Paso 3
Configura la ip fija para la red lab_soc `sudo ./net_server_setup.sh <ip> <wifi_pass> # sudo ./net_server_setup.sh 192.168.0.1 '#TuClaveWiFI'` 
Para el lab de VIÑA se está usando el n° de host en la ip el n° que tiene el pc asignado + 10, ej:

```
PC1 => 192.168.0.11
```

En caso de agregar más pc se pueden adicionar 10 más o conversar con Lab Manager para solución.

**Nota:** si la contraseña tiene un *"#"* debes colocar la contraseña dentro de comillas simples 'ejemploPass'

### Paso 4
Copiar la llave pública al servidor ssh `ssh-copy-id -i archivo.pub usuario@ip`
**Importante:** 
- Si vas a copiar la clave por segunda vez al OS que falta, primero debes ejecutar en el computador administrador (cliente): `ssh-keygen -R <ip>` (esto elimina la entrada antigua de known_hosts para evitar que al copiar la llave la máquina detecte un ataque man-in-the-middle al estar usando la misma ip)
- Tanto el pc cliente como el servidor (donde se copiara la llave pública) deben estar en la misma red *(lab_soc)*
- Reemplazar el nombre del archivo.pub por la llave correspondiente. Lo mismo el usuario y la ip. El usuario varíaa según la distribución de linux que se esté utilizando, pero siempre con la cuenta con permisos root.

### Paso 4.1
Validar la conexión remota: `ssh <usuario>@<ip>` esto no debería requerir contraseña si quedo bien configurado.

### Paso 5
Repetir el proceso con la distribución de linux faltante.
**Nota:** al probar la conexión ssh solo funcionara con la distribución de OS que está en ejecución. Por ende, si está en Kali y quiere probar con Ubuntu, primero debe cambiar a Ubuntu, de lo contrario fallará.

## Conexión remota
Cada vez que con el cliente te quieras conectar de forma remota y ya lo hayas hecho a una distro tienes que borrar esa maquina de los pcs conocidos por ssh: `ssh-keygen -R <ip>`