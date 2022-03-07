# How to prepare Ubuntu 20.04 LTS Linux for DSC

## Intro
This document is a guide to get `dsc for Linux` installed on an example target node running `Ubuntu 20.04` Linux.

## Supporting Information
Visit the official github project page for the latest details and other supported distributions.

    https://github.com/Microsoft/PowerShell-DSC-for-Linux

## OS Install
Perform the installation of `Ubuntu 20.04` from ISO or similar. The minimal installation is fine.

## Update and Install Packages
These are not required for `dsc` but are useful for our purposes.

    sudo apt update
    sudo apt install net-tools -y
    sudo apt install openssh-server -y

## Enable and Configure Firewall
Adjust for your network as needed when setting the rule below.

    sudo ufw enable
    sudo ufw allow from 10.0.0.0/8 to any app OpenSSH

## Restart Services

    sudo systemctl restart ufw.service
    sudo systemctl restart sshd.service

## Add Microsoft Repository

    #install curl
    sudo apt install curl -y

    #download repo
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc

    #add repo
    sudo apt-add-repository https://packages.microsoft.com/ubuntu/20.04/prod

    #update package list
    sudo apt update

*Note: Once the microsoft repo has been added as above, we can then install various bits such as `powershell` and `omi` directly from `apt`.  We do those installs next.*

## Install  `omi`
By installing `omi` we can get further control of the Linux guest for automation, monitoring and reporting.

    sudo apt install omi -y

## Optional - Check `omi` Service Status

    sudo systemctl status omid.service

## Optional - Learn About NTLM on Linux
The following article discusses authentication across Linux and Windows.

    https://github.com/Microsoft/omi/blob/master/Unix/doc/setup-ntlm-omi.md

## Optional - Show Linux Authentication Packages
If you read the article above, you will be familiar with these two package names. We can check if they are installed by performing the following:

    #installed by default
    sudo apt list libgssapi-krb5-2
    
    #not installed by default
    sudo apt list gss-ntlmssp

*Note: Likely, you will have the first one but not the second one.*

## Example Output for `Ubuntu 20.04`
    
    localadmin@linux01:~$ sudo apt list libgssapi-krb5-2 gss-ntlmssp | grep amd 
    gss-ntlmssp/focal 0.7.0-4build3 amd64
    libgssapi-krb5-2/focal-updates,focal-security,now 1.17-6ubuntu4.1 amd64 [installed,automatic]

## Optional - Add support for `gss` API
As we can see from above, we will not have the `gss-ntlmssp` by default. We can install this to add "API" support for `gss`.

    sudo apt install gss-ntlmssp

*Note: For more detail about `gss` see http://manpages.ubuntu.com/manpages/focal/man3/gssapi.3.html*

## Optional - Confirm `gss` Setup
Again, using `gss` is optional but if installed as outlined above using `apt`, then `Ubuntu 20.04` automatically places the file in the desired location.  We can confirm by listing with `ls`.

    ls /etc/gss/mech.d/mech.ntlmssp.conf

*Note: You can optionally `cat` the file to learn more about the internals but this is not required.*

## Install `powershell`

    sudo apt install powershell -y


## DSC Linux Requirements
To learn about the software requirements for `dsc for Linux` consult the latest `README` and also the `releases` page for more specifics.

    #readme
    https://github.com/microsoft/PowerShell-DSC-for-Linux/blob/master/README.md

    #releases
    https://github.com/Microsoft/PowerShell-DSC-for-Linux/releases


The following snippet shows the requirements for `DSC for Linux` version `1.2.2`.


**Required package**	| **Description**			| **Minimum version**
-----------------------	| -------------------------------------	| -------------------
`glibc`			| GNU C Library				| 2.4 - 31.30
`python`		| Python (2 or 3)				| 2.4 - 3.4
`omi`			| Open Management Infrastructure	| 1.0.8-4
`openssl`		| OpenSSL Libraries			| 0.9.8e or 1.0
`python-ctypes`		| Python CTypes library (if using python2)			| Must match Python2 version
`libcurl`		| cURL http client library		| 7.15.1
`unzip`         | Any unzip version is okay (required for dsc resources)

