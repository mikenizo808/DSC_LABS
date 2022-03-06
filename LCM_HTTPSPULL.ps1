# An example LCM that uses an https pull server to control the node.
# This can be performed from your client or authoring machine.

[DSCLocalConfigurationManager()]
Configuration LCM_HTTPSPULL
{
    param
        (
            [Parameter(Mandatory=$true)]
            [string[]]$ComputerName,

            [Parameter(Mandatory=$true)]
            [string]$Guid,

            [Parameter(Mandatory=$true)]
            [string]$Thumbprint

        )
	Node $ComputerName {

		Settings {

			AllowModuleOverwrite = $True
		    ConfigurationMode = 'ApplyAndAutoCorrect'
			RefreshMode = 'Pull'
			ConfigurationID = $guid
            CertificateID = $thumbprint
            RebootNodeIfNeeded = $true
            }

            ConfigurationRepositoryWeb DSCHTTPS {
                ServerURL = 'https://dscpull01.lab.local:8080/PSDSCPullServer.svc'
                CertificateID = $pullThumbrint
                AllowUnsecureConnection = $False
            }
	}
}

## Enter the node to manage, for example, s2 (required). Should be in the domain already (i.e. lab.local)
$strComputerName = Read-Host -Prompt "Enter ComputerName"

## Import helper function
Import-Module C:\DSC_LABS\Helper-Functions\Export-MachineCert.ps1 -Verbose

## Use the custom function, Export-MachineCert to get the desired cert info from remote node
$Cert = Export-MachineCert -computername $strComputerName -Path C:\Certs

## Create a cim session to remote node
$cim = New-CimSession -ComputerName $strComputerName

## Create guid
$guid=[guid]::NewGuid()

## Get the pull server certificate
$pullServer = 'dscpull01'
$pullSession = New-PSSession -ComputerName $pullServer -Credential (Get-Credential LAB\Administrator)
$pullCert = Invoke-Command -Session $pullSession -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\my | Where-Object {
      ($_.FriendlyName -eq 'PSDSCPullServerCert') `
      -and $_.PrivateKey.KeyExchangeAlgorithm
    }
}

## Optional - Show the pull server certificate
$pullCert

## get pull server certificate thumbprint
$pullThumbrint = $pullCert.Thumbprint

## Generate the configuration (mof output)
LCM_HTTPSPULL -ComputerName $strComputerName -Guid $guid -Thumbprint $Cert.Thumbprint -OutputPath c:\dsc\HTTPS_$strComputerName

## Optional - Get the current lcm (i.e. if it existed already)
Get-DscLocalConfigurationManager -CimSession $cim

## Set the lcm on remote node
Set-DscLocalConfigurationManager -CimSession $cim -Path C:\dsc\HTTPS_$strComputerName -Verbose
