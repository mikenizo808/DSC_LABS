## A configuration for dc01 and dc02 in lab.local
## Creates a highly available domain
Configuration HADomain {

    param (
        [string]$NodeName,
        [Parameter(Mandatory)]             
        [pscredential]$SafeModeAdministratorPassword,             
        [Parameter(Mandatory)]            
        [pscredential]$DomainAdministratorCredential        
        )
    
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xActiveDirectory
    Import-DscResource -ModuleName xNetworking
    
    Node $AllNodes.Where{$_.Role -eq "FirstDomainController"}.Nodename  {
        
        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint            
            RebootNodeIfNeeded = $true            
        }        

        xDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = $Node.Ethernet
            AddressFamily  = 'IPV4'
        }

        WindowsFeature ADDSTools            
        {             
            Ensure = "Present"             
            Name = "RSAT-ADDS"             
        }

        WindowsFeature ADDSInstall             
        {             
            Ensure = "Present"             
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $true  
        }        

        File ADFiles            
        {            
            DestinationPath = 'C:\NTDS'            
            Type = 'Directory'            
            Ensure = 'Present'            
        }            
        
        xADDomain FirstDS            
        {             
            DomainName = $Node.DomainName             
            DomainAdministratorCredential = $DomainAdministratorCredential             
            SafemodeAdministratorPassword = $SafeModeAdministratorPassword            
            DatabasePath = 'C:\NTDS'            
            LogPath = 'C:\NTDS'            
            DependsOn = "[WindowsFeature]ADDSInstall","[File]ADFiles"            
        }        
                                                
    }

    Node $AllNodes.Where{$_.Role -eq "SecondDomainController"}.Nodename
    {

        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint            
            RebootNodeIfNeeded = $true            
        }

        xDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = $Node.Ethernet
            AddressFamily  = 'IPV4'
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            IncludeAllSubFeature = $false
            DependsOn = "[xDNSServerAddress]DnsServerAddress"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $DomainAdministratorCredential
            RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }
        
        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $DomainAdministratorCredential
            SafemodeAdministratorPassword = $SafeModeAdministratorPassword
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }

        xADRecycleBin RecycleBin {
            EnterpriseAdministratorCredential = $DomainAdministratorCredential
            ForestFQDN = $Node.DomainName
            DependsOn = "[xADDomainController]SecondDC"
        }
    }    
}

## Create sessions
$session1 = New-PSSession -ComputerName '10.200.0.73' -Credential (Get-Credential LAB\Administrator)
$session2 = New-PSSession -ComputerName '10.200.0.204' -Credential (Get-Credential 10.200.0.204\Administrator)

## Get any valid local cert. You can get more specific by using FriendlyName or similar (not shown here).
$cert1 = Invoke-Command -Session $session1 -ScriptBlock {
    [string]$strName = cat env:ComputerName
    Get-ChildItem Cert:\LocalMachine\my | Where-Object { $_.PrivateKey.KeyExchangeAlgorithm }
}
$cert2 = Invoke-Command -Session $session2 -ScriptBlock {
    [string]$strName = cat env:ComputerName
    Get-ChildItem Cert:\LocalMachine\my | Where-Object { $_.PrivateKey.KeyExchangeAlgorithm }
}

## Extract thumbprints
$thumbprint1 = $cert1.thumbprint
$thumbprint2 = $cert2.thumbprint

##Show thumbprints (add to config data for nodes below)
$thumbprint1
$thumbprint2

## Note: When a machine gets promoted to a domain controller,
## the local machine password (RID500 a.k.a. Administrator)
## will become the domain password.
## Optionally, set the password first
psedit "C:\DSC_LABS\SetLocalAdminPw.ps1"

# Note: We expect Certificatefile (i.e. c:\certs\10.205.1.151.cer)
# for each node to already be saved locally on client / authoring machine.

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = '10.200.0.73'         #ip to reach this node at initial config time
            Role = "FirstDomainController"
            DomainName = "lab.local"
            DNSIPAddress  = '8.8.8.8'
            Ethernet   = 'Ethernet'                       
            Thumbprint = '99B549203C3FB932578B6F1777BFDF65EDC5A908'
            Certificatefile = 'c:\certs\dc03.cer'
            RetryCount = 20
            RetryIntervalSec = 30            
            PSDscAllowDomainUser = $true     
        }

        @{             
            Nodename = '10.200.0.204'        #ip to reach this node at initial config time          
            Role = "SecondDomainController"
            DomainName = "lab.local"
            DNSIPAddress  = @('10.200.0.73','8.8.8.8')
            Ethernet   = 'Ethernet'                       
            Thumbprint = '763D7BEC4934F10770C28E8E267DC7A329F2A1D6'
            Certificatefile = 'c:\certs\dc04.cer'
            RetryCount = 20
            RetryIntervalSec = 30            
            PSDscAllowDomainUser = $true     
        }               
    )             
}

# Generate Configuration
HADomain -ConfigurationData $ConfigData `
-SafeModeAdministratorPassword (Get-Credential -UserName '(Password Only)' `
-Message "New Domain Safe Mode Administrator Password") `
-DomainAdministratorCredential (Get-Credential -UserName lab\administrator `
-Message "New Domain Admin Credential") -OutputPath c:\dsc\HADomain

#Note: The above outputs result in some output files like "IP Address.mof" and "IP Address.meta.mof".

## Create cim sessions
$cim1 = New-CimSession -ComputerName 10.200.0.73 -Credential (Get-Credential LAB\Administrator)
$cim2 = New-CimSession -ComputerName 10.200.0.204 -Credential (Get-Credential 10.200.0.204\Administrator) 

## Show sessions
$cim1
$cim2

## Set LCM
Set-DscLocalConfigurationManager -CimSession $cim1, $cim2 -Path c:\dsc\HADomain -Verbose -Force

## Start DSC Configuration
Start-DscConfiguration -CimSession $cim2 -wait -force -Verbose -Path c:\dsc\HADomain

## Optional
Get-DscLocalConfigurationManager -CimSession $cim1, $cim2
Get-DscLocalConfigurationManager -CimSession $cim1, $cim2