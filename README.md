vagrant-centos
==============

Scripts to create a lean Ubuntu Vagrant box as a base for Hydra builds.

Run:

  ./build_box

At the boot prompt press ESC and F6 to gain access to the boot options. 
You'll get a prompt with a string of boot options. Replace the _file=/cdrom..._ 
boot option with the following:  
    _file=/floppy/hydra.seed' auto=true priority=critical_

The rest of the installation is automated. The Ubuntu server installation will
proceed unattended. Once the installation is complete, follow the instructions 
printed out under "FINISHING" to package you VM into a Vagrant box

Congratulations! You have just created a Vagrant box.


Specification
-------------

The box is constrained to 613 MiB of memory to vaguely resemble an
Amazon AWS micro instance. You may want to consider adjusting this
for your needs using options like:

    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", 2048]
        vb.customize ["modifyvm", :id, "--ioapic", "on", "--cpus", 2]
    end

in your `Vagrantfile`.

This box has a heavy bias towards US English locales. If this
affects you, please adjust the hydra.seed file accordingly. 


Additional Notes
----------------

Please be aware that these scripts will *not* install any special
provisioners beyond the shell. Patches will be considered if you
wish to contribute support for Puppet, Chef, etc.

This system is very bare-bones with just enough configuration to 
function as a Vagrant box. The intent is to provide a consistent
clean base to run additional Hydra deployment scripts against. 

You are encouraged to look at the file `vars.sh` to modify the
configuration to best suit your needs. In particular, take note
of the location of the ISOs (which aren't include in the git
repository):

    INSTALLER="./isos/ubuntu-12.04.4-server-amd64.iso"  
    GUESTADDITIONS="./isos/VBoxGuestAdditions.iso"  

Assumptions have been made about the location of the VM location
as well:

    VM_HOME="${HOME}/Documents/workspace/_no_backup/VirtualBox\ VMs"  