## Working with `python`
We will need to have `python` functioning on the Linux guest in order for `DSC` to have proper control. For `python`, the new standard across industries is `python3` though you could use older versions if needed.

    sudo apt install python3

*Note: To see an example of updating from `python2` to `python3`, see the article https://lornajane.net/posts/2020/the-python-is-python2-package-on-ubuntu-focal-fossa*

## Install Additional Linux Dependencies
Here we use `apt` to install more components, but we will do it using `powershell`.

    #launch powershell
    pwsh

    #Option A - your system is python2
    $list = @('glibc-source','python-is-python2','omi','openssl','python-ctypes','libcurl4','unzip')

    #Option B - your system is python3
    $list = @('glibc-source','python3','omi','openssl','libcurl4','unzip')

    #Check install status
    $list | % {sudo apt list $_ }

    #Install all
    foreach($package in $list){sudo apt install $package -y}

## Determine latest version of DSC
Optionally, navigate to the following page to see available versions of DSC available for download.

    https://github.com/Microsoft/PowerShell-DSC-for-Linux/releases/#

## Install DSC Linux Binaries
Here we install dsc for Linux version `1.2.2-0`, which is the latest at the time of this writing.

    #optional - change directory
    cd ~/Downloads

    #get the bits
    wget https://github.com/Microsoft/PowerShell-DSC-for-Linux/releases/download/v1.2.2-0/dsc-1.2.2-0.ssl_110.x64.deb

    #install dsc for Linux
    sudo dpkg -i ./dsc-1.2.2-0.ssl_110.x64.deb

## Optional - Install the `nx` Module (for authoring in `DSC`)
The `nx` module can be installed on any `Windows` or `Linux` device and allows you to "author" configurations for DSC.

    #launch powershell
    pwsh

    #install nx module
    Install-Module -Name nx

    #List module
    Get-Module -ListAvailable -Name nx | Select-Object Name

*Note: This module is used for resources so you will not see cmdlets that you can use like normal. Instead this will be used inside a dsc configuration.*


## OMI - Client vs Server
To manage a Linux node with `dsc`, it must have the omi "server" component running.  Note that there is also a "client" (`omicli`) included with the `omi` package (which we use from time to time), but the important bit is configuring the omi "server" on each Linux node.

## Optional - Configure OMI "Client"
The defaults for `omicli.conf` are fine, though you can review them.

    ## omi client
    cat /etc/opt/omi/conf/omicli.conf

## Required - Configure OMI "Server"
Edit the `omiserver.conf` to set the network ports as desired.

    ## omi server
    sudo nano /etc/opt/omi/conf/omiserver.conf

## Or, Edit `omiserver.conf` with `powershell`
Optionally, we can edit the `omiserver.conf` using `powershell` instead of `nano`.  By default the ports will be set to `0`, so here we set them to `5985` and `5986`.

    #launch powershell
    pwsh

    #get current config
    $info = Get-Content /etc/opt/omi/conf/omiserver.conf

    #variable to hold updated config 
    $updatedInfo = foreach($line in $info){
        $line -replace 'httpport=0','httpport=5985' -replace 'httpsport=0','httpsport=5986'
    }

    #write updated config temporarily to /home
    $updatedInfo | Out-File -Encoding utf8 -Path ~/updated-omi-config.conf

    #exit powershell
    exit

    #use sudo to replace existing config
    sudo cp ~/updated-omi-config.conf /etc/opt/omi/conf/omiserver.conf

    #optional - list config file to see date stamp
    sudo ls -lh /etc/opt/omi/conf/omiserver.conf

    #restart omi server
    sudo systemctl restart omid.service

