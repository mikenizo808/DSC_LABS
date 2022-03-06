Configuration NewCertServer {
        
  Param (

    #String. IP Address or name.
    [string]$NodeName,

    #String. This becomes the new node name if different from NodeName.
    [string]$MachineName,

    #String. One or more Windows features to install. The default installs the requirements for creating and managing a CA that can support DSC.
    [String[]]$WindowsFeature = @('RSAT-ADCS','Web-Mgmt-Console','ADCS-Web-Enrollment','RSAT-ADDS'),
    
    #Boolean. Set to true if your CA will be in a workgroup only. This is new / not tested.
    [bool]$OfflineCA,

    #Switch. Optionally, activate this switch to remove the target node from domain; Only valid when using the OfflineCA parameter.
    [switch]$Force

  )
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xAdcsDeployment,ComputerManagementDsc,NetworkingDsc
    
    Node $AllNodes.Where{$_.Role -eq "PKI"}.Nodename {

        LocalConfigurationManager            
        {            
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint            
            RebootNodeIfNeeded = $true            
        }

        IPAddress IPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = $Node.Ethernet
            #SubnetMask    = 16
            AddressFamily  = "IPV4"
 
        }

        DefaultGatewayAddress DefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = $Node.Ethernet
            Address = $Node.DefaultGateway
            DependsOn = '[IPAddress]IpAddress'
        }

        DNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = $Node.Ethernet
            AddressFamily  = 'IPV4'
        }

        If($OfflineCA){
            ## Ensure workgroup, remove from domain if needed
            If($Force){
                Computer JoinStatus
                    {
                        Name       = $Node.NodeName
                        DomainName = 'WORKGROUP'
                        Credential = $Node.Credential
                    }
            }
            ## Ensure workgroup, but do not remove from domain
            Else{
                Computer JoinStatus
                    {
                        Name       = $Node.NodeName
                        DomainName = 'WORKGROUP'
                    }
            }
        }
        Else{
            ## Ensure domain joined
            Computer JoinStatus
            {
                Name       = $Node.MachineName  #will rename computer if needed
                DomainName = $Node.Domain
                Credential = $Node.Credential
                Server     = 'dc03.lab.local' #optional domain controller to use for join
            }
        }

        WindowsFeature ADCS-Cert-Authority {
               Ensure = 'Present'
               Name = 'ADCS-Cert-Authority'
               DependsOn = '[Computer]JoinStatus'
        }
                
        Foreach ($Feature In $WindowsFeature){
            Write-Verbose -message [$Feature]
            WindowsFeature $Feature {
                Name = $Feature
                Ensure = 'Present'
                IncludeAllSubFeature = $true                
                DependsOn = '[WindowsFeature]ADCS-Cert-Authority'
            }
        }          
        
        xADCSCertificationAuthority ADCS {
            Ensure = 'Present'
            Credential = $Node.Credential
            CAType = 'EnterpriseRootCA'
            DependsOn = '[WindowsFeature]ADCS-Cert-Authority'              
        }
         
        xADCSWebEnrollment CertSrv {
            Ensure = 'Present'
            IsSingleInstance = 'Yes'
            Credential = $Node.Credential
            DependsOn = '[WindowsFeature]ADCS-Web-Enrollment','[xADCSCertificationAuthority]ADCS'
        }
                             
    }  
}

#Note: Be sure to highlight and run the above.

## Configuration data for our remote node, the cert01 server in this case.
$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = '10.200.0.205'
            MachineName = 'cert01'
            Domain = 'lab.local'
            Role = "PKI"
            Thumbprint = '88DD09B4974024A85FC2AF7E6A27431D8A375FE1'
            CertificateFile = 'C:\Certs\cert01.cer'
            IPAddress = '10.200.0.75'
            DefaultGateway = '10.200.0.1'
            DNSIPAddress = '10.200.0.73','10.200.0.74','8.8.8.8'
            Ethernet = 'Ethernet'
            PSDscAllowDomainUser = $true
            Credential = (Get-Credential -UserName 'LAB\Administrator' -message 'Enter login for lab.local domain')
        }
    )
}

## Handle using IP Address.
$ComputerName = $ConfigData.AllNodes.NodeName

## cim session
$cim = New-CimSession -ComputerName $ComputerName -Credential (Get-Credential $ComputerName\Administrator)

## show cim session
$cim

## drink frm the well, if needed
$Error.Clear();Clear-Host

## create dsc configuration (creates mof and meta)
NewCertServer -ConfigurationData $ConfigData -OutputPath c:\dsc\$ComputerName

## set lcm
Set-DscLocalConfigurationManager -Path c:\dsc\$ComputerName -Verbose -Force -CimSession $cim

## start dsc configuration on remote node.
Start-DscConfiguration -wait -force -Verbose -Path c:\dsc\$ComputerName -CimSession $cim

## optional - update credential variable to use lab.local and also machine name instead of "old" IP
$ComputerName = $ConfigData.AllNodes.MachineName
$cim = New-CimSession -ComputerName $ComputerName -Credential (Get-Credential LAB\Administrator)

## show cim session
$cim

## Optionally, show config info.
## Note: This responds even if busy. See the "LCMState" property
Get-DscLocalConfigurationManager -CimSession $cim

## Optional - show status (may return error if still busy)
Get-DscConfigurationStatus -CimSession $cim

## clear errors
$Error.Clear(); Clear-Host

## Next, we return to the Demo to discuss creating a cert.
## Close this tab now, or use the link below to return to the demo.
psedit "C:\DSC_LABS\docs\Demo 14 - How to create a certificate authority (CA) with dsc.ps1"