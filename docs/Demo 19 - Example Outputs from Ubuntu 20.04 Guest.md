# Example Outputs From Ubuntu 20.04 Guest

## Intro
These outputs are a collection of interactions with `omi` and `dsc` simply to show some example outputs.

## `omi` Commands

    #show basic info
    /opt/omi/bin/omicli ei root/omi OMI_Identify

## Example Output

    localadmin@linux01:~$ /opt/omi/bin/omicli ei root/omi OMI_Identify
    instance of OMI_Identify
    {
        [Key] InstanceID=2FDB5542-5896-45D5-9BE9-DC04430AAABE
        SystemName=linux01
        ProductName=OMI
        ProductVendor=Microsoft
        ProductVersionMajor=1
        ProductVersionMinor=6
        ProductVersionRevision=8
        ProductVersionString=1.6.8-1
        Platform=LINUX_X86_64_GNU
        OperatingSystem=LINUX
        Architecture=X86_64
        Compiler=GNU
        ConfigPrefix=GNU
        ConfigLibDir=/opt/omi/lib
        ConfigBinDir=/opt/omi/bin
        ConfigIncludeDir=/opt/omi/include
        ConfigDataDir=/opt/omi/share
        ConfigLocalStateDir=/var/opt/omi
        ConfigSysConfDir=/etc/opt/omi/conf
        ConfigProviderDir=/etc/opt/omi/conf
        ConfigLogFile=/var/opt/omi/log/omiserver.log
        ConfigPIDFile=/var/opt/omi/run/omiserver.pid
        ConfigRegisterDir=/etc/opt/omi/conf/omiregister
        ConfigSchemaDir=/opt/omi/share/omischema
        ConfigNameSpaces={root-omi}
    }

## output from installing dsc

    PS /home/localadmin/Downloads> sudo dpkg -i ./dsc-1.2.2-0.ssl_110.x64.deb
    Selecting previously unselected package dsc.
    (Reading database ... 163565 files and directories currently installed.)
    Preparing to unpack ./dsc-1.2.2-0.ssl_110.x64.deb ...
    Using python2
    Checking for ctypes python module...
    Cleanning up existing dsc_hosts...
    chmod: cannot access '/opt/dsc': No such file or directory
    Deployment operation type : install
    Cleanning directory /opt/dsc...
    Cleaned up existing dsc_hosts...
    Unpacking dsc (1.2.2.0) ...
    Setting up dsc (1.2.2.0) ...
    Using python2
    Running python2 in set up built in python version is , python2
    /opt/microsoft/dsc/Scripts/InstallModule.py:2: DeprecationWarning: the imp module is deprecated in favour of importlib; see the module's documentation for alternative uses
    import imp
    VERBOSE from InstallModule.py: Extracting module zip file from /opt/microsoft/dsc/module_packages/nx_1.1.zip to /opt/microsoft/dsc/modules
    VERBOSE from InstallModule.py: Installing resource MSFT_nxServiceResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxServiceResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxServiceResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxGroupResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxGroupResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxGroupResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxScriptResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxScriptResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxScriptResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxPackageResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxPackageResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxPackageResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxUserResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxUserResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxUserResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxFileLineResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxFileLineResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxFileLineResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxArchiveResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxArchiveResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxArchiveResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxEnvironmentResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxEnvironmentResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxEnvironmentResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxSshAuthorizedKeysResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxSshAuthorizedKeysResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxSshAuthorizedKeysResource.reg to 0o644
    VERBOSE from InstallModule.py: Installing resource MSFT_nxFileResource
    VERBOSE from InstallModule.py: Updated permissions of file: /opt/omi/lib/libMSFT_nxFileResource.so to 0o644
    VERBOSE from InstallModule.py: Updated permissions of file: /etc/opt/omi/conf/omiregister/root-Microsoft-DesiredStateConfiguration/MSFT_nxFileResource.reg to 0o644
    Trying to stop omi with systemctl
    omi is stopped.
    Trying to start omi with systemctl
    omi is started.
    PS /home/localadmin/Downloads>


