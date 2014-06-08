#!/bin/bash -e

# Based on info from
# http://www.beyondlinux.com/2011/06/29/how-to-automate-virtual-machine-creation-and-runing-on-virtualbox-by-command-line/
# and patterened after
# https://github.com/2creatives/vagrant-centos
# models automated seed file from
# http://blog.dustinkirkland.com/2011/03/ubuntu-server-quick-install-no.html

# Set Variables
NAME="dce-ubuntu-12.04.4"
TYPE="Ubuntu_64"
INSTALLER="./isos/ubuntu-12.04.4-server-amd64.iso"
GUESTADDITIONS="./isos/VBoxGuestAdditions.iso"
SEEDS="./preseed.img"
VM_HOME="/Users/mark/Documents/workspace/_no_backup/VirtualBox\ VMs"
# HDD="${HOME}/VirtualBox VMs/${NAME}/main.vdi"
HDD="${VM_HOME}/${NAME}/main.vdi"
HDD_SWAP="${VM_HOME}/${NAME}/swap.vdi"
NATNET="10.0.5.0/24"
IP=`echo ${NATNET} | sed -nE 's/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`

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

# Create and attach virtual HDs and attach installation media
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

# Attach a floppy image with the Ubuntu Seed file
VBoxManage storagectl ${NAME} \
    --name FDC --add floppy --portcount 1 --bootable on
VBoxManage storageattach ${NAME} \
    --storagectl FDC --port 0 --device 0 --type fdd --medium "${SEEDS}"

# Start up the machine
VBoxManage startvm ${NAME} --type gui

# Provide instructions to start automated installation using seed file
# clear
echo 'At the boot prompt, add the following boot options ...'
# echo "ks=http://${IP}.3:8081" # use a kickstart file servered from the host system
# echo "locale=en_US console-setup/ask_detect=false keyboard-configuration/layoutcode=us" # set default answers that can't easily be preseeded
echo "auto preseed/file=/floppy/vagrant-hydra.cfg debian/priority=critical" # Use preseed file on floppy image