## WinRM Client configuration, Windows
Now, back to your Windows client/laptop you are working from.
Before we can access anything via WinRM, we should run `winrm quickconfig`, if needed.

    #on your windows machine
    winrm quickconfig

## List WinRM TrustedHosts, Windows
    
    #on your Windows machine
    $trusted = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    $trusted

## Set WinRM TrustedHosts, Windows
When you perform a set command, it overwrites the previous settings, if any.
If you had 3 entries, and then you add 1, you will only have 1 entry.
Since it is a full overwrite, we add the entire array as one value.

    #on your Windows machine
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "*.lab.local,linux01,linux02"

> Note: Adjust names to reflect your dsc lab environment

## Using IP Address with WinRM, Windows
There is no requirement to use IP Address, but you can if desired.

We can allow a specific IP Address or an entire range using a wildcard such as `10.*`.

    #on your Windows machine
    Set-Item WSMan:\localhost\Client\TrustedHosts -Value "10.*"

## Optional - Create DNS A Record
For your linux nodes, you may want to add a static DNS entry in the lab.local domain (not shown).

    mstsc /v:dc01

## Optional - Join Domain
Not required, but If you will join a Linux node to a Windows domain you might also consider creating the computer object manually in Active Directory Users and Computers (ADUC) while on the domain controller.

To learn more about joining `Ubunutu` to a domain, see the official guide at:

    https://ubuntu.com/server/docs/service-sssd

*Tip: On your Linux node, be sure to set the hostname as FQDN (i.e. linux01.lab.local) for best results before joining the domain.*

## Handle your client dns
If needed, confirm you are pointing to the lab domain controllers for dns

    ncpa.cpl

## Optional - Ping or `Test-Connection`
Confirm you can ping the remote linux node.

    C:\>ping linux01

    Pinging linux01.lab.local [10.205.1.157] with 32 bytes of data:
    Reply from 10.205.1.157: bytes=32 time<1ms TTL=64
    Reply from 10.205.1.157: bytes=32 time<1ms TTL=64
    Reply from 10.205.1.157: bytes=32 time<1ms TTL=64
    Reply from 10.205.1.157: bytes=32 time<1ms TTL=64


## More Ubuntu `ufw` Firewall
Earlier, we setup the `ufw` firewall, and here we will add a couple more commands to run.

    #allow http
    sudo ufw allow from 10.0.0.0/8 to any port 5985

    #allow https
    sudo ufw allow from 10.0.0.0/8 to any port 5986

    #reload
    sudo ufw reload

    #show
    sudo ufw status numbered

    #or, show verbose (includes ports)
    sudo ufw status verbose

## Example Output
The following shows our current `ufw` firewall rules.

    localadmin@linux01:~$ sudo ufw status numbered
    Status: active

        To                         Action      From
        --                         ------      ----
    [ 1] OpenSSH                    ALLOW IN    10.0.0.0/8
    [ 2] 5985                       ALLOW IN    10.0.0.0/8
    [ 3] 5986                       ALLOW IN    10.0.0.0/8

## Test port connectivity with `telnet`
You can use a proper tool such as `nmap` if desired, but the `telnet-client` (Windows Feature) works fine for testing ports on a target machine.

    telnet 10.205.1.157 5986

> Tip: To exit a telnet session on windows type `]`, then type `q`, then press `<enter>`.

## Optional - Set local WinRM client to `AllowUnencrypted`
This is not secure, but we can optionally set our client to allow unencrypted traffic by setting `AllowUnencrypted` to a value of `$true`. This may be needed for testing `http` access to the remote node.

    Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $true

## Get WinRM AllowUnencrypted

    Get-Item -Path WSMan:\localhost\Client\AllowUnencrypted

> Note: Remember to set this back when done testing. The scope of this change is limited to your client, but it is global for all WinRM connections.

