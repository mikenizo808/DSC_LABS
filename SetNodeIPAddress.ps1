# A configuration to Set the IP Address of a remote node
Configuration SetNodeIPAddress {

    Import-DscResource -ModuleName xNetworking

    Node $AllNodes.Where{$_.Role -eq "FreshDeploy"}.Nodename {

        LocalConfigurationManager
        {
            ActionAfterReboot = 'ContinueConfiguration'
            ConfigurationMode = 'ApplyAndAutoCorrect'
            CertificateID = $Node.Thumbprint
            RebootNodeIfNeeded = $true
        }

        xIPAddress IPAddress
        {
            IPAddress      = $Node.IPAddress
            InterfaceAlias = $Node.Ethernet
            #SubnetMask     = 24
            AddressFamily  = "IPV4"
        }

        xDefaultGatewayAddress DefaultGateway
        {
            AddressFamily = 'IPv4'
            InterfaceAlias = $Node.Ethernet
            Address = $Node.DefaultGateway
            DependsOn = '[xIPAddress]IpAddress'
        }

        xDNSServerAddress DnsServerAddress
        {
            Address        = $Node.DNSIPAddress
            InterfaceAlias = $Node.Ethernet
            AddressFamily  = 'IPV4'
        }
    }
}

$ConfigData = @{             
    AllNodes = @(             
        @{             
            Nodename = '10.200.0.100'      #reachable now at
            Role = "FreshDeploy"
            IPAddress = '10.200.0.76'      #new address
            DefaultGateway = '10.200.0.1'
            DNSIPAddress = '10.200.0.73','8.8.8.8'
            Ethernet    = 'Ethernet'
            Thumbprint = '535D2ADE1E0881E48060C5B830C5F2E87BF958FC'
            Certificatefile = "C:\Certs\dscpull01.cer"
        }
    )
}

## Generate Configuration
SetNodeIPAddress -ConfigurationData $ConfigData -OutputPath c:\dsc\SetNodeIPAddress

## Create cim session
$cim = New-CimSession -ComputerName 10.200.0.100 -Credential (Get-Credential 10.200.0.100\Administrator)

## Show session
$cim

## Set LCM
Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\SetNodeIPAddress -Verbose -Force

## Get LCM state (optional)
Get-DscLocalConfigurationManager -CimSession $cim | Select-Object LCMStateDetail, LCMState, PSComputerName

## Start DSC Configuration
Start-DscConfiguration -CimSession $cim -wait -force -Verbose -Path c:\dsc\SetNodeIPAddress\

## Session cleanup
$ConfigData = $null
