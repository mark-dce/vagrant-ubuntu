#!/bin/bash -e

# Based on info from
# http://www.beyondlinux.com/2011/06/29/how-to-automate-virtual-machine-creation-and-runing-on-virtualbox-by-command-line/
# and patterened after
# https://github.com/2creatives/vagrant-centos


# Set Variables
NAME="dce-ubuntu-12.04.4"
TYPE="Ubuntu_64"
INSTALLER="./isos/ubuntu-12.04.4-server-amd64.iso"
GUESTADDITIONS="./isos/VBoxGuestAdditions.iso"
HDD="${HOME}/VirtualBox VMs/${NAME}/main.vdi"
HDD_SWAP="${HOME}/VirtualBox VMs/${NAME}/swap.vdi"
NATNET="10.0.2.0/24"

# Create VM and initialize base opitons
vboxmanage createvm --name $NAME --ostype $TYPE --register

vboxmanage modifyvm $NAME \
  --vram 16 \
  --accelerate3d off \
  --memory 512 \
  --usb off \
  --audio none \
  --boot1 disk --boot2 dvd --boot3 none --boot4 none \
  --nictype1 virtio --nic1 nat --natnet1 "${NATNET}" \
  --nictype2 virtio \
  --nictype3 virtio \
  --nictype4 virtio \
  --acpi on --ioapic off \
  --chipset piix3 \
  --rtcuseutc on \
  --hpet on \
  --bioslogofadein off \
  --bioslogofadeout off \
  --bioslogodisplaytime 0 \
  --biosbootmenu disabled

VBoxManage createhd --filename "${HDD}" --size 8192

VBoxManage createhd --filename "${HDD_SWAP}" --size 4096

VBoxManage storagectl ${NAME} \
    --name SATA --add sata --portcount 2 --bootable on
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 0 --type hdd --medium "${HDD}"
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 1 --type hdd --medium "${HDD_SWAP}"
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 2 --type dvddrive --medium "${INSTALLER}"
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 3 --type dvddrive --medium "${GUESTADDITIONS}"

# Start up the machine
VBoxManage startvm ${NAME} --type gui

IP=`echo ${NATNET} | sed -nE 's/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`

echo 'At the boot prompt, hit <TAB> and then add:'
echo " ks=http://${IP}.3:8081"


