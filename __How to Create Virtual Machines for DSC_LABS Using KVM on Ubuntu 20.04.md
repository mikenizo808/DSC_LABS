# How to Create Virtual Machines for DSC_LABS Using KVM on Ubuntu 20.04

## Intro
Here, we discuss the steps to deploy virtual machines on `Ubuntu 20.04` that we can use with the repo known as "DSC_LABS".

## Optional - Clone Repo
We will mostly use the repo from a Windows virtual machine later, but we can optionally clone the repo to our Linux node to review docs, etc.


    ## Change Directory

        cd Downloads/

    ## Clone the repo

        git clone https://github.com/mikenizo808/DSC_LABS.git

*Note: In the future, we expect you to be running Windows and to extract (or copy) to `C:\DSC_LABS`.*

## Navigate into folder

    cd DSC_LABS/

## List Folder

    ls -lh

## Open Visual Studio Code
From the terminal, we can open the current folder in `Visual Studio Code` with:

    code .

## Deploy Virtual Machines with `kvm`
Deploy one or more virtual machines using `kvm` and leave them unconfigured (though you can power them on and update if desired).  For tips on setting up your `Ubuntu` desktop for virtualization with `kvm`, check out:

    https://github.com/mikenizo808/Building-the-Ultimate-Ubuntu-Desktop-on-a-Pre-Made-Gaming-PC


## Optional - Read more about "Working with kvm Configuration Files":

    https://github.com/mikenizo808/Working-with-kvm-Configuration-Files

