## This is a configuration to be pushed from an author server (i.e. your jump box), in order to deploy a new dsc pull server
Configuration NewPullServer {
    param (
        
        [string[]]$NodeName,
        [string]$MachineName  #if different than nodename, we rename NodeName to MachineName using ComputerManagementDsc.
    )
    
    Import-DscResource -Module PSDesiredStateConfiguration,xPSDesiredStateConfiguration,xTimeZone,ComputerManagementDsc,NetworkingDsc

    Node $AllNodes.Where{$_.Role -eq "HTTPSPull"}.Nodename {
        
        LocalConfigurationManager
        {
            ActionAfterReboot  = 'ContinueConfiguration'
            ConfigurationMode  = 'ApplyAndAutoCorrect'
            CertificateID      = $Node.Thumbprint     #Thumbprint for dscpull01, such as a bastion cert for initial build.       
            RebootNodeIfNeeded = $true
        }
        
        xTimeZone SystemTimeZone {
            TimeZone = 'Central Standard Time'
            IsSingleInstance = 'Yes'

        }

        IPAddress NewIPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = $Node.Ethernet
            #SubnetMask     = 16
            AddressFamily  = "IPV4"
        }

        DefaultGatewayAddress NewDefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = $Node.Ethernet
            Address = $Node.DefaultGateway
            DependsOn = '[IPAddress]NewIpAddress'

        }
        
        DNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = $Node.Ethernet
            AddressFamily  = 'IPV4'
        }
        
        Computer JoinStatus
        {
                Name       = $Node.MachineName
                DomainName = $Node.Domain
                Credential = $Node.Credential
                Server     = 'dc03.lab.local' #domain controller for join
                DependsOn  = '[DNSServerAddress]DnsServerAddress' #will make a reasonable effort to join domain, but will move on with dsc install, so be sure your domain join technique works, or do the join in a dedicated configuration first.
        }

        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"
            DependsOn = '[Computer]JoinStatus'
        }

        WindowsFeature IISConsole {
            Ensure = "Present"
            Name   = "Web-Mgmt-Console"
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                  = "Present"
            UseSecurityBestPractices = $true
            EndpointName            = "PSDSCPullServer"
            Port                    = 8080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
            CertificateThumbPrint   = $Node.CertificateThumbPrint #Thumbprint of PSDSCServerCert created in IIS.
            ModulePath              = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
            ConfigurationPath       = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"
            State                   = "Started"
            RegistrationKeyPath     = "$env:PROGRAMFILES\WindowsPowerShell\DscService"
            DependsOn               = "[WindowsFeature]DSCServiceFeature"
        }

        xDscWebService PSDSCComplianceServer
        {
            Ensure                  = "Present"
            UseSecurityBestPractices = $true
            EndpointName            = "PSDSCComplianceServer"
            Port                    = 9080
            PhysicalPath            = "$env:SystemDrive\inetpub\wwwroot\PSDSCComplianceServer"
            CertificateThumbPrint   = $Node.ComplianceCert
            State                   = "Started"
            DependsOn               = ("[WindowsFeature]DSCServiceFeature","[xDSCWebService]PSDSCPullServer")
        }
    }
}

#Note: Be sure to highlight and run the above to bring into memory

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = 'dscpull01' #This should only be IP address if needed to reach.
            MachineName = 'dscpull01' #The node will be renamed if needed; MachineName wins for final config over NodeName
            Role = "HTTPSPull"
            Domain = 'lab.local'
            PsDscAllowPlainTextPassword = $false  #the default is $false so this is not required.
            PSDscAllowDomainUser = $true
            IPAddress = '10.200.0.76'
            DefaultGateway = "10.200.0.1"
            DNSIPAddress = '10.200.0.73','8.8.8.8'
            Ethernet = "Ethernet"
            CertificateThumbPrint   = '515311F40CF872161DF6ECDC22AAAE3B2B941933'  #Thumbprint of PSDSCPullServerCert created in IIS.
            Thumbprint              = '535D2ADE1E0881E48060C5B830C5F2E87BF958FC'  #Any thumbprint on the target node dscpull01 (i.e. bastion cert for initial build. Can also be from lab.local GPO-provided cert if domain joined).
            CertificateFile         = 'C:\Certs\dscpull01.cer'  #path on authoring server/jump box to saved certificate for dscpull01 (i.e. bastion cert for initial build).
            ComplianceCert          = 'D9C025CD6C433DC81E5513C52408C619D36B01C1'  #compliance server cert created on cert01 server for dsc pull server compliance server.
            Credential = (Get-Credential -UserName 'lab\administrator' -message 'Enter admin pwd for lab domain') # Used to join remote node to lab.local if needed.
        }
    )
}


## Session setup
$error.clear();clear
$guest = 'dscpull01'  #IP Address or name of guest node to manage.
$creds = Get-Credential "$guest\Administrator"
$session = New-PSSession -ComputerName $guest -Credential $creds

## Confirm session is active
$session

## Optional - show both certs
Invoke-Command -Session $session -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\my | ?{$_.FriendlyName -eq 'PSDSCPullServerCert' `
    -or $_.FriendlyName -eq 'PSDSCComplianceServerCert'} | `
    Select-Object Thumbprint,Subject,FriendlyName,EnhancedKeyUsageList
}

## Get the pull server iis cert

$PullCert = Invoke-Command -Session $session -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\my | Where-Object { $_.FriendlyName -eq "PSDSCPullServerCert" }
}

## Show pull cert
Write-Host "//pull cert"
$PullCert

## Get the compliance server iis cert
## This is a certificate we created earlier in our demos.
## Using a cert (as we are) is preferred to using 'AllowUnencryptedTraffic'. 
$ComplianceCert = Invoke-Command -Session $session -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\my | Where-Object { $_.FriendlyName -eq "PSDSCComplianceServerCert" }
}

## Show compliance cert
Write-Host "//compliance cert"
$ComplianceCert

## create config and write it to local authoring machine
NewPullServer -ConfigurationData $ConfigData -OutputPath c:\dsc\NewPullServer

## create new cim session for remote node (adjust login if not domain-joined yet)
$cim = New-CimSession -ComputerName 'dscpull01' -Credential (Get-Credential lab\administrator)

## show cim session
$cim

## set the lcm on remote node
Set-DscLocalConfigurationManager -Path c:\dsc\NewPullServer -CimSession $cim -Verbose -Force

## start dsc config on remote node
Start-DscConfiguration -Path c:\dsc\NewPullServer -CimSession $cim -Wait -Force -Verbose

## Optional - get dsc config on remote node (lots of detail)
Get-DscConfiguration -CimSession $cim -Verbose

## Optional - get dsc config on remote node (simple detail)
Get-DscLocalConfigurationManager -CimSession $cim -Verbose

## Show configuration download managers, expect none until using a pull server lcm.
Get-DscLocalConfigurationManager -CimSession $cim | Select-Object -ExpandProperty ConfigurationDownloadManagers

##Optional - Review health of dsc web page (xml format, viewable in ie or similar)
Start-Process -FilePath msedge.exe https://dscpull01.lab.local:8080/PSDSCPullServer.svc