## Test CIM Connectivity from Windows to Linux
This step uses PowerShell on your Windows client.
We use `Test-WSMan` to vet initial connectivity problems.

    ## Step 1. Launch Powershell from your client
    ## Locate the PowerShell icon and right-click run as Administrator (UAC)

    ## Step 2. Paste into powershell, you will be prompted for guest login.
    $GuestCredential = Get-Credential
    Test-WSMan -ComputerName "linux01.lab.local" -Credential $GuestCredential -Authentication Basic

## Example Output

    soap                             : http://www.w3.org/2003/05/soap-envelope
    wsmid                            : http://schemas.dmtf.org/wbem/wsman/identity/1/wsmanidentity.xsd
    lang                             :
    ProtocolVersion                  : http://schemas.dmtf.org/wbem/wsman/1/wsman.xsd
    ProductVendor                    : Open Management Infrastructure
    ProductVersion                   : 1.6.8-1
    SecurityProfiles                 : SecurityProfiles
    Capability_FaultIncludesCIMError : Capability_FaultIncludesCIMError

## Create CIM session
Here, we create a variable for a new CIM session called `$cim`.

    #get credential again if needed
    $GuestCredential = Get-Credential

    #create cim session
    $cim = New-CimSession -ComputerName "linux01.lab.local" -Credential $creds -Authentication Basic

## Show cim session
Show the contents of the `$cim` variable.

    $cim

## Example Output

    PS C:\> $cim
    Id           : 1
    Name         : CimSession1
    InstanceId   : e1dd372c-cfcb-48a5-b0dc-d17bc0b9b759
    ComputerName : linux01.lab.local
    Protocol     : WSMAN


> Note: Observe that you cannot connect after running the next step. You might practice turning the `AllowUnencrypted` on and off.

## Set `AllowUnencrypted` Back to `$false`
Now that testing is done, we can consider setting `AllowUnencrypted` back to `$false` (the default).

    Set-Item -Path WSMan:\localhost\Client\AllowUnencrypted -Value $false

## Final Steps - Prepare for `dsc`
Until now, we have been practicing with our own account. To use `dsc for Linux`, we will need the actual `root` account for the target node to work on.

## Preparing `root` on Ubuntu for `dsc`
Perform the following to set the password for `root` so that login can be used with `dsc`.  Be sure to remember the password you create.

    #enter the sudo shell
    sudo -e

    #change root password
    passwd root

    #exit sudo shell
    exit

## Remotely Apply DSC Configuration
Here we use a Windows jump server or authoring machine to remotely apply a `dsc` configuration on a Linux node.

*Important: `DSC` requires `root` login, so perform the section above if you missed it.*

    #root login required
    $GuestCredential = Get-Credential root

    #check credential is root
    If($GuestCredential.UserName -notmatch '^root'){throw "DSC Requires root!"}

    #Name of linux guest
    $linuxVM = 'linux01.lab.local'

    #cim options
    $Opt = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck -SkipRevocationCheck

    #create cim session
    $Session = New-CimSession -Credential $GuestCredential -ComputerName $linuxVM -Port 5986 -Authentication basic -SessionOption $Opt

    #optional - get dsc configuration
    Get-DscLocalConfigurationManager -CimSession $Session

    #set dsc configuration (this sets the LCM on the remote Linux node)
    Set-DscLocalConfigurationManager -CimSession $Session –Path ./SomeDscConfig

## Running Other `Dsc` Commands
On the Linux node, you can use `powershell` (if desired) or use the included `python` scripts.

    #dsc python scripts
    ls -lh /opt/microsoft/dsc/Scripts/

## Optional - DSC Pull Configuration for Linux Node
If using a Pull server, you can customize security options for your local Linux node using the `dsc.conf` file.

    /etc/opt/omi/conf/dsc/dsc.conf

*Note: Your path may vary, so `sudo find / -name dsc.conf` if needed.*

## Review `dsc` Logs
Show the last few entries in the dsc log.

    #from the linux node
    tail -n 20 /var/opt/omi/log/dscdetailed.log

