#!/bin/bash

pacman -S sudo man grub efibootmgr elogind dhcpcd networkmanager networkmanager-runit

echo -e "\nBelow you will see a list of available regions. Select your region.\n"
ls /usr/share/zoneinfo
echo -e "\n"

read -p "Region: " -r region

echo -e "\nPlease select your city.\n"
ls /usr/share/zoneinfo/"$region"

read -p "City: " -r city

ln -sf /usr/share/zoneinfo/"$region"/"$city" /etc/localtime
hwclock --systohc

# change locale to en_US.UTF-8
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf

# boot loader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# users and hostname
read -r -p "Enter hostname: " hostname
echo "${hostname}" > /etc/hostname

echo "Enter password for root. "
passwd

read -r -p "Create user: " user
useradd -m "$user"
passwd "$user"

usermod -a -G wheel,video,audio "$user"

# hosts
cat >/etc/hosts <<EOL
127.0.0.1        localhost
::1              localhost
127.0.1.1	 ${hostname}.localdomain 	${hostname}
EOL

# uncomment wheel group
sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

# networkmanager symlink
if [[ ! -h /etc/runit/runsvdir/current/NetworkManager ]] ; then
  ln -s /etc/runit/sv/NetworkManager/ /etc/runit/runsvdir/current
fi

# arch repos
echo "Configuring Repositories"

cat >>/etc/pacman.conf <<EOL

[lib32]
Include = /etc/pacman.d/mirrorlist

# universe repository
[universe]
Server = https://universe.artixlinux.org/\$arch
Server = https://mirror1.artixlinux.org/universe/\$arch
Server = https://mirror.pascalpuffke.de/artix-universe/\$arch
Server = https://artixlinux.qontinuum.space/artixlinux/universe/os/\$arch
Server = https://mirror1.cl.netactuate.com/artix/universe/\$arch
Server = https://ftp.crifo.org/artix-universe/
EOL

pacman -Syy && pacman -Syu
pacman -S artix-archlinux-support

cat >>/etc/pacman.conf <<EOL

# arch
[extra]
Include = /etc/pacman.d/mirrorlist-arch

[community]
Include = /etc/pacman.d/mirrorlist-arch

[multilib]
Include = /etc/pacman.d/mirrorlist-arch
EOL

pacman-key --populate archlinux
