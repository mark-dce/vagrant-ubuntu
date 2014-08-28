vagrant-ubuntu
==============

Scripts to create a lean Ubuntu Vagrant box as a base for Hydra builds.

Run:

```
  ./build_box
```

At the boot prompt press ESC and F6 to gain access to the boot options. 
You'll get a prompt with a string of boot options. Replace the `file=/cdrom...`
boot option with the following:  

    `file=/floppy/hydra.seed auto=true priority=critical`

The rest of the installation is automated. The Ubuntu server installation will
proceed unattended. 

Once the installation is complete, and you have a login promt in the VM window,
create a vagrant package by running:

```
  ./package_box
```

Congratulations! You have just created a Vagrant box.  You can connect to your box 
using the following command:

```
   vagrant ssh
```


Specifications
--------------

The box is constrained to 512 MB of memory to vaguely resemble an
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

You are encouraged to look at *#Set Variables* section of the 
*build_box* script to modify the configuration to best suit your needs. 
In particular, take note of the location of the ISOs (which are not 
included in the git repository):

    INSTALLER="./isos/ubuntu-12.04.5-server-amd64.iso"  
    GUESTADDITIONS="./isos/VBoxGuestAdditions.iso"  

Assumptions have been made about the location of the VM folder
as well:

    VM_HOME="${HOME}/Documents/workspace/_no_backup/VirtualBox VMs"  
	
Please change this to reflect the configuration on your local system.

