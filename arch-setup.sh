loadkeys no
sfdisk /dev/sda << EOF
,512MiB
;
EOF
mkfs.fat /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mount --mkdir /dev/sda1 /mnt/boot
pacstrap -K /mnt base linux linux-firmware grub sudo vim --noconfirm --needed
genfstab -U /mnt >> /mnt/etc/fstab
pacstrap /mnt efibootmgr --noconfirm --needed
arch-chroot /mnt << EOS
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
hwclock --systohc
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_DK.UTF-8 UTF-8/en_DK.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
cat > /etc/locale.conf << EOF
LANG=en_US.UTF-8
LC_TIME=en_DK.UTF-8
EOF
echo >/etc/vconsole.conf "KEYMAP=no"
pacman -S networkmanager dhclient --noconfirm --needed
systemctl enable --now NetworkManager
sed -i 's/^# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL' /etc/sudoers
sed -i 's/^# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL' /etc/sudoers
pacman -S i3-wm xorg xorg-xinit --noconfirm --needed
pacman -S --asdeps dmenu --noconfirm --needed
grub-install --efi-directory /boot /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
EOS
