#!/bin/sh -e

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
VM_HOME="${HOME}/Documents/workspace/_no_backup/VirtualBox\ VMs"
HDD="${VM_HOME}/${NAME}/main.vdi"
NATNET="10.0.5.0/24"
IP=`echo ${NATNET} | sed -nE 's/^([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*/\1/p'`

# Build floppy image for configuration preseeding
hdiutil detach /Volumes/HYDRA-SEED/  # In case we've been here before
dd if=/dev/zero of=$SEEDS bs=1024 count=1440
diskutil eraseVolume MS-DOS HYDRA-SEED `hdiutil attach -nomount $SEEDS`
cp hydra.seed /Volumes/HYDRA-SEED/hydra.seed	# Debian Installer seed file
cp vagrant_setup.sh /Volumes/HYDRA-SEED/vagrant_setup.sh # Vagrant specific setup script, called by seed file

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
  --natpf1 "Guest SSH,tcp,,2222,,22" \
  --natpf1 "Guest Jetty,tcp,,8983,,8983" \
  --natpf1 "Guest Rails Server,tcp,,3000,,3000" \

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

VBoxManage storagectl ${NAME} \
    --name SATA --add sata --portcount 2 --bootable on
VBoxManage storageattach ${NAME} \
    --storagectl SATA --port 0 --type hdd --medium "${HDD}"
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
echo 'At the boot prompt, replace the file=/cdrom... boot option with the following:'
echo 'auto=true priority=critical file=/floppy/hydra.seed' # Use preseed file on floppy image
echo
echo 'FINISHING'
echo 'rm preseed.img'
echo "vagrant package --base ${NAME}"
echo "vagrant box add ${NAME} package.box
echo "vagrant init ${NAME}"
echo "vagrant up"



