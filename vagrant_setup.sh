#!/bin/sh -e
echo "Vagrant Setup Starting" 

# Update Ubuntu
apt-get update -y && apt-get upgrade -y

# Add Vagrant public key
mkdir -p /home/vagrant/.ssh
curl -s -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0700 /home/vagrant/.ssh/
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh
echo "- Vagrant public key added"

# Setup passwordless sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > vagrant_passwordless
chown root:root vagrant_passwordless
chmod 0440 vagrant_passwordless
mv vagrant_passwordless /etc/sudoers.d/
echo "- Vagrant passwordless sudo configured"


# Turn off sshd dns checks (optional)
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
chmod o+w /etc/ssh/sshd_config
echo 'UseDNS no' >> /etc/ssh/sshd_config
chmod o-w /etc/ssh/sshd_config 
echo "- SSH server DNS checking disabled"

# Install VBox Guest Additions
mkdir -p /media/cdrom 
mount /dev/cdrom /media/cdrom/ > /dev/null		
/media/cdrom/VBoxLinuxAdditions.run > /var/log/GuestAdditionInstall.log 2>&1 || true # suppress X.Org warning from guest additions
echo "- VirtualBox Guest Additions installed"

echo "Vagrant Setup Complete" 