## After installing `dsc`
Now we see more `ConfigNameSpaces` besides just `omi` (we also see some dsc things).

    localadmin@linux01:~$ /opt/omi/bin/omicli ei root/omi OMI_Identify
    instance of OMI_Identify
    {
        [Key] InstanceID=2FDB5542-5896-45D5-9BE9-DC04430AAABE
        SystemName=linux01
        ProductName=OMI
        ProductVendor=Microsoft
        ProductVersionMajor=1
        ProductVersionMinor=6
        ProductVersionRevision=8
        ProductVersionString=1.6.8-1
        Platform=LINUX_X86_64_GNU
        OperatingSystem=LINUX
        Architecture=X86_64
        Compiler=GNU
        ConfigPrefix=GNU
        ConfigLibDir=/opt/omi/lib
        ConfigBinDir=/opt/omi/bin
        ConfigIncludeDir=/opt/omi/include
        ConfigDataDir=/opt/omi/share
        ConfigLocalStateDir=/var/opt/omi
        ConfigSysConfDir=/etc/opt/omi/conf
        ConfigProviderDir=/etc/opt/omi/conf
        ConfigLogFile=/var/opt/omi/log/omiserver.log
        ConfigPIDFile=/var/opt/omi/run/omiserver.pid
        ConfigRegisterDir=/etc/opt/omi/conf/omiregister
        ConfigSchemaDir=/opt/omi/share/omischema
        ConfigNameSpaces={root-Microsoft-Windows-DesiredStateConfiguration, root-Microsoft-DesiredStateConfiguration, root-omi}
    }

## About `gss` Configuration
No action required for this step, but feel free to confirm your setup by performing `cat` or `ls` to ensure that the file `mech.ntlmssp.conf` is in the `/etc/gss/mech.d` as shown below.

    cat  /etc/gss/mech.d/mech.ntlmssp.conf

## Example Output

    localadmin@linux01:~$ cat  /etc/gss/mech.d/mech.ntlmssp.conf
    # NTLMSSP mechanism plugin
    #
    # NOTE: to activate the NTLM SSP mechanism do the following
    #     * FOR krb5 < 1.12: copy the content of this file in /etc/gss/mech
    #     * FOR krb5 >= 1.12: copy this file in /etc/gss/mech.d
    #
    # Mechanism Name        Object Identifier               Shared Library Path                     Other Options
    gssntlmssp_v1           1.3.6.1.4.1.311.2.2.10          /usr/lib/x86_64-linux-gnu/gssntlmssp/gssntlmssp.so
    localadmin@linux01:~$


## omi server info
We can use `-p` to print the detail of our omi server.

    omiserver -p

## Example Output

    localadmin@linux01:~$ omiserver -p
    prefix=/opt/omi
    libdir=/opt/omi/lib
    bindir=/opt/omi/bin
    localstatedir=/var/opt/omi
    sysconfdir=/etc/opt/omi/conf
    providerdir=/opt/omi/lib
    certsdir=/etc/opt/omi/ssl
    datadir=/opt/omi/share
    rundir=/var/opt/omi/run
    logdir=/var/opt/omi/log
    schemadir=/opt/omi/share/omischema
    schemafile=/opt/omi/share/omischema/CIM_Schema.mof
    pidfile=/var/opt/omi/run/omiserver.pid
    logfile=/var/opt/omi/log/omiserver.log
    registerdir=/etc/opt/omi/conf/omiregister
    pemfile=/etc/opt/omi/ssl/omi.pem
    keyfile=/etc/opt/omi/ssl/omikey.pem
    agentprogram=/opt/omi/bin/omiagent
    serverprogram=/opt/omi/bin/omiserver
    includedir=/opt/omi/include
    configfile=/etc/opt/omi/conf/omiserver.conf
    socketfile=/var/opt/omi/run/omiserver.sock
    tmpdir=/home/serviceb/jenkins/workspace/OMI-Runner/label/RHEL_5.0_X64/omi/Unix/output_openssl_1.1.0/tmp
    destdir=/
    authdir=/var/opt/omi/omiauth
    httpsendtracefile=/var/opt/omi/log/omiserver-send.trc
    httprecvtracefile=/var/opt/omi/log/omiserver-recv.trc
    httpclientsendtracefile=/var/opt/omi/log/omiclient-send.trc
    httpclientrecvtracefile=/var/opt/omi/log/omiclient-recv.trc
    srcdir=/home/serviceb/jenkins/workspace/OMI-Runner/label/RHEL_5.0_X64/omi/Unix
    keytabfile=/etc/opt/omi/creds/omi.keytab
    clientconfigfile=/etc/opt/omi/conf/omicli.conf
    credsdir=/etc/opt/omi/creds

    localadmin@linux01:~$

## Reminder - Join Ubuntu to AD
If you have not already, do test out joining to AD as it is quite easy.

    https://ubuntu.com/server/docs/service-sssd