## Memory / RAM
Ideally, you should add RAM to your system so you have 32GB, though you could get by with 16GB only. Also, nice to have is 2 Desktops so you can run VMs on each one (they can both share the same interface with `vmm`, the `Virtual Machine Manager` GUI application. 

## Choosing a domain for your lab (and why people will tell you not to use `lab.local`)
One thing is for sure, do not use something that you can ping on the internet that is not yours such as `lab.com` (just making that up).  In our case, we always use `lab.local` which by standard is not allowed to route to the internet.  Of course the nodes inside the lab can talk to public DNS (i.e. 8.8.8.8, 1.1.1.1.1, etc.), if desired.

Please note that there have recently been some lazy standards allowed to pass that steps on `lab.local` in some small ways, but most can disregard the caution.

    https://en.wikipedia.org/wiki/.local


## Begin Creating VMs
Now we start making the VMs we will need to run the lab.

*Tip: When in doubt, use the GUI (the `vmm` icon in your applications) for managing VMs since it is really good.*

## Optional - Create a Windows Template
You can create a Windows template by building a guest, optionally performing Windows Updates, and then finally running `sysprep` to generalize the operating system.

From inside the guest, navigate to `c:\windows\system32\` and search for `sysprep.exe`.  Simply right-click and run as Administrator.  Next, choose the option for `Out of Box Experience` and then select `shutdown`.

Finally, edit the name of your vm to include "-template" or similar.  You can then use this image to deploy copies.

*Note: Your template will typically not be powered on again once built, though you can follow the above procedure again from time to time if updating the template is desired.*

## Clone a VM

    #list vms
    sudo virsh list --all

    #clone a vm
    sudo virt-clone --original Win-2019-Template --name dc01.lab.local --auto-clone


## Overview of DSC VMs
For this lab, we will have one or more of the following virtual machines:

    jump server (windows)  #you work from here
    domain controller 1    #handles auth, etc.
    domain controller 2    #handles auth, etc.
    certificate server     #handles certs
    dsc pull server        #gives us advanced dsc features

## Optional - Using Multiple Hypervisor Hosts
You can run `kvm` on multiple nodes if you have some available (i.e. multiple desktops/laptops).  I have my virtual machines spread across two physical hosts, each running `kvm`. They both connect to the same ethernet network hub.

## Example Output Host A

    mike@ubuntu03:~$ sudo virsh list --all
    Id   Name                State
    ------------------------------------
    -    dc01.lab.local      shut off
    -    dc02.lab.local      shut off
    -    jump01              shut off
    -    kali001             shut off
    -    Win-2019-Template   shut off


## Example Output Host B

    mike@ubuntu004:~$ sudo virsh list --all
    Id   Name                  State
    --------------------------------------
    -    cert01.lab.local      shut off
    -    dc03.lab.local        shut off
    -    dc04.lab.local        shut off
    -    dscpull01.lab.local   shut off
    -    Win-2019-Template     shut off

*Note: The `Name` for virtual machines can be short name, FQDN, or whatever you like. It does not need to match the OS, but it is a good practice.*

## Guest Networking
By default, guests will come up on what is called `NAT` which means the guest can magically use a virtual connection through your main host interface.  This is good if all of your virtual machines are on the same host. All guests can reach the internet and also communicate with each other.

However, if you need virtual machines across multiple hosts to communicate, then all virtual adapters should be set to use the `Host` device in `Bridged` mode.  The virtual machine should be powered off for this change.  You can optionally do it while powered on, but the change will not take affect until cold booted (i.e. reboot is not enough).  If changing network settings from a powered off state (recommended), you should have network access on your first boot up.

*Note: When using a `Host` adapter, you can optionally select the hosts WIFI or Ethernet connection. If wanting to communicate to VMs on other nearby hosts, be sure to use the same connection technique (WIFI or Ethernet) so that all virtual machines are on the same network.*

## Example Default Config with `NAT`
You should use the GUI for simplicity, but following snippet shows a virtual machine configuration when using `NAT`.

    <interface type='network'>
    <mac address='52:54:00:93:2d:5b'/>
    <source network='default' portid='7d73e38f-6dac-4af1-b74c-fbcf60398bbd' bridge='virbr0'/>
    <target dev='vnet0'/>
    <model type='e1000e'/>
    <alias name='net0'/>
    <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>

## Example with `Bridge`
You should use the GUI for simplicity, but following snippet shows a `bridge` connection, which is the recommended approach for communicating across hosts. Below, my device name is `enp3s0` but this can vary across devices. For example, another Ubuntu node on my network happens to use `enp4s0`.

*Tip: You can check your device name with `ifconfig` if needed. If you do not have that command `sudo apt install net-tools` or just export a config from a working VM setup to use the desired interface.*

    <interface type='direct'>
      <mac address='52:54:00:2a:9a:0c'/>
      <source dev='enp3s0' mode='bridge'/>
      <target dev='macvtap0'/>
      <model type='e1000e'/>
      <alias name='net0'/>
      <address type='pci' domain='0x0000' bus='0x01' slot='0x00' function='0x0'/>
    </interface>

*Note: The `interface type`, `source` and `target` are the main things that change when flippiong between `NAT` and `bridge` style networking.*

## No IP Address Shown in `bridge` Mode
When using the typical `NAT` setup you can ask `kvm` to tell you the IP Address of any given VM.  This is only for `NAT` mode, since when in `bridge` mode, the application is not aware of your upstream DHCP solution.  If using `bridge` mode, you can determine the guest IP Addresses by logging into your router and checking your DHCP status, etc.


## Listing Guest IP Addresses with `net-dhcp-leases`
For users of `NAT`, to list the IP Address and/or MAC Address of a domain (a.k.a. virtual machine or guest), we can run some native commands available to us from `libvirt` / `kvm`.

    #get network name
    virsh net-list

    #using output from above, enter network name
    virsh net-dhcp-leases <your-network-name> 

## List IP Address for a Single VM
Users of `NAT` can also list IP Address for a single VM.

    #list VMs
    sudo virsh list --all

    #get ip
    sudo virsh domifaddr <nameofvm>

    #get mac address (useful if above fails)
    sudo virsh domiflist <nameofvm>

## Reminder: Host Networking
When using `Host` (i.e. `Bridge`) networking for your guests (as opposed to `NAT`) you are on your own to learn the IP Address of the guests.  You can use `arp` or other techniques such as looking at your router to see DHCP leases, etc.

## Edit Config Files
To edit the configuration of a virtual machine, ideally we should use the GUI, but the next easiest is `virsh edit`.

    virsh edit <name of vm>

*Note: To change the editor used, you can run `/usr/bin/select-editor`* 

## Optional / Advanced - Exporting Config Files with `dumpxml`
When there is a setting we want to edit manually, we optionally export/import the config as needed.

    #list VMs
    sudo virsh list --all

    #export a config
    sudo virsh dumpxml myawesomevm > ~/Downloads/myawesomevm.xml

    #edit the file
    nano ~/Downloads/myawesomevm.xml

    #apply updated config
    sudo virsh update-device --domain myawesomevm --file ~/Downloads/myawesomevm.xml

    #start vm
    sudo virsh start myawesomevm

    #list ip address
    sudo virsh domifaddr myawesomevm

*Note: If you get the error `Failed to update device from /path/to/desired.xml` you can re-register the virtual machine by first removing it with `sudo virsh undefine <nameofvm>`; Finally, to re-register the VM, simply `sudo virsh define /path/to/desired.xml`.*

## Windows Firewall Common Settings
In the "DSC_LABS" repo, see the script `New-WinFwRule.ps1` which we included in the `payload` directory. This is a powershell script that enables `ICMP`, `RDP`, etc. through the Windows Firewall.

psedit "C:\DSC_LABS\dsc-payload\New-WinFwRule.ps1"


## Other Windows Firewall
I have had no issues with `dsc` and `Windows Server 2019`, but see the following for the Windows Firewall port to open on your domain controllers just in case it helps you:

    https://github.com/dsccommunity/ActiveDirectoryDsc/issues/247

*Note: It is unknown if the above is required, but you can optionally add a rule just in case.*

## Next Steps
Now that the virtual machines are deployed (albeit manually), you can start logging into the console of each one to answer a few questions to set the systems up as needed.

Then, proceed with the "docs" folder in DSC_LABS, which has a number of "DEMOs" for you to run through to configure the lab and domain, etc.
