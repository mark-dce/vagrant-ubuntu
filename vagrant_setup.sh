#!/bin/sh -e
echo "Vagrant Setup Starting" 

# Add Vagrant public key
mkdir -p /home/vagrant/.ssh
curl https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub >> /home/vagrant/.ssh/authorized_keys
chmod 0700 /home/vagrant/.ssh/
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Setup passwordless sudo
echo 'vagrant ALL=(ALL) NOPASSWD: ALL' > vagrant_passwordless
chown root:root vagrant_passwordless
chmod 0440 vagrant_passwordless
mv vagrant_passwordless /etc/sudoers.d/

# Turn off sshd dns checks (optional)
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
chmod o+w /etc/ssh/sshd_config
echo 'UseDNS no' >> /etc/ssh/sshd_config
chmod o-w /etc/ssh/sshd_config 

# Install VBox Guest Additions
mkdir ./cdrom
mount /dev/sr1 ./cdrom/		
/bin/sh /media/cdrom/VBoxLinuxAdditions.run
umount ./cdrom
rmdir ./cdrom

echo "Vagrant Setup Complete" 