# Setup to Configure SSH in Linux Environments
#==============================================
This project aims to provide a simple and easy-to-use setup for configuring SSH in Linux environments. Its primary goal is to enable remote and large-scale management of student PCs in the lab. This setup has some hardcode values for the lab's specific needs, but it can be easily adapted to other environments. Feel free to modify the code to suit your needs.

## Requirements

- Ubuntu 24.04
- Kali Linux 2025.1  
**Note:** Any machine with an OS capable of running SSH

## Execution

### Step 1
Clone the repository on the server PC  
`git clone https://github.com/SoC-UAI/ssh_setup.git`

### Step 2
Enter the setup directory  
`cd SSH_SETUP/setup`  
Start the SSH server  
`sudo ./ssh_server_setup.sh`

### Step 3
Set a static IP for the `lab_soc` network  
`sudo ./net_server_setup.sh <ip> <wifi_pass> # sudo ./net_server_setup.sh 192.168.0.1 '#YourWiFiPassword'`  

For the VIÑA lab, the host number is used in the IP by adding 10 to the assigned PC number, e.g.:

PC1 => 192.168.0.11


If more PCs are added, you can add 10 more or consult with the Lab Manager for a solution.

**Note:** If the password contains a *"#"*, you must enclose it in single quotes `'examplePass'`

### Step 4
Copy the public key to the SSH server  
`ssh-copy-id -i file.pub user@ip`  

**Important:**
- If you're copying the key again to a different OS, you must first run on the administrator (client) computer:  
  `ssh-keygen -R <ip>`  
  (This removes the previous `known_hosts` entry to avoid the system detecting a man-in-the-middle attack due to IP reuse.)
- Both the client and server PC (where the public key will be copied) must be on the same network *(lab_soc)*
- Replace `file.pub` with the corresponding key. Do the same for `user` and `ip`. The user may vary depending on the Linux distribution being used but must always have root permissions.

### Step 4.1
Validate the remote connection:  
`ssh <user>@<ip>`  
This should not require a password if everything was set up correctly.

### Step 5
Repeat the process with the remaining Linux distribution.  
**Note:** When testing the SSH connection, it will only work with the OS that is currently running. Therefore, if you are on Kali and want to test Ubuntu, you must first switch to Ubuntu, otherwise it will fail.

## Remote Connection
Each time you want to connect remotely from the client and you have already done so with a different distro, you must remove that machine from the known hosts:  
`ssh-keygen -R <ip>`

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for more details.

> This project is developed for educational purposes and is intended for non-commercial use only. It is provided as-is, without warranty of any kind.
