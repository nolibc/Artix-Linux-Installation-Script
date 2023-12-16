# Artix Linux Installation Script
A simple shell script that installs Artix Linux.

## Usage
To use the install script, just `curl` the `artix-setup` file onto the system and run it.

```bash
curl -O https://raw.githubusercontent.com/abql/Artix-Linux-Installation-Script/main/artix-setup
chmod +x artix-setup
./artix-setup
```

Some defaults include:

init: `runit`  
network: `networkmanager`  
bootloader: `grub`  
locale: `en_US.utf8`  