## Summary
In this write-up we prepared a remote Linux node running `Ubuntu 20.04` and got it ready for `DSC`. We reviewed some secure and non-secure techniques to interact with the remote Linux node via WinRM (with `http` and `https`). Now you can configure the LCM or start adding some `DSC` resources (not shown).

____

#############################
## MORE EXAMPLES AND OUTPUTS
#############################

## Generic `omi` example with "plain text" (Not recommended)
Some techniques are to be avoided, as a best practice. In general, we should avoid typing passwords in plain text.

    winrm enumerate http://schemas.microsoft.com/wbem/wscim/1/cim-schema/2/OMI_Identify?__cimnamespace=root/omi `
    -r:http://linux01.lab.local:5985 `
    -auth:Basic `
    -u:mike `
    -p:"P@ssword01" `
    -skipcncheck `
    -skipcacheck `
    -encoding:utf-8 `
    -unencrypted

*Tip: Avoid any techniques (like the above) that use plain text*.

## Using `PSCredential` (more secure)
By using `Get-Credential`, we will be prompted to enter the information. We could also do `Get-Credential root`, so the user name is already filled in, if desired.

    $node = 'linux01.lab.local'
    $GuestCredential = Get-Credential
    $Opt = New-CimSessionOption -UseSsl -SkipCACheck -SkipCNCheck -SkipRevocationCheck

    $Session = New-CimSession `
    -Credential $GuestCredential `
    -ComputerName $node `
    -Port 5986 `
    -Authentication basic `
    -SessionOption $Opt

*Tip: Remember, `dsc` needs `root` on the target in order to control it in any way.*

## Example `dsc.conf` Location

    mike@lab.local@linux01:~$ sudo ls -lh /etc/opt/omi/conf/dsc/dsc.conf
    -rwxr-xr-x 1 root root 84 Dec  7 02:50 /etc/opt/omi/conf/dsc/dsc.conf

## Example `dsc.conf` Contents

    mike@lab.local@linux01:~$ cat /etc/opt/omi/conf/dsc/dsc.conf
    NoSSLv3=false
    DoNotCheckCertificate=false
    #sslCipherSuite=
    #CURL_CA_BUNDLE=
    #PROXY=

## Show `curl` Info on `Ubuntu 20.04`

    mike@lab.local@linux01:~$ curl --version |head -n 1
    curl 7.68.0 (x86_64-pc-linux-gnu) libcurl/7.68.0 OpenSSL/1.1.1f zlib/1.2.11 brotli/1.0.7 libidn2/2.2.0 libpsl/0.21.0 (+libidn2/2.2.0) libssh/0.9.3/openssl/zlib nghttp2/1.40.0 librtmp/2.3

## Additional Modules
Besides the `nx` module itself, there are more linux resources for `dsc` being added over time.  You can check with:

    Find-Module -Name nx*

## Example Output

    PS C:\> Find-Module -Name  nx*

    Version    Name                      Repository           Description
    -------    ----                      ----------           -----------
    1.0        nx                        PSGallery            Module with DSC Resources for Linux
    1.1        nxNetworking              PSGallery            Module with DSC Networking Resources for Linux
    1.1        nxComputerManagement      PSGallery            Module with DSC Computer Management Resources for Linux
    0.2.0      nxtools                   PSGallery            Collection of Posix tools wrappers.

## omi certificates
By installing `omi`, a certificate is generated automcatically for you.  By default, DSC will use that cert without any action on your part.  However, feel free to review/modify `omiserver.conf` file, which tells `omi` which certificate to use.

    #show omi server configuration
    cat /etc/opt/omi/conf/omiserver.conf

## example cert locations

    pemfile=/etc/opt/omi/ssl/omi.pem
    keyfile=/etc/opt/omi/ssl/omikey.pem



## Next
In the next Demo, we review some additional outputs from an `Ubuntu 20.04` guest running the setup described thus far.

    #find this next and final "Demo 19" in the left pane
    "C:\DSC_LABS\docs\Demo 19 - Example Outputs from Ubuntu 20.04 Guest.md"


